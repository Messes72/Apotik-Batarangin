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

func AddSupplier(ctx context.Context, supplier class.Supplier) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}

	var exist string
	querycek := `SELECT id_supplier FROM supplier WHERE nama = ? LIMIT 1`
	err = tx.QueryRowContext(ctx, querycek, supplier.Nama).Scan(&exist)
	if err == nil {
		//supplier duplikat
		log.Println("SUppier baru sudah pernah ada (duplikat)")
		return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("Supplier dengan Nama : %s sudah ada", supplier.Nama)}, nil
	}
	if err != sql.ErrNoRows {
		log.Println("Error saat query cek duplikat supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menambahkan Supplier baru"}, err
	}
	if exist != "" {
		log.Println("Suppier baru sudah pernah ada (duplikat)")
		return class.Response{Status: http.StatusBadRequest, Message: fmt.Sprintf("Supplier dengan Nama : %s sudah ada", supplier.Nama)}, nil

	}

	query := `INSERT INTO supplier (id_supplier, nama, alamat, no_telp, keterangan, created_at)
	VALUES(?,?,?,?,?,NOW())`

	idsupplier, err := nextBizID(tx, "suppliercounter", "SUP")
	if err != nil {
		log.Println("Gagal membaut counter id supplier ")
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menambahkan Supplier Baru"}, err
	}

	_, err = tx.ExecContext(ctx, query, idsupplier, supplier.Nama, supplier.Alamat, supplier.NoTelp, supplier.Catatan)
	if err != nil {
		log.Println("Eror saat insert supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menambahkan Supplier Baru"}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success"}, nil

}

// func GetAllSupplier() (class.Response, error)

func DeleteSupplier(ctx context.Context, idsupplier, alasandelet string) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}

	var exist bool
	querycek := `SELECT EXISTS(SELECT id_supplier FROM supplier WHERE id_supplier = ? AND deleted_at IS NULL LIMIT 1)`
	err = tx.QueryRowContext(ctx, querycek, idsupplier).Scan(&exist)
	if err != nil {
		tx.Rollback()
		log.Println("Error saat cek apakah id supplier valid ", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Error saat menghapus data Supplier"}, err
	}
	if !exist {
		tx.Rollback()
		log.Println("Supplier tidak ditemukan", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Supplier tidak ditemukan"}, err
	}

	querdelet := `UPDATE supplier SET deleted_at = NOW(), alasan_delete= ? WHERE id_supplier = ?`
	_, err = tx.ExecContext(ctx, querdelet, alasandelet, idsupplier)
	if err != nil {
		log.Println("Error saat menghapus data supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat menghapus data Supplier"}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}
	return class.Response{Status: http.StatusOK, Message: "Success"}, nil

}
