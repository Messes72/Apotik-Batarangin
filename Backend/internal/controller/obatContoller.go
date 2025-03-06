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

const (
	JenisGudang = "gudang"
	JenisApotik = "apotek"
)

func AddObat(c echo.Context) error {
	var requestBody class.Obat

	// Bind the request body
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})
	}

	log.Printf("Received data: %+v", requestBody)

	// Validate required fields
	if requestBody.Nama == "" || requestBody.IDSatuan == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Nama, ID Kategori, ID Depo, and ID Satuan tidak boleh kosong"})
	}

	// Get ID Karyawan from JWT token
	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing id_karyawan in token"})
	}

	idDepoparam := c.QueryParam("depo")

	idKategori := c.Param("id_kategori")

	jenis := c.QueryParam("jenis") //apotik or gudang

	if jenis != JenisGudang && jenis != JenisApotik {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "jenis harus antara 'gudang' atau 'apotik' "})
	}
	// Call the model function
	result, err := model.AddObat(c.Request().Context(), requestBody, idKategori, idDepoparam, idKaryawan.(string), jenis)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func GetObat(c echo.Context) error {
	idobat := c.QueryParam("id_obat")
	pageparam := c.QueryParam("page")
	pagesizeparam := c.QueryParam("page_size")
	idkategori := c.Param("id_kategori")
	jenis := c.QueryParam("jenis") //apotik or gudang

	if jenis != JenisGudang && jenis != JenisApotik {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "jenis harus antara 'gudang' atau 'apotik' "})
	}
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

	result, err := model.GetObat(c.Request().Context(), idobat, idkategori, page, pageSize, jenis)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})

	}
	return c.JSON(result.Status, result)
}

func UpdateObat(c echo.Context) error {
	idkategori := c.Param("id_kategori")
	idobat := c.Param("id_obat")
	idkaryawan, ok := c.Get("id_karyawan").(string)
	if !ok {
		log.Println("id karyawan tidak diterima di controller updateobat dari jwt token, atau isi id karyawan bukan string")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, karyawan tidak dikenali"})
	}

	jenis := c.QueryParam("jenis") //apotik or gudang

	if jenis != JenisGudang && jenis != JenisApotik {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "jenis harus antara 'gudang' atau 'apotik' "})
	}

	var requestBody class.Obat
	err := c.Bind(&requestBody)
	log.Println("error r	equest body ", err)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})
	}

	parsedTime, err := time.Parse("2006-01-02", requestBody.Kadaluarsa)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid kadaluarsa format"})
	}

	requestBody.Kadaluarsa = parsedTime.Format("2006-01-02")

	if requestBody.Nama == "" || requestBody.IDSatuan == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Nama, ID Depo, and ID Satuan tidak boleh kosong"})
	}

	result, err := model.UpdateObat(c.Request().Context(), idkategori, idobat, requestBody, idkaryawan, jenis)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func DeleteObat(c echo.Context) error {

	idkategori := c.Param("id_kategori")
	idobat := c.Param("id_obat")
	idkaryawan, ok := c.Get("id_karyawan").(string)
	if !ok {
		log.Println("id karyawan tidak diterima di controller updateobat dari jwt token, atau isi id karyawan bukan string")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, karyawan tidak dikenali"})
	}
	jenis := c.QueryParam("jenis") //apotik or gudang

	if jenis != JenisGudang && jenis != JenisApotik {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "jenis harus antara 'gudang' atau 'apotik' "})
	}
	_ = idkategori //nanti perlu ditentukan apakah perlu idkategori untuk langkah penghapusan karena sebenernya tidak diperlukan
	//sementara gini , buat menghindari dia error gara2 dibuat tp tidak dipakai, kalau gak perlu ya nanti hapus aja tp jangan lupa tambahkan idkategori di query di model nya juga

	result, err := model.DeleteObat(c.Request().Context(), idobat, idkaryawan, jenis)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)

}
