package internal

import (
	"net/http"
	"strconv"
	"time"

	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"

	"github.com/labstack/echo/v4"
)

func Laporan(c echo.Context) error {
	pageparam := c.QueryParam("page")
	pagesizeparam := c.QueryParam("page_size")

	page := 1
	pageSize := 10

	if pageparam != "" {
		if p, err := strconv.Atoi(pageparam); err == nil && p > 0 {
			page = p
		}
	}
	if pagesizeparam != "" {
		if ps, err := strconv.Atoi(pagesizeparam); err == nil && ps > 0 {
			pageSize = ps
		}
	}

	iddepo := c.QueryParam("id_depo")
	if iddepo == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Paremeter Depo Invalid"})
	}

	idobat := c.QueryParam("id_obat")
	jenis := c.QueryParam("jenis")
	batch := c.QueryParam("batch")
	startdate := c.QueryParam("start_date")
	if startdate == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Paremeter Date Invalid"})
	}
	enddate := c.QueryParam("end_date")
	if enddate == "" {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Paremeter Date Invalid"})
	}
	startDate, err := time.Parse("2006-01-02", startdate)
	if err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Invalid start date format"})
	}
	endDate, err := time.Parse("2006-01-02", enddate)
	if err != nil {
		return c.JSON(http.StatusBadRequest, class.Response{Status: http.StatusBadRequest, Message: "Invalid end date format"})
	}

	result, err := model.Laporan(c.Request().Context(), startDate, endDate, iddepo, page, pageSize, idobat, jenis, batch)
	if err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error saat memproses permintaan"})
	}

	return c.JSON(result.Status, result)

}
