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

		querydetailkartustok := `INSERT INTO detail_kartustok (id_detail_kartu_stok, id_kartustok, id_batch_penerimaan , id_nomor_batch, masuk, keluar, sisa, created_at)
			VALUES (?,?,?,?,?,0,?,NOW())`

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

	tx.Commit()
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

	err := con.QueryRowContext(ctx, query, idpembelian).Scan(&pembelian.IDPembelianPenerimaanObat, &pembelian.IDSupplier, &pembelian.TotalHarga, &pembelian.Keterangan, &tpembelian, &tpenerimaan,
		&tpembayaran, &pembelian.Pemesan, &pembelian.Penerima, &pembelian.CreatedAt, &pembelian.CreatedBy, &pembelian.UpdatedAt, &pembelian.UpdatedBy)

	if err != nil {
		log.Println("Error saata scan data dari rows ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data pembelian obat", Data: nil}, err
	}

	if tpembelian.Valid { //format string ke date
		pembelian.TanggalPembelianInput = tpembelian.Time.Format("2006-01-02")
	}
	if tpembayaran.Valid {
		pembelian.TanggalPembelianInput = tpembayaran.Time.Format("2006-01-02")
	}
	if tpenerimaan.Valid {
		pembelian.TanggalPembelianInput = tpenerimaan.Time.Format("2006-01-02")
	}

	querysupplier := `SELECT nama FROM supplier WHERE id_supplier = ? AND deleted_at IS NULL`
	err = con.QueryRowContext(ctx, querysupplier, pembelian.IDSupplier).Scan(&pembelian.NamaSupplier)
	if err != nil {
		log.Println("Error saat mengambil nama supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil nama supplier", Data: nil}, err
	}

	querydetailpembelianpenerimaan := `SELECT id_detail_pembelian_penerimaan_obat, id_kartustok, id_depo, id_status, nama_obat, jumlah_dipesan,
	jumlah_diterima, created_at, updated_at, created_by, updated_by FROM detail_pembelian_penerimaan WHERE id_pembelian_penerimaan_obat = ?`

	rows, err := con.QueryContext(ctx, querydetailpembelianpenerimaan, idpembelian)
	if err != nil {
		log.Println("Error saat mengambil data detail pembelian penerimaan obat", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data detail pembelian penerimaan obat", Data: nil}, err
	}
	defer rows.Close()
	for rows.Next() {
		var detail class.DetailPembelianPenerimaan
		err := rows.Scan(&detail.IDDetailPembelianPenerimaan, &detail.IDKartuStok, &detail.IDDepo, &detail.IDStatus, &detail.NamaObat, &detail.JumlahDipesan, &detail.JumlahDiterima,
			&detail.CreatedAt, &detail.UpdatedAt, &detail.CreatedBy, &detail.UpdatedBy)

		if err != nil {
			log.Println("Error saat scan data detail pembelian penerimaan obat", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data detail pembelian penerimaan obat", Data: nil}, err

		}
		pembelian.ObatList = append(pembelian.ObatList, detail)
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: pembelian}, nil
}
