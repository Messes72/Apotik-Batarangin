package internal

import (
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"

	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
)

func CreateStokOpname(c echo.Context) error {
	idKaryawaninput := c.Get("id_karyawan")
	if idKaryawaninput == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	idKaryawan, ok := idKaryawaninput.(string)
	if !ok || idKaryawan == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid karyawan data"})
	}

	var requestBody class.RequestStokOpname
	if err := c.Bind(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{
			Status:  http.StatusBadRequest,
			Message: "Invalid Request",
		})
	}

	result, err := model.CreateStokOpname(c.Request().Context(), idKaryawan, requestBody)
	if err != nil {
		c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)

}

func GetNomorBatch(c echo.Context) error {
	idkartustok := c.QueryParam("obat")
	iddepo := c.QueryParam("depo")

	if idkartustok == "" || iddepo == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Terjadi kesalahan pada parameter program"})
	}

	result, err := model.GetNomorBatch(c.Request().Context(), idkartustok, iddepo)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}

func GetAllStokOpname(c echo.Context) error {
	iddepo := c.Param("depo")
	if iddepo == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Terjadi kesalahan pada parameter program"})
	}
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

	result, err := model.GetAllStokOpname(c.Request().Context(), iddepo, page, pageSize)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}

func GetDetailStokOpname(c echo.Context) error {
	idstokopname := c.Param("id_stokopname")
	if idstokopname == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Terjadi kesalahan pada parameter program"})
	}

	result, err := model.GetDetailStokOpname(c.Request().Context(), idstokopname)
	if err != nil {
		return c.JSON(result.Status, result)
	}
	return c.JSON(result.Status, result)
}
