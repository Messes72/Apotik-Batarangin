package internal

import (
	"context"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func GetDepo(ctx context.Context) (class.Response, error) {
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

	statement := `SELECT id_depo, nama,alamat,no_telp, catatan FROM Depo `

	rows, err := tx.QueryContext(ctx, statement)

	if err != nil {
		tx.Rollback()
		log.Println("error while query satuan data", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "failed to fetch satuan", Data: nil}, nil
	}
	defer rows.Close()

	alldepo := []class.Depo{}

	for rows.Next() {
		var depo class.Depo

		err := rows.Scan(&depo.IDDepo, &depo.Nama, &depo.Alamat, &depo.NoTelp, &depo.Catatan)
		if err != nil {
			log.Println("failed to get individual depo ", err)
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "failed to fetch depo", Data: nil}, nil

		}

		alldepo = append(alldepo, depo)
	}

	if len(alldepo) == 0 {
		return class.Response{Status: http.StatusInternalServerError, Message: "data depo tidak ditemukan", Data: nil}, nil
	}

	return class.Response{Status: http.StatusOK, Message: "berhasil mengambil seluruh data depo", Data: alldepo}, nil
}
