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
	Catatan    *string    `json:"catatan,omitempty"`
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

type ObatJadi struct {
	ID              int        `db:"id" json:"id"`
	IDObat          string     `db:"id_obat" json:"id_obat"`
	IDSatuan        string     `db:"id_satuan" json:"id_satuan"`
	IDKategori      string     `db:"id_kategori" json:"id_kategori"`
	NamaObat        string     `db:"nama_obat" json:"nama_obat"`
	HargaJual       float64    `db:"harga_jual" json:"harga_jual"`
	HargaBeli       float64    `db:"harga_beli" json:"harga_beli"`
	StokMinimum     uint       `db:"stok_minimun" json:"stok_minimun"`
	Uprate          *float64   `db:"uprate" json:"uprate,omitempty"`
	CreatedAt       time.Time  `db:"created_at" json:"created_at"`
	CreatedBy       string     `db:"created_by" json:"created_by"`
	UpdatedAt       *time.Time `db:"updated_at" json:"updated_at,omitempty"`
	UpdatedBy       *string    `db:"updated_by" json:"updated_by,omitempty"`
	DeletedAt       *time.Time `db:"deleted_at" json:"deleted_at,omitempty"`
	DeletedBy       *string    `db:"deleted_by" json:"deleted_by,omitempty"`
	LinkGambarObat  *string    `db:"link_gambar_obat" json:"link_gambar_obat,omitempty"`
	Keterangan      *string    `db:"keterangan" json:"keterangan,omitempty"`
	NamaSatuan      string     `json:"nama_satuan"`
	KeteranganHapus *string    `db:"keterangan_hapus" json:"keterangan_hapus,omitempty"`
}

type Satuan struct {
	ID         int       `json:"id"`
	IDSatuan   string    `json:"id_satuan"`
	NamaSatuan string    `json:"nama_satuan"`
	Catatan    *string   `json:"catatan,omitempty"`
	CreatedAt  time.Time `json:"created_at"`
}

type DetailKartuStok struct {
	ID                        uint       `json:"id"`
	IDDetailKartuStok         string     `json:"id_detail_kartu_stok"`
	IDKartuStok               string     `json:"id_kartustok"`
	IDPembelianPenerimaanObat string     `json:"id_pembelian_penerimaan_obat,omitempty"`
	IDDistribusi              string     `json:"id_distribusi,omitempty"`
	IDNomorBatch              string     `json:"id_nomor_batch,omitempty"`
	Masuk                     int        `json:"masuk"`
	Keluar                    int        `json:"keluar"`
	Sisa                      int        `json:"sisa"`
	CreatedAt                 time.Time  `json:"created_at"`
	UpdatedAt                 time.Time  `json:"updated_at"`
	DeletedAt                 *time.Time `json:"deleted_at,omitempty"`
}

type PembelianPenerimaan struct {
	ID                        uint                        `json:"id"`
	IDPembelianPenerimaanObat string                      `json:"id_pembelian_penerimaan_obat"`
	IDSupplier                string                      `json:"id_supplier"`
	NamaSupplier              string                      `json:"nama_supplier,omitempty"`
	TanggalPembelian          time.Time                   `json:"-"`
	TanggalPenerimaan         *time.Time                  `json:"-"`
	TanggalPembayaran         *time.Time                  `json:"-"`
	TanggalPembelianInput     string                      `json:"tanggal_pembelian"`
	TanggalPembayaranInput    string                      `json:"tanggal_pembayaran,omitempty"`
	TanggalPenerimaanInput    string                      `json:"tanggal_penerimaan"`
	Pemesan                   string                      `json:"pemesan,omitempty"`
	Penerima                  *string                     `json:"penerima,omitempty"`
	TotalHarga                float64                     `json:"total_harga"`
	Keterangan                *string                     `json:"keterangan,omitempty"`
	CreatedAt                 time.Time                   `json:"created_at"`
	CreatedBy                 string                      `json:"created_by"`
	UpdatedAt                 *time.Time                  `json:"updated_at,omitempty"`
	UpdatedBy                 *string                     `json:"updated_by,omitempty"`
	DeletedAt                 *time.Time                  `json:"deleted_at,omitempty"`
	DeletedBy                 *string                     `json:"deleted_by,omitempty"`
	ObatList                  []DetailPembelianPenerimaan `json:"obat_list"`
}

type DetailPembelianPenerimaan struct {
	ID                          uint       `json:"id"`
	IDPembelianPenerimaanObat   string     `json:"id_pembelian_penerimaan_obat"`
	IDDetailPembelianPenerimaan string     `json:"id_detail_pembelian_penerimaan_obat"`
	IdBatchPenerimaan           *string    `json:"id_batch_penerimaan,omitempty"`
	IDNomorBatch                *string    `json:"id_nomor_batch,omitempty"`
	NomorBatch                  string     `json:"nomor_batch"`
	IDKartuStok                 string     `json:"id_kartustok"`
	IDDepo                      string     `json:"id_depo"` //hardcode nanti ke gudang
	IDStatus                    string     `json:"id_status"`
	NamaObat                    string     `json:"nama_obat"`
	JumlahDipesan               int        `json:"jumlah_dipesan"`
	JumlahDiterima              int        `json:"jumlah_diterima"`
	Kadaluarsa                  time.Time  `json:"-"`
	KadaluarsaInput             string     `json:"kadaluarsa"`
	CreatedAt                   time.Time  `json:"created_at"`
	UpdatedAt                   *time.Time `json:"updated_at"`
	CreatedBy                   *string    `json:"created_by"`
	UpdatedBy                   *string    `json:"updated_by"`
	DeletedAt                   *time.Time `json:"deleted_at,omitempty"`
}
