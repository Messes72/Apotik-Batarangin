package internal

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
	"strings"
	"time"
)

func RequestBarangApotikKeGudang(ctx context.Context, idkarayawan string, listobat []class.RequestBarangObat, distribusi class.RequestBarang) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}

	IdDistribusi, err := nextBizID(tx, "distribusicounter", "DIS")
	if err != nil {
		log.Println("Error saat membuat id distribusi baru", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	}

	querydistribusi := `INSERT INTO distribusi (id_distribusi, id_depo_asal, id_depo_tujuan ,id_status,tanggal_permohonan, keterangan, created_at, created_by) VALUES (?,?,?,?,NOW(),?,NOW(),?)`
	depoasal := "10"
	depotujuan := "20"

	_, err = tx.ExecContext(ctx, querydistribusi, IdDistribusi, depoasal, depotujuan, "0", distribusi.Keterangan, idkarayawan)
	if err != nil {
		log.Println("Error saat insert data ke distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	}

	for _, obat := range listobat {

		iddetaildristribusi, err := nextBizID(tx, "detaildistribusicounter", "DDIS")
		if err != nil {
			log.Println("ERror saat membuat counter detail distribusi")
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		querydetaildistribusi := `INSERT INTO detail_distribusi (id_detail_distribusi, id_distribusi, id_kartustok, jumlah_diminta, jumlah_dikirim, created_at, created_by, catatan_apotik)
		VALUES (?,?,?,?,0,NOW(),?,?)`

		_, err = tx.ExecContext(ctx, querydetaildistribusi, iddetaildristribusi, IdDistribusi, obat.IDObat, obat.JumlahDiminta, idkarayawan, obat.CatatanApotik)

		if err != nil {
			log.Println("Error saat insert detail distribusi ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: nil}, nil

}

// helper – convert a possibly‑NULL time to *string (“YYYY‑MM‑DD HH:MM:SS”)
func toPtrTime(t sql.NullTime) *string {
	if !t.Valid {
		return nil
	}
	s := t.Time.Format("2006-01-02")
	return &s
}

// helper – convert a possibly‑NULL string to *string
func toPtrString(ns sql.NullString) *string {
	if !ns.Valid {
		return nil
	}
	s := ns.String
	return &s
}

func GetRequestByID(ctx context.Context, iddistribusi string) (class.Response, error) {

	con := db.GetDBCon()

	var distribusi class.Distribusi

	query := `SELECT id_distribusi, id_depo_asal, id_depo_tujuan ,id_status,tanggal_permohonan,tanggal_pengiriman, keterangan, created_at, created_by, updated_at, updated_by
	FROM distribusi WHERE id_distribusi = ? AND deleted_at IS NULL`

	var TanggalPengiriman sql.NullTime
	var ket sql.NullString
	var updatedat sql.NullTime
	var updatedby sql.NullString

	err := con.QueryRowContext(ctx, query, iddistribusi).Scan(&distribusi.IdDistribusi, &distribusi.IdDepoAsal, &distribusi.IdDepoTujuan, &distribusi.IdStatus, &distribusi.TanggalPermohonan, &TanggalPengiriman,
		&ket, &distribusi.CreatedAt, &distribusi.CreatedBy, &updatedat, &updatedby)

	if err == sql.ErrNoRows {
		log.Println("Error data distribusi tidak ditemukan", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error data distribusi tidak ditemukan", Data: nil}, err
	}
	if err != nil {
		log.Println("Error saat query data distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data distribusi", Data: nil}, err
	}

	distribusi.TanggalPengiriman = toPtrTime(TanggalPengiriman)
	distribusi.Keterangan = toPtrString(ket)
	distribusi.UpdatedAt = toPtrTime(updatedat)
	distribusi.UpdatedBy = toPtrString(updatedby)

	querydepo := `SELECT nama FROM Depo WHERE id_depo = ?`

	err = con.QueryRowContext(ctx, querydepo, distribusi.IdDepoAsal).Scan(&distribusi.IdDepoAsal)
	err = con.QueryRowContext(ctx, querydepo, distribusi.IdDepoTujuan).Scan(&distribusi.IdDepoTujuan)

	querykaryawan := `SELECT nama From Karyawan WHERE id_karyawan = ? `
	err = con.QueryRowContext(ctx, querykaryawan, distribusi.CreatedBy).Scan(&distribusi.CreatedBy)
	err = con.QueryRowContext(ctx, querykaryawan, distribusi.UpdatedBy).Scan(&updatedby)

	querydetail := `SELECT id_detail_distribusi , id_distribusi, id_kartustok, jumlah_diminta, jumlah_dikirim, created_at, created_by ,updated_at, updated_by, catatan_apotik, catatan_gudang FROM detail_distribusi WHERE id_distribusi = ? AND deleted_at IS NULL`
	rows, err := con.QueryContext(ctx, querydetail, iddistribusi)
	if err != nil {
		log.Println("Error saat mengambil data detail distribusi obat", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data transaksi", Data: nil}, err
	}
	defer rows.Close()

	var detail []class.DetailDistribusi

	for rows.Next() {

		var det class.DetailDistribusi
		var JumlahDikirim sql.NullInt64
		var updatedat sql.NullTime
		var updatedby sql.NullString
		var CatatanApotik, CatatanGudang sql.NullString

		err := rows.Scan(&det.IdDetailDistribusi, &det.IdDistribusi, &det.IdKartustok, &det.JumlahDiminta, &JumlahDikirim,
			&det.CreatedAt, &det.CreatedBy, &updatedat, &updatedby, &CatatanApotik, &CatatanGudang)

		if err != nil {
			log.Println("Error saat scan detail distribusi", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data distribusi", Data: nil}, err
		}

		if JumlahDikirim.Valid {
			val := int(JumlahDikirim.Int64)
			det.JumlahDikirim = &val
		}
		det.UpdatedAt = toPtrTime(updatedat)
		det.UpdatedBy = toPtrString(updatedby)
		det.CatatanApotik = toPtrString(CatatanApotik)
		det.CatatanGudang = toPtrString(CatatanGudang)

		querykaryawan := `SELECT nama From Karyawan WHERE id_karyawan = ? `
		err = con.QueryRowContext(ctx, querykaryawan, det.CreatedBy).Scan(&det.CreatedBy)
		err = con.QueryRowContext(ctx, querykaryawan, det.UpdatedBy).Scan(&updatedby)

		querydetailbatchdistribusi := `SELECT bdd.id_nomor_batch, bdd.jumlah , nb.no_batch, nb.kadaluarsa FROM batch_detail_distribusi bdd JOIN nomor_batch nb ON bdd.id_nomor_batch = nb.id_nomor_batch WHERE bdd.id_detail_distribusi = ?`
		batchrow, err := con.QueryContext(ctx, querydetailbatchdistribusi, det.IdDetailDistribusi)

		if err != nil {
			log.Println("Error saat mengambil data batch dari suatu obat", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data", Data: nil}, err
		}
		for batchrow.Next() {
			var batachdetail class.BatchDetailDistribusi

			err := batchrow.Scan(&batachdetail.IdNomorBatch, &batachdetail.Jumlah, &batachdetail.NoBatch, &batachdetail.Kadaluarsa)
			if err != nil {
				log.Println("Error saat mengambil batch obat", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data", Data: nil}, err
			}
			det.DetailBatch = append(det.DetailBatch, batachdetail)

		}
		batchrow.Close()

		detail = append(detail, det)

	}

	// err = rows.Err()
	// if err != nil {
	// 	log.Println("Error rows", err)
	// 	return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data distribusi", Data: nil}, err
	// }

	// var batchdetail []class.BatchDetailDistribusi

	// for _, batch := range detail {
	// 	querybatchdetail := `SELECT b.id_nomor_batch, b.jumlah, nb.no_batch, nb.kadaluarsa FROM batch_detail_distribusi b JOIN nomor_batch nb ON b.id_nomor_batch = nb.id_nomor_batch WHERE b.id_detail_distribusi = ?`
	// 	rowsbatch, err := con.QueryContext(ctx, querybatchdetail, batch.IdDetailDistribusi)
	// 	if err != nil {
	// 		log.Println("Error saat mengambil data tidap batch obat", err)
	// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	// 	}
	// 	defer rowsbatch.Close()

	// 	for rowsbatch.Next() {
	// 		var detailbatch class.BatchDetailDistribusi
	// 		err := rowsbatch.Scan(&detailbatch.IdNomorBatch, &detailbatch.Jumlah, &detailbatch.NoBatch, &detailbatch.Kadaluarsa)
	// 		if err != nil {
	// 			log.Println("Error saat query per batch yg dialokasikan", err)
	// 			return class.Response{Status: http.StatusInternalServerError, Message: "Errot saar mrmproses data"}, err
	// 		}
	// 		batchdetail = append(batchdetail, detailbatch)
	// 	}

	// 	err = rowsbatch.Err()
	// 	if err != nil {
	// 		log.Print("Error sat [asssmg]")
	// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error data ,e,,menyiapkan datanya"}, err
	// 	}
	// }

	type result struct {
		Distribusi       class.Distribusi         `json:"distribusi"`
		DetailDistribusi []class.DetailDistribusi `json:"detail_distribusi"`
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: result{Distribusi: distribusi, DetailDistribusi: detail}}, nil

}

func moveOutDistribusi(
	tx *sql.Tx,
	kasir, idKartu, iddistribusi, iddepo string,
	b class.AlokasiBatch, kuantitas int,
) error {

	if kuantitas <= 0 {
		return fmt.Errorf("kuantitas harus > 0")
	}
	if kuantitas > b.Sisa {
		return fmt.Errorf("qty %d melebihi sisa %d pada batch %s", kuantitas, b.Sisa, b.IDNomorBatch)
	}

	var stokkartustok int
	query := `SELECT stok_barang FROM kartu_stok Where id_kartustok = ? AND id_depo = ?`
	err := tx.QueryRow(query, idKartu, iddepo).Scan(&stokkartustok)
	if err != nil {
		return fmt.Errorf("gagal ambil stok di kartustok : %w", err)
	}
	if kuantitas > stokkartustok {
		return fmt.Errorf("qty %d melebihi stok %d pada kartu %s", kuantitas, stokkartustok, idKartu)
	}
	newSaldo := stokkartustok - kuantitas

	dksID, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
	if err != nil {
		return err
	}

	_, err = tx.Exec(`
		INSERT INTO detail_kartustok
		  (id_detail_kartu_stok,id_kartustok,
		   id_distribusi,id_batch_penerimaan,id_nomor_batch,
		   masuk,keluar,sisa,created_at,id_depo)
		VALUES (?,?,?,?,? ,0,?, ?,NOW(),?)`,
		dksID, idKartu,
		iddistribusi,
		b.IdBatchPenerimaan,
		b.IDNomorBatch,
		kuantitas, newSaldo, iddepo)
	if err != nil {
		return err
	}

	_, err = tx.Exec(`
		UPDATE kartu_stok
		   SET stok_barang = ?, updated_at = NOW(), updated_by = ?
		 WHERE id_kartustok = ? AND id_depo = ?`,
		newSaldo, kasir, idKartu, iddepo)
	return err
}

func moveInDistribusi(
	tx *sql.Tx,
	kasir, idKartu, iddistribusi, iddepo string,
	b class.AlokasiBatch, kuantitas int,
) error {

	if kuantitas <= 0 {
		return fmt.Errorf("kuantitas harus > 0")
	}
	if kuantitas > b.Sisa {
		return fmt.Errorf("qty %d melebihi sisa %d pada batch %s", kuantitas, b.Sisa, b.IDNomorBatch)
	}

	var stokkartustok int
	query := `SELECT stok_barang FROM kartu_stok Where id_kartustok = ? AND id_depo = ?`
	err := tx.QueryRow(query, idKartu, iddepo).Scan(&stokkartustok)
	if err != nil {
		return fmt.Errorf("gagal ambil stok di kartustok : %w", err)
	}

	newSaldo := stokkartustok + kuantitas

	dksID, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
	if err != nil {
		return err
	}
	_, err = tx.Exec(`
		INSERT INTO detail_kartustok
		  (id_detail_kartu_stok,id_kartustok,
		   id_distribusi,id_batch_penerimaan,id_nomor_batch,
		   masuk,keluar,sisa,created_at,id_depo)
		VALUES (?,?,?,?,?, ?,0, ?,NOW(),?)`,
		dksID, idKartu,
		iddistribusi,
		b.IdBatchPenerimaan,
		b.IDNomorBatch,
		kuantitas, newSaldo, iddepo)
	if err != nil {
		return err
	}

	_, err = tx.Exec(`
		UPDATE kartu_stok
		   SET stok_barang = ?, updated_at = NOW(), updated_by = ?
		 WHERE id_kartustok = ? AND id_depo = ?`,
		newSaldo, kasir, idKartu, iddepo)
	return err
}

func FulfilRequestApotik(ctx context.Context, idkarayawan string, distribusi class.FulfilRequest) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}
	defer tx.Rollback()

	// querydistribusi := `UPDATE distribusi set tanggal_penerimaan = ? , id_status = ? WHERE id_distribusi = ?`

	// querykartustokgudang := `INSERT INTO  `

	const (
		depoGudang       = "10"
		depoApotik       = "20"
		statusOpen       = "0"
		statusComplete   = "1"
		statusIncomplete = "2"
		statusEdited     = "4"
		statusCanceled   = "5"
	)

	var cekstatus string
	var tanggalkirim sql.NullTime
	querycekstatus := `SELECT id_status , tanggal_pengiriman FROM distribusi WHERE id_distribusi = ? FOR UPDATE `
	err = tx.QueryRowContext(ctx, querycekstatus, distribusi.IdDistribusi).Scan(&cekstatus, &tanggalkirim)
	if err != nil {
		log.Println("Error saat mengambil data status distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	}
	if cekstatus != statusOpen && cekstatus != statusCanceled && cekstatus != statusEdited {
		log.Println("distribusi sudah dipenuhi sebelumnya", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Distribusi sudah pernah dipenuhi sebelumnya", Data: nil}, nil
	}
	if cekstatus == statusCanceled {
		log.Println("request sudah dicancel", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Request sudah dibatalkan sebelumnya", Data: nil}, nil
	}

	// totalkirim := 0

	incomplete := false

	for _, obat := range distribusi.ListPemenuhanDistribusi {

		var idobat string
		var jumlahdiminta int

		querydetaildistribusi := `SELECT id_kartustok ,jumlah_diminta FROM detail_distribusi WHERE id_detail_distribusi = ? AND deleted_at IS NULL AND id_distribusi = ? FOR UPDATE `
		err = tx.QueryRowContext(ctx, querydetaildistribusi, obat.IdDetailDistribusi, distribusi.IdDistribusi).Scan(&idobat, &jumlahdiminta)
		if err != nil {
			log.Println("Error saat mengambil detail distribusi ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses transaksi", Data: nil}, err
		}

		if obat.JumlahDikirim < 0 {
			return class.Response{Status: http.StatusBadRequest, Message: "Jumlah barang yang dikirim tidak boleh kurang dari 0 ", Data: nil}, nil
		}
		if obat.JumlahDikirim == 0 {
			incomplete = true
			querystatuskirimkosong := `UPDATE detail_distribusi SET id_status = ?, jumlah_dikirim = 0, catatan_gudang = ? WHERE id_detail_distribusi = ? AND deleted_at IS NULL`
			_, err = tx.ExecContext(ctx, querystatuskirimkosong, statusIncomplete, obat.CatatanGudang, obat.IdDetailDistribusi)
			if err != nil {
				log.Println("Error saat update status saat tidak mengirimkan obat")
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi"}, err
			}
			continue //tidak mengirim apa2 untuk obat ini
		}

		if jumlahdiminta < obat.JumlahDikirim {
			return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("Tidak boleh melebihi jumlah yang diminta untuk obat : %s", idobat)}, err
		}

		_, batch, err := AlocateBatchObat(tx, ctx, idobat, depoGudang, obat.JumlahDikirim)
		if err != nil {
			log.Println("Error saat alokasi batch obat", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses transaksi", Data: nil}, err
		}

		totalalokasi := SumAlokasi(batch)
		if totalalokasi < obat.JumlahDikirim {
			querynamaobat := `SELECT nama_obat FROM obat_jadi WHERE id_obat = ?`
			var namaobat string
			err := tx.QueryRowContext(ctx, querynamaobat, idobat).Scan(&namaobat)
			return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("Stok %s di gudang tidak cukup untuk obat : ", namaobat), Data: nil}, err
		}

		// querydetaildistribusijumlahdikirim := `UPDATE detail_distribusi SET jumlah_dikirim = ? WHERE id_detail_distribusi = ? AND id_distribusi = ?`
		// _, err = tx.ExecContext(ctx, querydetaildistribusijumlahdikirim, obat.JumlahDikirim, obat.IdDetailDistribusi, distribusi.IdDistribusi)
		// if err != nil {
		// 	log.Println("Error saat update jumlah dikirim pada detaik distribusi ", err)
		// 	return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses transaksi", Data: nil}, err
		// }

		// totalkirim += obat.JumlahDikirim

		var idkartustokgudang, idkartustokapotik string

		idkartustokapotik, err = getKartuStokID(tx, idobat, depoApotik)
		if err != nil {
			log.Println("awld;lkadf", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
		}
		idkartustokgudang, err = getKartuStokID(tx, idobat, depoGudang)
		if err != nil {
			log.Println("awld;lkadf", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
		}

		dikirim := 0
		butuhdikirim := obat.JumlahDikirim //mengetahui sisa berapa yg harus dikirim
		for _, perbatch := range batch {

			kuantitas := perbatch.Alokasi //menyimpan jumlah yg dialokasikan dari suatu batch
			if kuantitas <= 0 {
				continue
			}
			if kuantitas <= butuhdikirim { //artinya cek apabila yg dialokasikan lebih kecil dari yg perlu dikirim
				dikirim += kuantitas
				butuhdikirim -= kuantitas //kalau iya maka batch dialokasi tsb dikirimkan semua
			} else { //artinya yg dialokasikan lebih banyak daripada yang dibutuhkan
				kuantitas = butuhdikirim // yg dialokasikan dibatasi dengan yg sisa butuh dikirim
				dikirim += kuantitas
				butuhdikirim -= kuantitas
			}

			err = moveOutDistribusi(tx, idkarayawan, idkartustokgudang, distribusi.IdDistribusi, depoGudang, perbatch, kuantitas)
			if err != nil {
				log.Println("Error saat move out stok dari gudang ke apotik", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses distribusi obat", Data: nil}, err
			}

			err = moveInDistribusi(tx, idkarayawan, idkartustokapotik, distribusi.IdDistribusi, depoApotik, perbatch, kuantitas)
			if err != nil {
				log.Println("Error saat move in stok dari gudang ke apotik", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses distribusi obat", Data: nil}, err
			}

			idbatchdistribusi, err := nextBizID(tx, "batchdetaildistribusicounter", "BDD")
			if err != nil {
				log.Println("Error saat membuat counter untuk batch detail distirbusi", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data distribusi ", Data: nil}, err
			}
			querybatchdetail := `INSERT INTO batch_detail_distribusi (id_batch_detail_distribusi, id_detail_distribusi, id_nomor_batch, jumlah, created_at) 
			VALUES (?,?,?,?, NOW())`

			_, err = tx.ExecContext(ctx, querybatchdetail, idbatchdistribusi, obat.IdDetailDistribusi, perbatch.IDNomorBatch, kuantitas)
			if err != nil {
				log.Println("Error saat insert detail batch dalam distribusi ", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data distribusi", Data: nil}, err
			}

			if butuhdikirim == 0 {
				break
			}

		}

		statustoset := statusComplete
		if dikirim < jumlahdiminta {
			statustoset = statusIncomplete
			incomplete = true
		}

		queryupdatestatus := `UPDATE detail_distribusi SET id_status = ?, jumlah_dikirim = ?, catatan_gudang = ? WHERE id_detail_distribusi = ? AND deleted_at IS NULL `
		_, err = tx.ExecContext(ctx, queryupdatestatus, statustoset, dikirim, obat.CatatanGudang, obat.IdDetailDistribusi)
		if err != nil {
			log.Println("Error saat update status distribusi obat ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data"}, err
		}

	}

	distribusistatus := statusComplete
	if incomplete {
		distribusistatus = statusIncomplete
	}

	queryupdatedistribusi := `UPDATE distribusi SET tanggal_pengiriman = ? , id_status = ? WHERE id_distribusi = ? `
	_, err = tx.ExecContext(ctx, queryupdatedistribusi, distribusi.TanggalPengiriman, distribusistatus, distribusi.IdDistribusi)
	if err != nil {
		log.Println("Error saat update distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menyelesaikan transaksi", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: nil}, nil
}

func CancelRequest(ctx context.Context, idkaryawan, iddistribusi string) (class.Response, error) {

	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}
	defer tx.Rollback()

	const (
		statusOpen     = "0" // belum diproses
		statusCanceled = "5" // dibatalkan
	)

	querycekfulfiled := `SELECT tanggal_pengiriman, id_status FROM distribusi WHERE id_distribusi = ? AND deleted_at IS NULL`
	var curstatus string
	var tanggalkirim sql.NullTime

	err = tx.QueryRowContext(ctx, querycekfulfiled, iddistribusi).Scan(&tanggalkirim, &curstatus)
	if err == sql.ErrNoRows {
		return class.Response{Status: http.StatusBadRequest, Message: "Request tidak ditemukan, mungkin sudah pernah dicancel sebelumnya", Data: nil}, nil
	}
	if err != nil {
		log.Println("Error saat cek status distribusi ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat membatalkan request", Data: nil}, err
	}

	if curstatus != statusOpen || tanggalkirim.Valid {
		return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("Request sudah dipenuhi gudang pada %s, tidak dapat dibatalkan", tanggalkirim.Time.Format("2006-01-02")), Data: nil}, nil
	}

	queryupdatestatusdistribusi := `UPDATE distribusi SET id_status = ?, deleted_at = NOW(), deleted_by = ? WHERE id_distribusi = ?`
	_, err = tx.ExecContext(ctx, queryupdatestatusdistribusi, statusCanceled, idkaryawan, iddistribusi)
	if err != nil {
		log.Println("Error saat update status distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat membatalkan request Apotik", Data: nil}, err
	}

	queryupdatestatusdetaildistribusi := `UPDATE detail_distribusi SET id_status = ?, updated_at = NOW(), updated_by = ? WHERE id_distribusi = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, queryupdatestatusdetaildistribusi, statusCanceled, idkaryawan, iddistribusi)
	if err != nil {
		log.Println("Error saat update detail distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat membatalkan request Apotik", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: nil}, nil
}

func GetRequest(ctx context.Context, page, pagesize int) (class.Response, error) {
	con := db.GetDBCon()
	if page <= 0 { //biar aman aja ini gak bisa masukin aneh2
		page = 1
	}
	if pagesize <= 0 {
		pagesize = 10
	}
	offset := (page - 1) * pagesize
	query := `SELECT id_distribusi, id_depo_asal, id_depo_tujuan, tanggal_permohonan,tanggal_pengiriman, keterangan, created_at, created_by , updated_at, updated_by,id_status FROM distribusi WHERE deleted_at IS NULL ORDER BY id DESC LIMIT ? OFFSET ? `

	rows, err := con.QueryContext(ctx, query, pagesize, offset)
	if err != nil {
		log.Println("Error saat query distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data permintaan", Data: nil}, err
	}
	defer rows.Close()

	var listrequest []class.Distribusi

	for rows.Next() {

		var distribusi class.Distribusi
		var TanggalPengiriman sql.NullTime
		var ket sql.NullString
		var updatedat sql.NullTime
		var updatedby sql.NullString
		var idstatus sql.NullString

		err := rows.Scan(&distribusi.IdDistribusi, &distribusi.IdDepoAsal, &distribusi.IdDepoTujuan, &distribusi.TanggalPermohonan, &TanggalPengiriman, &ket, &distribusi.CreatedAt, &distribusi.CreatedBy, &updatedat, &updatedby, &idstatus)
		if err != nil {
			log.Println("Error saat scan data distribusi", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data permintaan", Data: nil}, err

		}

		distribusi.TanggalPengiriman = toPtrTime(TanggalPengiriman)
		distribusi.Keterangan = toPtrString(ket)
		distribusi.UpdatedAt = toPtrTime(updatedat)
		distribusi.UpdatedBy = toPtrString(updatedby)
		distribusi.IdStatus = toPtrString(idstatus)

		listrequest = append(listrequest, distribusi)

	}

	err = rows.Err()
	if err != nil {
		log.Println("rows error get all requet", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil data permintaan", Data: nil}, err
	}

	var totalrecord int
	countrecordquery := `SELECT COUNT(*) FROM distribusi WHERE deleted_at IS NULL`
	err = con.QueryRowContext(ctx, countrecordquery).Scan(&totalrecord)

	if err != nil {
		log.Println("error total record distribusi ")
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data request"}, nil
	}

	totalpage := (totalrecord + pagesize - 1) / pagesize //bisa juga pakai total/pagesize tp kan nanti perlu di bulatkan keatas pakai package math dimana dia perlu type floating point yg membuat performa hitung lebih lambat

	metadata := class.Metadata{
		CurrentPage:  page,
		PageSize:     pagesize,
		TotalPages:   totalpage,
		TotalRecords: totalrecord,
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: listrequest, Metadata: metadata}, nil

}

func EditRequest(ctx context.Context, iddistribusi, idkaryawan string, obj []class.RequestBarangObat) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}
	defer tx.Rollback()

	const (
		statusOpen = "0"
	)

	querycekfulfiled := `SELECT tanggal_pengiriman, id_status FROM distribusi WHERE id_distribusi = ? AND deleted_at IS NULL`
	var curstatus string
	var tanggalkirim sql.NullTime

	err = tx.QueryRowContext(ctx, querycekfulfiled, iddistribusi).Scan(&tanggalkirim, &curstatus)
	if err == sql.ErrNoRows {
		return class.Response{Status: http.StatusBadRequest, Message: "Request tidak ditemukan, mungkin sudah pernah dicancel sebelumnya", Data: nil}, nil
	}
	if err != nil {
		log.Println("Error saat cek status distribusi ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat edit request", Data: nil}, err
	}

	if curstatus != statusOpen || tanggalkirim.Valid {
		return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("Request sudah dipenuhi gudang pada %s, tidak dapat diubah", tanggalkirim.Time.Format("2006-01-02")), Data: nil}, nil
	}

	queryupdatedistribusi := `UPDATE distribusi SET updated_at = NOW(), updated_by = ? WHERE id_distribusi = ? `
	_, err = tx.ExecContext(ctx, queryupdatedistribusi, idkaryawan, iddistribusi)
	if err != nil {
		log.Println("Error saat update distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat Edit Request", Data: nil}, err
	}

	querydeleteolddetaildistribusi := `UPDATE detail_distribusi SET deleted_at = NOW(), deleted_by = ? WHERE id_distribusi = ? `
	_, err = tx.ExecContext(ctx, querydeleteolddetaildistribusi, idkaryawan, iddistribusi)
	if err != nil {
		log.Println("Error saat soft delete detail distribusi ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat Edit Requset", Data: nil}, err
	}

	queryinsertdetaildistribusi := `INSERT INTO detail_distribusi (id_detail_distribusi, id_distribusi, id_kartustok, jumlah_diminta, created_at ,created_by, updated_at, updated_by,catatan_apotik, id_status,jumlah_dikirim) VALUES (?,?,?,?,NOW(),'sysedit',NOW(),?,?,?,0)`

	for _, obat := range obj {

		newiddetail, err := nextBizID(tx, "detaildistribusicounter", "DDIS")
		if err != nil {
			log.Println("Error saat generate id baru untuk detail distribusi", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat Edit Request", Data: nil}, err
		}

		_, err = tx.ExecContext(ctx, queryinsertdetaildistribusi, newiddetail, iddistribusi, obat.IDObat, obat.JumlahDiminta, idkaryawan, obat.CatatanApotik, statusOpen)
		if err != nil {
			log.Println("Error saat insert data detail distribusi baru", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat Edit Request", Data: nil}, err
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: nil}, nil

}

var (
	errBatchUnknown = errors.New("nomor batch tidak dikenali di depo asal")
)

func latestSaldo(tx *sql.Tx, idkartustok, idnomorbatch, iddepo string) (int, error) {

	query := `WITH latest AS (SELECT sisa, ROW_NUMBER() OVER (ORDER BY id DESC) rn 
	FROM detail_kartustok WHERE id_kartustok = ? AND id_nomor_batch = ? AND id_depo = ? )
	SELECT sisa FROM latest WHERE rn = 1`

	var saldo int

	err := tx.QueryRow(query, idkartustok, idnomorbatch, iddepo).Scan(&saldo)
	if err == sql.ErrNoRows {
		return 0, errBatchUnknown
	}

	if err != nil {
		return 0, err
	}
	return saldo, nil

}

const (
	depoRetur = "99"
)

func makessurekartustokexist(tx *sql.Tx, idkartusok, idobat string, created_by string) error {

	querycek := `SELECT 1 FROM kartu_stok WHERE id_kartustok = ? AND id_depo = ? LIMIT 1`
	var cek int
	err := tx.QueryRow(querycek, idkartusok, depoRetur).Scan(&cek)
	if err == nil {
		return nil //artinya kartustok ada untuk obat ini ada di depo ini.
	} else if err != sql.ErrNoRows {
		return err
	}

	queryinsert := `INSERT INTO kartu_stok (id_depo, id_obat,id_kartustok,stok_barang, created_at, created_by)
	VALUES(?,?,?,?,NOW(),?)`

	_, err = tx.Exec(queryinsert, depoRetur, idkartusok, idkartusok, 0, created_by)
	if err != nil {
		log.Println("Error insert into kartu stok pada func makesurekartustokexist", err)
		return err

	}

	return err
}

func returStokMovementIn(tx *sql.Tx, idkartu, iddepo, idbatch, idretur, idbatchpenerimaan string, masuk, keluar, saldoakhir int) error {
	iddetailkartustok, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
	if err != nil {
		log.Println("Error saat generate id detail karustok pada func returStokMovementIn", err)
		return err
	}

	query := `INSERT INTO detail_kartustok (id_detail_kartu_stok, id_kartustok, id_retur, id_depo,id_batch_penerimaan, id_nomor_batch, masuk, keluar, sisa, created_at)
	VALUES (?,?,?,?,?,?,?,?,?,NOW())`

	_, err = tx.Exec(query, iddetailkartustok, idkartu, idretur, iddepo, idbatchpenerimaan, idbatch, masuk, keluar, saldoakhir)
	if err != nil {
		log.Println("Error saat insert detail kartu stok pada fuction returStokMovementIn", err)
		return err
	}
	return err
}

func getIDPembelianPenerimaan(tx *sql.Tx, idkartustok, idnomorbatch, depo string) (string, error) {
	var id string
	query := `SELECT id_batch_penerimaan FROM detail_kartustok WHERE id_kartustok = ? AND id_nomor_batch = ? AND id_depo = ? ORDER BY id DESC LIMIT 1`
	err := tx.QueryRow(query, idkartustok, idnomorbatch, depo).Scan(&id)
	if err != nil {
		log.Println("Error saat get id batch penerimaan di dalam function getIDPembelianPenerimaan", err)
		return "", fmt.Errorf("no batch_penerimaan for %s/%s@%s", idkartustok, idnomorbatch, depo)
	}
	return id, err
}

func ReturObatApotik(ctx context.Context, idkaryawan string, retur class.ReturBarang) (class.Response, error) {

	const (
		depoRetur = "99"
	)

	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}
	defer tx.Rollback()

	if len(retur.Items) == 0 {
		log.Println("Obat Request retur kosong", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Payload Kosong"}, nil
	}

	idretur, err := nextBizID(tx, "retur_barangcounter", "RTR")
	if err != nil {
		log.Println("Error saat generate id retur barang", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
	}

	queryreturbarang := `INSERT INTO retur_barang (id_retur, id_depo,tanggal_retur, tujuan_retur, catatan , created_at, created_by ) 
	VALUES (?,?,?,?,?,NOW(),?)`
	returdate, err := time.Parse("2006-01-02", retur.TanggalRetur)
	if err != nil {
		log.Println("Error saat parsing retur date", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Format Tanggal Retur Invalid"}, err
	}
	_, err = tx.ExecContext(ctx, queryreturbarang, idretur, retur.IDDepo, returdate, retur.TujuanRetur, retur.Catatan, idkaryawan)
	if err != nil {
		log.Println("Error saat insert retur barang", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
	}

	for _, obat := range retur.Items {
		if len(obat.Batch) == 0 {
			return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("obat %s tidak punya batch", obat.IDKartuStok)}, nil
		}

		iddetailreturobat, err := nextBizID(tx, "detail_retur_barangcounter", "DRB")
		if err != nil {
			log.Println("Error saat generate id detail retur barang", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
		}

		totalkuantitas := 0

		querydetailreturobat := `INSERT INTO detail_retur_barang (id_detail_retur_barang, id_retur, id_kartustok, total_qty, catatan, created_at, created_by)
		VALUES (?,?,?,?,?,NOW(),?)`

		_, err = tx.ExecContext(ctx, querydetailreturobat, iddetailreturobat, idretur, obat.IDKartuStok, 0, obat.Catatan, idkaryawan)
		if err != nil {
			log.Println("Error saat insert detail retur barang", err)
			log.Println("IDkartustok : ", obat.IDKartuStok)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
		}

		for _, batch := range obat.Batch {

			if batch.Kuantitas <= 0 {
				return class.Response{Status: http.StatusBadRequest, Message: "Kuantitas harus > 0"}, nil
			}

			saldosistem, err := latestSaldo(tx, obat.IDKartuStok, batch.IDNomorBatch, retur.IDDepo)
			if err == errBatchUnknown {
				fmt.Sprintf("ERROR batch %s bukan milik depo %s",
					batch.IDNomorBatch, retur.IDDepo)
				return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("batch %s bukan milik depo %s",
					batch.IDNomorBatch, retur.IDDepo)}, nil
			} else if err != nil {
				log.Println("Error pada function latestSaldo", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			if batch.Kuantitas > saldosistem {
				return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("stok batch %s hanya %d, tidak cukup",
					batch.IDNomorBatch, saldosistem)}, nil
			}

			idbatchretur, err := nextBizID(tx, "batch_retur_barangcounter", "BRB")
			if err != nil {
				log.Println("Error saat generate id batch retur barang ", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat generate id batch retur barang"}, err
			}

			querybatchretur := `INSERT INTO batch_retur_barang (id_batch_retur_barang, id_detail_retur_barang, id_nomor_batch, qty, catatan,created_at, created_by)
			VALUES (?,?,?,?,?,NOW(),?)`

			_, err = tx.ExecContext(ctx, querybatchretur, idbatchretur, iddetailreturobat, batch.IDNomorBatch, batch.Kuantitas, batch.Catatan, idkaryawan)
			if err != nil {
				log.Println("Error saat inset batch retur barang", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			idbatchpenerimaan, err := getIDPembelianPenerimaan(tx, obat.IDKartuStok, batch.IDNomorBatch, retur.IDDepo)
			if err != nil {
				log.Println("Error saat memanggil getIDPembelianPenerimaan", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			newsaldodepoasal := saldosistem - batch.Kuantitas //movement barang keluar dari depo asal
			err = returStokMovementIn(tx, obat.IDKartuStok, retur.IDDepo, batch.IDNomorBatch, idretur, idbatchpenerimaan, 0, batch.Kuantitas, newsaldodepoasal)
			if err != nil {
				log.Println("Error saat function retur stok movement out ", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			queryupdatekartustok := `UPDATE kartu_stok SET stok_barang = ?, updated_at = NOW(), updated_by = ? WHERE id_kartustok = ? AND id_depo = ?`
			_, err = tx.ExecContext(ctx, queryupdatekartustok, newsaldodepoasal, idkaryawan, obat.IDKartuStok, retur.IDDepo)
			if err != nil {
				log.Println("Error saat update kartu stok", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			err = makessurekartustokexist(tx, obat.IDKartuStok, obat.IDKartuStok, idkaryawan)
			if err != nil {
				log.Println("Error makesurekartustokexist di retur model", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			//stok retur masuk ke depo 99
			saldoBaru, err := latestSaldo(tx, obat.IDKartuStok, batch.IDNomorBatch, depoRetur)
			if err == errBatchUnknown {
				saldoBaru = 0
			} else if err != nil {
				log.Println("Error pada function latestSaldo", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			newsaldoretur := saldoBaru + batch.Kuantitas

			err = returStokMovementIn(tx, obat.IDKartuStok, depoRetur, batch.IDNomorBatch, idretur, idbatchpenerimaan, batch.Kuantitas, 0, newsaldoretur)
			if err != nil {
				log.Println("Error saat call returstokmovement in di newsaldoretur", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}

			_, err = tx.ExecContext(ctx, queryupdatekartustok, newsaldoretur, idkaryawan, obat.IDKartuStok, depoRetur)
			if err != nil {
				log.Println("Error saat update kartustok untuk depo retur", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
			}
			totalkuantitas += batch.Kuantitas

		}

		querydetailretur := `UPDATE detail_retur_barang SET total_qty = ? WHERE id_detail_retur_barang = ?`
		_, err = tx.ExecContext(ctx, querydetailretur, totalkuantitas, iddetailreturobat)
		if err != nil {
			log.Println("Error saat update detail retur barang untuk set total kuantitas", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data Retur Barang"}, err
		}

	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: nil}, nil

}

func GetAllRetur(iddepo string, page, pagesize int) (class.Response, error) {

	con := db.GetDBCon()

	if page <= 0 { //biar aman aja ini gak bisa masukin aneh2
		page = 1
	}
	if pagesize <= 0 {
		pagesize = 10
	}
	offset := (page - 1) * pagesize
	queryreturbarang := `SELECT r.id_retur, r.id_depo, d.nama AS nama_depo, r.tanggal_retur, r.tujuan_retur, r.catatan, r.created_at, k.nama AS created_by 
	FROM retur_barang r JOIN Depo d ON d.id_depo = r.id_depo
	JOIN Karyawan k ON k.id_karyawan = r.created_by
	WHERE r.id_depo = ?
	ORDER BY r.created_at DESC 
	LIMIT ? OFFSET ? `
	// queryreturbarang := `SELECT
	// FROM retur_barang r JOIN Depo d ON d.id_depo = r.id_depo
	// JOIN Karyawan k ON k.id_karyawan = r.created_by
	// ORDER BY r.created_at DESC`

	rows, err := con.Query(queryreturbarang, iddepo, pagesize, offset)
	if err != nil {
		log.Println("Error saat query all retur", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil semua data Retur"}, err
	}
	defer rows.Close()

	var list []class.ReturBarangData
	for rows.Next() {
		var data class.ReturBarangData
		var catatan sql.NullString

		err := rows.Scan(&data.IDRetur, &data.IDDepo, &data.NamaDepo, &data.TanggalRetur, &data.TujuanRetur, &catatan, &data.Created_at, &data.CreatedBy)
		if err != nil {
			log.Println("Error saat scan rows query all retur", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil semua data Retur"}, err
		}
		if catatan.Valid {
			data.Catatan = &catatan.String
		}
		list = append(list, data)
	}

	err = rows.Err()
	if err != nil {
		log.Println("Ada Error pada rows get all retur", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil semua data Retur"}, err
	}
	if list == nil {
		list = []class.ReturBarangData{}
	}

	var totalrecord int
	countrecordquery := `SELECT COUNT(*) FROM retur_barang`
	err = con.QueryRow(countrecordquery).Scan(&totalrecord)

	if err != nil {
		log.Println("gagal menghitung jumlah entry table retur barang , pada query di model distribusi")
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal menghitung jumlah record retur"}, nil
	}

	totalpage := (totalrecord + pagesize - 1) / pagesize //bisa juga pakai total/pagesize tp kan nanti perlu di bulatkan keatas pakai package math dimana dia perlu type floating point yg membuat performa hitung lebih lambat

	metadata := class.Metadata{
		CurrentPage:  page,
		PageSize:     pagesize,
		TotalPages:   totalpage,
		TotalRecords: totalrecord,
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: list, Metadata: metadata}, nil

}

func GetDetailRetur(idretur string) (class.Response, error) {

	con := db.GetDBCon()
	queryreturbarang := `SELECT r.id_retur, r.id_depo, d.nama AS nama_depo, r.tanggal_retur, r.tujuan_retur, r.catatan, r.created_at, k.nama AS created_by 
	FROM retur_barang r JOIN Depo d ON d.id_depo = r.id_depo
	JOIN Karyawan k ON k.id_karyawan = r.created_by
	WHERE r.id_retur = ?`

	var header class.ReturBarangData
	var catatan sql.NullString
	var tanggalretur sql.NullTime
	err := con.QueryRow(queryreturbarang, idretur).Scan(&header.IDRetur, &header.IDDepo, &header.NamaDepo, &tanggalretur, &header.TujuanRetur, &catatan, &header.Created_at, &header.CreatedBy)
	if err == sql.ErrNoRows {
		return class.Response{Status: http.StatusBadRequest, Message: "Data Detail Retur tidak ditemukan"}, err
	}
	if err != nil {
		log.Println("Error saat query header retur barang", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Retur "}, err
	}
	if catatan.Valid {
		header.Catatan = &catatan.String
	}
	if tanggalretur.Valid {
		header.TanggalRetur = tanggalretur.Time.Format("2006-01-02")
	}

	querydetailretur := `SELECT id_detail_retur_barang, id_kartustok,total_qty, catatan 
	FROM detail_retur_barang WHERE id_retur = ?`
	rows, err := con.Query(querydetailretur, idretur)
	if err != nil {
		log.Println("Error saat query detail retur barang", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambild data Detail Retur"}, err
	}
	defer rows.Close()

	mapobat := make(map[string]*class.ReturBarangDetail)
	var list []class.ReturBarangDetail

	for rows.Next() {
		var obat class.ReturBarangDetail
		var catatan sql.NullString
		err := rows.Scan(&obat.IDDetailReturBarang, &obat.IDKartuStok, &obat.TotalKuantitas, &catatan)
		if err != nil {
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambild data Detail Retur"}, err
		}
		if catatan.Valid {
			obat.Catatan = &catatan.String
		}
		obat.Batch = make([]class.ReturBarangObatBatch, 0)
		mapobat[obat.IDDetailReturBarang] = &obat
		list = append(list, obat)

	}
	err = rows.Err()
	if err != nil {
		log.Println("Ada Error pada rows obat pada  get detail retur", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Retur"}, err
	}

	if len(list) > 0 {

		var iddetailretur []interface{}

		for _, obj := range list {
			iddetailretur = append(iddetailretur, obj.IDDetailReturBarang)
		}

		placeholder := make([]string, len(iddetailretur))
		for i := range iddetailretur {
			placeholder[i] = "?"
		}

		querybatch := fmt.Sprintf(`SELECT b.id_detail_retur_barang, b.id_nomor_batch, b.qty, b.catatan, nb.kadaluarsa, nb.no_batch FROM batch_retur_barang b 
		JOIN nomor_batch nb ON nb.id_nomor_batch = b.id_nomor_batch
		WHERE b.id_detail_retur_barang IN (%s)`, strings.Join(placeholder, ","))

		batchrows, err := con.Query(querybatch, iddetailretur...)

		if err != nil {
			log.Println("Error saat query batch obat", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Retur"}, err
		}
		defer batchrows.Close()

		for batchrows.Next() {
			var iddetail string
			var batch class.ReturBarangObatBatch
			var catatan sql.NullString
			var kadaluarsa sql.NullTime

			err := batchrows.Scan(&iddetail, &batch.IDNomorBatch, &batch.Kuantitas, &catatan, &kadaluarsa, &batch.NomorBatch)
			if err != nil {
				log.Println("Error saat scan batchrows ", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Retur"}, err
			}

			if catatan.Valid {
				batch.Catatan = &catatan.String
			}
			if kadaluarsa.Valid {
				batch.Kadaluarsa = kadaluarsa.Time.Format("2006-01-02")
			}

			obat, ok := mapobat[iddetail]
			if ok {
				obat.Batch = append(obat.Batch, batch)
			}
		}

		err = batchrows.Err()
		if err != nil {
			log.Println("Ada Error pada rows batch pada  get detail retur", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Retur"}, err
		}
	}

	out := make([]class.ReturBarangDetail, 0, len(mapobat))
	for _, ptr := range mapobat {
		out = append(out, *ptr)
	}

	result := class.AllReturBarangData{
		Alldata: header,
		Items:   out,
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: result}, nil
}
