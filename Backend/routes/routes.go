package internal

import (
	controller "proyekApotik/internal/controller"
	middleware "proyekApotik/internal/middleware"

	"github.com/labstack/echo/v4"
)

func Init() *echo.Echo {
	e := echo.New()
	e.Use(middleware.CORSMiddleware())
	e.Static("/uploads", "uploads")

	// e.Static("/uploads", "uploads")

	e.POST("/login", controller.LoginKaryawan)

	// Applying middleware for API key and JWT authentication
	karyawanRoute := e.Group("/karyawan")
	karyawanRoute.Use(middleware.CheckAPIKey)
	karyawanRoute.Use(middleware.JWTMiddleware)

	// Route for creating a new karyawan (POST for creating)
	karyawanRoute.POST("/create", controller.AddKaryawan, middleware.CheckPrivilege("Create User")) // POST /karyawan

	// Route for fetching all karyawan (GET for reading resources)
	karyawanRoute.GET("", controller.GetKaryawan, middleware.CheckPrivilege("Get User")) // GET /karyawan
	karyawanRoute.GET("/:id_karyawan", controller.GetKaryawan, middleware.CheckPrivilege("Get User"))
	karyawanRoute.PUT("/:id_karyawanupdate/edit", controller.UpdateKaryawan, middleware.CheckPrivilege("Edit User"))
	karyawanRoute.PUT("/:id_karyawandelete/delete", controller.DeleteKaryawan, middleware.CheckPrivilege("Delete User"))

	routeRole := e.Group("/role")
	routeRole.Use(middleware.CheckAPIKey)
	routeRole.Use(middleware.JWTMiddleware)
	routeRole.POST("/create", controller.CreateRole)
	routeRole.GET("/role", controller.GetAllRole)
	routeRole.GET("/:id_role/info", controller.GetRoleByID)
	routeRole.PUT("/:id_role/edit", controller.UpdateRole)
	routeRole.PUT("/:id_role/delete", controller.DeleteRole)

	routePrivilege := e.Group("/privilege")
	routePrivilege.Use(middleware.CheckAPIKey)
	routePrivilege.Use(middleware.JWTMiddleware)

	routePrivilege.POST("/create", controller.CreatePrivilege)
	routePrivilege.GET("", controller.GetAllPrivilege)
	routePrivilege.GET("/:id_privilege/info", controller.GetPrivilegeByID)
	routePrivilege.PUT("/:id_privilege/edit", controller.UpdatePrivilege)
	routePrivilege.PUT("/:id_privilege/delete", controller.DeletePrivilege)

	routeKustomer := e.Group("/kustomer")
	routeKustomer.Use(middleware.CheckAPIKey)
	routeKustomer.Use(middleware.JWTMiddleware)
	routeKustomer.GET("", controller.GetKustomer)
	routeKustomer.POST("/create", controller.AddKustomer)
	routeKustomer.PUT("/:id_kustomer/edit", controller.UpdateKustomer)
	routeKustomer.PUT("/:id_kustomer/delete", controller.DeleteKustomer)

	routeSupplier := e.Group("/supplier")
	routeSupplier.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routeSupplier.GET("", controller.GetAllSupplier)
	routeSupplier.GET("/:id_supplier/info", controller.GetSupplier)
	routeSupplier.POST("/create", controller.AddSupplier)
	routeSupplier.PUT("/:id_supplier/edit", controller.EditSupplier)
	routeSupplier.DELETE("/:id_supplier/delete", controller.DeleteSupplier)

	routeKategori := e.Group("/category")
	routeKategori.Use(middleware.CheckAPIKey)
	routeKategori.Use(middleware.JWTMiddleware)
	routeKategori.GET("", controller.GetKategori)
	routeKategori.POST("/create", controller.AddKategori)
	routeKategori.PUT("/:id_kategori/edit", controller.UpdateKategori)
	routeKategori.DELETE("/:id_kategori/delete", controller.DeleteKategori)

	routesatuan := e.Group("/satuan")
	routesatuan.Use(middleware.CheckAPIKey)
	routesatuan.Use(middleware.JWTMiddleware)
	routesatuan.GET("", controller.GetSatuan)

	routedepo := e.Group("/depo")
	routedepo.Use(middleware.CheckAPIKey)
	routedepo.Use(middleware.JWTMiddleware)
	routedepo.GET("", controller.GetDepo)

	routeProduk := e.Group("/product")
	routeProduk.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routeProduk.POST("/create", controller.AddObat)
	routeProduk.GET("/info", controller.GetObat)
	routeProduk.POST("/:id_obat/edit", controller.UpdateObat)
	routeProduk.DELETE("/:id_obat/delete", controller.DeleteObat)
	routeProduk.POST("/racik/create", controller.CreateObatRacik)
	routeProduk.GET("/racik/:id_obat_racik", controller.GetObatRacik)
	routeProduk.GET("/racik", controller.GetAllObatRacik)
	routeProduk.DELETE("/racik/:id_obat_racik/delete", controller.DeleteObatRacik)
	routeProduk.PUT("/racik/:id_obat_racik/edit", controller.EditObatRacik)

	routePembelianPenjualan := e.Group("/pembelianbarang")
	routePembelianPenjualan.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routePembelianPenjualan.POST("/create", controller.CreatePembelian)
	routePembelianPenjualan.GET("", controller.GetAllPembelian)
	routePembelianPenjualan.GET("/:id_pembelian_penerimaan_obat", controller.GetPembelianDetail)

	routePenerimaanBarang := e.Group("/penerimaanbarang")
	routePenerimaanBarang.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routePenerimaanBarang.POST("/create", controller.CreatePenerimaan)
	routePenerimaanBarang.PUT("/:id_pembelian_penerimaan/edit", controller.EditPenerimaan)

	routePOS := e.Group("/PoS")
	routePOS.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routePOS.POST("/requestalokasi", controller.AlocateBatchObat)
	routePOS.POST("/checkout", controller.CreateTransaksi)
	routePOS.GET("/stok/:id_obat", controller.GetStokObat)
	routePOS.GET("/:id_transaksi", controller.GetTransaksi)
	routePOS.GET("/transaksi", controller.GetHistoryTransaksi)

	routeRequestBarang := e.Group("/requestbarang")
	routeRequestBarang.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routeRequestBarang.POST("/apotikrequest", controller.RequestBarangApotikKeGudang)
	routeRequestBarang.GET("/:id", controller.GetRequestByID)
	routeRequestBarang.GET("", controller.GetRequest)
	routeRequestBarang.POST("/distribusibarang", controller.FulfilRequestApotik)
	routeRequestBarang.POST("/cancelrequest", controller.CancelRequest)
	routeRequestBarang.PUT("/edit", controller.EditRequest)

	routeStokOpname := e.Group("/stokopname")
	routeStokOpname.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routeStokOpname.POST("/create", controller.CreateStokOpname)
	routeStokOpname.GET("/batch", controller.GetNomorBatch)
	routeStokOpname.GET("/all/:depo", controller.GetAllStokOpname)
	routeStokOpname.GET("/:id_stokopname", controller.GetDetailStokOpname)
	routeStokOpname.GET("/stok/:id_depo", controller.GetSystemStokNow)
	// get stok sekarang untuk saat crate stok opname

	routeReturBarang := e.Group("/retur")
	routeReturBarang.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routeReturBarang.POST("/create", controller.ReturObatApotik)
	routeReturBarang.GET("/:id_depo", controller.GetAllRetur)
	routeReturBarang.GET("/get", controller.GetReturById)

	routelaporan := e.Group("/laporan")
	routelaporan.Use(middleware.CheckAPIKey, middleware.JWTMiddleware)
	routelaporan.GET("", controller.Laporan)
	// routelaporan.GET("/dashboard", controller.Dashboard)
	return e

}
