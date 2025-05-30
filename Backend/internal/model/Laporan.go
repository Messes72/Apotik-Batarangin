package internal

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
	"strings"
	"time"
)

// func LaporanPembelianPenerimaan(ctx context.Context, startdate, enddate time.Time) (class.Response, error) {

// 	con := db.GetDBCon()

// 	query := `SELECT p.id_pembelian_penerimaan_obat ,s.nama, p.total_harga, p.keterangan, p.tanggal_pemesanam, p.tanggal_penerimaan,
// 	p.tanggal_pembayaran, kpem.nama, kpen.nama, p.created_at
// 	FROM pembelian_penerimaan p
// 	LEFT JOIN supplier s 		ON p.id_supplier = s.id_supplier
// 	LEFT JOIN Karyawan kpem 	ON p.pemesan = kpem.id_karyawan
// 	LEFT JOIN Karyawan kpen		ON p.penerima = kpen.id_karyawan
// 	WHERE p.created_at BETWEEN ? AND ?
// 	ORDER BY p.created_at `

// 	rows, err := con.QueryContext(ctx, query, startdate, enddate)
// 	if err != nil {
// 		log.Println("Error saat query utama", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data laporan"}, err
// 	}

// 	defer rows.Close()

// 	var list []class.PenerimaanPembelianLaporan

// 	for rows.Next() {
// 		var data class.PenerimaanPembelianLaporan
// 		var keterangan, namapenerima sql.NullString
// 		var tanggalpenerimaan sql.NullTime
// 		err := rows.Scan(&data.IDPembelianPenerimaanObat, &data.NamaSupplier, &data.TotalHarga, &keterangan, &data.TanggalPemesanan,
// 			&tanggalpenerimaan, &data.TanggalPembayaran, &data.NamaPemesan, &namapenerima, &data.CreatedAt)
// 		if err != nil {
// 			log.Println("Error saat scan data", err)
// 			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data laporan"}, err
// 		}
// 		if keterangan.Valid {
// 			data.Keterangan = keterangan.String
// 		}
// 		if tanggalpenerimaan.Valid {
// 			data.TanggalPenerimaan = tanggalpenerimaan.Time
// 		}
// 		if namapenerima.Valid {
// 			data.NamaPenerima = namapenerima.String
// 		}
// 		list = append(list, data)

// 	}

// 	err = rows.Err()
// 	if err != nil {
// 		log.Println("Error di rows err ", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data laporan"}, err
// 	}

// 	return class.Response{Status: http.StatusOK, Message: "Success", Data: list}, nil
// }

