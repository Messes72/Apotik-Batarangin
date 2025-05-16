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

type AlokasiBatch struct { //mengatur data individual batch untuk setiap bacth yg dialokasikan ke suatu obat
	IdBatchPenerimaan string    `json:"id_batch_penerimaan"`
	IDNomorBatch      string    `json:"id_nomor_batch"`
	NomorBatch        string    `json:"nomor_batch"`
	Kadaluarsa        time.Time `json:"kadaluarsa"`
	Sisa              int       `json:"sisa"`
	Alokasi           int       `json:"alokasi_obat"`
}

type RequestAlokasi struct { //untuk data obat yg diminta
	IDObat    string `json:"id_obat"`
	Kuantitas int    `json:"kuantitas"`
}

type AlokasiObatResult struct {
	IDObat                 string         `json:"id_obat"`
	Listbatchteralokasikan []AlokasiBatch `json:"list_alokasi"`
}

type PenjualanObat struct {
	IDObat          string `json:"id_obat"`
	Kuantitas       int    `json:"kuantitas"`
	IdDepo          string `json:"id_depo"`
	AturanPakai     string `json:"aturan_pakai,omitempty"`
	CaraPakai       string `json:"cara_pakai,omitempty"`
	KeteranganPakai string `json:"keterangan_pakai,omitempty"`
}

type MetodeBayar struct {
	MetodeBayar string  `json:"metode_bayar"`
	TotalBayar  float64 `json:"total_bayar"`
}

type PermintaanPembelian struct {
	IDKaryawan string          `json:"id_karyawan"`
	IDKustomer *string         `json:"id_kustomer,omitempty"`
	Items      []PenjualanObat `json:"items"`
	Payment    MetodeBayar     `json:"pembayaran"`
}

type RequestStokBarang struct {
	IDobat string `json:"id_obat"`
	Stok   int64  `json:"stok_barang"`
}

type TransaksiItem struct { //detal transaksi
	IDKartustok     string    `json:"id_kartustok"`
	NamaObat        string    `json:"nama_obat"`
	Jumlah          int       `json:"jumlah"`
	Totalharga      float64   `json:"total_harga"`
	NomorBatch      string    `json:"nomor_batch"`
	Kadaluarsa      time.Time `json:"kadaluarsa"`
	AturanPakai     string    `json:"aturan_pakai"`
	CaraPakai       string    `json:"cara_pakai"`
	KeteranganPakai string    `json:"keterangan_pakai"`
}

type TransactionDetail struct { //single transaction
	IDTransaksi  string          `json:"id_transaksi"`
	KasirID      string          `json:"id_karyawan"`
	KasirNama    string          `json:"nama_karyawan"`
	KustomerID   *string         `json:"id_kustomer,omitempty"`
	KustomerNama *string         `json:"nama_kustomer,omitempty"`
	TotalHarga   float64         `json:"total_harga"`
	MetodeBayar  string          `json:"metode_bayar"`
	Status       string          `json:"status"`
	CreatedAt    time.Time       `json:"created_at"`
	Items        []TransaksiItem `json:"items"`
}

type RequestBarang struct {
	IDDepoTujuan string              `json:"id_depo_tujuan"`
	Keterangan   *string             `json:"keterangan"`
	ListObat     []RequestBarangObat `json:"list_permintaan_obat"`
}

type RequestBody struct {
	ListPermintaanObat []RequestBarangObat `json:"list_permintaan_obat"`
}

type RequestBarangObat struct {
	IDObat        string  `json:"id_obat"`
	JumlahDiminta int64   `json:"jumlah_diminta"`
	CatatanApotik *string `json:"catatan_apotik"`
}

type FulfilRequest struct {
	IdDistribusi            string              `json:"id_distribusi"`
	ListPemenuhanDistribusi []FulfilRequestObat `json:"list_pemenuhan_distribusi"`
	TanggalPengiriman       time.Time           `json:"-"`
	TanggalPengirimaninput  string              `json:"tanggal_pengiriman"`
}

type FulfilRequestObat struct {
	IdDetailDistribusi string  `json:"id_detail_distribusi"`
	JumlahDikirim      int     `json:"jumlah_dikirim"`
	CatatanGudang      *string `json:"catatan_gudang"`
}

type Distribusi struct {
	IdDistribusi      string  `json:"id_distribusi"`
	IdDepoAsal        *string `json:"id_depo_asal"`
	IdDepoTujuan      string  `json:"id_depo_tujuan"`
	TanggalPermohonan string  `json:"tanggal_permohonan"`
	TanggalPengiriman *string `json:"tanggal_pengiriman"`
	IdStatus          *string `json:"id_status"`
	Keterangan        *string `json:"keterangan,omitempty"`
	CreatedAt         string  `json:"created_at"`
	CreatedBy         string  `json:"created_by"`
	UpdatedAt         *string `json:"updated_at,omitempty"`
	UpdatedBy         *string `json:"updated_by,omitempty"`
	DeletedAt         *string `json:"deleted_at,omitempty"`
	DeletedBy         *string `json:"deleted_by,omitempty"`
}

type DetailDistribusi struct {
	IdDetailDistribusi string                  `json:"id_detail_distribusi"`
	IdDistribusi       string                  `json:"id_distribusi"`
	IdKartustok        string                  `json:"id_kartustok"`
	IdNomorBatch       *string                 `json:"id_nomor_batch"`
	JumlahDiminta      int                     `json:"jumlah_diminta"`
	JumlahDikirim      *int                    `json:"jumlah_dikirim"`
	CreatedAt          string                  `json:"created_at"`
	CreatedBy          string                  `json:"created_by"`
	UpdatedAt          *string                 `json:"updated_at,omitempty"`
	UpdatedBy          *string                 `json:"updated_by,omitempty"`
	CatatanApotik      *string                 `json:"catatan_apotik,omitempty"`
	CatatanGudang      *string                 `json:"catatan_gudang,omitempty"`
	DetailBatch        []BatchDetailDistribusi `json:"batch_obat"`
}

type BatchDetailDistribusi struct {
	IdNomorBatch string    `json:"id_nomor_batch"` // ID of the batch
	NoBatch      string    `json:"no_batch"`       // Batch number (e.g., BT001, BT002)
	Kadaluarsa   time.Time `json:"kadaluarsa"`     // Expiration date of the batch
	Jumlah       int       `json:"jumlah"`         // Quantity of the batch available
}

type RequestStokOpnameObatBatch struct {
	IDNomorBatch   string  `json:"id_nomor_batch"`
	KuantitasFisik int     `json:"kuantitas_fisik"`
	Catatan        *string `json:"catatan,omitempty"`
}

type RequestStokOpnameObat struct {
	IDKartuStok string                       `json:"id_kartustok"`
	Batch       []RequestStokOpnameObatBatch `json:"batches"`
}

type RequestStokOpname struct {
	IDDepo            string                  `json:"id_depo"`
	TanggalStokOpname string                  `json:"tanggal_stok_opname"`
	CreatedBy         string                  `json:"created_by"`
	Catatan           *string                 `json:"catatan,omitempty"`
	Items             []RequestStokOpnameObat `json:"items"`
}

type BatchInfo struct {
	IdNomorBatch string  `json:"id_nomor_batch"`
	NoBatch      string  `json:"no_batch"`
	Kadaluarsa   *string `json:"kadaluarsa,omitempty"`
	Saldo        int     `json:"sisa"`
}
