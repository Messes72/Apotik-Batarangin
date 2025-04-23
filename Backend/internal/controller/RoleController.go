package internal

import (
	"log"
	"net/http"

	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"

	"github.com/labstack/echo/v4"
)

func CreateRole(c echo.Context) error {
	var requestBody class.Role
	// Bind the request body
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}

	log.Printf("Received data: %+v", requestBody)

	if requestBody.NamaRole == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "nama role tidak boleh kosong"})
	}

	result, err := model.CreateRole(c.Request().Context(), requestBody)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)

}

func GetAllRole(c echo.Context) error {
	result, err := model.GetAllRole(c.Request().Context())
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "failed to get all role"})
	}

	if result.Status != http.StatusOK {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}
	return c.JSON(result.Status, result.Data)
}

func GetRoleByID(c echo.Context) error {

	getparam := c.Param("id_role")
	// getid, err := strconv.Atoi(getparam)

	// if err != nil {
	// 	log.Println("gagal get param di route atau idrole invalid")
	// 	return c.JSON(http.StatusBadRequest, map[string]string{"message": "ID role Invalid"})
	// }

	result, err := model.GetRoleByID(c.Request().Context(), getparam)

	if err != nil {

		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}

	return c.JSON(result.Status, result.Data)
}

func UpdateRole(c echo.Context) error {
	idparam := c.Param("id_role")

	var requestRole class.Role

	if err := c.Bind(&requestRole); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}
	result, err := model.UpdateRole(c.Request().Context(), idparam, requestRole)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func DeleteRole(c echo.Context) error {
	idparam := c.Param("id_role")
	alasan := c.FormValue("alasandelete")
	result, err := model.DeleteRole(c.Request().Context(), idparam, alasan)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}
