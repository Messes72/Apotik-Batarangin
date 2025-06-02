package internal

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
	"time"
)

func GetTotalStokMovement(ctx context.Context, iddpeo string) (class.ManagementDashboardResponse, error) {
	con := db.GetDBCon()

	query := `SELECT

		SUM(CASE WHEN DATE(created_at) = CURRENT_DATE THEN masuk ELSE 0 END) AS daily_in,
		SUM(CASE WHEN DATE(created_at) = CURRENT_DATE THEN keluar ELSE 0 END) AS daily_out,

		SUM(CASE WHEN created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY) THEN masuk ELSE 0 END) AS weekly_in,
		SUM(CASE WHEN created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY) THEN keluar ELSE 0 END) AS weekly_out,

		SUM(CASE WHEN created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) THEN masuk ELSE 0 END) AS monthly_in,
		SUM(CASE WHEN created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) THEN keluar ELSE 0 END) AS monthly_out

		FROM detail_kartustok
		WHERE (? = '' OR id_depo = ?)

	`
	var data class.ManagementDashboardResponse
	rows := con.QueryRowContext(ctx, query, iddpeo, iddpeo)
	err := rows.Scan(&data.TotalStockMovement.DailyIn, &data.TotalStockMovement.DailyOut, &data.TotalStockMovement.WeeklyIn, &data.TotalStockMovement.WeeklyOut,
		&data.TotalStockMovement.MonthlyIn, &data.TotalStockMovement.MonthlyOut)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Println("tidak ada stok movemnet yang ditemukan ", err)
			return class.ManagementDashboardResponse{}, nil
		}
		log.Println("Error saat mengambil data stok movmenet", err)
		return class.ManagementDashboardResponse{}, err
	}
	return data, nil
}

func GetTotalPenjualan(ctx context.Context) (class.PeriodSales, error) {

	con := db.GetDBCon()
	var penj class.PeriodSales

	queryall := `SELECT COALESCE(SUM(total_harga),0) FROM transaksi `
	err := con.QueryRowContext(ctx, queryall).Scan(&penj.AllTime)
	if err != nil {
		log.Println("Error saat menghitung total penjualan", err)
		return penj, err
	}

	endtime := time.Now()

	starttime := time.Now().Truncate(24 * time.Hour)

	queryharian := `SELECT COALESCE(SUM(total_harga),0) FROM transaksi WHERE created_at BETWEEN ? AND ?`

	if err := con.QueryRowContext(ctx, queryharian, starttime, endtime).Scan(&penj.Daily); err != nil {
		log.Println("Error saat mengambil total penjualan harian", err)
		return penj, err
	}

	starttimeweekly := starttime.AddDate(0, 0, -6)
	querymingguan := `SELECT COALESCE(SUM(total_harga),0) FROM transaksi WHERE created_at BETWEEN ? AND ?`

	if err := con.QueryRowContext(ctx, querymingguan, starttimeweekly, endtime).Scan(&penj.Weekly); err != nil {
		log.Println("Error saat mengambil total penjualan mingguan", err)
		return penj, err
	}

	starttimemonthly := starttime.AddDate(0, -1, 0)
	querybulanan := `SELECT COALESCE(SUM(total_harga),0) FROM transaksi WHERE created_at BETWEEN ? AND ?`

	if err := con.QueryRowContext(ctx, querybulanan, starttimemonthly, endtime).Scan(&penj.Monthly); err != nil {
		log.Println("Error saat mengambil total penjualan bulanan", err)
		return penj, err
	}

	return penj, nil
}
func GetTopSellingObatHelper(ctx context.Context, start, end time.Time, filter bool) ([]class.TopSellingProduct, error) {
	con := db.GetDBCon()
	var (
		query string
		arg   []interface{}
	)
	if filter {
		query = `
		SELECT oj.nama_obat, SUM(COALESCE(dt.jumlah,0)) AS jumlah
		FROM detail_transaksi_penjualan_obat dt
		JOIN obat_jadi oj ON dt.id_kartustok = oj.id_obat
		WHERE dt.created_at BETWEEN ? AND ?
		GROUP BY oj.nama_obat
		ORDER BY jumlah DESC 
		LIMIT 10`

		arg = []interface{}{start, end}
	} else {
		query = `
		SELECT oj.nama_obat, SUM(COALESCE(dt.jumlah,0)) AS jumlah
		FROM detail_transaksi_penjualan_obat dt
		JOIN obat_jadi oj ON dt.id_kartustok = oj.id_obat
		GROUP BY oj.nama_obat
		ORDER BY jumlah DESC 
		LIMIT 10`

		arg = nil
	}

	rows, err := con.QueryContext(ctx, query, arg...)
	if err != nil {
		log.Println("Error saat query di helper get top selling obt", err)
		return nil, err
	}

	defer rows.Close()

	var list []class.TopSellingProduct

	for rows.Next() {

		var obj class.TopSellingProduct

		if err := rows.Scan(&obj.NamaObat, &obj.Jumlah); err != nil {
			log.Println("Error saat scan top selling obat helpoer", err)
			return nil, err
		}
		list = append(list, obj)
	}
	return list, nil

}
func GetTopSellingObat(ctx context.Context) (class.PeriodTopSelling, error) {

	var topselling class.PeriodTopSelling

	endtime := time.Now()

	starttime := time.Now().Truncate(24 * time.Hour)
	starttimeweekly := starttime.AddDate(0, 0, -6)

	starttimemonthly := starttime.AddDate(0, -1, 0)
	log.Println("time :", starttime, endtime, starttimeweekly, starttimemonthly)

	overall, err := GetTopSellingObatHelper(ctx, time.Time{}, time.Time{}, false)
	if err != nil {
		log.Println("Error fetching all-time top selling:", err)
		return topselling, err
	}
	topselling.AllTime = overall

	daily, err := GetTopSellingObatHelper(ctx, starttime, endtime, true)
	if err != nil {
		log.Println("Error fetching harian top selling:", err)
		return topselling, err
	}
	topselling.Daily = daily

	weekly, err := GetTopSellingObatHelper(ctx, starttimeweekly, endtime, true)
	if err != nil {
		log.Println("Error fetching weekly top selling:", err)
		return topselling, err
	}
	topselling.Weekly = weekly

	monthly, err := GetTopSellingObatHelper(ctx, starttimemonthly, endtime, true)
	if err != nil {
		log.Println("Error fetching monthly top selling:", err)
		return topselling, err
	}
	topselling.Monthly = monthly

	return topselling, nil

}

