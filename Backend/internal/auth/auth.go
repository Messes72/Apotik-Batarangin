package internal

import (
	"fmt"
	"os"
	class "proyekApotik/internal/class"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

type Claims struct {
	IDKaryawan string            `json:"id_karyawan"`
	Privileges []class.Privilege `json:"privilege"`
	Depo       []class.Depo      `json:"depo"`
	jwt.RegisteredClaims
}

// var jwtkey = []byte(os.Getenv("JWT_SECRET_KEY"))

func GenerateJWTToken(userid string, privileges []class.Privilege, depos []class.Depo) (string, error) {
	jwtkey := []byte(os.Getenv("JWT_SECRET_KEY"))
	// fmt.Println("JWT_SECRET_KEY:GenerateJWTToken", string(jwtkey))

	privilege := []map[string]interface{}{} //slice of map dimana {} pertama itu bagian syntx dri map trs yg {} kedua itu kita declare isinya kosongan
	for _, p := range privileges {
		privilege = append(privilege, map[string]interface{}{
			"id_privilege":   p.IDPrivilege,
			"nama_privilege": p.NamaPrivilege,
		})
	} //payload harus di enkripsi

	depo := []map[string]interface{}{} //slice of map dimana {} pertama itu bagian syntx dri map trs yg {} kedua itu kita declare isinya kosongan
	for _, p := range depos {
		depo = append(depo, map[string]interface{}{
			"id_depo":   p.IDDepo,
			"nama_depo": p.Nama,
		})
	}
	// Define claims
	claims := jwt.MapClaims{
		"id_karyawan": userid,
		"privilege":   privilege,
		"depo":        depo,
		"exp":         time.Now().Add(24 * time.Hour).Unix(), // sexpird 24 jam
		"iat":         time.Now().Unix(),                     // issued at
	}

	if len(jwtkey) == 0 {
		return "", fmt.Errorf("JWT secret key is missing")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	tokenString, err := token.SignedString(jwtkey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func ValidateJWTToken(tokenString string) (*Claims, error) {
	jwtkey := []byte(os.Getenv("JWT_SECRET_KEY"))
	// fmt.Println("JWT_SECRET_KEY ValidateJWTToken:", string(jwtkey))
	if string(jwtkey) == "" {
		return nil, fmt.Errorf("JWT secret key is missing")
	}

	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// cek apakah token di sign dgn algo yg bnr
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return jwtkey, nil
	})

	if err != nil {
		return nil, fmt.Errorf("error parsing token: %v", err)
	}

	// Extract dan return claims jika valid
	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, fmt.Errorf("invalid token: claims extraction failed")
	}

	return claims, nil
}
