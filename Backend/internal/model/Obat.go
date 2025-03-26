package internal

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func AddObat(ctx context.Context, obat class.ObatJadi, idKategori string, idKaryawan string) (class.Response, error) {
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
	//ToDo...
	//tanyakan apakh perlu ada pengecekan untuk memastikan bahwa depo yang dimasukan user adalah depo yang sesuai dengan jenis...
	//ToDo...

	var exists string
	checkQuery := `SELECT 1 FROM obat_jadi WHERE nama_obat = ? AND id_kategori = ? LIMIT 1`
	err = tx.QueryRowContext(ctx, checkQuery, obat.NamaObat, idKategori).Scan(&exists)
	if err != nil {
		if err == sql.ErrNoRows {
			// Obat not found, proceed with the transaction.
		} else {
			// An actual error occurred during the query.
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "Error checking obat", Data: nil}, nil
		}
	} else {
		// Obat found, rollback the transaction and return a conflict error.
		tx.Rollback()
		return class.Response{Status: http.StatusConflict, Message: "Obat sudah ada di depo ini", Data: nil}, nil
	}

	var counter int
	queryCounter := `SELECT count FROM ObatCounter FOR UPDATE`
	err = tx.QueryRowContext(ctx, queryCounter).Scan(&counter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to fetch counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
	}

	newCounter := counter + 1
	prefix := "MDC"
	newIDObat := fmt.Sprintf("%s%d", prefix, newCounter)
	log.Printf("New id obat: %s", newIDObat)

	updateCounter := `UPDATE ObatCounter SET count = ?`
	_, err = tx.ExecContext(ctx, updateCounter, newCounter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to update obat counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
	}

	insertObat := `INSERT INTO obat_jadi (id_obat, id_satuan,  id_kategori, nama_obat, harga_jual, harga_beli, stok_minimum, uprate, created_at, created_by, link_gambar_obat ,keterangan) 
	VALUES (?, ?, ?, ?, ?,?, ?, ?, NOW(),?, ?, ?)`
	_, err = tx.ExecContext(ctx, insertObat, newIDObat, obat.IDSatuan, idKategori, obat.NamaObat, obat.HargaJual, obat.HargaBeli, obat.StokMinimum, obat.Uprate, idKaryawan, obat.LinkGambarObat, obat.Keterangan)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to insert obat: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to insert obat", Data: nil}, err
	}
	depoquery := `SELECT id_depo FROM Depo`
	rows, err := tx.QueryContext(ctx, depoquery)
	if err != nil {
		tx.Rollback()

		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve depo list", Data: nil}, err
	}
	defer rows.Close()
	insertKartuStok := `INSERT INTO kartu_stok (id_kartustok, id_depo, id_obat, stok_barang, created_at, created_by, keterangan) 
							VALUES (?, ?, ?, ?, NOW(), ?, ?)`
	for rows.Next() {
		var idDepo string
		if err := rows.Scan(&idDepo); err != nil {
			tx.Rollback()
			log.Println("error di scan rows addobat kartu stok", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Eror saat Pembuatan Kartu stok", Data: nil}, err
		}
		// log.Println("scan", idDepo)
		log.Println(con.PingContext(ctx))
		_, err = tx.ExecContext(ctx, insertKartuStok, newIDObat, idDepo, newIDObat, 0, idKaryawan, obat.Keterangan)
		log.Println(con.PingContext(ctx))
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to insert kartu_stok for depo %s: %v\n", idDepo, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Gagal membuat kartu_stok", Data: nil}, err
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusCreated, Message: "Obat successfully added", Data: nil}, nil
}

