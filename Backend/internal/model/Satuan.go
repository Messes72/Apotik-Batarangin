package internal

import (
	"context"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func GetSatuan(ctx context.Context) (class.Response, error) {
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

	statement := `SELECT id_satuan, nama_satuan,catatan, created_at FROM Satuan `

	rows, err := tx.QueryContext(ctx, statement)

	if err != nil {
		tx.Rollback()
		log.Println("error while query satuan data", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "failed to fetch satuan", Data: nil}, nil
	}
	defer rows.Close()

	allsatuan := []class.Satuan{}

	for rows.Next() {
		var satuan class.Satuan

		err := rows.Scan(&satuan.IDSatuan, &satuan.NamaSatuan, &satuan.Catatan, &satuan.CreatedAt)
		if err != nil {
			log.Println("failed to get individual satuan ", err)
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "failed to fetch satuan", Data: nil}, nil

		}

		allsatuan = append(allsatuan, satuan)
	}

	if len(allsatuan) == 0 {
		return class.Response{Status: http.StatusInternalServerError, Message: "data satuan tidak ditemukan", Data: nil}, nil
	}

	return class.Response{Status: http.StatusOK, Message: "berhasil mengambil seluruh data satuan", Data: allsatuan}, nil
}
