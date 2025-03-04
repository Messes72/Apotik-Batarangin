package internal

import (
	"log"
	"net/http"
	model "proyekApotik/internal/model"

	"github.com/labstack/echo/v4"
)

func GetKategori(c echo.Context) error {
	result, err := model.GetKategori(c.Request().Context())

	if err != nil {
		log.Println("gagal di controller getkategori")
		c.JSON(http.StatusInternalServerError, map[string]string{"message": "failed to get all kategori"})
	}

	if result.Status != http.StatusOK {
		c.JSON(result.Status, map[string]string{"message": result.Message})

	}
	return c.JSON(result.Status, result.Data)
}
