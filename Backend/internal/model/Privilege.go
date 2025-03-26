package internal

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func CreatePrivilege(ctx context.Context, privilege class.Privilege) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err
	}

	// Insert query
	query := `INSERT INTO Privilege (id_privilege, nama_privilege, created_at, updated_at, catatan) VALUES (?, ?, NOW(), NOW(), ?)`
	_, err = tx.ExecContext(ctx, query, privilege.IDPrivilege, privilege.NamaPrivilege, privilege.Catatan)

	if err != nil {
		log.Printf("Failed to insert privilege: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to create privilege", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err
	}

	return class.Response{Status: http.StatusCreated, Message: "Privilege successfully created", Data: privilege}, nil
}

func GetAllPrivilege(ctx context.Context) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err
	}

	statement := `SELECT id_privilege, nama_privilege, created_at, updated_at, catatan FROM Privilege WHERE deleted_at IS NULL`

	rows, err := tx.QueryContext(ctx, statement)

	if err != nil {
		log.Printf("Failed to fetch privileges: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to get all privileges ", Data: nil}, err

	}
	defer rows.Close()

	privileges := []class.Privilege{}

	for rows.Next() {
		var privilege class.Privilege
		var Catatan sql.NullString
		err := rows.Scan(&privilege.IDPrivilege, &privilege.NamaPrivilege, &privilege.CreatedAt, &privilege.UpdatedAt, &Catatan)
		if err != nil {
			log.Printf("Failed to scan privilege row: %v\n", err)
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch privilege row", Data: nil}, err
		}

		// perbaikan error unsupported convertng null to string ? aneh ini , di karyawan catatan nya bisa tp ?
		if Catatan.Valid {
			privilege.Catatan = Catatan.String
		} else {
			privilege.Catatan = ""
		}
		privileges = append(privileges, privilege)
	}

	if err = rows.Err(); err != nil {
		log.Printf("Row iteration error: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to loop privilege row", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err
	}
	return class.Response{Status: http.StatusOK, Message: "Berhasil menampilkan seluruh role yang ada", Data: privileges}, err
}

func GetPrivilegeByID(ctx context.Context, idprivilege string) (class.Response, error) {
	var privilege class.Privilege
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)

	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err

	}

	staement := `SELECT id_privilege,nama_privilege,created_at,updated_at,catatan FROM Privilege WHERE id_privilege = ? AND deleted_at IS NULL`
	var catatan sql.NullString //fix string convert error atau apalah itu , yg errornya gara-gara catatan itu valuenya nulluoeue

	err = tx.QueryRowContext(ctx, staement, idprivilege).Scan(&privilege.IDPrivilege, &privilege.NamaPrivilege, &privilege.CreatedAt, &privilege.UpdatedAt, &catatan)
	if err != nil {
		if err == sql.ErrNoRows {
			tx.Rollback()
			return class.Response{Status: http.StatusNotFound, Message: "privilege not found", Data: nil}, nil
		}
		log.Printf("\nerror query privilege : %v ", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "failed to get privilege", Data: nil}, nil
	}

	if catatan.Valid {
		privilege.Catatan = catatan.String
	} else {
		privilege.Catatan = "" //fix catatan nill error pecah pala dah nt meledak

	}

	err = tx.Commit()

	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err

	}
	return class.Response{Status: http.StatusOK, Message: "berhasil mengambil data privilege", Data: privilege}, nil

}

func UpdatePrivilege(ctx context.Context, idupdate string, privilege class.Privilege) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err

	}
	var exists bool
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Privilege WHere id_privilege=? AND deleted_at is null)`, idupdate).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking privielge existence"}, err

	}
	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "privilege not found"}, nil

	}

	updatestatement := `UPDATE Privilege SET id_privilege=? ,nama_privilege =?, catatan=?, updated_at =NOW() WHERE id_privilege=?`
	log.Println("dari obj ", privilege.IDPrivilege)
	log.Println("dari param ", idupdate)
	_, err = tx.ExecContext(ctx, updatestatement, privilege.IDPrivilege, privilege.NamaPrivilege, privilege.Catatan, idupdate)
	if err != nil {
		tx.Rollback()
		log.Println("error update ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update privilege"}, err
	}
	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "transaction commit error"}, err

	}
	return class.Response{Status: http.StatusOK, Message: "berhasil update data privilege"}, nil

}

func DeletePrivilege(ctx context.Context, iddelete string) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)

	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start failed", Data: nil}, err
	}

	var exists bool //cek apakah ada id yg mau did delte itu
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Privilege WHere id_privilege=? AND deleted_at is null)`, iddelete).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking Privilege existence"}, err

	}
	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "Privilege not found"}, nil

	}

	querydelete := `UPDATE Privilege SET updated_at = NOW(), deleted_at=NOw() WHERE id_privilege = ? `
	_, err = tx.ExecContext(ctx, querydelete, iddelete)
	if err != nil {
		log.Println("Failed to soft delete Privilege: ", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete Privilege", Data: nil}, err

	}
	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "transaction commit error"}, err

	}

	return class.Response{Status: http.StatusOK, Message: "berhasil delete data Privilege"}, nil
}
