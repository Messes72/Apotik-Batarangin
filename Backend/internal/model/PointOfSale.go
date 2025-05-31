package internal

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"math"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
	"time"
)

func AlocateBatchObat(tx *sql.Tx, ctx context.Context, idobat, iddepo string, quantitas int) (class.Response, []class.AlokasiBatch, error) {

	// con := db.GetDBCon()

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

	rows, err := tx.QueryContext(ctx, querylatestentryperbatch, idobat, iddepo)
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

	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}
	var hasil []class.AlokasiObatResult
	iddepo := "20"
	for _, obat := range request {
		resp, result, err := AlocateBatchObat(tx, ctx, obat.IDObat, iddepo, obat.Kuantitas)
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

func CalculateObatRacik(ctx context.Context, req class.RequestCalculateHargaRacik) (class.Response, error) {
	var total float64
	var list []class.IngredientDetail

	for _, ing := range req.Ingredients {
		var item class.IngredientDetail
		harga, err := GetHargaJual(ctx, ing.IDObat)
		if err != nil {
			log.Println("Error saat mengambil harga jual", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menghitung harga racik"}, err
		}

		jumlahdipakai := int(math.Ceil(ing.JumlahDecimal * float64(req.Kuantitas)))
		subtotal := float64(jumlahdipakai) * harga
		total += subtotal

		item.IDObat = ing.IDObat
		item.HargaSatuan = harga
		item.JumlahTerpakai = jumlahdipakai
		item.Subtotal = subtotal

		list = append(list, item)

	}
	return class.Response{Status: http.StatusOK, Message: "Suceess", Data: list}, nil

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
	// log.Println("IDkaryawan ; ", idkaryawan)

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

		queryaturanpakai := `INSERT INTO aturan_pakai (id_aturan_pakai, aturan_pakai, created_at) VALUES (?,?, NOW())`

		_, err = tx.ExecContext(ctx, queryaturanpakai, idAtp, obat.AturanPakai)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat insert aturan pakai", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat input aturan pakai"}, err
		}

		querycarapakai := `INSERT INTO cara_pakai (id_cara_pakai, nama_cara_pakai, created_at) VALUES (?,?, NOW())`

		_, err = tx.ExecContext(ctx, querycarapakai, idCrp, obat.CaraPakai)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat insert cara pakai", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat input cara pakai"}, err
		}

		queryketeranganpakai := `INSERT INTO keterangan_pakai (id_keterangan_pakai, nama_keterangan_pakai, created_at) VALUES (?,?, NOW())`

		_, err = tx.ExecContext(ctx, queryketeranganpakai, idKrp, obat.KeteranganPakai)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat insert keterangan pakai", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat input keterangan pakai"}, err
		}

		isracik := len(obat.Ingredients) > 0
		// var (
		// 	idracik                  sql.NullString
		// 	dosis                    sql.NullString
		// 	jumlahracik              sql.NullInt64
		// 	satuandosis, satuanracik sql.NullString
		// )
		if !isracik {
			harga, err := GetHargaJual(ctx, obat.IDObat)
			if err != nil {
				tx.Rollback()
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
			}
			totalhargathisobat := harga * float64(obat.Kuantitas)

			grandtotal += totalhargathisobat

			_, batchs, err := AlocateBatchObat(tx, ctx, obat.IDObat, iddepo, obat.Kuantitas)
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

			idkartu, err := getKartuStokID(tx, obat.IDObat, "20")
			if err != nil {
				tx.Rollback()
				log.Println("Error saat query kartu stok sesuai id depo apotik", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
			}
			iddetailtransaksi, _ := nextBizID(tx, "detail_transaksi_penjualan_obatcounter", "DDTP")
			querydetailtransaksi := `INSERT INTO detail_transaksi_penjualan_obat (id_detail_transaksi_penjualan,id_kartustok, id_transaksi, id_aturan_pakai, id_cara_pakai
			, id_keterangan_pakai , total_harga, jumlah, created_at ) VALUES (?,?,?,?,?,?,?,?,NOW())`

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
			continue
		}

		totalRacik := 0.0
		for _, comp := range obat.Ingredients {

			pu, err := GetHargaJual(ctx, comp.IDObat)
			if err != nil {
				tx.Rollback()
				return class.Response{Status: http.StatusInternalServerError,
					Message: "Error fetching price for ingredient " + comp.IDObat}, err
			}

			unitterpakai := int(math.Ceil(comp.JumlahDecimal * float64(obat.Kuantitas)))
			totalRacik += pu * float64(unitterpakai)
		}
		grandtotal += totalRacik
		masterLineID, _ := nextBizID(tx, "detail_transaksi_penjualan_obatcounter", "DDTP")
		querydetailtransaksi := `INSERT INTO detail_transaksi_penjualan_obat (id_detail_transaksi_penjualan, id_transaksi, id_aturan_pakai, id_cara_pakai
			, id_keterangan_pakai , total_harga, id_obat_racik, jumlah_racik, satuan_racik, created_at ) VALUES (?,?,?,?,?,?,?,?,?,NOW())`

		_, err = tx.ExecContext(ctx, querydetailtransaksi, masterLineID, newidtransaksi, idAtp, idCrp, idKrp, totalRacik, obat.IDObat, obat.Kuantitas, obat.SatuanRacik)
		if err != nil {
			tx.Rollback()
			log.Println("Error saat insert detail transaksi", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
		}

		for _, ing := range obat.Ingredients {
			pakai := int(math.Ceil(ing.JumlahDecimal * float64(obat.Kuantitas)))
			kartuid, err := getKartuStokID(tx, ing.IDObat, "20")
			if err != nil {
				tx.Rollback()
				log.Println("Error sat get karrtu stok id di query ing , range obat.ingredients", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi"}, err
			}
			_, batches, err := AlocateBatchObat(tx, ctx, ing.IDObat, "20", pakai)
			if err != nil {
				tx.Rollback()
				log.Println("Error sat alokasi batch obat ing , range obat.ingredients", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi"}, err
			}

			ingdetailtransaksiid, _ := nextBizID(tx, "detail_transaksi_penjualan_obatcounter", "DDTP")
			querydetailtransaksi2 := `INSERT INTO detail_transaksi_penjualan_obat (id_detail_transaksi_penjualan,id_kartustok, id_transaksi,
				total_harga, jumlah, id_obat_racik,Dosis, jumlah_racik, satuan_racik, qty_decimal, created_at ) VALUES (?,?,?,?,?,?,?,?,?,?,NOW())`

			_, err = tx.ExecContext(ctx, querydetailtransaksi2, ingdetailtransaksiid, kartuid, newidtransaksi, 0.0, pakai, obat.IDObat, ing.Dosis, obat.Kuantitas, obat.SatuanRacik, ing.JumlahDecimal)
			if err != nil {
				tx.Rollback()
				log.Println("Error saat insert detail transaksi 2", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi", Data: nil}, err
			}

			for _, indivudalbatch := range batches { //loop untuk tiap batch
				idbatchpenjualan, err := nextBizID(tx, "batch_penjualancounter", "BTP")
				if err != nil {
					tx.Rollback()
					log.Println("error saat counter batch penjualan")
				}
				querybatchpenjualan := `INSERT INTO batch_penjualan (id_batch_penjualan, id_detail_transaksi_penjualan, id_nomor_batch , jumlah_dijual, created_At)
				VALUES (?,?,?,?,NOW())`
				_, err = tx.ExecContext(ctx, querybatchpenjualan, idbatchpenjualan, ingdetailtransaksiid, indivudalbatch.IDNomorBatch, indivudalbatch.Alokasi)
				if err != nil {
					tx.Rollback()
					log.Println("Error saat insert batch penjualan", err)
					return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data transaksi"}, err
				}

				err = moveOut(tx, idkaryawan, kartuid, newidtransaksi, "20", indivudalbatch, indivudalbatch.Alokasi)
				if err != nil {
					tx.Rollback()
					log.Println("Error saat memproses perpindahan stok", err)
					return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok", Data: nil}, err
				}
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

type BatchUsage struct {
	NoBatch    string `json:"no_batch"`
	UsedQty    int    `json:"used_qty"`
	Kadaluarsa string `json:"kadaluarsa"`
}

// Ingredient represents one component of a racikan
type Ingredient struct {
	ObatID     string       `json:"id_obat"`
	NamaObat   string       `json:"nama_obat"`
	Dosis      *string      `json:"dosis,omitempty"`
	Catatan    *string      `json:"catatan,omitempty"`
	BatchUsage []BatchUsage `json:"batch_usage"`
}
type TransaksiItem struct {
	IDKartustok     string  `json:"id_kartustok"`
	NamaObat        string  `json:"nama_obat"`
	Jumlah          *int    `json:"jumlah,omitempty"`
	Totalharga      float64 `json:"total_harga"`
	NomorBatch      *string `json:"nomor_batch,omitempty"`
	Kadaluarsa      *string `json:"kadaluarsa,omitempty"`
	AturanPakai     *string `json:"aturan_pakai,omitempty"`
	CaraPakai       *string `json:"cara_pakai,omitempty"`
	KeteranganPakai *string `json:"keterangan_pakai,omitempty"`

	// Racik-specific fields
	IsRacikan   bool         `json:"is_racikan,omitempty"`
	DosisRacik  *string      `json:"dosis,omitempty"` // from detail_transaksi_penjualan_obat
	JumlahRacik *int         `json:"jumlah_racik,omitempty"`
	SatuanRacik *string      `json:"satuan_racik,omitempty"`
	Komposisi   []Ingredient `json:"komposisi,omitempty"`
}

// TransactionDetail is the header + all items
type TransactionDetail struct {
	IDTransaksi  string          `json:"id_transaksi"`
	KasirID      string          `json:"id_karyawan"`
	KasirNama    string          `json:"nama_karyawan"`
	KustomerID   *string         `json:"id_kustomer,omitempty"`
	KustomerNama *string         `json:"nama_kustomer,omitempty"`
	TotalHarga   float64         `json:"total_harga"`
	MetodeBayar  string          `json:"metode_bayar"`
	Status       string          `json:"status"`
	CreatedAt    time.Time       `json:"created_at"`
	Items        []TransaksiItem `json:"items"`
}

func GetTransaksi(ctx context.Context, idTransaksi string) (class.Response, error) {
	con := db.GetDBCon()
	var td TransactionDetail

	// 1) Load header
	qHeader := `
	SELECT
	  t.id_transaksi, t.id_karyawan, k.nama,
	  t.id_kustomer, ku.nama,
	  t.total_harga, t.metode_pembayaran, st.nama_status, t.created_at
	FROM transaksi t
	JOIN Karyawan k ON t.id_karyawan = k.id_karyawan
	LEFT JOIN Kustomer ku ON t.id_kustomer = ku.id_kustomer
	JOIN status_transaksi st ON t.id_status = st.id_status
	WHERE t.id_transaksi = ?
	`
	var (
		kID   sql.NullString
		kNama sql.NullString
	)
	if err := con.QueryRowContext(ctx, qHeader, idTransaksi).Scan(
		&td.IDTransaksi,
		&td.KasirID,
		&td.KasirNama,
		&kID,
		&kNama,
		&td.TotalHarga,
		&td.MetodeBayar,
		&td.Status,
		&td.CreatedAt,
	); err != nil {
		if err == sql.ErrNoRows {
			return class.Response{Status: http.StatusBadRequest, Message: "Transaksi tidak ditemukan"}, err
		}
		log.Println("Error loading header:", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil transaksi"}, err
	}
	if kID.Valid {
		td.KustomerID = &kID.String
	}
	if kNama.Valid {
		td.KustomerNama = &kNama.String
	}

	// 2) Load detail
	qItems := `
	SELECT
		d.id_kartustok,
		COALESCE(r.nama_racik, o.nama_obat) AS nama_obat,
		d.jumlah,
		d.total_harga,
		ap.aturan_pakai,
		cp.nama_cara_pakai,
		kp.nama_keterangan_pakai,
		d.id_obat_racik,
		d.dosis,
		d.jumlah_racik,
		d.satuan_racik
	FROM detail_transaksi_penjualan_obat d
	LEFT JOIN obat_jadi o ON d.id_kartustok = o.id_obat
	LEFT JOIN obat_racik r ON d.id_obat_racik = r.id_obat_racik
	LEFT JOIN aturan_pakai ap ON d.id_aturan_pakai = ap.id_aturan_pakai
	LEFT JOIN cara_pakai cp ON d.id_cara_pakai = cp.id_cara_pakai
	LEFT JOIN keterangan_pakai kp ON d.id_keterangan_pakai = kp.id_keterangan_pakai
	WHERE d.id_transaksi = ?
	ORDER BY d.id
	`
	rows, err := con.QueryContext(ctx, qItems, idTransaksi)
	if err != nil {
		log.Println("Error loading detail rows:", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal mengambil detail"}, err
	}
	defer rows.Close()

	currentRacikIdx := -1
	for rows.Next() {
		var (
			rawKartustok sql.NullString
			rawRacikID   sql.NullString

			ti          TransaksiItem
			dbJumlah    sql.NullInt64
			aturanP     sql.NullString
			caraP       sql.NullString
			ketP        sql.NullString
			dosisRacik  sql.NullString
			jumlahRacik sql.NullInt32
			satuanRacik sql.NullString
		)

		if err := rows.Scan(
			&rawKartustok,
			&ti.NamaObat,
			&dbJumlah,
			&ti.Totalharga,
			&aturanP,
			&caraP,
			&ketP,
			&rawRacikID,
			&dosisRacik,
			&jumlahRacik,
			&satuanRacik,
		); err != nil {
			log.Println("Error scanning detail:", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Gagal memproses detail"}, err
		}

		isKartustokEmpty := !rawKartustok.Valid || rawKartustok.String == ""
		isRacikRow := rawRacikID.Valid && rawRacikID.String != ""

		// 2a) Racikan header
		if isKartustokEmpty && isRacikRow {
			ti.IsRacikan = true
			if dosisRacik.Valid {
				ti.DosisRacik = &dosisRacik.String
			}
			if jumlahRacik.Valid {
				v := int(jumlahRacik.Int32)
				ti.JumlahRacik = &v
			}
			if satuanRacik.Valid {
				ti.SatuanRacik = &satuanRacik.String
			}
			td.Items = append(td.Items, ti)
			currentRacikIdx = len(td.Items) - 1
			continue
		}

		// 2b) Komposisi line
		if !isKartustokEmpty && isRacikRow && currentRacikIdx >= 0 {
			master := &td.Items[currentRacikIdx]
			ingID := rawKartustok.String

			var ing = Ingredient{
				ObatID:   ingID,
				NamaObat: ti.NamaObat,
			}

			// Load batch usage
			usageRows, err := con.QueryContext(ctx, `
				SELECT nb.no_batch, dk.keluar, nb.kadaluarsa
				FROM detail_kartustok dk
				LEFT JOIN nomor_batch nb ON dk.id_nomor_batch = nb.id_nomor_batch
				WHERE dk.id_transaksi = ? AND dk.id_kartustok = ? AND dk.keluar > 0 
			`, idTransaksi, ingID)
			if err != nil {
				log.Println("error", err)
			}
			if err == nil {
				for usageRows.Next() {
					var bu BatchUsage
					var kadaluarsa sql.NullTime
					if err := usageRows.Scan(&bu.NoBatch, &bu.UsedQty, &kadaluarsa); err == nil {
						if kadaluarsa.Valid {
							bu.Kadaluarsa = kadaluarsa.Time.Format("2006-01-02")
						}
						ing.BatchUsage = append(ing.BatchUsage, bu)
					}
				}
				usageRows.Close()
			}
			master.Komposisi = append(master.Komposisi, ing)
			continue
		}

		// 2c) Plain obat
		ti.IDKartustok = rawKartustok.String
		if dbJumlah.Valid {
			v := int(dbJumlah.Int64)
			ti.Jumlah = &v
		}
		if aturanP.Valid {
			ti.AturanPakai = &aturanP.String
		}
		if caraP.Valid {
			ti.CaraPakai = &caraP.String
		}
		if ketP.Valid {
			ti.KeteranganPakai = &ketP.String
		}

		td.Items = append(td.Items, ti)
	}

	if err := rows.Err(); err != nil {
		log.Println("Row iteration error:", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Kesalahan iterasi detail"}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: td}, nil
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
