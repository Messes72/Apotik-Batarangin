package internal

import (
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"

	"github.com/labstack/echo/v4"
)

func CreatePrivilege(c echo.Context) error {
	var requestBody class.Privilege
	// Bind the request body
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}

	log.Printf("Received data: %+v", requestBody)

	if requestBody.NamaPrivilege == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "nama privilege tidak boleh kosong"})
	}

	result, err := model.CreatePrivilege(c.Request().Context(), requestBody)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)

}

func GetAllPrivilege(c echo.Context) error {
	result, err := model.GetAllPrivilege(c.Request().Context())
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "failed to get all privilege"})
	}

	if result.Status != http.StatusOK {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}
	return c.JSON(result.Status, result.Data)
}

func GetPrivilegeByID(c echo.Context) error {

	getparam := c.Param("id_privilege")

	result, err := model.GetPrivilegeByID(c.Request().Context(), getparam)

	if err != nil {

		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}

	return c.JSON(result.Status, result.Data)
}

func UpdatePrivilege(c echo.Context) error {
	idparam := c.Param("id_privilege")

	var requestPrivilege class.Privilege

	if err := c.Bind(&requestPrivilege); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}
	result, err := model.UpdatePrivilege(c.Request().Context(), idparam, requestPrivilege)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func DeletePrivilege(c echo.Context) error {
	idparam := c.Param("id_privilege")
	alasan := c.FormValue("alasandelete")
	result, err := model.DeletePrivilege(c.Request().Context(), idparam, alasan)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}
