package internal

import "time"

type Response struct {
	Status   int         `json:"status"`
	Message  string      `json:"message"`
	Data     interface{} `json:"data"`
	Metadata Metadata    `json:"metadata"`
}

type Metadata struct {
	CurrentPage  int `json:"current_page"`  // Current page number
	PageSize     int `json:"page_size"`     // Number of items per page
	TotalPages   int `json:"total_pages"`   // Total number of pages
	TotalRecords int `json:"total_records"` // Total number of records available
}

type Role struct {
	ID        int        `json:"id"`
	IDRole    string     `json:"id_role"`
	NamaRole  string     `json:"nama_role"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty"`
	Catatan   string     `json:"catatan,omitempty"`
}

type Privilege struct {
	ID            int        `json:"id"`
	IDPrivilege   string     `json:"id_privilege"`
	NamaPrivilege string     `json:"nama_privilege"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
	DeletedAt     *time.Time `json:"deleted_at,omitempty"`
	Catatan       string     `json:"catatan,omitempty"`
}

type Karyawan struct {
	ID         int         `json:"id"`
	IDKaryawan string      `json:"id_karyawan"`
	Nama       string      `json:"nama"`
	Alamat     string      `json:"alamat"`
	NoTelp     string      `json:"no_telp"`
	CreatedAt  time.Time   `json:"created_at"`
	UpdatedAt  time.Time   `json:"updated_at"`
	DeletedAt  *time.Time  `json:"deleted_at,omitempty"`
	Catatan    string      `json:"catatan,omitempty"`
	Roles      []Role      `json:"roles"`
	Privileges []Privilege `json:"privileges"`
	Depo       []Depo      `json:"depo"`
}

type StaffLogin struct {
	ID         int        `json:"id"`
	KaryawanID int        `json:"karyawan_id"`
	Username   string     `json:"username"`
	Password   string     `json:"password"`
	LastLogin  *time.Time `json:"last_login,omitempty"`
}

type DetailRoleKaryawan struct {
	IDRole     string `json:"id_role"`
	IDKaryawan string `json:"id_karyawan"`
}

type DetailPrivilegeKaryawan struct {
	IDPrivilege string `json:"id_privilege"`
	IDKaryawan  string `json:"id_karyawan"`
}

type Kustomer struct {
	ID         int        `json:"id"`
	IDKustomer string     `json:"id_kustomer"`
	Nama       string     `json:"nama"`
	Alamat     string     `json:"alamat"`
	NoTelp     string     `json:"no_telp"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
	DeletedAt  *time.Time `json:"deleted_at,omitempty"`
	Catatan    string     `json:"catatan,omitempty"`
}

type Depo struct {
	ID      int     `json:"id" db:"id"`
	IDDepo  string  `json:"id_depo" db:"id_depo"`
	Nama    string  `json:"nama" db:"nama"`
	Alamat  string  `json:"alamat" db:"alamat"`
	NoTelp  string  `json:"no_telp" db:"no_telp"`
	Catatan *string `json:"catatan,omitempty" db:"catatan"`
}

type Kategori struct {
	ID         int        `json:"id" db:"id"`
	IDDepo     string     `json:"id_depo" db:"id_depo"`
	IDKategori string     `json:"id_kategori" db:"id_kategori"`
	Nama       string     `json:"nama" db:"nama"`
	CreatedAt  time.Time  `json:"created_at" db:"created_at"`
	CreatedBy  *string    `json:"created_by,omitempty" db:"created_by"`
	UpdatedAt  *time.Time `json:"updated_at" db:"updated_at"`
	UpdatedBy  *string    `json:"updated_by,omitempty" db:"updated_by"`
	DeletedAt  *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
	DeletedBy  *string    `json:"deleted_by,omitempty" db:"deleted_by"`
	Catatan    *string    `json:"catatan,omitempty" db:"catatan"`
}
type DetailKaryawan struct {
	IDDepo     string     `json:"id_depo" db:"id_depo"`
	IDKaryawan string     `json:"id_karyawan" db:"id_karyawan"`
	CreatedAt  time.Time  `json:"created_at" db:"created_at"`
	CreatedBy  *string    `json:"created_by,omitempty" db:"created_by"`
	UpdatedAt  time.Time  `json:"updated_at" db:"updated_at"`
	UpdatedBy  *string    `json:"updated_by,omitempty" db:"updated_by"`
	DeletedAt  *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
	DeletedBy  *string    `json:"deleted_by,omitempty" db:"deleted_by"`
	Catatan    string     `json:"catatan,omitempty" db:"catatan"`
}

type Obat struct {
	ID          int        `json:"id"`
	IDObat      string     `json:"id_obat"`
	IDSatuan    string     `json:"id_satuan"`
	IDDepo      string     `json:"id_depo"`
	IDKartuStok string     `json:"id_kartustok"`
	IDKategori  string     `json:"id_kategori"`
	Nama        string     `json:"nama"`
	HargaJual   uint       `json:"harga_jual"`
	HargaBeli   uint       `json:"harga_beli"`
	StokBarang  uint       `json:"stok_barang"`
	Uprate      uint       `json:"uprate"`
	NoBatch     string     `json:"no_batch"`
	Kadaluarsa  string     `json:"kadaluarsa"`
	CreatedAt   time.Time  `json:"created_at"`
	CreatedBy   string     `json:"created_by"`
	UpdatedBy   *string    `json:"updated_by,omitempty"`
	DeletedBy   *string    `json:"deleted_by,omitempty"`
	UpdatedAt   *time.Time `json:"updated_at,omitempty"`
	DeletedAt   *time.Time `json:"deleted_at,omitempty"`
	Catatan     *string    `json:"catatan,omitempty"`
}

type Satuan struct {
	ID         int       `json:"id"`
	IDSatuan   string    `json:"id_satuan"`
	NamaSatuan string    `json:"nama_satuan"`
	Jumlah     uint      `json:"jumlah"`
	Catatan    *string   `json:"catatan,omitempty"`
	CreatedAt  time.Time `json:"created_at"`
}
