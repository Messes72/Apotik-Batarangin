package internal

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	class "proyekApotik/internal/class"
	model "proyekApotik/internal/model"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"
)

func AddObat(c echo.Context) error {

	file, err := c.FormFile("image")
	var img *string = nil

	if err == nil && file != nil {
		src, err := file.Open()
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal open file image"})
		}
		defer src.Close()
		//nama file baru
		namafilebaru := fmt.Sprintf("img_%d_%s", time.Now().UnixNano(), file.Filename)
		dirupload := "uploads" // cek dir , create kalau ga ada
		if _, err := os.Stat(dirupload); os.IsNotExist(err) {
			if err = os.MkdirAll(dirupload, 0755); err != nil {
				return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membuat directory upload"})
			}
		}
		pathfile := fmt.Sprintf("%s/%s", dirupload, namafilebaru)
		dst, err := os.Create(pathfile)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membuat file di server"})
		}
		defer dst.Close()

		if _, err := io.Copy(dst, src); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menyimpan gambar"})
		}

		createurl := fmt.Sprintf("%s/%s", dirupload, namafilebaru)
		img = &createurl
	} else {
		log.Println("Tidak menerima Image")
		defaulturl := "uploads/default.png"
		img = &defaulturl
	}
	namaObat := c.FormValue("nama_obat")
	idSatuan := c.FormValue("id_satuan")
	hargaJualStr := c.FormValue("harga_jual")
	hargaBeliStr := c.FormValue("harga_beli")
	stokMinimumStr := c.FormValue("stok_minimum")
	uprateStr := c.FormValue("uprate")
	keterangan := c.FormValue("keterangan")
	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}
	// log.Println("contoller", idDepoparam)
	idKategori := c.FormValue("id_kategori")

	hargaJual, err := strconv.ParseFloat(hargaJualStr, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "invalid harga jual"})
	}
	hargaBeli, err := strconv.ParseFloat(hargaBeliStr, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "invalid harga beli"})
	}
	stokMinimum, err := strconv.Atoi(stokMinimumStr)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "invalid stok minimum"})
	}
	var uprate *float64 = nil
	if uprateStr != "" {
		uprateInt, err := strconv.ParseFloat(uprateStr, 64)
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "invalid uprate"})
		}
		uprateUint := float64(uprateInt)
		uprate = &uprateUint
	}
	log.Println("imge url", img)
	obat := class.ObatJadi{
		IDSatuan:       idSatuan,
		NamaObat:       namaObat,
		HargaJual:      hargaJual,
		HargaBeli:      hargaBeli,
		StokMinimum:    uint(stokMinimum),
		Uprate:         uprate,
		LinkGambarObat: img,
		Keterangan:     &keterangan,
	}

	// Call the model function
	result, err := model.AddObat(c.Request().Context(), obat, idKategori, idKaryawan.(string))
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func GetObat(c echo.Context) error {
	idobat := c.QueryParam("id_obat")
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

	result, err := model.GetObat(c.Request().Context(), idobat, page, pageSize)

	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})

	}
	return c.JSON(result.Status, result)
}
func validateimgtype(file io.Reader, filesize int64) (bool, string) {

	//cek ukuran gambar max 2mb
	const maxsize = 2 * 1024 * 1024 //2mb
	if filesize > maxsize {
		return false, "Ukuran foto melebihi 2MB"
	}
	//caranya dibaca 512 byte awal dari file terserbut untuk cek dia itu gambar atau bukan
	tmp := make([]byte, 512)
	_, err := file.Read(tmp)
	if err != nil {
		log.Println("error saat read file di validasi image : ", err)
		return false, ""
	}

	cek := http.DetectContentType(tmp)
	switch cek {
	case "image/jpg", "image/png", "image/jpeg":
		if seeker, ok := file.(io.Seeker); ok {
			_, err := seeker.Seek(0, io.SeekStart)
			if err != nil {
				log.Println("Error saat reset file pointer (Seeker)", err)
				return false, "Error saat membaca file image"
			}
		} else {
			log.Println("File tidak support seeking")
			return false, "Error saat membaca file image"
		}
		return true, cek
	default:
		return false, fmt.Sprintf("Format gambar invalid, format yang diperbolehkan adalah JPG, JPEG dan PNG, sedangkan file anda adalah : %s", cek)
	}
}
func UpdateObat(c echo.Context) error {

	file, err := c.FormFile("image")
	var imgupdate *string = nil

	if err == nil && file != nil {
		src, err := file.Open()
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal open file image"})
		}
		defer src.Close()

		filesize := file.Size

		cekimage, message := validateimgtype(src, filesize) //untuk cek apakah file yg dikasi user beneran image dan tipenya bener serta ada cek max size 2mb juga
		if !cekimage {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": message})
		}

		//nama file baru
		namafilebaru := fmt.Sprintf("img_%d_%s", time.Now().UnixNano(), file.Filename)
		dirupload := "uploads" // cek dir , create kalau ga ada
		if _, err := os.Stat(dirupload); os.IsNotExist(err) {
			if err = os.MkdirAll(dirupload, 0755); err != nil {
				return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membuat directory upload"})
			}
		}
		pathfile := fmt.Sprintf("%s/%s", dirupload, namafilebaru)
		dst, err := os.Create(pathfile)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membuat file di server"})
		}
		defer dst.Close()

		if _, err := io.Copy(dst, src); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menyimpan gambar"})
		}

		updateurl := fmt.Sprintf("%s/%s", dirupload, namafilebaru)
		imgupdate = &updateurl

	} else {
		log.Println("Tidak menerima gambar")
		imgupdate = nil
	}

	namaObat := c.FormValue("nama_obat")
	idSatuan := c.FormValue("id_satuan")
	idKategori := c.FormValue("id_kategori")
	idObat := c.Param("id_obat")
	hargaJualStr := c.FormValue("harga_jual")
	hargaBeliStr := c.FormValue("harga_beli")
	stokMinimumStr := c.FormValue("stok_minimum")
	uprateStr := c.FormValue("uprate")
	keterangan := c.FormValue("keterangan")
	idKaryawan := c.Get("id_karyawan")
	if idKaryawan == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, missing karyawan data in token"})
	}

	// Convert numeric values.
	hargaJual, err := strconv.ParseFloat(hargaJualStr, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid harga_jual"})
	}
	hargaBeli, err := strconv.ParseFloat(hargaBeliStr, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid harga_beli"})
	}
	stokMinimum, err := strconv.Atoi(stokMinimumStr)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid stok_minimum"})
	}
	var uprate *float64 = nil
	if uprateStr != "" {
		uprateVal, err := strconv.ParseFloat(uprateStr, 64)
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid uprate"})
		}
		uprate = &uprateVal
	}

	obat := class.ObatJadi{
		IDSatuan:       idSatuan,
		IDKategori:     idKategori,
		NamaObat:       namaObat,
		HargaJual:      hargaJual,
		HargaBeli:      hargaBeli,
		StokMinimum:    uint(stokMinimum),
		Uprate:         uprate,
		LinkGambarObat: imgupdate,
		Keterangan:     &keterangan,
	}
	result, err := model.UpdateObat(c.Request().Context(), idKategori, idObat, obat, idKaryawan.(string))
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)
}

func DeleteObat(c echo.Context) error {

	idobat := c.Param("id_obat")
	idkaryawan, ok := c.Get("id_karyawan").(string)
	if !ok {
		log.Println("id karyawan tidak diterima di controller updateobat dari jwt token, atau isi id karyawan bukan string")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized, karyawan tidak dikenali"})
	}

	//nanti perlu ditentukan apakah perlu idkategori untuk langkah penghapusan karena sebenernya tidak diperlukan
	//sementara gini , buat menghindari dia error gara2 dibuat tp tidak dipakai, kalau gak perlu ya nanti hapus aja tp jangan lupa tambahkan idkategori di query di model nya juga

	result, err := model.DeleteObat(c.Request().Context(), idobat, idkaryawan)
	if err != nil {
		return c.JSON(result.Status, map[string]string{"message": result.Message})
	}

	return c.JSON(result.Status, result)

}