func Laporan(ctx context.Context, startdate, enddate time.Time, iddepo string, page, pageSize int, idobat, jenisparam, nobatch string) (class.Response, error) {
	con := db.GetDBCon()

	if page <= 0 {
		page = 1

	}

	if pageSize <= 0 {
		pageSize = 10
	}
	offset := (page - 1) * pageSize

	var (
		filters []string
		argumn  []interface{}
	)

	//filter untuk filtering based on user input dia mau lihat laporan based on apa
	//bisa by idobat, jenis transaks dan batch
	filters = append(filters, "dk.id_depo = ?")
	argumn = append(argumn, iddepo)
	argumn = append(argumn, iddepo)
	filters = append(filters, "dk.created_at >= ? AND dk.created_at < ?")
	enddate = enddate.AddDate(0, 0, 1)
	argumn = append(argumn, startdate, enddate)

	if idobat != "" { //by idobat
		filters = append(filters, "ks.id_obat = ?")
		argumn = append(argumn, idobat)
	}

	var jenislist []string
	if jenisparam != "" {
		jenislist = strings.Split(jenisparam, ",")
	}
	if len(jenislist) > 0 { //by jenis transaksi yg diberikan

		dummyquestionmark := strings.TrimRight(strings.Repeat("?", len(jenislist)), ",")
		filters = append(filters, fmt.Sprintf(`(
		CASE
			WHEN dk.id_transaksi IS NOT NULL THEN 'Penjualan'
			WHEN dk.id_retur IS NOT NULL THEN 'Retur'
			WHEN dk.id_distribusi IS NOT NULL THEN 'Distribusi'
			WHEN dk.id_stokopname IS NOT NULL THEN 'Stok Opname'
			WHEN dk.id_batch_penerimaan IS NOT NULL THEN 'Pembelian Penerimaan'
		ELSE 'Lainnya'
		END
		) IN (%s)`, dummyquestionmark))

		for _, m := range jenislist {
			argumn = append(argumn, m)
		}
	}

	//berdasarkan no batch
	if nobatch != "" {
		filters = append(filters, "dk.id_nomor_batch = ?")
		argumn = append(argumn, nobatch)
	}

	where := "WHERE " + strings.Join(filters, " AND ")

	query := `SELECT
		dk.id_kartustok,
		dk.created_at,
		ks.id_obat,
		oj.nama_obat,
		dk.masuk,
		dk.keluar,
		dk.sisa AS sisa_batch,
		(
			SELECT SUM(COALESCE(dk2.masuk, 0) - COALESCE(dk2.keluar, 0))
			FROM detail_kartustok dk2
			JOIN kartu_stok ks2 ON dk2.id_kartustok = ks2.id_kartustok AND dk2.id_depo = ks2.id_depo
			WHERE ks2.id_obat = oj.id_obat
			AND dk2.id_depo = ?
			AND dk2.created_at <= dk.created_at
		) AS stoktotal,
		CASE
			WHEN dk.id_transaksi IS NOT NULL THEN 'Penjualan'
			WHEN dk.id_retur IS NOT NULL THEN 'Retur'
			WHEN dk.id_distribusi IS NOT NULL THEN 'Distribusi'
			WHEN dk.id_stokopname IS NOT NULL THEN 'Stok Opname'
			WHEN dk.id_batch_penerimaan IS NOT NULL THEN 'Pembelian Penerimaan'
		ELSE 'Lainnya'
		END  AS jenistransaksi,
		COALESCE (
		dk.id_transaksi ,
		dk.id_stokopname,
		dk.id_distribusi, 
		dk.id_retur,
		dk.id_batch_penerimaan
		) AS referensi ,
		 nb.no_batch, 
		 nb.kadaluarsa
		FROM detail_kartustok dk
		JOIN kartu_stok ks ON dk.id_kartustok = ks.id_kartustok AND dk.id_depo = ks.id_depo
		JOIN obat_jadi oj ON ks.id_obat = oj.id_obat
		LEFT JOIN nomor_batch nb ON dk.id_nomor_batch = nb.id_nomor_batch
		%s
		ORDER BY dk.created_at DESC
		LIMIT ? OFFSET ?
	`

	querydynamic := fmt.Sprintf(query, where)

	argumn = append(argumn, pageSize, offset)
	log.Println(argumn...)

	rows, err := con.QueryContext(ctx, querydynamic, argumn...)
	if err != nil {
		log.Println("Error saat query main laporan", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat membuat Laporan"}, err
	}
	defer rows.Close()

	var list []class.LaporanMutasi

	for rows.Next() {
		var data class.LaporanMutasi
		var nomorbatch sql.NullString
		var kadaluarsa sql.NullTime

		if err := rows.Scan(&data.IDKartuStok, &data.Tanggal, &data.IDObat, &data.NamaObat, &data.QtyMasuk, &data.QtyKeluar,
			&data.StokBatch, &data.StokAkhir, &data.JenisTransaksi, &data.Referensi, &nomorbatch, &kadaluarsa); err != nil {
			log.Println("Error saat scan data laproan", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat membuat laporan"}, err
		}
		if nomorbatch.Valid {
			data.NomorBatch = &nomorbatch.String
		}
		var kadaluarsastring *string
		if kadaluarsa.Valid {
			format := kadaluarsa.Time.Format("2006-01-02")
			kadaluarsastring = &format
			data.Kadaluarsa = kadaluarsastring
		}

		list = append(list, data)

	}

	var totalrecord int
	var (
		countRecordQuery string
		args             []interface{}
	)

	if nobatch != "" || len(jenislist) <= 0 {
		countRecordQuery = `
        SELECT COUNT(*)
        FROM detail_kartustok dk
        JOIN kartu_stok ks ON dk.id_kartustok = ks.id_kartustok
        JOIN obat_jadi oj ON ks.id_obat = oj.id_obat
        WHERE dk.id_depo = ? AND ks.id_depo = ? AND dk.created_at BETWEEN ? AND ?
        AND dk.id_nomor_batch = ?
    `
		args = []interface{}{iddepo, iddepo, startdate, enddate, nobatch}
	} else {
		countRecordQuery = `
        SELECT COUNT(*)
        FROM detail_kartustok dk
        JOIN kartu_stok ks ON dk.id_kartustok = ks.id_kartustok
        JOIN obat_jadi oj ON ks.id_obat = oj.id_obat
        WHERE dk.id_depo = ? AND dk.created_at BETWEEN ? AND ?
    `
		args = []interface{}{iddepo, startdate, enddate}
	}

	err = con.QueryRowContext(ctx, countRecordQuery, args...).Scan(&totalrecord)
	if err != nil {
		log.Println("count record query error:", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat count total record"}, err
	}

	totalpage := (totalrecord + pageSize - 1) / pageSize

	metadata := class.Metadata{
		CurrentPage:  page,
		PageSize:     pageSize,
		TotalPages:   totalpage,
		TotalRecords: totalrecord,
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: list, Metadata: metadata}, nil

}
