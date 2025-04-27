package internal

import (
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"
)

func CreatePembelian(c echo.Context) error {
	var requestBody class.PembelianPenerimaan

	if err := c.Bind(&requestBody); err != nil {
		log.Println("Binding Error:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid Request"})
	}

	log.Printf("Request Body: %+v", requestBody)

	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}
	requestBody.CreatedBy = idKaryawan.(string)
	//caraya nanti diterima sebagai string jadi nanti ada 2 tanggal penerimaan 1 string 1 time dimana nanti yg string di convert ke time

	const layoutdate = "2006-01-02"
	tanggalpembelian, err := time.Parse(layoutdate, requestBody.TanggalPembelianInput)
	if err != nil {
		log.Println("Error parsing TanggalPembelianInput:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Error parsing Tanggal Pembelian"})
	}

	requestBody.TanggalPembelian = time.Date(tanggalpembelian.Year(), tanggalpembelian.Month(), tanggalpembelian.Day(), 0, 0, 0, 0, time.UTC)

	if requestBody.TanggalPembayaranInput != "" {
		tanggalpembayaran, err := time.Parse(layoutdate, requestBody.TanggalPembayaranInput)
		if err != nil {
			log.Println("Error parsing TanggalPembelianInput:", err)
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Error parsing Tanggal Pembayaran"})
		}

		tmp := time.Date(tanggalpembayaran.Year(), tanggalpembayaran.Month(), tanggalpembayaran.Day(), 0, 0, 0, 0, time.UTC)
		requestBody.TanggalPembayaran = &tmp
	}

	result, err := model.CreatePembelianPenerimaan(c.Request().Context(), requestBody, requestBody.ObatList)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat memproses Pembelian"})
	}
	return c.JSON(result.Status, result)
}

func CreatePenerimaan(c echo.Context) error {
	var requestBody class.PembelianPenerimaan

	if err := c.Bind(&requestBody); err != nil {
		log.Println("Binding Error:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid Request"})
	}

	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	if idVal, ok := idKaryawan.(string); ok {
		requestBody.Penerima = &idVal
	} else {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Invalid karyawan ID in token",
		})
	}

	const layoutdate = "2006-01-02"
	tanggalpenerimaan, err := time.Parse(layoutdate, requestBody.TanggalPenerimaanInput)
	if err != nil {
		log.Println("Error parsing TanggalPenerimaanInput:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Error parsing Tanggal Penerimaan"})
	}

	requestBody.TanggalPenerimaan = &tanggalpenerimaan

	var listobat []class.DetailPembelianPenerimaan

	for _, obat := range requestBody.ObatList {
		tanggalkadaluarsa, err := time.Parse(layoutdate, obat.KadaluarsaInput)
		if err != nil {
			log.Println("Error parsing KadaluarsaInput:", err)
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Error parsing Kadaluarsa obat"})
		}
		obat.Kadaluarsa = tanggalkadaluarsa
		listobat = append(listobat, obat)

	}

	result, err := model.CreatePenerimaan(c.Request().Context(), requestBody, listobat)
	if err != nil {
		log.Println("Error in CreatePenerimaan:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memproses data penerimaan"})

	}

	return c.JSON(result.Status, result)
}

func GetAllPembelian(c echo.Context) error {
	pageparam := c.QueryParam("page")
	pagesizeparam := c.QueryParam("page_size")

	page := 1
	pageSize := 10

	if pageparam != "" {
		if p, err := strconv.Atoi(pageparam); err == nil && p > 0 {
			page = p
		}
	}
	if pagesizeparam != "" {
		if ps, err := strconv.Atoi(pagesizeparam); err == nil && ps > 0 {
			pageSize = ps
		}
	}
	result, _ := model.GetAllPembelian(c.Request().Context(), page, pageSize)
	// result, err := model.GetAllPembelian(c.Request().Context(), page, pageSize)
	// if err != nil {
	// 	c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat mengambil semua data pembelian"})
	// }
	return c.JSON(result.Status, result)

}

func GetPembelianDetail(c echo.Context) error {
	idpembelian := c.Param("id_pembelian_penerimaan_obat")
	if idpembelian == "" {
		log.Println("Error karena id pembelian di parameter kosong", idpembelian)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Error saat mengambil data"})
	}
	result, _ := model.GetPembelianDetail(c.Request().Context(), idpembelian)
	// // result, err = model.GetPembelianDetail(c.Request().Context(), idpembelian)
	// if err!=nil{
	// 	c.JSON(http.StatusInternalServerError, map[string]string{"message" : "Error saat mengambil data"})
	// }

	return c.JSON(result.Status, result)

}

func EditPenerimaan(c echo.Context) error {

	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	IDPembelianPenerimaanObat := c.Param("id_pembelian_penerimaan")
	if IDPembelianPenerimaanObat == "" {
		c.JSON(http.StatusBadRequest, map[string]string{"message": "Id tidak boleh kosong"})
	}

	var obatbatch []class.DetailPembelianPenerimaan
	if err := c.Bind(&obatbatch); err != nil {
		log.Println("Binding Error:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid Request"})
	}

	const layoutdate = "2006-01-02"

	for i := range obatbatch {
		tanggalkadaluarsa, err := time.Parse(layoutdate, obatbatch[i].KadaluarsaInput)
		if err != nil {
			log.Println("Error di controller saat parsing kadaluarsa", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat memproses data"})
		}
		obatbatch[i].Kadaluarsa = tanggalkadaluarsa
	}

	result, err := model.EditPenerimaan(c.Request().Context(), idKaryawan.(string), obatbatch, IDPembelianPenerimaanObat)
	if err != nil {
		log.Println("Error msg dari controller edit penerimaan : ", err)
	}
	return c.JSON(result.Status, result)
}
