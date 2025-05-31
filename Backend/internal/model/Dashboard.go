package internal

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
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

func GetTotalPenjualan(ctx context.Context) (float64, error) {

	con := db.GetDBCon()

	var total float64
	query := `SELECT COALESCE(SUM(total_harga),0) FROM transaksi `
	err := con.QueryRowContext(ctx, query).Scan(&total)
	if err != nil {
		log.Println("Error saat menghitung total penjualan", err)
		return 0, err
	}
	return total, nil
}

func GetTopSellingObat(ctx context.Context) ([]class.TopSellingProduct, error) {

	con := db.GetDBCon()

	query := `SELECT oj.nama_obat, SUM(COALESCE(dt.jumlah,0)) AS jumlah
	FROM detail_transaksi_penjualan_obat dt
	JOIN obat_jadi oj ON dt.id_kartustok = oj.id_obat
	GROUP BY oj.nama_obat
	ORDER BY jumlah DESC 
	LIMIT 10
	`

	rows, err := con.QueryContext(ctx, query)
	if err != nil {
		log.Println("Error saat query top selling obat", err)
		return nil, err
	}
	defer rows.Close()

	var list []class.TopSellingProduct

	for rows.Next() {

		var obat class.TopSellingProduct

		if err := rows.Scan(&obat.NamaObat, &obat.Jumlah); err != nil {
			log.Println("Error saat scan rows top selling obat", err)
			return nil, err
		}
		list = append(list, obat)
	}
	return list, nil

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
    dks.sisa	,
    ks.id_depo
	FROM detail_kartustok dks
	JOIN nomor_batch nb ON dks.id_nomor_batch = nb.id_nomor_batch
	JOIN kartu_stok ks ON dks.id_kartustok = ks.id_kartustok
	JOIN obat_jadi o ON ks.id_obat = o.id_obat
	WHERE nb.kadaluarsa <= CURRENT_DATE + INTERVAL 30 DAY
	AND dks.sisa > 0
	AND (? = '' OR ks.id_depo = ?)
	ORDER BY nb.kadaluarsa ASC
`

	rows, err := con.QueryContext(ctx, query, iddepo, iddepo)
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
