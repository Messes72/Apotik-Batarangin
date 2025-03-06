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
)

type TableNames struct {
	Obat      string
	KartuStok string
	Counter   string
}

var tableMappings = map[string]TableNames{
	"gudang": {
		Obat:      "obat_gudang",
		KartuStok: "kartu_stok_gudang",
		Counter:   "ObatCounterGudang",
	},
	"apotek": {
		Obat:      "obat_apotik",
		KartuStok: "kartu_stok_apotik",
		Counter:   "ObatCounter",
	},
}

func getTableNames(jenis string) (TableNames, error) {
	tables, ok := tableMappings[jenis]
	if !ok {
		return TableNames{}, errors.New("invalid jenis value")
	}
	return tables, nil
}

func AddObat(ctx context.Context, obat class.Obat, idKategori string, idDepo string, idKaryawan string, jenis string) (class.Response, error) {
	con, err := db.DbConnection()
	if err != nil {
		log.Printf("Failed to connect to the database: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database connection error", Data: nil}, err
	}
	defer db.DbClose(con)

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}

	tables, err := getTableNames(jenis)
	if err != nil {
		return class.Response{Status: http.StatusBadRequest, Message: "Invalid jenis value", Data: nil}, nil
	}

	tableObat := tables.Obat
	tableKartuStok := tables.KartuStok
	tableCounter := tables.Counter

	var exists string
	checkQuery := `SELECT 1 FROM ` + tableObat + ` WHERE LOWER(nama) = ? AND id_depo = ? LIMIT 1`
	err = tx.QueryRowContext(ctx, checkQuery, strings.ToLower(obat.Nama), idDepo).Scan(&exists)
	if err == nil {
		tx.Rollback()
		return class.Response{Status: http.StatusConflict, Message: "Obat sudah ada di depo ini", Data: nil}, nil
	}
	if err != sql.ErrNoRows {
		tx.Rollback()
		log.Println("Error cek existing obat:", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error cek existing obat", Data: nil}, err
	}

	var counter int
	queryCounter := `SELECT count FROM ` + tableCounter + ` FOR UPDATE`
	err = tx.QueryRowContext(ctx, queryCounter).Scan(&counter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to fetch counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
	}

	newCounter := counter + 1
	newIDObat := fmt.Sprintf("MDC%012d", counter)

	updateCounter := `UPDATE ` + tableCounter + ` SET count = ?`
	_, err = tx.ExecContext(ctx, updateCounter, newCounter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to update obat counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
	}

	insertKartuStok := `INSERT INTO ` + tableKartuStok + ` (id_kartustok, id_depo, id_satuan, stok_barang, created_at, created_by, updated_at, deleted_at, catatan) 
						VALUES (?, ?, ?, ?, NOW(), ?, NULL, NULL, ?)`
	_, err = tx.ExecContext(ctx, insertKartuStok, newIDObat, idDepo, obat.IDSatuan, obat.StokBarang, idKaryawan, obat.Catatan)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to insert kartu_stok: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to insert kartu_stok", Data: nil}, err
	}

	insertObat := `INSERT INTO ` + tableObat + ` (id_obat, id_satuan, id_depo, id_kartustok, id_kategori, nama, harga_jual, harga_beli, stok_barang, uprate, no_batch, kadaluarsa, created_at, created_by, updated_at, deleted_at, catatan) 
					VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?, NULL, NULL, ?)`
	_, err = tx.ExecContext(ctx, insertObat, newIDObat, obat.IDSatuan, idDepo, newIDObat, idKategori, strings.ToLower(obat.Nama), obat.HargaJual, obat.HargaBeli, 0, obat.Uprate, obat.NoBatch, obat.Kadaluarsa, idKaryawan, obat.Catatan)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to insert obat: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to insert obat", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusCreated, Message: "Obat successfully added", Data: nil}, nil
}

