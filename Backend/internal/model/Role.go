package internal

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
)

func CreateRole(ctx context.Context, role class.Role) (class.Response, error) {
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

	// Insert query
	query := `INSERT INTO Role (id_role, nama_role, created_at, updated_at, catatan) VALUES (?, ?, NOW(), NOW(), ?)`
	_, err = tx.ExecContext(ctx, query, role.IDRole, role.NamaRole, role.Catatan)

	if err != nil {
		log.Printf("Failed to insert role: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to create role", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err
	}

	return class.Response{Status: http.StatusCreated, Message: "Role successfully created", Data: role}, nil

}

func GetAllRole(ctx context.Context) (class.Response, error) {
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

	statement := `SELECT id_role, nama_role, created_at, updated_at, catatan FROM Role WHERE deleted_at IS NULL`

	rows, err := tx.QueryContext(ctx, statement)

	if err != nil {
		log.Printf("Failed to fetch roles: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to get all role ", Data: nil}, err

	}
	defer rows.Close()

	roles := []class.Role{}

	for rows.Next() {
		var role class.Role
		var Catatan sql.NullString
		err := rows.Scan(&role.IDRole, &role.NamaRole, &role.CreatedAt, &role.UpdatedAt, &Catatan)
		if err != nil {
			log.Printf("Failed to scan role row: %v\n", err)
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch role row", Data: nil}, err
		}

		// perbaikan error unsupported convertng null to string ? aneh ini , di karyawan catatan nya bisa tp ?
		if Catatan.Valid {
			role.Catatan = Catatan.String
		} else {
			role.Catatan = ""
		}
		roles = append(roles, role)
	}

	if err = rows.Err(); err != nil {
		log.Printf("Row iteration error: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to loop role row", Data: nil}, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err
	}
	return class.Response{Status: http.StatusOK, Message: "Berhasil menampilkan seluruh role yang ada", Data: roles}, err
}

func GetRoleByID(ctx context.Context, idrole string) (class.Response, error) {
	var role class.Role
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

	staement := `SELECT id_role,nama_role,created_at,updated_at,catatan FROM Role WHERE id_role = ? AND deleted_at IS NULL`
	var catatan sql.NullString //fix string convert error atau apalah itu , yg errornya gara-gara catatan itu valuenya nulluoeue

	err = tx.QueryRowContext(ctx, staement, idrole).Scan(&role.IDRole, &role.NamaRole, &role.CreatedAt, &role.UpdatedAt, &catatan)
	if err != nil {
		if err == sql.ErrNoRows {
			tx.Rollback()
			return class.Response{Status: http.StatusNotFound, Message: "Role not found", Data: nil}, nil
		}
		log.Printf("\nerror query role : %v ", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "failed to get role", Data: nil}, nil
	}

	if catatan.Valid {
		role.Catatan = catatan.String
	} else {
		role.Catatan = "" //fix catatan nill error pecah pala dah nt meledak

	}

	err = tx.Commit()

	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err

	}
	return class.Response{Status: http.StatusOK, Message: "berhasil mengambil data role", Data: role}, nil

}

func UpdateRole(ctx context.Context, idupdate string, role class.Role) (class.Response, error) {
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
	var exists bool
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Role WHere id_role=? AND deleted_at is null)`, idupdate).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking role existence"}, err

	}
	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "Role not found"}, nil

	}

	updatestatement := `UPDATE Role SET id_role=? ,nama_role =?, catatan=?, updated_at =NOW() WHERE id_role=?`
	log.Println("dari obj ", role.IDRole)
	log.Println("dari param ", idupdate)
	_, err = tx.ExecContext(ctx, updatestatement, role.IDRole, role.NamaRole, role.Catatan, idupdate)
	if err != nil {
		tx.Rollback()
		log.Println("error update ", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update role"}, err
	}
	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "transaction commit error"}, err

	}
	return class.Response{Status: http.StatusOK, Message: "berhasil update data role"}, nil

}

func DeleteRole(ctx context.Context, iddelete string) (class.Response, error) {
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

	var exists bool //cek apakah ada id yg mau did delte itu
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROm Role WHere id_role=? AND deleted_at is null)`, iddelete).Scan(&exists)
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Error checking role existence"}, err

	}
	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "Role not found"}, nil

	}

	querydelete := `UPDATE Role SET updated_at = NOW(), deleted_at=NOw() WHERE id_role = ? `
	_, err = tx.ExecContext(ctx, querydelete, iddelete)
	if err != nil {
		log.Println("Failed to soft delete role: ", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete role", Data: nil}, err

	}
	err = tx.Commit()
	if err != nil {
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "transaction commit error"}, err

	}

	return class.Response{Status: http.StatusOK, Message: "berhasil delete data role"}, nil
}
