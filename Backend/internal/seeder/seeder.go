package seeder

import (
	"fmt"
	"log"
	"proyekApotik/internal/db"
)

func SeedRolesAndPrivileges() {
	con, err := db.DbConnection()
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer con.Close()

	// Insert Roles
	roles := []struct {
		id   int
		name string
	}{
		{1, "Admin"},
		{2, "Manager"},
		{3, "Staff"},
	}

	for _, role := range roles {
		_, err := con.Exec("INSERT INTO Role (id_role, nama_role) VALUES (?, ?) ON DUPLICATE KEY UPDATE nama_role = ?", role.id, role.name, role.name)
		if err != nil {
			log.Printf("Error inserting role %s: %v", role.name, err)
		} else {
			fmt.Printf("Inserted role: %s\n", role.name)
		}
	}

	// Insert Privileges
	privileges := []struct {
		id   int
		name string
	}{
		{1, "Create User"},
		{2, "Edit User"},
		{3, "Delete User"},
		{4, "View Reports"},
	}

	for _, priv := range privileges {
		_, err := con.Exec("INSERT INTO Privilege (id_privilege, nama_privilege) VALUES (?, ?) ON DUPLICATE KEY UPDATE nama_privilege = ?", priv.id, priv.name, priv.name)
		if err != nil {
			log.Printf("Error inserting privilege %s: %v", priv.name, err)
		} else {
			fmt.Printf("Inserted privilege: %s\n", priv.name)
		}
	}

	fmt.Println("Seeding completed!")
}
