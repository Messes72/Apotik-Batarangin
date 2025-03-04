package internal

import (
	"fmt"
	"net/http"
	"os"
	auth "proyekApotik/internal/auth"
	class "proyekApotik/internal/class"
	"strings"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

// CORS Middleware Configuration
func CORSMiddleware() echo.MiddlewareFunc {
	return middleware.CORSWithConfig(middleware.DefaultCORSConfig)
}

func CheckAPIKey(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		apiKey := c.Request().Header.Get("X-API-KEY")
		if apiKey == "" {
			return echo.ErrUnauthorized
		}
		if apiKey != os.Getenv("API_KEY") {
			return echo.ErrForbidden
		}
		return next(c)
	}
}

// middleware function untuk authenticate request dengan JWT
func JWTMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		tokenString := c.Request().Header.Get("Authorization")
		if tokenString == "" {
			return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Authorization token required"})
		}

		if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
			tokenString = tokenString[7:]
		}

		// fmt.Println("Received token: ", tokenString)

		claims, err := auth.ValidateJWTToken(tokenString) //ini dia cek properti tokennya dan return claimsnya (payload token tsb)
		if err != nil {
			fmt.Println("Error during token validation:", err)
			return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Invalid token middleware"})
		}

		// Debug: Print claims content
		// log.Println("")
		// log.Printf("Decoded Claims: %+v\n", claims)

		// Check if privileges exist in the claims
		if len(claims.Privileges) == 0 {
			fmt.Println("No privileges found in JWT!")
			return c.JSON(http.StatusUnauthorized, map[string]string{"message": "User privileges not found in JWT"})
		}

		c.Set("id_karyawan", claims.IDKaryawan) //simpan datanya di echo context biar bisa diakses tanpa validasi token lagi
		c.Set("privileges", claims.Privileges)
		c.Set("depos", claims.Depo)
		return next(c)
	}
}

func CheckPrivilege(requiredPrivilege string) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc { //nerima next handler funct
		return func(c echo.Context) error {

			rawPrivileges := c.Get("privileges") //ngambil privilege dari jwt token return interface{}
			fmt.Println("Raw privileges from context:", rawPrivileges)

			privileges, ok := rawPrivileges.([]class.Privilege) //ambil data priv dari interface
			if !ok {
				fmt.Println("Privileges type assertion gagal")
				return c.JSON(http.StatusUnauthorized, map[string]string{"message": "User privileges tidak ada di JWT token"})
			}

			fmt.Println("Extracted privilege : ", privileges)

			// Check if the user has the required privilege
			for _, p := range privileges {
				fmt.Println("Checking privilege:", p.NamaPrivilege, "required:", requiredPrivilege)
				if strings.TrimSpace(p.NamaPrivilege) == strings.TrimSpace(requiredPrivilege) {
					fmt.Println("User punya privilege:", requiredPrivilege)
					return next(c) // lanjut kalo priv nya cukup
				}
			}

			fmt.Println("User tidak punya privilege yang cukup:", requiredPrivilege)
			return c.JSON(http.StatusForbidden, map[string]string{"message": "user privileges tidak cukup"})
		}
	}
}