func GetObat(ctx context.Context, idget, idkategori string, page, pagesize int, jenis string) (class.Response, error) {
	con, err := db.DbConnection()
	if err != nil {
		log.Printf("Failed to connect to the database: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database connection error", Data: nil}, err
	}
	defer db.DbClose(con)

	tables, err := getTableNames(jenis)
	if err != nil {
		return class.Response{Status: http.StatusBadRequest, Message: "Invalid jenis value", Data: nil}, nil
	}

	tableObat := tables.Obat

	if idget != "" { //get data sebuah obat
		var obat class.Obat

		queryoneobat := `SELECT id_obat, id_satuan, id_depo, id_kartustok, id_kategori,nama,harga_jual, harga_beli,stok_barang,uprate,no_batch,kadaluarsa,created_at, created_by, updated_at,updated_by, catatan 
				  FROM ` + tableObat + ` WHERE id_obat = ? AND deleted_at IS NULL`
		err := con.QueryRowContext(ctx, queryoneobat, idget).Scan(&obat.IDObat, &obat.IDSatuan, &obat.IDDepo, &obat.IDKartuStok, &obat.IDKategori, &obat.Nama, &obat.HargaJual, &obat.HargaBeli, &obat.StokBarang,
			&obat.Uprate, &obat.NoBatch, &obat.Kadaluarsa, &obat.CreatedAt, &obat.CreatedBy, &obat.UpdatedAt, &obat.UpdatedBy, &obat.Catatan)

		if err == sql.ErrNoRows {
			return class.Response{Status: http.StatusNotFound, Message: "Data obat tidak ditemukan", Data: nil}, nil
		} else if err != nil {
			log.Println("gagal mengambil data untuk obat dengan id :", idget, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data obat", Data: nil}, nil
		}
		return class.Response{Status: http.StatusOK, Message: "berhasil mengambil data obat", Data: obat}, nil
	} else {
		offset := (page - 1) * pagesize
		var sliceobat []class.Obat

		querymanyobat := `SELECT id_obat, id_satuan, id_depo, id_kartustok, id_kategori,nama,harga_jual, harga_beli,stok_barang,uprate,no_batch,kadaluarsa,created_at, created_by, updated_at,updated_by, catatan 
				  FROM ` + tableObat + ` WHERE deleted_at IS NULL  LIMIT ? OFFSET ?`

		rows, err := con.QueryContext(ctx, querymanyobat, pagesize, offset)
		if err != nil {
			log.Println("gagal mengambil data list obat ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data list obat", Data: nil}, nil
		}
		defer rows.Close()

		for rows.Next() {
			var obat class.Obat
			err := rows.Scan(
				&obat.IDObat, &obat.IDSatuan, &obat.IDDepo, &obat.IDKartuStok, &obat.IDKategori, &obat.Nama, &obat.HargaJual, &obat.HargaBeli, &obat.StokBarang,
				&obat.Uprate, &obat.NoBatch, &obat.Kadaluarsa, &obat.CreatedAt, &obat.CreatedBy, &obat.UpdatedAt, &obat.UpdatedBy, &obat.Catatan)
			if err != nil {
				log.Println("gagal get data individual obat di model obat", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data obat"}, nil
			}
			sliceobat = append(sliceobat, obat)
		}

		var totalrecord int
		countrecordquery := `SELECT COUNT(*) FROM ` + tableObat
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

		return class.Response{Status: http.StatusOK, Message: "berhasil mengambil data list obat", Data: sliceobat, Metadata: metadata}, nil
	}

}

func UpdateObat(ctx context.Context, idkategori, idobat string, obat class.Obat, idkaryawan string, jenis string) (class.Response, error) {
	con, err := db.DbConnection()
	if err != nil {
		log.Printf("Failed to connect to the database: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database connection error", Data: nil}, err
	}
	defer db.DbClose(con)

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}

	tables, err := getTableNames(jenis)
	if err != nil {
		return class.Response{Status: http.StatusBadRequest, Message: "Invalid jenis value", Data: nil}, nil
	}

	// Use the table names dynamically
	tableObat := tables.Obat
	tableKartuStok := tables.KartuStok

	var exist bool
	cekexist := `SELECT EXISTS(SELECT 1 FROM ` + tableObat + ` WHERE id_obat = ? AND id_kategori = ? AND deleted_at IS NULL LIMIT 1)`
	err = tx.QueryRowContext(ctx, cekexist, idobat, idkategori).Scan(&exist)
	if err != nil {
		tx.Rollback()
		log.Println("error cek existence obat ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal cek obat"}, nil
	}
	if !exist {
		tx.Rollback()
		log.Println("error data obat tidak ditemukan : ", exist)
		return class.Response{Status: http.StatusNotFound, Message: "data obat tidak ditemukan"}, nil
	}

	queryupdateobat := `UPDATE ` + tableObat + ` SET id_satuan = ? , id_kategori =?,nama = ?,harga_jual = ?, harga_beli =?, uprate = ? , kadaluarsa = ? , updated_at = NOW(),updated_by = ?, catatan=? WHERE id_obat = ? AND deleted_at IS NULL`

	_, err = con.ExecContext(ctx, queryupdateobat, obat.IDSatuan, obat.IDKategori, obat.Nama, obat.HargaJual,
		obat.HargaBeli, obat.Uprate, obat.Kadaluarsa, idkaryawan, obat.Catatan, idobat)

	if err != nil {
		tx.Rollback()
		log.Println("gagal memperbarui data obat : ", idobat, "dengan error", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal memperbarui data obat", Data: nil}, err
	}

	var id_kartustok string
	queryGetKartuStok := `SELECT id_kartustok FROM ` + tableObat + ` WHERE id_obat = ? AND deleted_at IS NULL`

	err = tx.QueryRowContext(ctx, queryGetKartuStok, idobat).Scan(&id_kartustok)
	if err != nil {
		tx.Rollback()
		log.Println("gagal mendapatkan id_kartustok untuk obat:", idobat, "dengan error", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal mendapatkan kartu stok", Data: nil}, err
	}

	queryupdatekartustok := `UPDATE ` + tableKartuStok + ` SET id_satuan = ? , updated_at = NOW(), updated_by = ? WHERE id_kartustok = ? `
	_, err = con.ExecContext(ctx, queryupdatekartustok, obat.IDSatuan, idkaryawan, id_kartustok)

	if err != nil {
		tx.Rollback()
		log.Println("gagal memperbarui data kartu stok : ", idobat, "dengan error", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal memperbarui data kartu stok", Data: nil}, err
	}
	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "data obat berhasil diperbarui", Data: nil}, nil

}

func DeleteObat(ctx context.Context, idobat, idkaryawan string, jenis string) (class.Response, error) {
	con, err := db.DbConnection()
	if err != nil {
		log.Printf("Failed to connect to the database: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database connection error", Data: nil}, err
	}
	defer db.DbClose(con)

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}
	tables, err := getTableNames(jenis)
	if err != nil {
		return class.Response{Status: http.StatusBadRequest, Message: "Invalid jenis value", Data: nil}, nil
	}

	// Use the table names dynamically
	tableObat := tables.Obat

	var exist bool
	cekexist := `SELECT EXISTS(SELECT 1 FROM ` + tableObat + ` WHERE id_obat = ? AND deleted_at IS NULL LIMIT 1)`
	err = tx.QueryRowContext(ctx, cekexist, idobat).Scan(&exist)
	if err != nil {
		tx.Rollback()
		log.Println("error cek existence obat ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal cek obat"}, nil
	}
	if !exist {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "data obat tidak ditemukan"}, nil
	}

	querydelete := `UPDATE ` + tableObat + ` SET deleted_at = NOW(), deleted_by = ?  WHERE id_obat = ? AND deleted_at is NULL`
	result, err := tx.ExecContext(ctx, querydelete, idkaryawan, idobat)

	if err != nil {
		log.Println("gagal menghapus data obat : ", idobat, "dengan error", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal menghapus data obat", Data: nil}, nil
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Failed to get affected rows: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to check deletion result", Data: nil}, err
	}

	if rowsAffected == 0 {
		tx.Rollback()
		log.Println("obat not found of deleted in rows affected")
		return class.Response{Status: http.StatusNotFound, Message: "obat not found or already deleted ", Data: nil}, nil
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "berhasil menghapus data obat", Data: nil}, nil
}
