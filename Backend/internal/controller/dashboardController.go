package internal

import (
	"net/http"

	model "proyekApotik/internal/model"

	"github.com/labstack/echo/v4"
)

func DashboardManagement(c echo.Context) error {
	iddepo := c.QueryParam("id_depo")

	result, err := model.DashboardManagement(c.Request().Context(), iddepo)
	if err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat memproses permintaan"})
	}

	return c.JSON(result.Status, result)
}

func DashboardGudang(c echo.Context) error {

	result, err := model.DashboardGudang(c.Request().Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat memproses permintaan"})
	}

	return c.JSON(result.Status, result)
}

func DashboardApotik(c echo.Context) error {

	result, err := model.DashboardApotik(c.Request().Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat memproses permintaan"})
	}

	return c.JSON(result.Status, result)
}