func GetObat(ctx context.Context, idget string, page, pagesize int) (class.Response, error) {
	con, err := db.DbConnection()
	if err != nil {
		log.Printf("Failed to connect to the database: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database connection error", Data: nil}, err
	}
	defer db.DbClose(con)

	log.Println("idget : ", idget)
	if idget != "" { //get data sebuah obat
		var obat class.ObatJadi

		queryoneobat := `SELECT o.id_obat, o.id_satuan, o.id_kategori, o.nama_obat, o.harga_jual, o.harga_beli, o.stok_minimum, o.uprate, o.created_at, o.updated_at, o.link_gambar_obat, o.keterangan, s.nama_satuan
				  FROM obat_jadi o JOIN satuan s ON o.id_satuan = s.id_satuan WHERE o.id_obat = ? AND o.deleted_at IS NULL ORDER BY o.id_obat ASC`
		err := con.QueryRowContext(ctx, queryoneobat, idget).Scan(&obat.IDObat, &obat.IDSatuan, &obat.IDKategori, &obat.NamaObat, &obat.HargaJual, &obat.HargaBeli, &obat.StokMinimum,
			&obat.Uprate, &obat.CreatedAt, &obat.UpdatedAt, &obat.LinkGambarObat, &obat.Keterangan, &obat.NamaSatuan)

		if err == sql.ErrNoRows {
			return class.Response{Status: http.StatusNotFound, Message: "Data obat tidak ditemukan", Data: nil}, nil
		} else if err != nil {
			log.Println("gagal mengambil data untuk obat dengan id :", idget, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data obat", Data: nil}, nil
		}
		return class.Response{Status: http.StatusOK, Message: "berhasil mengambil data obat", Data: obat}, nil
	} else {
		offset := (page - 1) * pagesize
		var sliceobat []class.ObatJadi

		querymanyobat := `SELECT o.id_obat, o.id_satuan, o.id_kategori, o.nama_obat, o.harga_jual, o.harga_beli, o.stok_minimum, o.uprate, o.created_at, o.updated_at, o.link_gambar_obat, o.keterangan, s.nama_satuan
				  FROM obat_jadi o JOIN satuan s ON o.id_satuan = s.id_satuan WHERE o.deleted_at IS NULL ORDER BY o.id_obat ASC LIMIT ? OFFSET ?`

		rows, err := con.QueryContext(ctx, querymanyobat, pagesize, offset)
		if err != nil {
			log.Println("gagal mengambil data list obat ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data list obat", Data: nil}, nil
		}
		defer rows.Close()

		for rows.Next() {
			var obat class.ObatJadi
			err := rows.Scan(
				&obat.IDObat, &obat.IDSatuan, &obat.IDKategori, &obat.NamaObat, &obat.HargaJual, &obat.HargaBeli, &obat.StokMinimum,
				&obat.Uprate, &obat.CreatedAt, &obat.UpdatedAt, &obat.LinkGambarObat, &obat.Keterangan, &obat.NamaSatuan)
			if err != nil {
				log.Println("gagal get data individual obat di model obat", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data obat"}, nil
			}
			sliceobat = append(sliceobat, obat)
		}

		var totalrecord int
		countrecordquery := `SELECT COUNT(*) FROM obat_jadi WHERE deleted_at IS NULL`
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

func UpdateObat(ctx context.Context, idkategori, idobat string, obat class.ObatJadi, idkaryawan string) (class.Response, error) {
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

	var exist bool //cek apakah obat dgn idobat itu ada
	cekexist := `SELECT EXISTS(SELECT 1 FROM obat_jadi WHERE id_obat = ? AND deleted_at IS NULL LIMIT 1)`
	err = tx.QueryRowContext(ctx, cekexist, idobat).Scan(&exist)
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

	var duplicate bool

	querycekduplicate := `SELECT EXISTS(SELECT 1 FROM obat_jadi WHERE nama_obat = ? AND id_obat <> ? AND deleted_at IS NULL)`
	err = tx.QueryRowContext(ctx, querycekduplicate, obat.NamaObat, idobat).Scan(&duplicate)
	if err != nil {
		tx.Rollback()
		log.Println("Error saat validasi duplikat konten update", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal validasi update obat"}, nil

	}
	if duplicate {
		tx.Rollback()
		log.Println("Nama obat sudah digunakan entry obat lain")
		return class.Response{Status: http.StatusConflict, Message: "Nama obat sudah ada"}, nil

	}

	var oldimage *string

	if obat.LinkGambarObat != nil && *obat.LinkGambarObat != "" {
		queryambilgambarlama := `SELECT link_gambar_obat FROM obat_jadi WHERE id_obat = ? AND deleted_at IS NULL`
		err = tx.QueryRowContext(ctx, queryambilgambarlama, idobat).Scan(&oldimage)
		if err != nil {
			tx.Rollback()
			log.Println("error saat mengambil data gambar lama", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengupdate gambar"}, nil
		}
	}

	if obat.LinkGambarObat != nil && *obat.LinkGambarObat != "" {
		queryupdateobat := `UPDATE obat_jadi SET id_satuan = ? , id_kategori =?,nama_obat = ?,harga_jual = ?, harga_beli =?, stok_minimum = ?,uprate = ? ,
		updated_at = NOW(),updated_by = ?, link_gambar_obat = ? ,keterangan=? WHERE id_obat = ? AND deleted_at IS NULL`

		_, err = con.ExecContext(ctx, queryupdateobat, obat.IDSatuan, obat.IDKategori, obat.NamaObat, obat.HargaJual,
			obat.HargaBeli, obat.StokMinimum, obat.Uprate, idkaryawan, obat.LinkGambarObat, obat.Keterangan, idobat)
	} else {
		queryupdateobat := `UPDATE obat_jadi SET id_satuan = ? , id_kategori =?,nama_obat = ?,harga_jual = ?, harga_beli =?, stok_minimum = ?,uprate = ? ,
		updated_at = NOW(),updated_by = ?,  keterangan=? WHERE id_obat = ? AND deleted_at IS NULL`

		_, err = con.ExecContext(ctx, queryupdateobat, obat.IDSatuan, obat.IDKategori, obat.NamaObat, obat.HargaJual,
			obat.HargaBeli, obat.StokMinimum, obat.Uprate, idkaryawan, obat.Keterangan, idobat)
	}
	if err != nil {
		tx.Rollback()
		log.Println("Gagal memperbarui data obat : ", idobat, "dengan error", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal memperbarui data obat", Data: nil}, err
	}

	// var id_kartustok string
	// queryGetKartuStok := `SELECT id_kartustok FROM obat_jadi WHERE id_obat = ? AND deleted_at IS NULL`

	// err = tx.QueryRowContext(ctx, queryGetKartuStok, idobat).Scan(&id_kartustok)
	// if err != nil {
	// 	tx.Rollback()
	// 	log.Println("gagal mendapatkan id_kartustok untuk obat:", idobat, "dengan error", err)
	// 	return class.Response{Status: http.StatusInternalServerError, Message: "gagal mendapatkan kartu stok", Data: nil}, err
	// }

	// queryupdatekartustok := `UPDATE kartu_stok SET updated_at = NOW(), updated_by = ? WHERE id_kartustok = ? `
	// _, err = con.ExecContext(ctx, queryupdatekartustok, idkaryawan, id_kartustok)

	// if err != nil {
	// 	tx.Rollback()
	// 	log.Println("gagal memperbarui data kartu stok : ", idobat, "dengan error", err)
	// 	return class.Response{Status: http.StatusInternalServerError, Message: "gagal memperbarui data kartu stok", Data: nil}, err
	// }  //perlu kejelasan apakah perlu update juga kartu stoknya karena dari segi data ,tidak ada yang diupdate

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	if obat.LinkGambarObat != nil && *obat.LinkGambarObat != "" && oldimage != nil && *oldimage != "" {
		err := os.Remove(*oldimage)
		if err != nil {
			log.Println("error saat menghapus file image dari obat yang sudah diupdate")

		} else {
			log.Println("berhasil menghapus file image dari obat yang sudah diupdate")
		}
	}

	return class.Response{Status: http.StatusOK, Message: "data obat berhasil diperbarui", Data: nil}, nil

}

func DeleteObat(ctx context.Context, idobat, idkaryawan string) (class.Response, error) {
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

	var exist bool
	cekexist := `SELECT EXISTS(SELECT 1 FROM obat_jadi WHERE id_obat = ? AND deleted_at IS NULL LIMIT 1)`
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

	var oldimage *string
	queryoldimage := `SELECT link_gambar_obat FROM obat_jadi WHERE id_obat = ? AND deleted_at IS NULL`
	err = tx.QueryRowContext(ctx, queryoldimage, idobat).Scan(&oldimage)
	if err != nil {
		tx.Rollback()
		log.Println("Error saat mengambil path image dari obat yang akan dihapus")
		return class.Response{Status: http.StatusInternalServerError, Message: "Gagal menghapus data obat"}, nil
	}

	querydelete := `UPDATE obat_jadi SET deleted_at = NOW(), deleted_by = ?  WHERE id_obat = ? AND deleted_at is NULL`
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

	if oldimage != nil && *oldimage != "" && *oldimage != "uploads/default.png" {
		err = os.Remove(*oldimage)
		if err != nil {
			log.Println("Gagal menghapus file image", *oldimage, "Dengan error : ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Data obat berhasil dihapus, Namun terjadi kegagalan saat menghapus gambar obat"}, nil

		} else {
			log.Println("Berhasil menghapus file image ")
		}
	}

	return class.Response{Status: http.StatusOK, Message: "berhasil menghapus data obat", Data: nil}, nil
}
