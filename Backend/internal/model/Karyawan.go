package internal

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"proyekApotik/internal/db"
	"time"

	// auth "proyekApotik/internal/auth"
	class "proyekApotik/internal/class"
	"proyekApotik/pkg"

	auth "proyekApotik/internal/auth"
)

func AddKaryawan(karyawan class.Karyawan, username, password string, idcreator string) (class.Response, error) {
	con := db.GetDBCon()

	// Start transaction
	tx, err := con.Begin()
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err
	}

	// Check username ada ga
	var existingUserID int
	query := "SELECT id FROM StaffLogin WHERE username = ?"
	err = tx.QueryRow(query, username).Scan(&existingUserID) //queryrow return 1 value
	if err != nil && err != sql.ErrNoRows {
		tx.Rollback()
		log.Printf("Database query error: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database query error", Data: nil}, err
	}
	if existingUserID != 0 {
		tx.Rollback()
		return class.Response{Status: http.StatusConflict, Message: "Username exist", Data: nil}, nil
	}

	var counter int
	queryCounter := `SELECT count FROM karyawancounter FOR UPDATE`
	err = tx.QueryRow(queryCounter).Scan(&counter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to fetch counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to fetch obat counter", Data: nil}, err
	}

	newCounter := counter + 1
	prefix := "KAR"
	newidkaryawan := fmt.Sprintf("%s%d", prefix, newCounter)
	log.Printf("New id obat: %s", newidkaryawan)

	updateCounter := `UPDATE karyawancounter SET count = ?`
	_, err = tx.Exec(updateCounter, newCounter)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to update obat counter: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update counter", Data: nil}, err
	}

	// Insert into Karyawan
	insertKaryawan := `
			INSERT INTO Karyawan (id_karyawan, nama, alamat, no_telp, created_at, updated_at,catatan) 
			VALUES (?, ?, ?, ?, NOW(), NOW(),?)`
	_, err = tx.Exec(insertKaryawan, newidkaryawan, karyawan.Nama, karyawan.Alamat, karyawan.NoTelp, karyawan.Catatan)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to insert Karyawan: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to insert staff", Data: nil}, err
	}

	// // Get last inserted ID
	// karyawanID64, err := result.LastInsertId()
	// if err != nil {
	// 	tx.Rollback()
	// 	log.Printf("Failed to retrieve Karyawan ID: %v\n", err)
	// 	return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve staff ID", Data: nil}, err
	// }
	// karyawan.ID = int(karyawanID64)

	// Hash the password
	hashedPassword, err := pkg.HashPassword(password)
	if err != nil {
		tx.Rollback()
		log.Printf("Failed to hash password: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Password hashing failed", Data: nil}, err
	}

	insertLogin := `
			INSERT INTO StaffLogin (id_karyawan, username, password_hash, last_login) 
			VALUES (?, ?, ?, NULL)`
	_, err = tx.Exec(insertLogin, newidkaryawan, username, hashedPassword)
	if err != nil {
		log.Printf("Failed to insert StaffLogin: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to insert login credentials", Data: nil}, err
	}

	insertRole := `
			INSERT INTO detail_role_karyawan (id_role, id_karyawan) 
			VALUES (?, ?)`
	for _, roleID := range karyawan.Roles {
		_, err = tx.Exec(insertRole, roleID.IDRole, newidkaryawan)
		if err != nil {
			log.Printf("Failed to assign role %s: %v\n", roleID, err)
			tx.Rollback()
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to assign role", Data: nil}, err
		}
	}

	insertPrivilege := `
			INSERT INTO detail_privilege_karyawan (id_privilege, id_karyawan) 
			VALUES (?, ?)`
	for _, privilegeID := range karyawan.Privileges {
		_, err = tx.Exec(insertPrivilege, privilegeID.IDPrivilege, newidkaryawan)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to assign privilege %s: %v\n", privilegeID, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to assign privileges", Data: nil}, err
		}
	}

	insertDepo := `INSERT INTO detail_karyawan (id_depo, id_karyawan, created_at, created_by, catatan) VALUES (?,?,NOW(),?,?)`
	for _, depo := range karyawan.Depo {
		_, err = tx.Exec(insertDepo, depo.IDDepo, newidkaryawan, idcreator, depo.Catatan)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to assign depo %s: %v\n", depo.IDDepo, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to assign depo", Data: nil}, err
		}
	}
	// _, err = tx.Exec(insertDepo, karyawan.Depo.IDDepo, newidkaryawan, idcreator, karyawan.Depo.Catatan)
	// if err != nil {
	// 	tx.Rollback()
	// 	log.Printf("Failed to insert depo karyawan: %v\n", err)
	// 	return class.Response{Status: http.StatusInternalServerError, Message: "Failed to insert depo karyawan", Data: nil}, err
	// }

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusCreated, Message: "User added successfully", Data: karyawan}, nil
}
func LoginKaryawan(username, passwordinput, apiKey string) (class.Response, error) {
	var karyawan class.Karyawan
	var roles []class.Role
	var privileges []class.Privilege
	var Password string

	if apiKey != os.Getenv("API_KEY") {
		log.Printf("Invalid API key: %v\n", apiKey)
		return class.Response{Status: http.StatusUnauthorized, Message: "Invalid API Key", Data: nil}, nil
	}

	con := db.GetDBCon()

	// data karyawan
	query := `
		SELECT karyawan.id_karyawan, karyawan.nama, karyawan.alamat, karyawan.no_telp, karyawan.created_at, 
			karyawan.updated_at, karyawan.deleted_at, karyawan.catatan, 
			login.password_hash
		FROM Karyawan karyawan
		LEFT JOIN StaffLogin login ON login.id_karyawan = karyawan.id_karyawan
		WHERE login.username = ?`

	err := con.QueryRow(query, username).
		Scan(&karyawan.IDKaryawan, &karyawan.Nama, &karyawan.Alamat, &karyawan.NoTelp, &karyawan.CreatedAt,
			&karyawan.UpdatedAt, &karyawan.DeletedAt, &karyawan.Catatan, &Password)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("karywan not found: %v\n", username)
			return class.Response{Status: http.StatusUnauthorized, Message: "Invalid Username", Data: nil}, nil
		}
		log.Printf("Error query user: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Database error", Data: nil}, err
	}

	// Check if the user is blocked
	// if karyawan.Status == 2 {
	// 	log.Printf("Blocked user attempted login: %v\n", username)
	// 	return class.Response{Status: http.StatusForbidden, Message: "User is blocked", Data: nil}, nil
	// }

	// Validate the password
	err = pkg.CheckPasswordHash(Password, passwordinput)
	if err != nil {
		log.Printf("Invalid password: %v\n", err)
		return class.Response{Status: http.StatusUnauthorized, Message: "Invalid password", Data: nil}, nil
	}

	// role karywan ngambil dari detail role dan pakai info dari tble role untuk tambahan info detaol suatu role
	//intine ngambil nama role dari role table tp hanya untuk entry yang ada di detail role yg idrolenya match dan dimiliki oleh seseorang
	rows, err := con.Query(`
			SELECT r.id, r.id_role, r.nama_role 
			FROM detail_role_karyawan dr
			JOIN Role r ON dr.id_role = r.id_role
			WHERE dr.id_karyawan = ?`, karyawan.IDKaryawan)
	if err != nil {
		log.Printf("Error fetching roles: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error fetching roles", Data: nil}, err
	}
	defer rows.Close()

	for rows.Next() {
		var role class.Role
		if err := rows.Scan(&role.ID, &role.IDRole, &role.NamaRole); err != nil {
			log.Printf("Error scanning role: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error scanning role", Data: nil}, err
		}
		roles = append(roles, role)
	}

	//priv karyawna
	rows, err = con.Query(`
			SELECT p.id_privilege, p.nama_privilege 
			FROM detail_privilege_karyawan dp
			JOIN Privilege p ON dp.id_privilege = p.id_privilege
			WHERE dp.id_karyawan = ?`, karyawan.IDKaryawan)
	if err != nil {
		log.Printf("Error fetching privileges: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error fetching privileges", Data: nil}, err
	}
	defer rows.Close()

	for rows.Next() {
		var privilege class.Privilege
		if err := rows.Scan(&privilege.IDPrivilege, &privilege.NamaPrivilege); err != nil {
			log.Printf("Error scanning privilege: model  %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error scanning privilege", Data: nil}, err
		}
		privileges = append(privileges, privilege)
	}
	queryDepo := `SELECT d.id_depo, d.nama
	FROM detail_karyawan dk
	JOIN Depo d ON dk.id_depo = d.id_depo
	WHERE dk.id_karyawan = ?`
	queryDepoRow, err := con.Query(queryDepo, karyawan.IDKaryawan)
	if err != nil {
		log.Printf("Failed to fetch depos for karyawan %s: %v\n", karyawan.IDKaryawan, err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve depos", Data: nil}, err
	}
	defer queryDepoRow.Close()

	var depos []class.Depo
	for queryDepoRow.Next() {
		var depo class.Depo
		if err := queryDepoRow.Scan(&depo.IDDepo, &depo.Nama); err != nil {
			log.Printf("Failed to scan depo for karyawan %s: %v\n", karyawan.IDKaryawan, err)
			continue
		}
		log.Println(len(depos), "panjang nya depo array")
		depos = append(depos, depo)
	}
	log.Println(len(depos))
	log.Println("karyawan id ", karyawan.IDKaryawan)

	// Generate JWT token
	JWTToken, err := auth.GenerateJWTToken(karyawan.IDKaryawan, privileges, depos)
	if err != nil {
		log.Printf("Error generating token: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error generating token", Data: nil}, err
	}

	querystatement := `UPDATE StaffLogin SET last_login = NOW() WHERE username=?`
	_, err = con.Exec(querystatement, username)
	if err != nil {
		log.Printf("Error update last login user: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "error while updating db", Data: nil}, err
	}

	data := map[string]interface{}{
		"karyawan_id": karyawan.IDKaryawan,
		"nama":        karyawan.Nama,
		"alamat":      karyawan.Alamat,
		"no_telp":     karyawan.NoTelp,
		"created_at":  karyawan.CreatedAt,
		"updated_at":  karyawan.UpdatedAt,
		"deleted_at":  karyawan.DeletedAt,
		"catatan":     karyawan.Catatan,
		// "status":
		"role":       roles,
		"privileges": privileges,
		"depos":      depos,
		"jwttoken":   JWTToken,
	}

	// log.Printf("Login Successful: %v\n", data)

	return class.Response{Status: http.StatusOK, Message: "Login Successful", Data: data}, nil
}

func GetKaryawan(id string, page, pageSize int) (class.Response, error) {
	var response class.Response
	karyawans := []class.Karyawan{}

	// Default pagination value
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 {
		pageSize = 10
	}

	con := db.GetDBCon()

	if id != "" { // kalau ada dikasi id maka getbyid
		var karyawan class.Karyawan

		query := `SELECT id_karyawan, nama, alamat, no_telp, created_at, updated_at, deleted_at, catatan 
				  FROM Karyawan WHERE id_karyawan = ? AND deleted_at IS NULL`
		err := con.QueryRow(query, id).Scan(&karyawan.IDKaryawan, &karyawan.Nama, &karyawan.Alamat, &karyawan.NoTelp, &karyawan.CreatedAt, &karyawan.UpdatedAt, &karyawan.DeletedAt, &karyawan.Catatan)
		if err != nil {
			if err == sql.ErrNoRows {
				log.Printf("Karyawan with ID %s not found\n", id)
				return class.Response{Status: http.StatusNotFound, Message: "Tidak dapat menemukan data karyawan tersebut", Data: nil}, nil
			}
			log.Printf("Failed to fetch karyawan ID %s: %v\n", id, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "gagal mengambil data karyawan", Data: nil}, err
		}

		queryRole := `SELECT r.id_role, r.nama_role FROM detail_role_karyawan dr JOIN Role r ON dr.id_role = r.id_role WHERE dr.id_karyawan = ?`
		queryRoleRow, err := con.Query(queryRole, id)
		if err != nil {
			log.Printf("Failed to fetch roles for karyawan %s: %v\n", id, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve roles", Data: nil}, err
		}
		defer queryRoleRow.Close()

		var roles []class.Role
		for queryRoleRow.Next() {
			var role class.Role
			if err := queryRoleRow.Scan(&role.IDRole, &role.NamaRole); err != nil {
				log.Printf("Failed to scan role for karyawan %s: %v\n", id, err)
				continue
			}
			roles = append(roles, role)
		}
		karyawan.Roles = roles

		queryPrivilege := `SELECT p.id_privilege, p.nama_privilege FROM detail_privilege_karyawan dp JOIN Privilege p ON dp.id_privilege = p.id_privilege WHERE dp.id_karyawan = ?`
		queryPrivilegeRow, err := con.Query(queryPrivilege, id)
		if err != nil {
			log.Printf("Failed to fetch privileges karyawan %s: %v\n", id, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve privileges", Data: nil}, err
		}
		defer queryPrivilegeRow.Close()

		var privileges []class.Privilege
		for queryPrivilegeRow.Next() {
			var privilege class.Privilege
			if err := queryPrivilegeRow.Scan(&privilege.IDPrivilege, &privilege.NamaPrivilege); err != nil {
				log.Printf("Failed to scan privilege for karyawan %s: %v\n", id, err)
				continue
			}
			privileges = append(privileges, privilege)
		}
		karyawan.Privileges = privileges

		queryDepo := `SELECT d.id_depo, d.nama, d.alamat, d.no_telp, d.catatan 
              FROM detail_karyawan dk
              JOIN Depo d ON dk.id_depo = d.id_depo
              WHERE dk.id_karyawan = ?`
		queryDepoRow, err := con.Query(queryDepo, id)
		log.Println("id : ", id)
		if err != nil {
			log.Printf("Failed to fetch depos for karyawan %s: %v\n", id, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve depos", Data: nil}, err
		}
		defer queryDepoRow.Close()

		var depos []class.Depo
		for queryDepoRow.Next() {
			var depo class.Depo
			if err := queryDepoRow.Scan(&depo.IDDepo, &depo.Nama, &depo.Alamat, &depo.NoTelp, &depo.Catatan); err != nil {

				log.Printf("Failed to scan depo for karyawan %s: %v\n", id, err)
				continue
			}
			log.Println("depo : ", depo)
			depos = append(depos, depo)
		}
		karyawan.Depo = depos

		return class.Response{Status: http.StatusOK, Message: "Karyawan retrieved successfully", Data: karyawan}, nil

	} else { //kalo ga ada id maka get all with paginaton

		offset := (page - 1) * pageSize

		// Query karyawan data pagination
		query := `SELECT id_karyawan, nama, alamat, no_telp, created_at, updated_at, deleted_at, catatan 
				  FROM Karyawan WHERE deleted_at IS NULL LIMIT ? OFFSET ?`
		rows, err := con.Query(query, pageSize, offset)
		if err != nil {
			log.Printf("Failed to execute query: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve karyawan", Data: nil}, err
		}
		defer rows.Close()

		for rows.Next() {
			var karyawan class.Karyawan
			err := rows.Scan(&karyawan.IDKaryawan, &karyawan.Nama, &karyawan.Alamat, &karyawan.NoTelp, &karyawan.CreatedAt, &karyawan.UpdatedAt, &karyawan.DeletedAt, &karyawan.Catatan)
			if err != nil {
				log.Printf("Failed to scan karyawan: %v\n", err)
				continue
			}

			// role karyawan
			roleQuery := `SELECT r.id_role, r.nama_role FROM detail_role_karyawan dr JOIN Role r ON dr.id_role = r.id_role WHERE dr.id_karyawan = ?`
			roleRows, err := con.Query(roleQuery, karyawan.IDKaryawan)
			if err != nil {
				log.Printf("Failed to fetch roles for karyawan %v: %v\n", karyawan.IDKaryawan, err)
				continue
			}
			defer roleRows.Close()

			var roles []class.Role
			for roleRows.Next() {
				var role class.Role
				err := roleRows.Scan(&role.IDRole, &role.NamaRole)
				if err != nil {
					log.Printf("Failed to scan role for karyawan %v: %v\n", karyawan.IDKaryawan, err)
					continue
				}
				roles = append(roles, role)
			}
			karyawan.Roles = roles

			// priv karyawan
			privQuery := `SELECT p.id_privilege, p.nama_privilege FROM detail_privilege_karyawan dp JOIN Privilege p ON dp.id_privilege = p.id_privilege WHERE dp.id_karyawan = ?`
			privRows, err := con.Query(privQuery, karyawan.IDKaryawan)
			if err != nil {
				log.Printf("Failed to fetch privileges for karyawan %v: %v\n", karyawan.IDKaryawan, err)
				continue
			}
			defer privRows.Close()

			var privileges []class.Privilege
			for privRows.Next() {
				var privilege class.Privilege
				err := privRows.Scan(&privilege.IDPrivilege, &privilege.NamaPrivilege)
				if err != nil {
					log.Printf("Failed to scan privilege for karyawan %v: %v\n", karyawan.IDKaryawan, err)
					continue
				}
				privileges = append(privileges, privilege)
			}
			karyawan.Privileges = privileges

			queryDepo := `SELECT d.id_depo, d.nama, d.alamat, d.no_telp, d.catatan 
              FROM detail_karyawan dk
              JOIN Depo d ON dk.id_depo = d.id_depo
              WHERE dk.id_karyawan = ?`
			queryDepoRow, err := con.Query(queryDepo, karyawan.IDKaryawan)
			if err != nil {
				log.Printf("Failed to fetch depos for karyawan %s: %v\n", id, err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve depos", Data: nil}, err
			}
			defer queryDepoRow.Close()

			var depos []class.Depo
			for queryDepoRow.Next() {
				var depo class.Depo
				err := queryDepoRow.Scan(&depo.IDDepo, &depo.Nama, &depo.Alamat, &depo.NoTelp, &depo.Catatan)
				if err != nil {
					log.Printf("Failed to scan depo for karyawan %s: %v\n", id, err)
					continue
				}

				log.Println("depo : ", depo)
				depos = append(depos, depo)
			}
			karyawan.Depo = depos

			karyawans = append(karyawans, karyawan)
		}

		if err := rows.Err(); err != nil {
			return class.Response{Status: http.StatusInternalServerError, Message: "Error processing karyawan data", Data: nil}, err
		}

		var totalRecords int
		countQuery := `SELECT COUNT(*) FROM Karyawan WHERE deleted_at IS NULL`
		err = con.QueryRow(countQuery).Scan(&totalRecords)
		if err != nil {
			log.Printf("Failed to count total karyawans: %v\n", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to retrieve total records", Data: nil}, err
		}

		totalPages := (totalRecords + pageSize - 1) / pageSize

		metadata := class.Metadata{
			CurrentPage:  page,
			PageSize:     pageSize,
			TotalPages:   totalPages,
			TotalRecords: totalRecords,
		}

		response = class.Response{
			Status:   http.StatusOK,
			Message:  "Data karyawan berhasil diambil",
			Data:     karyawans,
			Metadata: metadata,
		}
		return response, nil
	}
}

func UpdateKaryawan(ctx context.Context, idnow string, idupdate string, karyawan class.Karyawan) (class.Response, error) {
	con := db.GetDBCon()
	log.Println("modal", idnow, idupdate)
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction tx start failed", Data: nil}, err
	}

	statementkaryawan := `UPDATE Karyawan SET nama = ? , alamat = ? , no_telp = ? , catatan = ?, updated_at = NOW() WHERE id_karyawan = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, statementkaryawan, karyawan.Nama, karyawan.Alamat, karyawan.NoTelp, karyawan.Catatan, idupdate)
	if err != nil {
		log.Printf("Failed to update data karyawan: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to update data karyawan", Data: nil}, err
	}

	var count int
	checkQuery := `SELECT COUNT(*) FROM Karyawan WHERE id_karyawan = ?`
	err = tx.QueryRowContext(ctx, checkQuery, idupdate).Scan(&count)
	if err != nil || count == 0 {
		tx.Rollback()
		return class.Response{Status: http.StatusBadRequest, Message: "Karyawan not found", Data: nil}, errors.New("karyawan not found")
	}

	statementroledelete := `UPDATE detail_role_karyawan SET deleted_at = NOW() WHERE id_karyawan = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, statementroledelete, idupdate)
	if err != nil {
		log.Printf("Failed to delete old roles: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete old roles", Data: nil}, err
	}

	insertRole := `
		INSERT INTO detail_role_karyawan (id_role, id_karyawan, updated_at, updated_by) 
		VALUES (?, ?, NOW(), ?)`

	for _, roleID := range karyawan.Roles {
		var roleCount int
		roleCheckQuery := `SELECT COUNT(*) FROM Role WHERE id_role = ?`
		err = tx.QueryRowContext(ctx, roleCheckQuery, roleID.IDRole).Scan(&roleCount)
		if err != nil || roleCount == 0 {
			tx.Rollback()
			return class.Response{Status: http.StatusBadRequest, Message: "role tidak ditemukan", Data: nil}, err
		}

		_, err = tx.ExecContext(ctx, insertRole, roleID.IDRole, idupdate, idnow)
		if err != nil {
			tx.Rollback()
			log.Println("Failed to assign role", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to assign role", Data: nil}, err
		}
	}

	statementprivilegedelete := `UPDATE detail_privilege_karyawan SET deleted_at = NOW() WHERE id_karyawan = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, statementprivilegedelete, idupdate)
	if err != nil {
		log.Printf("Failed to delete old privileges: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete old privileges", Data: nil}, err
	}

	insertPrivilege := `
		INSERT INTO detail_privilege_karyawan (id_privilege, id_karyawan, updated_at, updated_by) 
		VALUES (?, ?, NOW(), ?)`
	for _, privilegeID := range karyawan.Privileges {
		_, err = tx.ExecContext(ctx, insertPrivilege, privilegeID.IDPrivilege, idupdate, idnow)
		if err != nil {
			tx.Rollback()
			log.Println("Failed to assign privilege", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to assign privileges", Data: nil}, err
		}
	}
	statementdeletedepo := `UPDATE detail_karyawan SET deleted_at= NOW() WHERE id_karyawan = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, statementdeletedepo, idupdate)
	if err != nil {
		log.Printf("Failed to delete old depo: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete old depo", Data: nil}, err
	}

	for _, depo := range karyawan.Depo {
		var createdBy *string
		var createdAt time.Time

		// Check if there is an existing record for this id_depo
		queryExisting := `
			SELECT created_by, created_at FROM detail_karyawan 
			WHERE id_karyawan = ? AND id_depo = ? AND deleted_at IS NOT NULL
			ORDER BY created_at DESC LIMIT 1
		`
		row := tx.QueryRow(queryExisting, idupdate, depo.IDDepo)
		err := row.Scan(&createdBy, &createdAt)

		if err != nil {
			// If no existing record, use the current user and timestamp
			createdBy = &idnow
			createdAt = time.Now()
		}

		insertDepo := `
			INSERT INTO detail_karyawan (id_depo, id_karyawan, created_at, created_by, updated_at, updated_by,catatan) 
			VALUES (?, ?, ?, ?,NOW(),?, ?)
		`
		_, err = tx.Exec(insertDepo, depo.IDDepo, idupdate, createdAt, createdBy, idnow, depo.Catatan)
		if err != nil {
			tx.Rollback()
			log.Printf("Failed to assign depo %s: %v\n", depo.IDDepo, err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Failed to assign depo", Data: nil}, err
		}
	}

	// insertDepo := `INSERT INTO detail_karyawan (id_depo, id_karyawan, updated_at, updated_by, catatan) VALUES (?,?,NOW(),?,?)`
	// for _, depo := range karyawan.Depo {
	// 	_, err = tx.Exec(insertDepo, depo.IDDepo, idupdate, idnow, depo.Catatan)
	// 	if err != nil {
	// 		tx.Rollback()
	// 		log.Println("id karyawan depo : ", karyawan.IDKaryawan)
	// 		log.Printf("Failed to assign depo %s: %v\n", depo.IDDepo, err)
	// 		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to assign depo", Data: nil}, err
	// 	}
	// }

	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit failed", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Data karyawan berhasil diupdate", Data: nil}, nil
}

func DeleteKaryawan(ctx context.Context, idnow, iddelete, alasan string) (class.Response, error) {
	con := db.GetDBCon()

	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to begin transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction tx start failed", Data: nil}, err
	}

	log.Println("ini id delete", iddelete, "ini id now", idnow)
	//cek apakah ada karyawannya
	var exists bool //default flsae
	err = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM Karyawan WHERE id_karyawan = ? AND deleted_at IS NULL)`, iddelete).Scan(&exists)
	if err != nil {
		log.Printf("Failed to check karyawan existence: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to verify karyawan existence", Data: nil}, err
	}

	if !exists {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "Karyawan not found or already deleted chechking", Data: exists}, nil
	}

	statementdeletekaryawan := `UPDATE Karyawan SET deleted_at = NOW(), updated_at= NOW(), catatan = ? WHERE id_karyawan = ? `
	result, err := tx.ExecContext(ctx, statementdeletekaryawan, alasan, iddelete)

	if err != nil {
		log.Printf("Failed to soft delete data karyawan: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete data karyawan", Data: nil}, err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Failed to get affected rows: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to check deletion result", Data: nil}, err
	}

	if rowsAffected == 0 {
		tx.Rollback()
		return class.Response{Status: http.StatusNotFound, Message: "Karyawan not found or already deleted row affected", Data: nil}, nil
	}

	statementdeleterole := `UPDATE detail_role_karyawan SET updated_at = NOW(), deleted_at = NOW(), updated_by= ? WHERE id_karyawan = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, statementdeleterole, idnow, iddelete)
	if err != nil {
		log.Printf("Failed to soft delete karyawan roles: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete karyawan roles", Data: nil}, err
	}

	statementdeleteprivilege := `UPDATE detail_privilege_karyawan SET updated_at = NOW(), deleted_at =NOW(), updated_by =? WHERE id_karyawan = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, statementdeleteprivilege, idnow, iddelete)
	if err != nil {
		log.Printf("Failed to soft delete karyawan privileges: %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete karyawan privileges", Data: nil}, err
	}

	deleteDetailKaryawanSQL := `UPDATE detail_karyawan SET deleted_at = NOW(), deleted_by = ? WHERE id_karyawan = ? AND deleted_at IS NULL`
	_, err = tx.ExecContext(ctx, deleteDetailKaryawanSQL, idnow, iddelete)
	if err != nil {
		log.Printf("Failed to soft delete karyawan depo : %v\n", err)
		tx.Rollback()
		return class.Response{Status: http.StatusInternalServerError, Message: "Failed to delete karyawan depo ", Data: nil}, err
	}
	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit delete transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit delete failed", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Data Karyawan berhasil di hapus", Data: nil}, nil
}
