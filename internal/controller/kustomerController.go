package internal

import (
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"

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

	result, err := model.DeleteKustomer(c.Request().Context(), idparam)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}
