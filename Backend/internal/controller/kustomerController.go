package internal

import (
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
	"strconv"

	"github.com/labstack/echo/v4"
)

func AddKustomer(c echo.Context) error {
	var requestBody class.Kustomer
	// Bind the request body
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}

	log.Printf("Received data: %+v", requestBody)

	if requestBody.Nama == "" || requestBody.Alamat == "" || requestBody.NoTelp == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "id role and nama privilege tidak boleh kosong"})
	}

	result, err := model.AddKustomer(c.Request().Context(), requestBody)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func GetKustomer(c echo.Context) error {
	idKustomer := c.QueryParam("id_kustomer")
	pageParam := c.QueryParam("page")
	pageSizeParam := c.QueryParam("page_size")

	page := 1
	pageSize := 10

	if pageParam != "" {
		if p, err := strconv.Atoi(pageParam); err == nil && p > 0 {
			page = p
		}
	}
	if pageSizeParam != "" {
		if ps, err := strconv.Atoi(pageSizeParam); err == nil && ps > 0 {
			pageSize = ps
		}
	}

	result, err := model.GetKustomer(c.Request().Context(), idKustomer, page, pageSize)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}
	return c.JSON(result.Status, result)
}

func UpdateKustomer(c echo.Context) error {
	idparam := c.Param("id_kustomer")

	var requestkaryawan class.Kustomer

	if err := c.Bind(&requestkaryawan); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}

	result, err := model.UpdateKustomer(c.Request().Context(), idparam, requestkaryawan)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func DeleteKustomer(c echo.Context) error {
	idparam := c.Param("id_kustomer")
	alasan := c.FormValue("alasandelete")
	result, err := model.DeleteKustomer(c.Request().Context(), idparam, alasan)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}
