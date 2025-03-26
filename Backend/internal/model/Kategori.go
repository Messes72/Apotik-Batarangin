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

func GetKategori(ctx context.Context) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err
	}

	statement := `SELECT id_depo, id_kategori,nama,created_at,updated_at,catatan FROM Kategori WHERE deleted_at IS NULL`

	rows, err := tx.QueryContext(ctx, statement)

	if err != nil {
		tx.Rollback()
		log.Println("error while query kategori data")
		return class.Response{Status: http.StatusInternalServerError, Message: "failed to fetch kategoris", Data: nil}, nil
	}
	defer rows.Close()

	allkategori := []class.Kategori{}

	for rows.Next() {
		var kategori class.Kategori
		var catatan sql.NullString

		err := rows.Scan(&kategori.IDDepo, &kategori.IDKategori, &kategori.Nama, &kategori.CreatedAt, &kategori.UpdatedAt, &catatan)
		if err != nil {
			log.Println("failed to get individual kategori ", err)
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "failed to fetch kategori", Data: nil}, nil

		}

		allkategori = append(allkategori, kategori)
	}

	if len(allkategori) == 0 {
		return class.Response{Status: http.StatusInternalServerError, Message: "data kategori tidak ditemukan", Data: nil}, nil
	}

	return class.Response{Status: http.StatusOK, Message: "berhasil mengambil seluruh data kategori", Data: allkategori}, nil

}

func AddKategori(ctx context.Context, kategori class.Kategori, idkaryawan string) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err
	}

	var exists bool //cek apakah ada id yg mau did delte itu
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Kategori WHere id_kategori=? OR LOWER(nama)=? )`, kategori.IDKategori, kategori.Nama).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking Kategori existence"}, err

	}
	if exists {
		tx.Rollback()
		return class.Response{Status: http.StatusConflict, Message: "Kategori sudah ada"}, nil
	}

	var counter int16
	querycounter := `SELECT count from KategoriCounter FOR UPDATE`
	err = tx.QueryRowContext(ctx, querycounter).Scan(&counter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to fetch counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch counter id", Data: nil}, err
	}

	forcounterupdate := counter + 1

	autoincrementid := fmt.Sprintf("KAT%09d", forcounterupdate)

	updatecounterstatement := `UPDATE KategoriCounter SET count = ?`
	_, err = tx.ExecContext(ctx, updatecounterstatement, forcounterupdate)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to update counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
	}

	statement := `INSERT INTO Kategori (id_kategori, id_depo, nama, created_at, created_by, catatan) VALUES (?,?,?,NOW(),?,?)`
	_, err = tx.ExecContext(ctx, statement, autoincrementid, kategori.IDDepo, kategori.Nama, idkaryawan, kategori.Catatan)

	if err != nil {
		log.Printf("Failed to insert Kategori: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to create Kategori", Data: nil}, err
	}
	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err
	}
	return class.Response{Status: http.StatusOK, Message: "Berhasil menambahkan data Kategori"}, nil
}

func UpdateKategori(ctx context.Context, kategori class.Kategori, idkaryawan string, idkategori string) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err
	}

	var exists bool //cek apakah ada id yg mau did delte itu
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Kategori WHere id_kategori=? )`, idkategori).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking Kategori existence"}, err

	}
	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "Kategori tidak ditemukan"}, nil

	}

	statementupdate := `UPDATE Kategori SET id_depo = ? , nama = ? , catatan=? , updated_at= NOW(), updated_by= ? WHERE id_kategori = ? WHERE deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, statementupdate, kategori.IDDepo, kategori.Nama, kategori.Catatan, idkaryawan, idkategori)
	if err != nil {
		tx.Rollback()
		log.Println("error in update:", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Update data Kategori gagal"}, err
	}

	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "transaction commit error"}, err

	}

	return class.Response{Status: http.StatusOK, Message: "Berhasil mengupdate data Kategori"}, nil
}

func DeleteKategori(ctx context.Context, idkaryawan string, iddelete string) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err
	}

	var exists bool //cek apakah ada id yg mau did delte itu
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Kategori WHere id_kategori=? )`, iddelete).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking Kategori existence"}, err

	}
	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "Kategori tidak ditemukan"}, nil

	}

	statementdelete := `UPDATE Kategori SET deleted_at = NOW(), deleted_by = ? WHERE id_kategori = ?`
	_, err = tx.ExecContext(ctx, statementdelete, idkaryawan, iddelete)
	if err != nil {
		tx.Rollback()
		log.Println("error in delete:", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Delete data Kategori gagal"}, err
	}

	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "transaction commit error"}, err

	}

	return class.Response{Status: http.StatusOK, Message: "Berhasil menghapus data Kategori"}, nil
}
