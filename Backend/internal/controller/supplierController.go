package internal

import (
	"net/http"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"

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
