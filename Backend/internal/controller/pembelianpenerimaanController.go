package internal

import (
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
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

	requestBody.Penerima = idKaryawan.(string)

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