func GetLowStokObat(ctx context.Context, iddepo string) ([]class.LowStockItem, error) {

	con := db.GetDBCon()

	query := `SELECT oj.id_obat, oj.nama_obat, ks.id_depo, ks.stok_barang, oj.stok_minimum
	FROM obat_jadi oj 
	JOIN kartu_stok ks ON oj.id_obat = ks.id_kartustok
	WHERE ks.stok_barang < oj.stok_minimum
	AND (?= '' OR ks.id_depo = ?)`

	rows, err := con.QueryContext(ctx, query, iddepo, iddepo)
	if err != nil {
		log.Println("Error saat query stok low obat", err)
		return nil, err
	}
	defer rows.Close()

	var list []class.LowStockItem

	for rows.Next() {
		var obat class.LowStockItem

		if err := rows.Scan(&obat.IDObat, &obat.Nama, &obat.IDDepo, &obat.StokBarang, &obat.StokMinimum); err != nil {

			log.Println("Error ssaat scan di get low stok obat", err)
			return nil, err
		}
		list = append(list, obat)
	}
	return list, nil
}

func GetNearExpiredObat(ctx context.Context, iddepo string) ([]class.NearExpiryItem, error) {
	con := db.GetDBCon()

	query := `SELECT 
    nb.id_nomor_batch,
    nb.no_batch,
    nb.kadaluarsa,
    ks.id_obat,
    o.nama_obat,
    dks.sisa,
    ks.id_depo
	FROM detail_kartustok dks
	JOIN (
		SELECT id_nomor_batch, MAX(created_at) AS latest
		FROM detail_kartustok
		GROUP BY id_nomor_batch
	) latest_dks ON dks.id_nomor_batch = latest_dks.id_nomor_batch
				AND dks.created_at = latest_dks.latest
	JOIN nomor_batch nb ON dks.id_nomor_batch = nb.id_nomor_batch
	JOIN kartu_stok ks ON dks.id_kartustok = ks.id_kartustok
	JOIN obat_jadi o ON ks.id_obat = o.id_obat
	WHERE nb.kadaluarsa <= CURRENT_DATE + INTERVAL 30 DAY AND (? = '' OR dks.id_depo = ?)
	AND dks.sisa > 0 
	AND (? = '' OR ks.id_depo = ?)
	GROUP BY dks.id_nomor_batch
	ORDER BY nb.kadaluarsa ASC

	`

	rows, err := con.QueryContext(ctx, query, iddepo, iddepo, iddepo, iddepo)
	if err != nil {
		log.Println("Error saat query stok near expired", err)
		return nil, err

	}
	defer rows.Close()

	var list []class.NearExpiryItem
	for rows.Next() {
		var obat class.NearExpiryItem

		if err := rows.Scan(&obat.IDNomorBatch, &obat.NoBatch, &obat.Kadaluarsa, &obat.IDObat, &obat.Nama, &obat.StokBarang, &obat.IDDepo); err != nil {
			log.Println("Error saat scan rows near expired item", err)
			return nil, err
		}
		list = append(list, obat)
	}
	return list, nil
}

