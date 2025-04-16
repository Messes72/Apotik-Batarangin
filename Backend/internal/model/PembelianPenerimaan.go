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

// func CreatePenerimaan(ctx context.Context, penerimaan class.PembelianPenerimaan, listobat []class.DetailPembelianPenerimaan) (class.Response, error) {
// 	con := db.GetDBCon()
// 	tx, err := con.BeginTx(ctx, nil)
// 	if err != nil {
// 		log.Printf("Failed to start transaction: %v\n", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

// 	}
// 	query := `UPDATE pembelian_penerimaan SET tanggal_penerimaan = ?, penerima = ? WHERE id_pembelian_penerimaan_obat = ?`
// 	_, err = tx.ExecContext(ctx, query, penerimaan.TanggalPenerimaan, penerimaan.Pemesan, penerimaan.IDPembelianPenerimaanObat)
// 	if err != nil {
// 		tx.Rollback()
// 		log.Println("Error di update pembelian penerimaan obat", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err

// 	}

// 	for _, obat := range listobat {

// 		if obat.NomorBatch == "" {
// 			var counter int
// 			queryCounter := `SELECT count FROM nomor_batchcounter FOR UPDATE`
// 			err = tx.QueryRowContext(ctx, queryCounter).Scan(&counter)
// 			if err != nil {
// 				tx.Rollback()
// 				log.Printf("Failed to fetch counter: %v\n", err)
// 				return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
// 			}

// 			newCounter := counter + 1
// 			prefix := "BN"
// 			newidnomorbatch := fmt.Sprintf("%s%d", prefix, newCounter)
// 			log.Printf("New id obat: %s", newidnomorbatch)

// 			updateCounter := `UPDATE nomor_batchcounter SET count = ?`
// 			_, err = tx.ExecContext(ctx, updateCounter, newCounter)
// 			if err != nil {
// 				tx.Rollback()
// 				log.Printf("Failed to update obat counter: %v\n", err)
// 				return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
// 			}

// 			querybatch := `INSERT INTO nomor_batch (id_nomor_batch, no_batch, kadaluarsa, created_at)`
// 			_, err := tx.ExecContext(ctx, querybatch, newidnomorbatch, obat.NomorBatch, obat.Kadaluarsa)
// 			if err != nil {
// 				tx.Rollback()
// 				log.Println("Gagal insert nomor batch")
// 				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses nomor batch", Data: nil}, err

// 			}

// 		}

// 		obat.IDDepo = "10"

// 		if obat.JumlahDipesan < obat.JumlahDiterima {
// 			tx.Rollback()
// 			log.Println("user input jumlah diterima lebih besar dari dipesan")
// 			return class.Response{Status: http.StatusBadRequest, Message: "Jumlah obat diterima tidak boleh lebih besar daripada yang dipesan", Data: nil}, err
// 		}
// 		idstatus := "0"
// 		if obat.JumlahDiterima > 0 {
// 			if obat.JumlahDiterima == obat.JumlahDipesan {
// 				idstatus = "1"
// 			} else {
// 				idstatus = "2"
// 			}
// 		}

// 		obat.IDStatus = idstatus

// 		querydetailobat := `INSERT INTO detail_pembelian_penerimaan(id_pembelian_penerimaan_obat, id_detail_pembelian_penerimaan_obat, id_nomor_batch, id_kartustok, id_depo, id_status, nama_obat, jumlah_dipesan, jumlah_diterima, )`

// 	}

// }
