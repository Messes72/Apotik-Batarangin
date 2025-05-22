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

func AlocateBatchObat(ctx context.Context, idobat, iddepo string, quantitas int) (class.Response, []class.AlokasiBatch, error) {

	con := db.GetDBCon()

	querylatestentryperbatch := ` 
		WITH latest AS (
    SELECT dk.id_batch_penerimaan,
           dk.id_nomor_batch,
           dk.sisa,
           ROW_NUMBER() OVER (PARTITION BY dk.id_nomor_batch
                              ORDER BY dk.id DESC) AS rn
    FROM detail_kartustok dk
    WHERE dk.id_kartustok = ?   
      AND dk.id_depo      = ?
)
SELECT l.id_batch_penerimaan,
       l.id_nomor_batch,
       nb.no_batch,
       nb.kadaluarsa,
       l.sisa
  FROM latest l
  JOIN nomor_batch nb ON nb.id_nomor_batch = l.id_nomor_batch
 WHERE l.rn = 1
   AND l.sisa > 0
 ORDER BY nb.kadaluarsa ASC;
`
	// querylatestentryperbatch := `WITH latest AS (SELECT dk.id_batch_penerimaan , dk.id_nomor_batch, dk.sisa,
	// ROW_NUMBER() OVER (PARTITION BY dk. id_batch_penerimaan ORDER BY dk.id DESC) AS rn FROM detail_kartustok dk WHERE id_kartustok = ?)
	// SELECT l.id_batch_penerimaan, l.id_nomor_batch, nb.no_batch, nb.kadaluarsa, l.sisa FROM latest l JOIN nomor_batch nb ON nb.id_nomor_batch = l.id_nomor_batch
	// WHERE l.rn = 1 AND l.sisa > 0 ORDER BY nb.kadaluarsa ASC `

	rows, err := con.QueryContext(ctx, querylatestentryperbatch, idobat, iddepo)
	if err != nil {
		log.Println("Error di rows query get alokasi obat ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, nil, err
	}

	defer rows.Close()

	var alokasi []class.AlokasiBatch
	kebutuhan := quantitas

	for rows.Next() && kebutuhan > 0 {
		var batch class.AlokasiBatch

		err := rows.Scan(&batch.IdBatchPenerimaan, &batch.IDNomorBatch, &batch.NomorBatch, &batch.Kadaluarsa, &batch.Sisa)
		if err != nil {
			log.Println("Error saat scan alokasi batch")
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, nil, err
		}

		if kebutuhan <= 0 {
			break
		}

		ambil := batch.Sisa

		if ambil > kebutuhan {
			ambil = kebutuhan
		}
		batch.Alokasi = ambil
		alokasi = append(alokasi, batch)
		kebutuhan -= ambil

	}

	err = rows.Err()
	if err != nil {
		log.Println("Errors saat loop row", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, nil, err
	}

	if kebutuhan > 0 {
		info := fmt.Sprintf("Stok obat tidak cukup , hanya teralokasi %d dari %d", quantitas-kebutuhan, quantitas)
		log.Println(info)
		return class.Response{Status: http.StatusBadRequest, Message: info, Data: alokasi}, alokasi, nil
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: alokasi}, alokasi, nil

}

func AlokasiMassalObat(ctx context.Context, request []class.RequestAlokasi) (class.Response, error) {

	var hasil []class.AlokasiObatResult
	iddepo := "20"
	for _, obat := range request {
		resp, result, err := AlocateBatchObat(ctx, obat.IDObat, iddepo, obat.Kuantitas)
		if err != nil {
			log.Println("Error di function alokasi batch per obat ", err)
			return class.Response{Status: resp.Status, Message: resp.Message}, err
		}

		if resp.Status != http.StatusOK {
			return class.Response{Status: resp.Status, Message: resp.Message, Data: result}, nil

		}

		hasil = append(hasil, class.AlokasiObatResult{IDObat: obat.IDObat, Listbatchteralokasikan: result})

	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: hasil}, nil
}

func SumAlokasi(list []class.AlokasiBatch) int { //itung jumlah barang dalam alokasi suatu obat
	total := 0
	for _, x := range list {
		total += x.Alokasi
	}
	return total
}

func GetHargaJual(ctx context.Context, idObat string) (float64, error) {
	var h float64
	err := db.GetDBCon().QueryRowContext(ctx,
		`SELECT harga_jual FROM obat_jadi WHERE id_obat = ?`, idObat).
		Scan(&h)
	return h, err
}

// kartu stok lookup
func getKartuStokID(tx *sql.Tx, idObat, iddepo string) (string, error) {
	var id string
	err := tx.QueryRow(`
        SELECT id_kartustok
          FROM kartu_stok
         WHERE id_obat = ? AND id_depo = ?`,
		idObat, iddepo).Scan(&id)
	return id, err
}

func nextBizID(tx *sql.Tx, tbl, prefix string) (string, error) {
	var cnt int
	if err := tx.QueryRow(`SELECT count FROM ` + tbl + ` FOR UPDATE`).Scan(&cnt); err != nil {
		return "", err
	}
	newCnt := cnt + 1
	if _, err := tx.Exec(`UPDATE `+tbl+` SET count = ?`, newCnt); err != nil {
		return "", err
	}
	return fmt.Sprintf("%s%d", prefix, newCnt), nil
}

func moveOut(
	tx *sql.Tx,
	kasir, idKartu, trxID, iddepo string,
	b class.AlokasiBatch, kuantitas int,
) error {

	if kuantitas <= 0 {
		return fmt.Errorf("kuantitas harus > 0")
	}
	if kuantitas > b.Sisa {
		return fmt.Errorf("qty %d melebihi sisa %d pada batch %s", kuantitas, b.Sisa, b.IDNomorBatch)
	}
	dksID, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
	if err != nil {
		return err
	}

	newSaldo := b.Sisa - b.Alokasi

	_, err = tx.Exec(`
		INSERT INTO detail_kartustok
		  (id_detail_kartu_stok,id_kartustok,
		   id_transaksi,id_batch_penerimaan,id_nomor_batch,
		   masuk,keluar,sisa,created_at,id_depo)
		VALUES (?,?,?,?,?,0,?, ?,NOW(),?)`,
		dksID, idKartu,
		trxID,
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

func TransaksiPenjualanObat(ctx context.Context, idkaryawan string, listobat []class.PenjualanObat, bayar class.MetodeBayar, idkustomer *string) (class.Response, error) {

	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}

	var counter int
	queryCounter := `SELECT count FROM transaksicounter FOR UPDATE`
	err = tx.QueryRowContext(ctx, queryCounter).Scan(&counter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to fetch counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch transaksi counter", Data: nil}, err
	}

	newCounter := counter + 1
	prefix2 := "TRX"
	newidtransaksi := fmt.Sprintf("%s%d", prefix2, newCounter)

	updateCounter := `UPDATE transaksicounter SET count = ?`
	_, err = tx.ExecContext(ctx, updateCounter, newCounter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to update transaksi counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
	}

	const (
		statusberhasil = 1
		statuscancel   = 2
	)
	log.Println("IDkaryawan ; ", idkaryawan)

	querytransaksi := `INSERT INTO transaksi (id_transaksi, id_karyawan, total_harga, metode_pembayaran,id_status, created_at, id_kustomer) VALUES (?,?,0,?,?,NOW(),?)`
	_, err = tx.ExecContext(ctx, querytransaksi, newidtransaksi, idkaryawan, bayar.MetodeBayar, statuscancel, idkustomer)
	if err != nil {
		tx.Rollback()
		log.Println("Error saat insert transaksi dengan status masih cancel", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
	}

	grandtotal := 0.0
	iddepo := "20"
	for _, obat := range listobat {
		_, batchs, err := AlocateBatchObat(ctx, obat.IDObat, iddepo, obat.Kuantitas)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat call alocatebatchobat di looping", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data alokasi batch", Data: nil}, err
		}

		if SumAlokasi(batchs) < obat.Kuantitas {
			tx.Rollback()
			log.Printf("Stok %s tidak cukup", obat.IDObat)
			return class.Response{Status: http.StatusInternalServerError, Message: fmt.Sprintf("Stok %s tidak cukup", obat.IDObat), Data: nil}, err
		}

		harga, err := GetHargaJual(ctx, obat.IDObat)
		if err != nil {
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		idAtp, err := nextBizID(tx, "aturanpakaicounter", "ATP")
		if err != nil {
			tx.Rollback()
			log.Println("error saat counter arutanpakai")
		}

		idKrp, err := nextBizID(tx, "keteranganpakaicounter", "KRP")
		if err != nil {
			tx.Rollback()
			log.Println("error saat counter keteranganpakai")
		}

		idCrp, err := nextBizID(tx, "carapakaicounter", "CRP")
		if err != nil {
			tx.Rollback()
			log.Println("error saat counter carapakai")
		}

		iddetailtransaksi, err := nextBizID(tx, "detail_transaksi_penjualan_obatcounter", "DDTP")
		if err != nil {
			tx.Rollback()
			log.Println("error saat counter detail transaksi")
		}

		queryaturanpakai := `INSERT INTO aturan_pakai (id_aturan_pakai, aturan_pakai, created_at) VALUES (?,?, NOW())`

		_, err = tx.ExecContext(ctx, queryaturanpakai, idAtp, obat.AturanPakai)
		if err != nil {
			log.Println("Error saat insert aturan pakai", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat input aturan pakai"}, err
		}

		querycarapakai := `INSERT INTO cara_pakai (id_cara_pakai, nama_cara_pakai, created_at) VALUES (?,?, NOW())`

		_, err = tx.ExecContext(ctx, querycarapakai, idCrp, obat.CaraPakai)
		if err != nil {
			log.Println("Error saat insert cara pakai", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat input cara pakai"}, err
		}

		queryketeranganpakai := `INSERT INTO keterangan_pakai (id_keterangan_pakai, nama_keterangan_pakai, created_at) VALUES (?,?, NOW())`

		_, err = tx.ExecContext(ctx, queryketeranganpakai, idKrp, obat.KeteranganPakai)
		if err != nil {
			log.Println("Error saat insert keterangan pakai", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat input keterangan pakai"}, err
		}

		idkartu, err := getKartuStokID(tx, obat.IDObat, "20")
		if err != nil {
			tx.Rollback()
			log.Println("Error saat query kartu stok sesuai id depo apotik", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
		}

		totalhargathisobat := harga * float64(obat.Kuantitas)

		grandtotal += totalhargathisobat

		querydetailtransaksi := `INSERT INTO detail_transaksi_penjualan_obat (id_detail_transaksi_penjualan,id_kartustok, id_transaksi, id_aturan_pakai, id_cara_pakai
		, id_keterangan_pakai , total_harga, jumlah ) VALUES (?,?,?,?,?,?,?,?)`

		_, err = tx.ExecContext(ctx, querydetailtransaksi, iddetailtransaksi, idkartu, newidtransaksi, idAtp, idCrp, idKrp, totalhargathisobat, obat.Kuantitas)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat insert detail transaksi", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
		}

		for _, indivudalbatch := range batchs { //loop untuk tiap batch
			idbatchpenjualan, err := nextBizID(tx, "batch_penjualancounter", "BTP")
			if err != nil {
				tx.Rollback()
				log.Println("error saat counter batch penjualan")
			}
			querybatchpenjualan := `INSERT INTO batch_penjualan (id_batch_penjualan, id_detail_transaksi_penjualan, id_nomor_batch , jumlah_dijual, created_At)
			VALUES (?,?,?,?,NOW())`
			_, err = tx.ExecContext(ctx, querybatchpenjualan, idbatchpenjualan, iddetailtransaksi, indivudalbatch.IDNomorBatch, indivudalbatch.Alokasi)
			if err != nil {
				tx.Rollback()
				log.Println("Error saat insert batch penjualan", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi"}, err
			}

			err = moveOut(tx, idkaryawan, idkartu, newidtransaksi, "20", indivudalbatch, indivudalbatch.Alokasi)
			if err != nil {
				tx.Rollback()
				log.Println("Error saat memproses perpindahan stok", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok", Data: nil}, err
			}
		}

	}

	queryfinaltransaksi := `UPDATE transaksi SET total_harga = ?, id_status = ? WHERE id_transaksi = ?`
	_, err = tx.ExecContext(ctx, queryfinaltransaksi, grandtotal, statusberhasil, newidtransaksi)
	if err != nil {
		tx.Rollback()
		log.Println("Error saat finalisasi data transaksi ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: map[string]string{"id_transaksi": newidtransaksi}}, nil

}

func GetStokObat(ctx context.Context, idobat string) (class.Response, error) {
	con := db.GetDBCon()

	query := `SELECT stok_barang FROM kartu_stok WHERE id_kartustok  = ? AND id_depo = '20'`
	var stok class.RequestStokBarang
	err := con.QueryRowContext(ctx, query, idobat).Scan(&stok.Stok)

	if err == sql.ErrNoRows {
		log.Println("Obat tidak ditemukan")
		return class.Response{Status: http.StatusInternalServerError, Message: "Obat tidak ditemukan", Data: nil}, err
	}
	if err != nil {
		log.Println("Error saat query stok barang dari kartu stok", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data stok obat", Data: nil}, err
	}

	stok.IDobat = idobat

	return class.Response{Status: http.StatusOK, Message: "Success", Data: stok}, nil
}

func GetTransaksi(ctx context.Context, idtransaksi, idkaryawan string) (class.Response, error) {
	con := db.GetDBCon()

	var get class.TransactionDetail

	querytransaksi := `SELECT t.id_transaksi, t.id_karyawan, k.nama, t.total_harga,t.id_kustomer ,ku.nama, t.metode_pembayaran, t.id_status, t.created_at 
	FROM transaksi t JOIN Karyawan k ON t.id_karyawan = k.id_karyawan LEFT JOIN Kustomer ku ON t.id_kustomer = ku.id_kustomer WHERE id_transaksi = ?`

	err := con.QueryRowContext(ctx, querytransaksi, idtransaksi).Scan(&get.IDTransaksi, &get.KasirID, &get.KasirNama, &get.TotalHarga, &get.KustomerID, &get.KustomerNama, &get.MetodeBayar, &get.Status, &get.CreatedAt)

	if err == sql.ErrNoRows {
		log.Println("Transaksi tidak ditemukan ", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Transaksi tidak ditemukan ", Data: nil}, err
	}

	if err != nil {
		log.Println("Error saat query table transaksi ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Transaksi", Data: nil}, err
	}

	queryperobat := `SELECT d.id_kartustok, o.nama_obat , bp.jumlah_dijual, d.total_harga, nb.no_batch, nb.kadaluarsa, ap.aturan_pakai, cp.nama_cara_pakai, kp.nama_keterangan_pakai
	
	
	FROM detail_transaksi_penjualan_obat d 
	JOIN obat_jadi o ON d.id_kartustok = o.id_obat
	JOIN batch_penjualan bp ON bp.id_detail_transaksi_penjualan = d.id_detail_transaksi_penjualan
	JOIN nomor_batch nb on bp.id_nomor_batch = nb.id_nomor_batch
	LEFT JOIN aturan_pakai ap ON d.id_aturan_pakai = ap.id_aturan_pakai
	LEFT JOIN cara_pakai cp ON d.id_cara_pakai = cp.id_cara_pakai
	LEFT JOIN keterangan_pakai kp ON d.id_keterangan_pakai = kp.id_keterangan_pakai
	WHERE d.id_transaksi = ? ORDER BY d.id`

	rows, err := con.QueryContext(ctx, queryperobat, idtransaksi)
	if err != nil {
		log.Println("Error saat query detail obat dalam suatu transaksi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data obat dalam transaksi ", Data: nil}, err
	}
	defer rows.Close()

	for rows.Next() {
		var obat class.TransaksiItem
		err := rows.Scan(&obat.IDKartustok, &obat.NamaObat, &obat.Jumlah, &obat.Totalharga, &obat.NomorBatch, &obat.Kadaluarsa, &obat.AturanPakai, &obat.CaraPakai, &obat.KeteranganPakai)

		if err != nil {
			log.Println("Error saat scan detail obat dalam transaksi", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data obat dalam transaksi ", Data: nil}, err
		}

		get.Items = append(get.Items, obat)

	}
	err = rows.Err()
	if err != nil {
		log.Println("Error pada row", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data obat dalam transaksi", Data: nil}, err
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: get}, nil

}

func GetHistoryTransaksi(ctx context.Context, page, pagesize int) (class.Response, error) {

	con := db.GetDBCon()

	offset := (page - 1) * pagesize

	querygetall := `SELECT t.id_transaksi, t.created_at, k.nama, t.id_kustomer, ku.nama, t.total_harga, t.metode_pembayaran, t.id_status
	FROM transaksi t JOIN Karyawan k ON t.id_karyawan = k.id_karyawan
	LEFT JOIN Kustomer ku ON t.id_kustomer = ku.id_kustomer ORDER BY t.created_at DESC LIMIT ? OFFSET ? `

	rows, err := con.QueryContext(ctx, querygetall, pagesize, offset)

	if err != nil {
		log.Println("Error saat query all data", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data", Data: nil}, err
	}
	defer rows.Close()

	var listtransaksi []class.TransactionDetail

	for rows.Next() {
		var transaksi class.TransactionDetail
		err := rows.Scan(&transaksi.IDTransaksi, &transaksi.CreatedAt, &transaksi.KasirNama, &transaksi.KustomerID, &transaksi.KustomerNama,
			&transaksi.TotalHarga, &transaksi.MetodeBayar, &transaksi.Status)
		if err != nil {
			log.Println("Error saat scan data transaksi", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data transaksi", Data: nil}, err
		}

		listtransaksi = append(listtransaksi, transaksi)
	}

	err = rows.Err()
	if err != nil {
		log.Println("Error saat scan data", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data transaksi", Data: nil}, err
	}

	var totalrecord int
	countrecordquery := `SELECT COUNT(*) FROM transaksi WHERE deleted_at IS NULL`
	err = con.QueryRowContext(ctx, countrecordquery).Scan(&totalrecord)

	if err != nil {
		log.Println("gagal menghitung jumlah entry table transaksi , pada query di model pos")
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal menghitung jumlah transaksi"}, nil
	}

	totalpage := (totalrecord + pagesize - 1) / pagesize //bisa juga pakai total/pagesize tp kan nanti perlu di bulatkan keatas pakai package math dimana dia perlu type floating point yg membuat performa hitung lebih lambat

	metadata := class.Metadata{
		CurrentPage:  page,
		PageSize:     pagesize,
		TotalPages:   totalpage,
		TotalRecords: totalrecord,
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: listtransaksi, Metadata: metadata}, nil
}
