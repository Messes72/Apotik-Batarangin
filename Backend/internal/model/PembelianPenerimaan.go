package internal

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func CreatePembelianPenerimaan(ctx context.Context, pembelian class.PembelianPenerimaan, listobat []class.DetailPembelianPenerimaan) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}

	var totalharga float64
	for _, obat := range listobat {
		var hargabeli float64
		queryhargabeli := `SELECT harga_beli from obat_jadi WHERE id_obat = ?`
		err := tx.QueryRowContext(ctx, queryhargabeli, obat.IDKartuStok).Scan(&hargabeli)
		if err == sql.ErrNoRows {
			log.Printf("No harga_beli found for id_obat %s", obat.IDKartuStok)
			tx.Rollback()
			return class.Response{Status: http.StatusNotFound, Message: fmt.Sprintf("Obat %s tidak ditemukan di database", obat.IDKartuStok)}, nil
		} else if err != nil {
			tx.Rollback()
			log.Println("Unexpected DB error:", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Database error saat ambil harga beli"}, err
		}
		log.Printf("Obat ID: %s, Harga Beli: %.2f, Jumlah Dipesan: %d, Total Harga: %.2f",
			obat.IDKartuStok, hargabeli, obat.JumlahDipesan, hargabeli*float64(obat.JumlahDipesan))

		log.Printf("Harga beli obat %s = %.2f, jumlah = %d", obat.IDKartuStok, hargabeli, obat.JumlahDipesan)
		totalharga += hargabeli * float64(obat.JumlahDipesan)

	}
	fmt.Printf("Total Harga: %.2f\n", totalharga)

	var counter int
	queryCounter := `SELECT count FROM pembelian_penerimaancounter FOR UPDATE`
	err = tx.QueryRowContext(ctx, queryCounter).Scan(&counter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to fetch counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
	}

	newCounter := counter + 1
	prefix := "PO"
	newidpembelianpenerimaan := fmt.Sprintf("%s%d", prefix, newCounter)
	log.Printf("New id obat: %s", newidpembelianpenerimaan)

	updateCounter := `UPDATE pembelian_penerimaancounter SET count = ?`
	_, err = tx.ExecContext(ctx, updateCounter, newCounter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to update obat counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
	}

	query := `INSERT INTO pembelian_penerimaan (id_pembelian_penerimaan_obat, id_supplier, total_harga, keterangan, tanggal_pemesanan,tanggal_pembayaran, pemesan , created_at, created_by)
		VALUES (?,?,?,?,?,?,?,NOW(),?)`
	_, err = tx.ExecContext(ctx, query, newidpembelianpenerimaan, pembelian.IDSupplier, totalharga, pembelian.Keterangan, pembelian.TanggalPembelian, pembelian.TanggalPembayaran, pembelian.CreatedBy, pembelian.CreatedBy)
	if err != nil {
		tx.Rollback()
		log.Println("gagal membuat record pembelian_penerimaan", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error dalam membuat pembelian"}, err
	}

	for _, obat := range listobat {

		var counter int
		queryCounter := `SELECT count FROM detail_pembelian_penerimaancounter FOR UPDATE`
		err = tx.QueryRowContext(ctx, queryCounter).Scan(&counter)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to fetch counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
		}

		newCounter := counter + 1
		prefix := "DPO"
		newiddetailpembelianpenerimaan := fmt.Sprintf("%s%d", prefix, newCounter)
		log.Printf("New id obat: %s", newiddetailpembelianpenerimaan)

		updateCounter := `UPDATE detail_pembelian_penerimaancounter SET count = ?`
		_, err = tx.ExecContext(ctx, updateCounter, newCounter)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to update obat counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
		}

		idDepo := "10"

		querydetail := `INSERT INTO detail_pembelian_penerimaan (id_pembelian_penerimaan_obat, id_detail_pembelian_penerimaan_obat, id_kartustok, id_depo, id_status,nama_obat, jumlah_dipesan, jumlah_diterima, created_at, created_by)
			VALUES (?,?,?,?,?,?,?,?,NOW(),?)`

		_, err := tx.ExecContext(ctx, querydetail, newidpembelianpenerimaan, newiddetailpembelianpenerimaan, obat.IDKartuStok, idDepo, "0", obat.NamaObat, obat.JumlahDipesan, obat.JumlahDiterima, pembelian.CreatedBy)
		if err != nil {
			tx.Rollback()
			log.Println("Gagal insert detail pembelian obat", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error dalam membuat pembelian", Data: nil}, err
		}

	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Berhasil ", Data: nil}, nil

}

func CreatePenerimaan(ctx context.Context, penerimaan class.PembelianPenerimaan, listobat []class.DetailPembelianPenerimaan) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}
	query := `UPDATE pembelian_penerimaan SET tanggal_penerimaan = ?, penerima = ? WHERE id_pembelian_penerimaan_obat = ?`
	_, err = tx.ExecContext(ctx, query, penerimaan.TanggalPenerimaan, penerimaan.Penerima, penerimaan.IDPembelianPenerimaanObat)
	if err != nil {
		tx.Rollback()
		log.Println("Error di update pembelian penerimaan obat", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err

	}

	for _, obat := range listobat {

		var counter int
		queryCounter := `SELECT count FROM batch_penerimaancounter FOR UPDATE`
		err = tx.QueryRowContext(ctx, queryCounter).Scan(&counter)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to fetch counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
		}

		newCounter := counter + 1
		prefix := "BP"
		newidbatchpenerimaan := fmt.Sprintf("%s%d", prefix, newCounter)

		updateCounter := `UPDATE batch_penerimaancounter SET count = ?`
		_, err = tx.ExecContext(ctx, updateCounter, newCounter)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to update obat counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
		}

		var counter1 int
		queryCounter1 := `SELECT count FROM nomor_batchcounter FOR UPDATE`
		err = tx.QueryRowContext(ctx, queryCounter1).Scan(&counter1)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to fetch counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
		}

		newCounter1 := counter1 + 1
		prefix1 := "NB"
		newidbatch := fmt.Sprintf("%s%d", prefix1, newCounter1)

		updateCounter1 := `UPDATE nomor_batchcounter SET count = ?`
		_, err = tx.ExecContext(ctx, updateCounter1, newCounter1)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to update obat counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
		}

		querynomorbatch := `INSERT INTO nomor_batch (id_nomor_batch, no_batch, kadaluarsa, created_at) VALUES (?,?,?,NOW())`
		_, err := tx.ExecContext(ctx, querynomorbatch, newidbatch, obat.NomorBatch, obat.Kadaluarsa)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat insert nomor batch baru", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses nomor batch obat", Data: nil}, err
		}

		querybatchpenerimaan := `INSERT INTO batch_penerimaan (id_batch_penerimaan, id_detail_pembelian_penerimaan, id_nomor_batch, jumlah_diterima, created_at) 
			VALUEs (?,?,?,?,NOW())`

		_, err = tx.ExecContext(ctx, querybatchpenerimaan, newidbatchpenerimaan, obat.IDDetailPembelianPenerimaan, newidbatch, obat.JumlahDiterima)
		if err != nil {
			tx.Rollback()
			log.Println("error saat insert batch penerimaan")
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data penerimaan obat", Data: nil}, err
		}

		var totalterima int
		query := `SELECT IFNULL(SUM(jumlah_diterima), 0) FROM batch_penerimaan WHERE id_detail_pembelian_penerimaan = ?`
		err = tx.QueryRowContext(ctx, query, obat.IDDetailPembelianPenerimaan).Scan(&totalterima)
		if err != nil {
			tx.Rollback()
			log.Println("error saat menghitung total obat yang diterima", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menghitung total barang yang diterima", Data: nil}, err
		}

		var totalpesan int
		querytotalpesan := `SELECT jumlah_dipesan FROM detail_pembelian_penerimaan WHERE id_detail_pembelian_penerimaan_obat = ?`
		err = tx.QueryRowContext(ctx, querytotalpesan, obat.IDDetailPembelianPenerimaan).Scan(&totalpesan)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat mengambil data jumlah dipesan dari db", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data status penerimaan obat", Data: nil}, err
		}

		var newStatus string
		if totalterima == 0 {
			newStatus = "0" //tidak ada obat diterima
		} else if totalterima < totalpesan {
			newStatus = "2" //incomplete
		} else if totalterima >= totalpesan {
			newStatus = "1" //done
		}

		querydetailpembelianpenerimaan := `UPDATE detail_pembelian_penerimaan SET id_status = ?, jumlah_diterima = ? WHERE id_detail_pembelian_penerimaan_obat = ?`
		_, err = tx.ExecContext(ctx, querydetailpembelianpenerimaan, newStatus, totalterima, obat.IDDetailPembelianPenerimaan)
		if err != nil {
			tx.Rollback()
			log.Println("error saat mengupdate status dari obat yang diterima", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data status penerimaan", Data: nil}, err
		}

		var counter2 int
		queryCounter2 := `SELECT count FROM detail_kartustokcounter FOR UPDATE`
		err = tx.QueryRowContext(ctx, queryCounter2).Scan(&counter2)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to fetch counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
		}

		newCounter2 := counter2 + 1
		prefix2 := "DKS"
		newiddetailkartustok := fmt.Sprintf("%s%d", prefix2, newCounter2)

		updateCounter2 := `UPDATE detail_kartustokcounter SET count = ?`
		_, err = tx.ExecContext(ctx, updateCounter2, newCounter2)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to update obat counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
		}

		querydetailkartustok := `INSERT INTO detail_kartustok (id_detail_kartu_stok, id_kartustok, id_batch_penerimaan , id_nomor_batch, masuk, keluar, sisa, created_at, id_depo)
			VALUES (?,?,?,?,?,0,?,NOW(),'10')`

		var stoklama int
		querystoklama := `SELECT stok_barang FROM kartu_stok WHERE id_kartustok= ?`
		err = tx.QueryRowContext(ctx, querystoklama, obat.IDKartuStok).Scan(&stoklama)
		if err != nil {
			tx.Rollback()
			log.Println("Failed to get stok lama from stok barang", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menghitung stok barang", Data: nil}, err
		}

		stokbaru := stoklama + obat.JumlahDiterima
		iddepo := "10"

		queryupdatekartustok := `UPDATE kartu_stok SET stok_barang = ? WHERE id_kartustok = ? AND id_depo = ?`
		_, err = tx.ExecContext(ctx, queryupdatekartustok, stokbaru, obat.IDKartuStok, iddepo)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat update kartu stok mengenai stok barang baru", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat update data kartu stok", Data: nil}, err
		}

		_, err = tx.ExecContext(ctx, querydetailkartustok, newiddetailkartustok, obat.IDKartuStok, newidbatchpenerimaan, newidbatch, obat.JumlahDiterima, stokbaru)
		if err != nil {
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data ke kartu stok", Data: nil}, err
		}

	}

	queryupdatepembelianpenerimaan := `UPDATE pembelian_penerimaan p SET total_harga = (SELECT IFNULL(SUM(o.harga_beli * dp.jumlah_diterima),0)
	FROM detail_pembelian_penerimaan dp JOIN obat_jadi o ON o.id_obat = dp.id_kartustok WHERE dp.id_pembelian_penerimaan_obat = ?
	) WHERE p.id_pembelian_penerimaan_obat =?`

	_, err = tx.ExecContext(ctx, queryupdatepembelianpenerimaan, penerimaan.IDPembelianPenerimaanObat, penerimaan.IDPembelianPenerimaanObat)
	if err != nil {
		tx.Rollback()
		log.Println("Error saat update total harga pembelian penerimaan obat", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}
	return class.Response{Status: http.StatusOK, Message: "Berhasil Menyimpan Data Penerimaan Barang.", Data: nil}, err
}

