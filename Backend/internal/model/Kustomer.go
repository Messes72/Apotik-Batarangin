package internal

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
	"strings"
)

func AddKustomer(ctx context.Context, kustomer class.Kustomer) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}

	var exists string

	checkquery := `SELECT 1 FROM Kustomer WHERE (LOWER(nama) = ?) OR (no_telp = ?) LIMIT 1` //dark magic sql iki, it works, dont touch, idk !!
	err = tx.QueryRowContext(ctx, checkquery, strings.ToLower(kustomer.Nama), kustomer.NoTelp).Scan(&exists)
	log.Println(err, "asdw")
	if err == nil { //klo nil kan berarti berhasil mengambil data
		tx.Rollback()
		log.Println("err == nil cek kustomer ", err)
		return class.Response{Status: http.StatusConflict, Message: "kustomer sudah ada, periksa list kustomer, data tidak ditambahkan", Data: nil}, nil
	}

	if err != sql.ErrNoRows { //error random lainne, kalau dia ga dpt apa apa pas query maka keluar error errnorow itu, klo memu sesuatu kan gaada error itu
		tx.Rollback()
		log.Println("checking exist kustomer error", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "error checking data customer", Data: nil}, nil
	}

	var counter int16
	querycounter := `SELECT count from Counter FOR UPDATE`
	err = tx.QueryRowContext(ctx, querycounter).Scan(&counter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to fetch counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch counter id", Data: nil}, err
	}

	forcounterupdate := counter + 1

	autoincrementid := fmt.Sprintf("BTA%09d", forcounterupdate)

	updatecounterstatement := `UPDATE Counter SET count = ?`
	_, err = tx.ExecContext(ctx, updatecounterstatement, forcounterupdate)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to update counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
	}

	statement := `Insert INTO Kustomer (id_kustomer,nama,alamat,no_telp,created_at,updated_at,catatan) VALUES (?,?,?,?,NOW(),NOW(),?)`
	_, err = tx.ExecContext(ctx, statement, autoincrementid, strings.ToLower(kustomer.Nama), kustomer.Alamat, kustomer.NoTelp, kustomer.Catatan)

	if err != nil {
		tx.Rollback()
		log.Printf("Failed to insert kustomer: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to insert kustomer", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}
	return class.Response{Status: http.StatusCreated, Message: "berhasil menambahkan kustomer baru", Data: nil}, nil
}

func GetKustomer(ctx context.Context, idkustomer string, page, pagesize int) (class.Response, error) {
	con := db.GetDBCon()

	if page <= 0 { //biar aman aja ini gak bisa masukin aneh2
		page = 1
	}
	if pagesize <= 0 {
		pagesize = 10
	}
	offset := (page - 1) * pagesize

	if idkustomer != "" {
		var kustomer class.Kustomer

		queryget := `SELECT id_kustomer, nama, alamat, no_telp, created_at, catatan FROM Kustomer WHERE id_kustomer = ? AND deleted_at IS NULL`

		err := con.QueryRowContext(ctx, queryget, idkustomer).Scan(&kustomer.IDKustomer, &kustomer.Nama, &kustomer.Alamat, &kustomer.NoTelp, &kustomer.CreatedAt, &kustomer.Catatan)
		if err == sql.ErrNoRows {
			return class.Response{Status: http.StatusNotFound, Message: "Data kustomer tidak ditemukan", Data: nil}, nil
		} else if err != nil {
			log.Println("gagal mengambil data untuk kustomer dengan id :", idkustomer, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data kustomer", Data: nil}, nil
		}
		return class.Response{Status: http.StatusOK, Message: "Berhasil mengambil data kustomer", Data: kustomer}, nil
	} else {
		querygetpagination := `SELECT id_kustomer, nama, alamat, no_telp, created_at, catatan FROM Kustomer WHERE deleted_at IS NULL ORDER BY id_kustomer DESC LIMIT ? OFFSET ? `

		rows, err := con.QueryContext(ctx, querygetpagination, pagesize, offset)
		if err != nil {
			log.Println("error di query get kustomer with pagination", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data kustomer", Data: nil}, err
		}
		defer rows.Close()
		var listkustomer []class.Kustomer

		for rows.Next() {
			var kustomer class.Kustomer

			err = rows.Scan(&kustomer.IDKustomer, &kustomer.Nama, &kustomer.Alamat, &kustomer.NoTelp, &kustomer.CreatedAt, &kustomer.Catatan)
			if err != nil {
				log.Println("Error saat mengambil list kustomer", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data kustomer"}, err

			}
			listkustomer = append(listkustomer, kustomer)
		}

		var totalrecord int
		err = con.QueryRowContext(ctx, `SELECT COUNT(*) FROM Kustomer WHERE deleted_at IS NULL`).Scan(&totalrecord)
		if err != nil {
			log.Printf("GetKustomer count error: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to count kustomer"}, err
		}
		totalpage := (totalrecord + pagesize - 1) / pagesize
		metadata := class.Metadata{
			CurrentPage:  page,
			PageSize:     pagesize,
			TotalPages:   totalpage,
			TotalRecords: totalrecord,
		}

		return class.Response{Status: http.StatusOK, Message: "Success", Data: listkustomer, Metadata: metadata}, nil
	}
}

func UpdateKustomer(ctx context.Context, idupdate string, kustomer class.Kustomer) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}

	var exists bool
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Kustomer WHere id_kustomer=? AND deleted_at is null)`, idupdate).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking kustomer existence"}, err

	}
	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "kustomer not found"}, nil
	}

	updatestatement := `UPDATE Kustomer set nama = ? , alamat= ? , no_telp=?, updated_at=NOW() WHERE id_kustomer =?`

	_, err = tx.ExecContext(ctx, updatestatement, kustomer.Nama, kustomer.Alamat, kustomer.NoTelp, idupdate)
	if err != nil {
		tx.Rollback()
		log.Println("failed to update kustomer ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "failed to update kustomer", Data: nil}, nil
	}

	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		log.Println("failed to commit transaction ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "transaksi commit error", Data: nil}, nil
	}

	return class.Response{Status: http.StatusOK, Message: "data kustomer berhasil diupdate", Data: nil}, nil
}

func DeleteKustomer(ctx context.Context, iddelete, alasan string) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}

	var exists bool //cek apakah ada id yg mau did delte itu
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Kustomer WHere id_kustomer=? AND deleted_at is null)`, iddelete).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking kustomer existence"}, err

	}
	if !exists {
		tx.Rollback()
		log.Println("sql delete kustomer eror", err, exists, iddelete)
		return class.Response{Status: http.StatusNotFound, Message: "kustomer not found"}, nil

	}

	querydelete := `UPDATE Kustomer SET updated_at = NOW(), deleted_at=NOw(), alasandelete = ? WHERE id_kustomer = ? `
	_, err = tx.ExecContext(ctx, querydelete, alasan, iddelete)
	if err != nil {
		log.Println("Failed to soft delete kustomer: ", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete kustomer", Data: nil}, err

	}
	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "transaction commit error"}, err

	}

	return class.Response{Status: http.StatusOK, Message: "berhasil delete data kustomer"}, nil
}
