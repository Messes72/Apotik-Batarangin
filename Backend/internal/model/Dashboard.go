// package internal

// import (
// 	"context"
// 	"database/sql"
// 	"log"
// 	class "proyekApotik/internal/class"
// 	"proyekApotik/internal/db"
// )

// func GetTotalStokMovement(ctx context.Context, iddpeo string) (class.ManagementDashboardResponse, error) {
// 	con := db.GetDBCon()

// 	query := `SELECT

// 		SUM(CASE WHEN created_at >= CURRENT_DATE THEN masuk ELSE 0 END) AS daily_in,
// 		SUM(CASE WHEN created_at >= CURRENT_DATE THEN keluar ELSE 0 END) AS daily_out,

// 		SUM(CASE WHEN created_at >= CURRENT_DATE - INTERVAL 7 DAYS THEN masuk ELSE 0 END) AS weekly_in,
// 		SUM(CASE WHEN created_at >= CURRENT_DATE - INTERVAL 7 DAYS THEN keluar ELSE 0 END) AS weekly_out,

// 		SUM(CASE WHEN created_at >= CURRENT_DATE - INTERVAL 30 DAYS THEN masuk ELSE 0 END) AS monthly_in,
// 		SUM(CASE WHEN created_at >= CURRENT_DATE - INTERVAL 30 DAYS THEN keluar ELSE 0 END) AS monthly_out

// 		FROM detail_kartustok
// 		WHERE ($1 = '' OR id_depo = $1)

// 	`
// 	var data class.ManagementDashboardResponse
// 	rows := con.QueryRowContext(ctx, query, iddpeo)
// 	err := rows.Scan(&data.TotalStockMovement.DailyIn, &data.TotalStockMovement.DailyOut, &data.TotalStockMovement.WeeklyIn, &data.TotalStockMovement.WeeklyOut,
// 		&data.TotalStockMovement.MonthlyIn, &data.TotalStockMovement.MonthlyOut)
// 	if err != nil {
// 		if err == sql.ErrNoRows {
// 			log.Println("tidak ada stok movemnet yang ditemukan ", err)
// 			return class.ManagementDashboardResponse{}, nil
// 		}
// 		log.Println("Error saat mengambil data stok movmenet", err)
// 		return class.ManagementDashboardResponse{}, err
// 	}
// 	return data, nil
// }

// func GetTotalPenjualan(ctx context.Context) (float64, error) {

// 	con := db.GetDBCon()

// 	var total float64
// 	query := `SELECT COALESCE(SUM(total_harga),0) FROM transaksi `
// 	err := con.QueryRowContext(ctx, query).Scan(&total)
// 	if err!=nil{
// 		log.Println("Error saat menghitung total penjualan", err)
// 		return 0, err
// 	}
// }

// func DashboardManagement(ctx context.Context) (class.Response, error) {

// 	con := db.GetDBCon()

// }
