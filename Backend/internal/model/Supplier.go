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
	querycek := `SELECT id_supplier FROM supplier WHERE nama = ? AND deleted_at IS NULL LIMIT 1`
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

func GetAllSupplier(page, pagesize int) (class.Response, error) {
	con := db.GetDBCon()

	if page <= 0 { //biar aman aja ini gak bisa masukin aneh2
		page = 1
	}
	if pagesize <= 0 {
		pagesize = 10
	}
	offset := (page - 1) * pagesize

	var list []class.Supplier

	query := `SELECT id_supplier, nama, alamat, no_telp,keterangan ,created_at FROM supplier WHERE deleted_at IS NULL 
	ORDER BY id DESC
	LIMIT ? OFFSET ? `
	rows, err := con.Query(query, pagesize, offset)
	if err != nil {
		log.Print("Error saat query data all supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Supplier"}, err
	}
	defer rows.Close()

	for rows.Next() {
		var supplier class.Supplier
		var catatan sql.NullString

		err := rows.Scan(&supplier.IDSupplier, &supplier.Nama, &supplier.Alamat, &supplier.NoTelp, &catatan, &supplier.CreatedAt)
		if err != nil {
			log.Println("Error saat scan rows data supplier", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Supplier"}, err
		}
		if catatan.Valid {
			supplier.Catatan = &catatan.String
		}
		list = append(list, supplier)

	}
	err = rows.Err()
	if err != nil {
		log.Println("Ada Error pada rows get all supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Supplier"}, err
	}

	var totalrecord int
	countrecordquery := `SELECT COUNT(*) FROM supplier`
	err = con.QueryRow(countrecordquery).Scan(&totalrecord)

	if err != nil {
		log.Println("gagal menghitung jumlah entry table supplier ")
		return class.Response{Status: http.StatusInternalServerError, Message: "Metadata Error"}, nil
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
func GetSupplier(idsupplier string) (class.Response, error) {
	con := db.GetDBCon()

	var exist bool
	querycek := `SELECT EXISTS(SELECT id_supplier FROM supplier WHERE id_supplier = ? AND deleted_at IS NULL LIMIT 1)`
	err := con.QueryRow(querycek, idsupplier).Scan(&exist)
	if err != nil {
		log.Println("Error saat cek apakah id supplier valid ", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Error saat menghapus data Supplier"}, err
	}
	if !exist {
		log.Println("Supplier tidak ditemukan", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Supplier tidak ditemukan"}, err
	}

	query := `SELECT id_supplier, nama, alamat, no_telp,keterangan ,created_at FROM supplier 
	WHERE id_supplier = ? AND deleted_at IS NULL
	`
	var supplier class.Supplier
	var catatan sql.NullString
	err = con.QueryRow(query, idsupplier).Scan(&supplier.IDSupplier, &supplier.Nama, &supplier.Alamat, &supplier.NoTelp, &catatan, &supplier.CreatedAt)
	if err != nil {
		log.Println("Error saat query data supplier", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Supplier"}, err
	}
	if catatan.Valid {
		supplier.Catatan = &catatan.String
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: supplier}, nil

}

func EditSupplier(ctx context.Context, idupdate string, supplier class.Supplier) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}
	var exist bool
	querycek := `SELECT EXISTS(SELECT id_supplier FROM supplier WHERE id_supplier = ? AND deleted_at IS NULL LIMIT 1)`
	err = tx.QueryRowContext(ctx, querycek, idupdate).Scan(&exist)
	if err != nil {
		log.Println("Error saat cek apakah id supplier valid ", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Error saat Edit data Supplier"}, err
	}
	if !exist {
		log.Println("Supplier tidak ditemukan", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Supplier tidak ditemukan"}, err
	}

	query := `UPDATE supplier SET nama= ? , alamat = ?, no_telp = ?, updated_at = NOW(), keterangan = ? WHERE id_supplier = ?`
	_, err = tx.ExecContext(ctx, query, supplier.Nama, supplier.Alamat, supplier.NoTelp, supplier.Catatan, idupdate)
	if err != nil {
		log.Println("Error saat update data supplier")
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat update data Supplier"}, err

	}
	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}
	return class.Response{Status: http.StatusOK, Message: "Success"}, nil

}

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
