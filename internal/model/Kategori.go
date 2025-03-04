package internal

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func GetKategori(ctx context.Context) (class.Response, error) {
	con, err := db.DbConnection()
	if err != nil {
		log.Printf("Failed to connect to database: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database connection failed", Data: nil}, err
	}
	defer db.DbClose(con)

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
