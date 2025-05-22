package internal

import (
	"net/http"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
	"strconv"

	"github.com/labstack/echo/v4"
)

func AddSupplier(c echo.Context) error {
	var requestBody class.Supplier
	if err := c.Bind(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{
			Status:  http.StatusBadRequest,
			Message: "Bad JSON",
		})
	}

	if requestBody.Nama == "" || requestBody.Alamat == "" || requestBody.NoTelp == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Data tidak lengkap"})
	}

	result, err := model.AddSupplier(c.Request().Context(), requestBody)
	if err != nil {
		return c.JSON(result.Status, result)

	}
	return c.JSON(result.Status, result)
}

func GetAllSupplier(c echo.Context) error {
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

	result, err := model.GetAllSupplier(page, pageSize)
	if err != nil {
		return c.JSON(result.Status, result)

	}
	return c.JSON(result.Status, result)
}
func GetSupplier(c echo.Context) error {
	idsupplier := c.Param("id_supplier")
	if idsupplier == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Data tidak lengkap"})
	}
	result, err := model.GetSupplier(idsupplier)
	if err != nil {
		return c.JSON(result.Status, result)

	}
	return c.JSON(result.Status, result)
}

func EditSupplier(c echo.Context) error {
	idsupplier := c.Param("id_supplier")
	if idsupplier == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Data tidak lengkap"})
	}
	var requestBody class.Supplier
	if err := c.Bind(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{
			Status:  http.StatusBadRequest,
			Message: "Bad JSON",
		})
	}

	if requestBody.Nama == "" || requestBody.Alamat == "" || requestBody.NoTelp == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Data tidak lengkap"})
	}
	result, err := model.EditSupplier(c.Request().Context(), idsupplier, requestBody)
	if err != nil {
		return c.JSON(result.Status, result)

	}
	return c.JSON(result.Status, result)
}

func DeleteSupplier(c echo.Context) error {

	idsupplier := c.Param("id_supplier")
	alasandelet := c.FormValue("alasandelete")
	if idsupplier == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Data tidak lengkap"})
	}

	result, err := model.DeleteSupplier(c.Request().Context(), idsupplier, alasandelet)
	if err != nil {
		return c.JSON(result.Status, result)

	}
	return c.JSON(result.Status, result)

}
