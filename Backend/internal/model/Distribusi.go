package internal

import (
	"context"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func RequestBarangApotikKeGudang(ctx context.Context, idkarayawan string, listobat []class.RequestBarangObat, distribusi class.RequestBarang) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}

	IdDistribusi, err := nextBizID(tx, "distribusicounter", "DIS")
	if err != nil {
		log.Println("Error saat membuat id distribusi baru", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	}

	querydistribusi := `INSERT INTO distribusi (id_distribusi, id_depo_asal, id_depo_tujuan ,id_status,tanggal_permohonan, keterangan, created_at, created_by) VALUES (?,?,?,?,NOW(),?,NOW(),?)`

	_, err = tx.ExecContext(ctx, querydistribusi, IdDistribusi, "10", "20", "0", distribusi.Keterangan, idkarayawan)
	if err != nil {
		log.Println("Error saat insert data ke distribusi", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
	}

	for _, obat := range listobat {

		iddetaildristribusi, err := nextBizID(tx, "detaildistribusicounter", "DDIS")
		if err != nil {
			log.Println("ERror saat membuat counter detail distribusi")
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}

		querydetaildistribusi := `INSERT INTO detail_distribusi (id_detail_distribusi, id_distribusi, id_kartustok, jumlah_diminta, jumlah_dikirim, created_at, created_by)
		VALUES (?,?,?,?,0,NOW(),?)`

		_, err = tx.ExecContext(ctx, querydetaildistribusi, iddetaildristribusi, IdDistribusi, obat.IDObat, obat.JumlahDiminta, idkarayawan)

		if err != nil {
			log.Println("Error saat insert detail distribusi ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data", Data: nil}, err
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: nil}, nil

}

// func GetRequestByID(ctx context.Context, iddistribusi string) (class.Response, error) {

// 	con := db.GetDBCon()

// 	var distribusi class.Distribusi

// 	query := `SELECT id_distribusi, id_depo_asal, id_depo_tujuan ,id_status,tanggal_permohonan,tanggal_pengiriman, keterangan, created_at, created_by, updated_at, updated_by
// 	FROM distribusi WHERE id_distribusi = ? AND deleted_at IS NULL`

// 	err := con.QueryRowContext(ctx, query, iddistribusi).Scan(&distribusi.IdDistribusi, &distribusi.IdDepoAsal, &distribusi.IdDepoTujuan, &distribusi.IdStatus, &distribusi.TanggalPermohonan, &distribusi.TanggalPengiriman, &distribusi.Keterangan, &distribusi.CreatedAt, &distribusi.CreatedBy, &distribusi.UpdatedAt, &distribusi.UpdatedBy)
// 	if err != nil {
// 		log.Println("Error saat query data distribusi", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data distribusi", Data: nil}, nil
// 	}
// }
