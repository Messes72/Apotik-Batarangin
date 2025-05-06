package internal

import (
	"log"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"

	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
)

func AlocateBatchObat(c echo.Context) error {
	var requestBody []class.RequestAlokasi
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}

	result, err := model.AlokasiMassalObat(c.Request().Context(), requestBody)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}

func CreateTransaksi(c echo.Context) error {
	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	var requestBody class.PermintaanPembelian
	if err := c.Bind(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{
			Status:  http.StatusBadRequest,
			Message: "Bad JSON",
		})
	}

	if len(requestBody.Items) <= 0 {
		log.Println("user input tidak input list obat")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Wajib menyeritakan obat yang akan dibeli"})

	}

	requestBody.IDKaryawan = idKaryawan.(string)

	result, err := model.TransaksiPenjualanObat(c.Request().Context(), requestBody.IDKaryawan, requestBody.Items, requestBody.Payment, requestBody.IDKustomer)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}

func GetStokObat(c echo.Context) error {

	idobat := c.Param("id_obat")

	if idobat == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "ID obat tidak boleh kosong"})
	}

	result, err := model.GetStokObat(c.Request().Context(), idobat)
	if err != nil {
		return c.JSON(result.Status, result)
	}

	return c.JSON(result.Status, result)
}

func GetTransaksi(c echo.Context) error {

	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	idtransaksi := c.Param("id_transaksi")
	if idtransaksi == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "ID Transakai tidak boleh kosong"})
	}

	result, err := model.GetTransaksi(c.Request().Context(), idtransaksi, idKaryawan.(string))

	if err != nil {
		return c.JSON(result.Status, result)
	}

	return c.JSON(result.Status, result)

}

func GetHistoryTransaksi(c echo.Context) error {
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

	result, err := model.GetHistoryTransaksi(c.Request().Context(), page, pageSize)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})

	}
	return c.JSON(result.Status, result)
}
