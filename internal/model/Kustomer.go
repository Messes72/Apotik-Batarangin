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

func UpdateKustomer(ctx context.Context, idupdate string, kustomer class.Kustomer) (class.Response, error) {
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

func DeleteKustomer(ctx context.Context, iddelete string) (class.Response, error) {
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

	querydelete := `UPDATE Kustomer SET updated_at = NOW(), deleted_at=NOw() WHERE id_kustomer = ? `
	_, err = tx.ExecContext(ctx, querydelete, iddelete)
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