func GetAllPembelian(ctx context.Context, page, pagesize int) (class.Response, error) {
	con := db.GetDBCon()

	if page <= 0 { //biar aman aja ini gak bisa masukin aneh2
		page = 1
	}
	if pagesize <= 0 {
		pagesize = 10
	}
	offset := (page - 1) * pagesize

	querypembelianpenerimaan := `SELECT id_pembelian_penerimaan_obat, id_supplier, total_harga, keterangan, tanggal_pemesanan, tanggal_penerimaan,
		tanggal_pembayaran, pemesan, penerima,created_at,created_by,updated_at,updated_by FROM pembelian_penerimaan WHERE deleted_at IS NULL ORDER BY created_at DESC LIMIT ? OFFSET ? `

	rows, err := con.QueryContext(ctx, querypembelianpenerimaan, pagesize, offset)
	if err != nil {
		log.Println("Error saat mengambil data pemebelian penerimaan obat", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data pembelian obat", Data: nil}, err
	}
	defer rows.Close()

	var listpembelian []class.PembelianPenerimaan
	for rows.Next() {

		var pembelian class.PembelianPenerimaan
		var tpembelian, tpembayaran, tpenerimaan sql.NullTime

		err := rows.Scan(&pembelian.IDPembelianPenerimaanObat, &pembelian.IDSupplier, &pembelian.TotalHarga, &pembelian.Keterangan, &tpembelian, &tpenerimaan,
			&tpembayaran, &pembelian.Pemesan, &pembelian.Penerima, &pembelian.CreatedAt, &pembelian.CreatedBy, &pembelian.UpdatedAt, &pembelian.UpdatedBy)

		if err != nil {
			log.Println("Error saata scan data dari rows ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data pembelian obat", Data: nil}, err
		}

		if tpembelian.Valid {
			pembelian.TanggalPembelianInput = tpembelian.Time.Format("2006-01-02")
		}
		if tpembayaran.Valid {
			pembelian.TanggalPembayaranInput = tpembayaran.Time.Format("2006-01-02")
		}
		if tpenerimaan.Valid {
			pembelian.TanggalPenerimaanInput = tpenerimaan.Time.Format("2006-01-02")
		}

		listpembelian = append(listpembelian, pembelian)

	}
	var totalrecord int
	countrecordquery := `SELECT COUNT(*) FROM pembelian_penerimaan WHERE deleted_at IS NULL`
	err = con.QueryRowContext(ctx, countrecordquery).Scan(&totalrecord)

	if err != nil {
		log.Println("gagal menghitung jumlah entry table obat , pada query di model obat")
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal menghitung jumlah obat"}, nil
	}

	totalpage := (totalrecord + pagesize - 1) / pagesize //bisa juga pakai total/pagesize tp kan nanti perlu di bulatkan keatas pakai package math dimana dia perlu type floating point yg membuat performa hitung lebih lambat

	metadata := class.Metadata{
		CurrentPage:  page,
		PageSize:     pagesize,
		TotalPages:   totalpage,
		TotalRecords: totalrecord,
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: listpembelian, Metadata: metadata}, err

}

func GetPembelianDetail(ctx context.Context, idpembelian string) (class.Response, error) {
	con := db.GetDBCon()

	query := `SELECT id_pembelian_penerimaan_obat, id_supplier, total_harga, keterangan, tanggal_pemesanan, tanggal_penerimaan,
		tanggal_pembayaran, pemesan, penerima, created_at, created_by, updated_at, updated_by FROM pembelian_penerimaan WHERE id_pembelian_penerimaan_obat = ? AND deleted_at IS NULL`

	var pembelian class.PembelianPenerimaan
	var tpembelian, tpembayaran, tpenerimaan sql.NullTime
	var tmppemesan, tmppenerima *string

	err := con.QueryRowContext(ctx, query, idpembelian).Scan(&pembelian.IDPembelianPenerimaanObat, &pembelian.IDSupplier, &pembelian.TotalHarga, &pembelian.Keterangan, &tpembelian, &tpenerimaan,
		&tpembayaran, &tmppemesan, &tmppenerima, &pembelian.CreatedAt, &pembelian.CreatedBy, &pembelian.UpdatedAt, &pembelian.UpdatedBy)

	if err != nil {
		log.Println("Error saata scan data dari rows ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data pembelian obat", Data: nil}, err
	}

	querykaryawan := `SELECT nama from Karyawan WHERE id_karyawan = ?`

	err = con.QueryRowContext(ctx, querykaryawan, tmppemesan).Scan(&pembelian.Pemesan)

	err = con.QueryRowContext(ctx, querykaryawan, tmppenerima).Scan(&pembelian.Penerima)

	if tpembelian.Valid { //format string ke date
		pembelian.TanggalPembelianInput = tpembelian.Time.Format("2006-01-02")
	}
	if tpembayaran.Valid {
		pembelian.TanggalPembayaranInput = tpembayaran.Time.Format("2006-01-02")
	}
	if tpenerimaan.Valid {
		pembelian.TanggalPenerimaanInput = tpenerimaan.Time.Format("2006-01-02")
	}

	querysupplier := `SELECT nama FROM supplier WHERE id_supplier = ? AND deleted_at IS NULL`
	err = con.QueryRowContext(ctx, querysupplier, pembelian.IDSupplier).Scan(&pembelian.NamaSupplier)
	if err != nil {
		log.Println("Error saat mengambil nama supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil nama supplier", Data: nil}, err
	}

	querydetailpembelianpenerimaan := `SELECT d.id_detail_pembelian_penerimaan_obat, d.id_kartustok, d.id_depo, d.id_status, d.nama_obat, d.jumlah_dipesan,
	bp.jumlah_diterima, bp.id_batch_penerimaan, d.created_at, d.updated_at, d.created_by, d.updated_by, nb.no_batch, nb.kadaluarsa, nb.id_nomor_batch FROM detail_pembelian_penerimaan d 
	LEFT JOIN batch_penerimaan bp ON bp.id_detail_pembelian_penerimaan = d.id_detail_pembelian_penerimaan_obat
	LEFT JOIN nomor_batch nb ON nb.id_nomor_batch = bp.id_nomor_batch WHERE d.id_pembelian_penerimaan_obat = ?`

	rows, err := con.QueryContext(ctx, querydetailpembelianpenerimaan, idpembelian)
	if err != nil {
		log.Println("Error saat mengambil data detail pembelian penerimaan obat", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data detail pembelian penerimaan obat", Data: nil}, err
	}
	defer rows.Close()
	for rows.Next() {
		var detail class.DetailPembelianPenerimaan
		var kadaluarsa sql.NullTime
		var jumlah_diterima sql.NullInt64
		var no_batch sql.NullString
		err := rows.Scan(&detail.IDDetailPembelianPenerimaan, &detail.IDKartuStok, &detail.IDDepo, &detail.IDStatus, &detail.NamaObat, &detail.JumlahDipesan, &jumlah_diterima,
			&detail.IdBatchPenerimaan, &detail.CreatedAt, &detail.UpdatedAt, &detail.CreatedBy, &detail.UpdatedBy, &no_batch, &kadaluarsa, &detail.IDNomorBatch)

		if err != nil {
			log.Println("Error saat scan data detail pembelian penerimaan obat", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data detail pembelian penerimaan obat", Data: nil}, err

		}
		if jumlah_diterima.Valid {
			detail.JumlahDiterima = int(jumlah_diterima.Int64)
		} else {
			detail.JumlahDiterima = 0
		}
		if no_batch.Valid {
			detail.NomorBatch = no_batch.String
		}
		if kadaluarsa.Valid {
			detail.Kadaluarsa = kadaluarsa.Time
			detail.KadaluarsaInput = kadaluarsa.Time.Format("2006-01-02")
		}
		pembelian.ObatList = append(pembelian.ObatList, detail)
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: pembelian}, nil
}

func EditPenerimaan(ctx context.Context, idKaryawan string, obatbatch []class.DetailPembelianPenerimaan, idpembelianpenerimaanobat string) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}

	queryupdatebatchpenerimaan := `UPDATE batch_penerimaan bp JOIN detail_pembelian_penerimaan d ON bp.id_detail_pembelian_penerimaan = d.id_detail_pembelian_penerimaan_obat SET bp.jumlah_diterima = ? WHERE bp.id_batch_penerimaan = ? AND d.id_pembelian_penerimaan_obat = ?`

	querygetlastinserteddatadetailkartustok := `SELECT sisa FROM detail_kartustok WHERE id_kartustok = ?
	ORDER BY id DESC LIMIT 1`

	querygetjumlahditerima := `SELECT jumlah_diterima FROM batch_penerimaan WHERE id_batch_penerimaan = ?`

	queryinsertdetailkartustok := `INSERT INTO detail_kartustok (id_detail_kartu_stok, id_kartustok ,id_batch_penerimaan,id_nomor_batch, masuk, keluar, sisa,created_at,updated_at, id_depo)
	VALUES (?,?,?,?,?,?,?,NOW(),NOW(),'10')`

	queryupdatenomorbatch := `UPDATE nomor_batch SET no_batch = ? ,kadaluarsa = ?, updated_at = NOW() WHERE id_nomor_batch = ?  `

	querydetailpembelianpenerimaan := `UPDATE detail_pembelian_penerimaan SET jumlah_diterima = ?, id_status = ?, updated_by = ?, updated_at = NOW() WHERE id_detail_pembelian_penerimaan_obat = ?`

	// queryhargabeli := `SELECT harga_beli from obat_jadi WHERE id_obat = ?`

	queryupdatepembelianpenerimaan := `UPDATE pembelian_penerimaan p SET total_harga = (SELECT IFNULL(SUM(o.harga_beli * dp.jumlah_diterima),0)
	FROM detail_pembelian_penerimaan dp JOIN obat_jadi o ON o.id_obat = dp.id_kartustok WHERE dp.id_pembelian_penerimaan_obat = ?
	) WHERE p.id_pembelian_penerimaan_obat =?`

	for _, batch := range obatbatch {

		_, err := tx.ExecContext(ctx, queryupdatenomorbatch, batch.NomorBatch, batch.Kadaluarsa, batch.IDNomorBatch)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat update data di nomor batch", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		var oldjumlahditerima int

		err = tx.QueryRowContext(ctx, querygetjumlahditerima, batch.IdBatchPenerimaan).Scan(&oldjumlahditerima) //get data jumlah diterima yang lama
		if err != nil {
			tx.Rollback()
			log.Println("Error saat mengambil jumlah diterima lama ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		selisih := batch.JumlahDiterima - oldjumlahditerima
		if selisih == 0 {
			continue
		}

		_, err = tx.ExecContext(ctx, queryupdatebatchpenerimaan, batch.JumlahDiterima, batch.IdBatchPenerimaan, idpembelianpenerimaanobat) // update batch penerimaan
		if err != nil {
			tx.Rollback()
			log.Println("Error saat update batch penerimaan", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		//get last inserted data dari detail kartu stok untuk per id batch penerimaan
		var lastsisa int
		err = tx.QueryRowContext(ctx, querygetlastinserteddatadetailkartustok, batch.IDKartuStok).Scan(&lastsisa)
		if err != nil && err != sql.ErrNoRows {
			tx.Rollback()
			log.Println("Error saat mengambil data detail kartu stok", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		var masuk, keluar, newisisa int
		if selisih > 0 {
			masuk = selisih
			keluar = 0
			newisisa = lastsisa + selisih
		} else {
			masuk = 0
			keluar = -selisih             //karena selsih kan minus tp db terima angka positif , maka dicancel dengan -selisih
			newisisa = lastsisa + selisih // ini di tambah karena selisih nya sendiri valuenya pasti negatif sehingga otomatis ngurangin lastsisa
		}

		var counter2 int
		queryCounter2 := `SELECT count FROM detail_kartustokcounter FOR UPDATE`
		err = tx.QueryRowContext(ctx, queryCounter2).Scan(&counter2)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to fetch counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
		}

		newCounter2 := counter2 + 1
		prefix2 := "DKS"
		newiddetailkartustok := fmt.Sprintf("%s%d", prefix2, newCounter2)

		updateCounter2 := `UPDATE detail_kartustokcounter SET count = ?`
		_, err = tx.ExecContext(ctx, updateCounter2, newCounter2)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to update obat counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
		}

		_, err = tx.ExecContext(ctx, queryinsertdetailkartustok, newiddetailkartustok, batch.IDKartuStok, batch.IdBatchPenerimaan, batch.IDNomorBatch, masuk, keluar, newisisa)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat insert record detail kartustok baru", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		const updKartuStokQ = `
		UPDATE kartu_stok
		   SET stok_barang = ?, updated_at = NOW(), updated_by = ?
		 WHERE id_kartustok = ? AND id_depo = "10"`
		if _, err = tx.ExecContext(ctx, updKartuStokQ,
			newisisa,   // the fresh running balance
			idKaryawan, // who edited
			batch.IDKartuStok,
		); err != nil {
			tx.Rollback()
			log.Println("Error saat update stok_barang kartu_stok:", err)
			return class.Response{Status: http.StatusInternalServerError,
				Message: "Error saat memperbarui stok_barang"}, err
		}

		var totalterima int
		query := `SELECT IFNULL(SUM(jumlah_diterima), 0) FROM batch_penerimaan WHERE id_detail_pembelian_penerimaan = ?`
		err = tx.QueryRowContext(ctx, query, batch.IDDetailPembelianPenerimaan).Scan(&totalterima)
		if err != nil {
			tx.Rollback()
			log.Println("error saat menghitung total obat yang diterima", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menghitung total barang yang diterima", Data: nil}, err
		}

		var totalpesan int
		querytotalpesan := `SELECT jumlah_dipesan FROM detail_pembelian_penerimaan WHERE id_detail_pembelian_penerimaan_obat = ?`
		err = tx.QueryRowContext(ctx, querytotalpesan, batch.IDDetailPembelianPenerimaan).Scan(&totalpesan)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat mengambil data jumlah dipesan dari db", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data status penerimaan obat", Data: nil}, err
		}

		var newStatus string
		if totalterima == 0 {
			newStatus = "0" //tidak ada obat diterima
		} else if totalterima < totalpesan {
			newStatus = "2" //incomplete
		} else if totalterima >= totalpesan {
			newStatus = "1" //done
		}

		_, err = tx.ExecContext(ctx, querydetailpembelianpenerimaan, totalterima, newStatus, idKaryawan, batch.IDDetailPembelianPenerimaan)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat update detail pembelian penerimaan ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

	}
	// log.Println("total harga", totalharga)
	_, err = tx.ExecContext(ctx, queryupdatepembelianpenerimaan, idpembelianpenerimaanobat, idpembelianpenerimaanobat)
	if err != nil {
		tx.Rollback()
		log.Println("Error saat update total harga pembelian penerimaan", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success"}, err
}