func DashboardManagement(ctx context.Context, iddepo string) (class.Response, error) {
	var res class.ManagementDashboardResponse

	stokMovement, err := GetTotalStokMovement(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data stok movement"}, err
	}
	res.TotalStockMovement = stokMovement.TotalStockMovement

	if iddepo == "20" || iddepo == "" {
		totalPenjualan, err := GetTotalPenjualan(ctx)
		if err != nil {
			return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data total penjualan"}, err
		}
		res.TotalSales = totalPenjualan

		topSelling, err := GetTopSellingObat(ctx)
		if err != nil {
			return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data top selling"}, err
		}
		res.TopSellingProducts = topSelling
	}

	lowStok, err := GetLowStokObat(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data low stok"}, err
	}
	res.LowStockItems = lowStok

	nearExp, err := GetNearExpiredObat(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data near expired"}, err
	}
	res.NearExpiryItems = nearExp

	return class.Response{
		Status:  http.StatusOK,
		Message: "Berhasil mengambil data dashboard",
		Data:    res,
	}, nil
}

func GetOpenRequestObat(ctx context.Context) ([]class.OpenRequestApotik, error) {

	con := db.GetDBCon()

	query := `SELECT
	id_distribusi , id_depo_tujuan, tanggal_permohonan, keterangan, created_at, updated_at, created_by
	FROM distribusi WHERE tanggal_pengiriman IS NULL
	`

	rows, err := con.QueryContext(ctx, query)

	if err != nil {
		log.Println("Error saat query open request obat", err)
		return nil, err
	}
	defer rows.Close()

	var list []class.OpenRequestApotik

	for rows.Next() {

		var data class.OpenRequestApotik

		var keterangan sql.NullString
		var updatedat sql.NullTime

		if err := rows.Scan(&data.IdDistribusi, &data.IdDepoTujuan, &data.TanggalPermohonan, &keterangan,
			&data.CreatedAt, &updatedat, &data.CreatedBy); err != nil {
			log.Println("Error saat scan open requested obat", err)
			return nil, err
		}

		if keterangan.Valid {
			data.Keterangan = &keterangan.String
		}
		if updatedat.Valid {
			data.UpdatedAt = &updatedat.Time
		}

		list = append(list, data)
	}
	return list, nil

}

func GetTopRequestedObat(ctx context.Context) ([]class.TopRequestedObat, error) {

	con := db.GetDBCon()

	query := `SELECT oj.nama_obat , SUM(dpo.jumlah_diminta) AS total
	FROM detail_distribusi dpo 
	JOIN obat_jadi oj ON dpo.id_kartustok = oj.id_obat 
	GROUP BY oj.nama_obat
	ORDER BY total DESC 
	LIMIT 10
	`

	rows, err := con.QueryContext(ctx, query)

	if err != nil {
		log.Println("Error saat query top requested obat", err)
		return nil, err
	}
	defer rows.Close()

	var list []class.TopRequestedObat
	for rows.Next() {
		var obj class.TopRequestedObat

		if err := rows.Scan(&obj.NamaObat, &obj.Jumlah); err != nil {
			log.Println("Error saat scan top requested obat", err)
			return nil, err
		}
		list = append(list, obj)
	}
	return list, nil
}
func GetTopFulfilledObat(ctx context.Context) ([]class.TopRequestedObat, error) {

	con := db.GetDBCon()

	query := `SELECT oj.nama_obat , SUM(dpo.jumlah_dikirim) AS total
	FROM detail_distribusi dpo 
	JOIN obat_jadi oj ON dpo.id_kartustok = oj.id_obat 
	ORDER BY total DESC 
	LIMIT 10
	`

	rows, err := con.QueryContext(ctx, query)

	if err != nil {
		log.Println("Error saat query top requested obat", err)
		return nil, err
	}
	defer rows.Close()

	var list []class.TopRequestedObat
	for rows.Next() {
		var obj class.TopRequestedObat

		if err := rows.Scan(&obj.NamaObat, &obj.Jumlah); err != nil {
			log.Println("Error saat scan top requested obat", err)
			return nil, err
		}
		list = append(list, obj)
	}
	return list, nil
}

