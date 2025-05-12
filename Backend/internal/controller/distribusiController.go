package internal

import (
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"

	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
)

func RequestBarangApotikKeGudang(c echo.Context) error {
	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	var requestBody class.RequestBarang
	if err := c.Bind(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{
			Status:  http.StatusBadRequest,
			Message: "Bad JSON",
		})
	}

	if len(requestBody.ListObat) <= 0 {
		log.Println("user input tidak input list obat")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Wajib menyeritakan obat yang akan diminta"})

	}

	result, err := model.RequestBarangApotikKeGudang(c.Request().Context(), idKaryawan.(string), requestBody.ListObat, requestBody)
	if err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat memproses permintaan"})
	}

	return c.JSON(result.Status, result)
}

func GetRequestByID(c echo.Context) error {
	iddistribusi := c.Param("id_distribusi")
	if iddistribusi == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "parameter permintaan tidak lengkap"})
	}

	result, err := model.GetRequestByID(c.Request().Context(), iddistribusi)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}

func FulfilRequestApotik(c echo.Context) error {

	idKaryawaninput := c.Get("id_karyawan")
	if idKaryawaninput == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	idKaryawan, ok := idKaryawaninput.(string)
	if !ok || idKaryawan == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid karyawan data"})
	}

	var requestBody class.FulfilRequest
	if err := c.Bind(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{
			Status:  http.StatusBadRequest,
			Message: "Invalid Request",
		})
	}

	tanggalpengiriman, err := time.Parse("2006-01-02", requestBody.TanggalPengirimaninput)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "invalid tanggal pengiriman"})
	}

	requestBody.TanggalPengiriman = tanggalpengiriman

	result, err := model.FulfilRequestApotik(c.Request().Context(), idKaryawan, requestBody)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}

func CancelRequest(c echo.Context) error {
	idKaryawaninput := c.Get("id_karyawan")
	if idKaryawaninput == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	idKaryawan, ok := idKaryawaninput.(string)
	if !ok || idKaryawan == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid karyawan data"})
	}

	iddistribusi := c.QueryParam("id")
	if iddistribusi == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "parameter tidak lengkap"})
	}

	result, err := model.CancelRequest(c.Request().Context(), idKaryawan, iddistribusi)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}

func GetRequest(c echo.Context) error {
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

	result, err := model.GetRequest(c.Request().Context(), page, pageSize)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}
