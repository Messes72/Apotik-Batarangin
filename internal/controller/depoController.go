package internal

import (
	"log"
	"net/http"
	model "proyekApotik/internal/model"

	"github.com/labstack/echo/v4"
)

func GetDepo(c echo.Context) error {

	result, err := model.GetDepo(c.Request().Context())
	if err != nil {
		log.Println("gagal di controller getsatuan")
		c.JSON(http.StatusInternalServerError, map[string]string{"message": "gagal mengambil list data depo"})
	}

	if result.Status != http.StatusOK {
		c.JSON(result.Status, map[string]string{"message": result.Message})

	}
	return c.JSON(result.Status, result.Data)
}
