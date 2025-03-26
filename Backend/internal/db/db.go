package db

import (
	// "context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

var OpenCon = 0
var db *sql.DB

func DbClose() {
	db.Close()
	OpenCon -= 1
	fmt.Printf("%c%c", 13, 13)
	fmt.Print("Open Con <" + strconv.Itoa(OpenCon) + ">")
}

func DbConnection() (*sql.DB, error) {
	fmt.Println("sesuatu")
	username := os.Getenv("DB_USERNAME")
	password := os.Getenv("DB_PASSWORD")
	hostname := os.Getenv("DB_HOSTNAME")
	port := os.Getenv("DB_PORT")
	dbname := os.Getenv("DB_NAME")

	connectionString := username + ":" + password + "@tcp(" + hostname + ":" + port + ")/" + dbname + "?parseTime=true"
	dbTemp, err := sql.Open("mysql", connectionString)
	if err != nil {
		log.Printf("Error %s when opening DB\n", err)
		return nil, err
	}
	db = dbTemp
	err = db.Ping()

	if err != nil {
		fmt.Println("Err :", err)
		fmt.Println("tidak dapat membuka koneksi")
		return nil, err
	}

	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(time.Minute * 5)

	// ctx, cancelfunc := context.WithTimeout(context.Background(), 5*time.Second)
	// defer cancelfunc()
	// err = db.PingContext(ctx)
	// if err != nil {
	//  log.Printf("Errors %s pinging DB", err)
	//  return nil, err
	// }

	// OpenCon += 1
	// fmt.Printf("%c%c", 13, 13)
	// fmt.Print("Open Con <" + strconv.Itoa(OpenCon) + ">")
	return db, nil
}

func GetDBCon() *sql.DB {
	return db
}
