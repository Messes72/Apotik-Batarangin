package internal

import (
	"log"
	"net/http"

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
