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

	_, err = tx.ExecContext(ctx, querydistribusi, IdDistribusi, "10", "20", "0", distribusi.Keterangan, idkarayawan)
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
			_, err = tx.ExecContext(ctx, querystatuskirimkosong, statusIncomplete, distribusi.CatatanGudang, obat.IdDetailDistribusi)
			if err != nil {
				log.Println("Error saat update status saat tidak mengirimkan obat")
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi"}, err
			}
			continue //tidak mengirim apa2 untuk obat ini
		}

		if jumlahdiminta < obat.JumlahDikirim {
			return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("Tidak boleh melebihi jumlah yang diminta untuk obat : %s", idobat)}, err
		}

		_, batch, err := AlocateBatchObat(ctx, idobat, depoGudang, obat.JumlahDikirim)
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
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
		}
		idkartustokgudang, err = getKartuStokID(tx, idobat, depoGudang)
		if err != nil {
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
		_, err = tx.ExecContext(ctx, queryupdatestatus, statustoset, dikirim, distribusi.CatatanGudang, obat.IdDetailDistribusi)
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
