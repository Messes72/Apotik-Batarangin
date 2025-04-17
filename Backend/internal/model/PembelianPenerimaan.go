package internal

import (
	"context"
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
	_, err = tx.ExecContext(ctx, query, newidpembelianpenerimaan, pembelian.IDSupplier, pembelian.TotalHarga, pembelian.Keterangan, pembelian.TanggalPembelian, pembelian.TanggalPembayaran, pembelian.CreatedBy, pembelian.CreatedBy)
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

		querydetail := `INSERT INTO detail_pembelian_penerimaan (id_pembelian_penerimaan_obat, id_detail_pembelian_penerimaan_obat, id_kartustok, id_depo, id_status,nama_obat, jumlah_dipesan, jumlah_diterima, created_at)
		VALUES (?,?,?,?,?,?,?,?,NOW())`

		_, err := tx.ExecContext(ctx, querydetail, newidpembelianpenerimaan, newiddetailpembelianpenerimaan, obat.IDKartuStok, idDepo, obat.IDStatus, obat.NamaObat, obat.JumlahDipesan, obat.JumlahDiterima)
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
	_, err = tx.ExecContext(ctx, query, penerimaan.TanggalPenerimaan, penerimaan.Pemesan, penerimaan.IDPembelianPenerimaanObat)
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
		log.Printf("New id obat: %s", newidbatchpenerimaan)

		updateCounter := `UPDATE batch_penerimaancounter SET count = ?`
		_, err = tx.ExecContext(ctx, updateCounter, newCounter)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to update obat counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
		}

		var counter1 int
		queryCounter1 := `SELECT count FROM nomor_batchcounter FOR UPDATE`
		err = tx.QueryRowContext(ctx, queryCounter1).Scan(&counter)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to fetch counter: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
		}

		newCounter1 := counter1 + 1
		prefix1 := "NB"
		newidbatch := fmt.Sprintf("%s%d", prefix1, newCounter1)
		log.Printf("New id obat: %s", newidbatch)

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

		var totalReceived int
		query := `SELECT IFNULL(SUM(jumlah_diterima), 0) FROM batch_penerimaan WHERE id_detail_pembelian_penerimaan = ?`
		err = tx.QueryRowContext(ctx, query, obat.IDDetailPembelianPenerimaan).Scan(&totalReceived)
		if err != nil {
			log.Println("error saat menghitung total obat yang diterima", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menghitung total barang yang diterima", Data: nil}, err
		}

		var newStatus string
		if totalReceived == 0 {
			newStatus = "0"
		} else if totalReceived < obat.JumlahDipesan {
			newStatus = "2"
		} else if totalReceived >= obat.JumlahDipesan {
			newStatus = "1"
		}

		querydetailpembelianpenerimaan := `UPDATE detail_pembelian_penerimaan SET id_status = ? WHERE id_detail_pembelian_penerimaan_obat = ?`
		_, err = tx.ExecContext(ctx, querydetailpembelianpenerimaan, newStatus, obat.IDDetailPembelianPenerimaan)
		if err != nil {
			tx.Rollback()
			log.Println("error saat mengupdate status dari obat yang diterima", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data status penerimaan", Data: nil}, err
		}

		tx.Commit()
	}
	return class.Response{Status: http.StatusOK, Message: "Berhasil Menyimpan Data Penerimaan Barang.", Data: nil}, err
}