func DashboardGudang(ctx context.Context) (class.Response, error) {

	var res class.GudangDashboardResponse

	const iddepo = "10"
	stokMovement, err := GetTotalStokMovement(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data stok movement"}, err
	}
	res.TotalStockMovement = stokMovement.TotalStockMovement

	lowStok, err := GetLowStokObat(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data low stok"}, err
	}
	res.LowStockItems = lowStok

	nearExp, err := GetNearExpiredObat(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data near expired"}, err
	}
	res.NearExpiryItems = nearExp

	openreq, err := GetOpenRequestObat(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data open requested obat"}, err
	}
	res.OpenRequestApotik = openreq

	topreq, err := GetTopRequestedObat(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data top requested obat"}, err
	}
	res.TopRequestedObat = topreq

	topful, err := GetTopFulfilledObat(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data top fulfilled obat"}, err
	}
	res.TopFulfilledObat = topful

	return class.Response{
		Status:  http.StatusOK,
		Message: "Berhasil mengambil data dashboard",
		Data:    res,
	}, nil

	//ingat tanya perlu ga function untuk tampilkan semua stok barang dari tiap obat yang ada
}

func GetOpenPembelianPenerimaan(ctx context.Context) ([]class.GetOpenPembelianPenerimaan, error) {

	con := db.GetDBCon()
	query := `SELECT pp.id_pembelian_penerimaan_obat ,su.nama, pp.total_harga, pp.keterangan, pp.tanggal_pemesanan,
	pp.tanggal_pembayaran, kpem.nama, kpen.nama, pp.created_at 
	FROM pembelian_penerimaan pp
	JOIN Supplier su ON su.id_supplier = pp.id_supplier
	JOIN Karyawan kpem ON kpem.id_karyawan = pp.pemesan  
	LEFT JOIN Karyawan kpen ON kpen.id_karyawan = pp.penerima
	WHERE pp.tanggal_penerimaan IS NULL  
	`

	rows, err := con.QueryContext(ctx, query)
	if err != nil {
		log.Println("Error saat query open pembelian penerimaan", err)
		return nil, err
	}
	defer rows.Close()

	var list []class.GetOpenPembelianPenerimaan

	for rows.Next() {
		var data class.GetOpenPembelianPenerimaan
		var keterangan, namapenerima sql.NullString
		var tglpembayaran sql.NullTime
		err := rows.Scan(&data.IDPembelianPenerimaanObat, &data.NamaSupplier, &data.TotalHarga, &keterangan, &data.TanggalPembelianInput,
			&tglpembayaran, &data.Pemesan, &namapenerima, &data.CreatedAt)
		if err != nil {
			log.Println("Error saat scan data", err)
			return nil, err
		}
		if keterangan.Valid {
			data.Keterangan = &keterangan.String
		}
		if namapenerima.Valid {
			data.Penerima = &namapenerima.String
		}
		data.TanggalPembelian = data.TanggalPembelianInput.Format("2006-01-02")
		data.TanggalPembayaran = tglpembayaran.Time.Format("2006-01-02")
		list = append(list, data)

	}

	return list, nil
}

func DashboardApotik(ctx context.Context) (class.Response, error) {
	var res class.ApotikDashboardResponse

	const iddepo = "20"
	stokMovement, err := GetTotalStokMovement(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data stok movement"}, err
	}
	res.TotalStockMovement = stokMovement.TotalStockMovement

	lowStok, err := GetLowStokObat(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data low stok"}, err
	}
	res.LowStockItems = lowStok

	nearExp, err := GetNearExpiredObat(ctx, iddepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data near expired"}, err
	}
	res.NearExpiryItems = nearExp

	openreq, err := GetOpenRequestObat(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data open requested obat"}, err
	}
	res.OpenRequestApotik = openreq

	topreq, err := GetTopRequestedObat(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data top requested obat"}, err
	}
	res.TopRequestedObat = topreq

	topful, err := GetTopFulfilledObat(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data top fulfilled obat"}, err
	}
	res.TopFulfilledObat = topful

	totalPenjualan, err := GetTotalPenjualan(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data total penjualan"}, err
	}
	res.TotalSales = totalPenjualan

	topSelling, err := GetTopSellingObat(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data top selling"}, err
	}
	res.TopSellingProducts = topSelling

	getopenpem, err := GetOpenPembelianPenerimaan(ctx)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data open pembelian penerimaan"}, err
	}
	res.OpenPembelianPenerimaan = getopenpem

	return class.Response{Status: http.StatusOK, Message: "Success", Data: res}, nil
}
