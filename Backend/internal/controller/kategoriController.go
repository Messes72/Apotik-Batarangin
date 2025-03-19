package internal

import (
	"log"
	"net/http"
	class "proyekApotik/internal/class"
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

func AddKategori(c echo.Context) error {
	idkaryawan := c.Get("id_karyawan")
	if idkaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	var requestBody class.Kategori
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}

	if requestBody.Nama == "" || requestBody.IDDepo == "" {
		c.JSON(http.StatusBadRequest, map[string]string{"message": "Incorrect request body"})
	}
	log.Println("request body addkategori", requestBody)
	result, err := model.AddKategori(c.Request().Context(), requestBody, idkaryawan.(string))
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}
	return c.JSON(result.Status, result)
}

func UpdateKategori(c echo.Context) error {
	idkaryawan := c.Get("id_karyawan")
	if idkaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	idkategori := c.Param("id_kategori")
	var requestBody class.Kategori
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}
	if requestBody.Nama == "" || requestBody.IDDepo == "" {
		c.JSON(http.StatusBadRequest, map[string]string{"message": "Incorrect request body"})
	}
	log.Println("request body addkategori", requestBody)
	result, err := model.UpdateKategori(c.Request().Context(), requestBody, idkaryawan.(string), idkategori)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}
	return c.JSON(result.Status, result)
}

func DeleteKategori(c echo.Context) error {
	idkaryawan := c.Get("id_karyawan")
	if idkaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	idkategori := c.Param("id_kategori")
	var requestBody class.Kategori
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}
	result, err := model.DeleteKategori(c.Request().Context(), idkaryawan.(string), idkategori)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}
	return c.JSON(result.Status, result)

}
