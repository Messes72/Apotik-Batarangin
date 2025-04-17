package internal

import (
	"fmt"
	"log"
	"net/http"
	"os"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
	"strconv"

	"github.com/labstack/echo/v4"
)

func AddKaryawan(c echo.Context) error {
	log.Println()
	var requestBody struct {
		Karyawan class.Karyawan `json:"karyawan"`
		Username string         `json:"username"`
		Password string         `json:"password"`
	}
	idcreatorparam := c.Get("id_karyawan")
	idcreator, ok := idcreatorparam.(string) //ambil data priv dari interface
	if !ok {
		fmt.Println("karyawan type assertion gagal")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "gagal extract interface id karyawan dari jwt"})
	}
	// Bind the request body
	if err := c.Bind(&requestBody); err != nil {
		log.Println(err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})

	}

	log.Println(requestBody.Karyawan.Privileges)
	log.Println(requestBody.Karyawan.Roles)
	// Validate required fields
	if requestBody.Username == "" || requestBody.Password == "" || len(requestBody.Karyawan.Roles) == 0 || len(requestBody.Karyawan.Privileges) == 0 {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Username, password, role, and privileges are required"})
	}

	// Call model function to add Karyawan
	response, err := model.AddKaryawan(requestBody.Karyawan, requestBody.Username, requestBody.Password, idcreator)
	if err != nil {
		return c.JSON(response.Status, map[string]string{"message": response.Message})
	}

	return c.JSON(response.Status, map[string]string{"message": response.Message})
}

// handle user login.
func LoginKaryawan(c echo.Context) error {
	username := c.FormValue("username")
	password := c.FormValue("password")
	apiKey := c.Request().Header.Get("X-API-Key")

	if username == "" || password == "" || apiKey == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Username, password, and API key kosong"})
	}

	if apiKey != os.Getenv("API_KEY") {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Invalid API Key"})
	}

	response, err := model.LoginKaryawan(username, password, apiKey)
	if err != nil {
		return c.JSON(response.Status, map[string]string{"message": response.Message})
	}

	return c.JSON(response.Status, response.Data)
}

func GetKaryawan(c echo.Context) error {
	// Retrieve query parameters for pagination and ID
	idKaryawan := c.Param("id_karyawan")
	pageParam := c.QueryParam("page")
	pageSizeParam := c.QueryParam("page_size")

	page, err := strconv.Atoi(pageParam)
	if err != nil {
		page = 1
	}

	pageSize, err := strconv.Atoi(pageSizeParam)
	if err != nil {
		pageSize = 10
	}

	karyawanResult, err := model.GetKaryawan(idKaryawan, page, pageSize)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve karyawan"})
	}

	if idKaryawan != "" && karyawanResult.Data == nil {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Karyawan not found"})
	}

	return c.JSON(karyawanResult.Status, map[string]interface{}{
		"data":     karyawanResult.Data,     // karyawan data
		"metadata": karyawanResult.Metadata, // metadata
	})
}

func UpdateKaryawan(c echo.Context) error {
	updaterID, ok := c.Get("id_karyawan").(string)
	if !ok {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "invalid JWT payload"})
	}
	targetID := c.Param("id_karyawanupdate")

	// 1) bind directly into a Karyawan
	var k class.Karyawan
	if err := c.Bind(&k); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "invalid JSON body"})
	}

	// log what actually arrived:
	log.Printf("→ update %s: %+v\n", targetID, k)
	for i, r := range k.Roles {
		log.Printf("  role[%d]=%#v\n", i, r)
	}
	for i, p := range k.Privileges {
		log.Printf("  priv[%d]=%#v\n", i, p)
	}
	for i, d := range k.Depo {
		log.Printf("  depo[%d]=%#v\n", i, d)
	}

	// 2) call your model
	resp, err := model.UpdateKaryawan(c.Request().Context(), updaterID, targetID, k)
	if err != nil {
		return c.JSON(resp.Status, map[string]string{"message": resp.Message})
	}
	return c.JSON(resp.Status, resp)
}

func DeleteKaryawan(c echo.Context) error {
	idnow := c.Get("id_karyawan")
	iddelete := c.Param("id_karyawandelete")
	iddeletor, ok := idnow.(string) //ambil data priv dari interface
	alasandelete := c.FormValue("alasandelete")
	if alasandelete == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Alasan penghapusan harus diisi"})
	}
	if !ok {
		fmt.Println("karyawan type assertion gagal")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "gagal extract interface id karyawan dari jwt"})
	}

	result, err := model.DeleteKaryawan(c.Request().Context(), iddeletor, iddelete, alasandelete)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}
	return c.JSON(result.Status, result)
}
