-- ========================================
-- Database: ApotikDB
-- ========================================

-- Create the Role table
CREATE TABLE Role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_role VARCHAR(10) NOT NULL UNIQUE,
    nama_role VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    catatan VARCHAR(255),
    alasandelete VARCHAR(255)
);

-- Create the Privilege table
CREATE TABLE Privilege (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_privilege VARCHAR(10) NOT NULL UNIQUE,
    nama_privilege VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    catatan VARCHAR(255),
    alasandelete VARCHAR(255)
);

-- Create the Karyawan table (staff details)
CREATE TABLE Karyawan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_karyawan VARCHAR(10) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    no_telp VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    catatan VARCHAR(255)
);

-- Create the separate StaffLogin table for login credentials
CREATE TABLE StaffLogin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_karyawan VARCHAR(10) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    last_login DATETIME,
    deleted_at DATETIME,
    CONSTRAINT fk_stafflogin_karyawan FOREIGN KEY (id_karyawan) REFERENCES Karyawan(id_karyawan)
);



-- Create a join table between Role and Karyawan
CREATE TABLE detail_role_karyawan (
    id_role VARCHAR(10) NOT NULL,
    id_karyawan VARCHAR(10) NOT NULL,
    CONSTRAINT fk_detail_role_role FOREIGN KEY (id_role) REFERENCES Role(id_role),
    CONSTRAINT fk_detail_role_karyawan FOREIGN KEY (id_karyawan) REFERENCES Karyawan(id_karyawan)
);

-- Create a join table between Privilege and Karyawan
CREATE TABLE detail_privilege_karyawan (
    id_privilege VARCHAR(10) NOT NULL,
    id_karyawan VARCHAR(10) NOT NULL,
    CONSTRAINT fk_detail_privilege_privilege FOREIGN KEY (id_privilege) REFERENCES Privilege(id_privilege),
    CONSTRAINT fk_detail_privilege_karyawan FOREIGN KEY (id_karyawan) REFERENCES Karyawan(id_karyawan)
);

ALTER TABLE detail_privilege_karyawan 
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at DATETIME NULL,
ADD COLUMN deleted_at DATETIME NULL,
ADD COLUMN updated_by VARCHAR(10) NULL;
ALTER TABLE detail_role_karyawan 
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at DATETIME NULL,
ADD COLUMN deleted_at DATETIME NULL,
ADD COLUMN updated_by VARCHAR(10) NULL;




CREATE TABLE Kustomer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_kustomer VARCHAR(15) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    no_telp VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    catatan VARCHAR(255),
    alasandelete VARCHAR(255)
);


CREATE TABLE Counter (
    count PRIMARY KEY BIGINT NOT NULL DEFAULT 1 
) 
INSERT INTO Counter (COUNT) VALUES (1)

CREATE TABLE ObatCounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO ObatCounter (COUNT) VALUES (1)

CREATE TABLE ObatCounterGudang (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO ObatCounterGudang (COUNT) VALUES (1)

CREATE TABLE KategoriCounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO KategoriCounter (COUNT) VALUES (1)


CREATE TABLE pembelian_penerimaancounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO pembelian_penerimaancounter (COUNT) VALUES (1)

CREATE TABLE detail_pembelian_penerimaancounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO detail_pembelian_penerimaancounter (COUNT) VALUES (1)

CREATE TABLE nomor_batchcounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO nomor_batchcounter (COUNT) VALUES (1)

CREATE TABLE karyawancounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO karyawancounter (COUNT) VALUES (1)

CREATE TABLE batch_penerimaancounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO batch_penerimaancounter (COUNT) VALUES (1)


CREATE TABLE rolecounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO rolecounter (COUNT) VALUES (1)

CREATE TABLE privilegecounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO privilegecounter (COUNT) VALUES (1)


CREATE TABLE detail_kartustokcounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO detail_kartustokcounter (COUNT) VALUES (1)

CREATE TABLE transaksicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO transaksicounter (COUNT) VALUES (1)

CREATE TABLE aturanpakaicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO aturanpakaicounter (COUNT) VALUES (1)

CREATE TABLE carapakaicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO carapakaicounter (COUNT) VALUES (1)

CREATE TABLE keteranganpakaicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);
INSERT INTO keteranganpakaicounter (COUNT) VALUES (1)

CREATE TABLE IF NOT EXISTS detaildistribusicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO detaildistribusicounter (count) VALUES (1)

CREATE TABLE IF NOT EXISTS batchdetaildistribusicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO batchdetaildistribusicounter (count) VALUES (1)

-- Depo Table
CREATE TABLE Depo (
    id INT PRIMARY KEY AUTO_INCREMENT,  -- PK and Auto-incrementing (A.I.)
    id_depo VARCHAR(10) NOT NULL UNIQUE,       -- UQ: Unique constraint
    nama VARCHAR(100) NOT NULL,        -- NN: Not Null constraint
    alamat VARCHAR(255) NOT NULL,      -- NN: Not Null constraint
    no_telp VARCHAR(20) NOT NULL,       -- NN: Not Null constraint
    catatan VARCHAR(255)                       -- 0: Optional (NULL allowed)
);

-- Kategori Table
CREATE TABLE Kategori (
    id INT PRIMARY KEY AUTO_INCREMENT,  -- PK and Auto-incrementing (A.I.)
    id_kategori VARCHAR(15) NOT NULL UNIQUE,   -- UQ: Unique constraint
    id_depo VARCHAR(10) NOT NULL,             -- FK: Foreign Key referencing Depo
    nama VARCHAR(100) NOT NULL,        -- NN: Not Null constraint
    created_at DATETIME NOT NULL, 
    created_by VARCHAR(10) not null,      -- NN: Not Null constraint
    updated_at DATETIME NULL, 
    updated_by VARCHAR(10) NULL, 
    deleted_at DATETIME Null,               -- 0: Optional (NULL allowed)
    deleted_by VARCHAR(10) NULL,     -- NN: Not Null constraint
    catatan VARCHAR(255),                     -- 0: Optional (NULL allowed)
    alasandelete VARCHAR(255) NULL,
    FOREIGN KEY (id_depo) REFERENCES Depo(id_depo) -- Define the Foreign Key
);

Create TABLE detail_karyawan(
    id_depo VARCHAR(10) NOT NULL,
    id_karyawan VARCHAR(10) NOT NULL,
    created_at DATETIME Not Null,
    created_by VARCHAR(10),
    updated_at DATETIME not Null,
    updated_by VARCHAR(10) NULL,
    deleted_at DATETIME NULL,
    deleted_by VARCHAR(10) NULL,
    catatan VARCHAR(255),
    CONSTRAINT fk_detail_karyawan_depo FOREIGN KEY (id_depo) REFERENCES Depo(id_depo),
    CONSTRAINT fk_detail_karyawan_karyawan FOREIGN KEY (id_karyawan) REFERENCES Karyawan(id_karyawan)
)





CREATE TABLE detail_keluarmasukobat (
    id_kartustok VARCHAR(15) NOT NULL,
    id_kategori VARCHAR(15) NOT NULL,
    id_obat VARCHAR(15) NOT NULL,
    stok_barang INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL,
    catatan VARCHAR(255),
    CONSTRAINT fk_detail_keluarmasukobat_kartu_stok FOREIGN KEY (id_kartustok) REFERENCES kartu_stok(id_kartustok),
    CONSTRAINT fk_detail_keluarmasukobat_kategori FOREIGN KEY (id_kategori) REFERENCES kategori(id_kategori), 
    CONSTRAINT fkfkfkf FOREIGN KEY (id_obat) REFERENCES obat(id_obat) 
);//salah



CREATE TABLE cara_pakai (
    id INT AUTO_INCREMENT PRIMARY KEY,               
    id_cara_pakai VARCHAR(50) NOT NULL UNIQUE,        
    nama_cara_pakai VARCHAR(200) NOT NULL,            
    created_at DATETIME NOT NULL,
    keterangan VARCHAR(255) NULL                        
);


CREATE TABLE keterangan_pakai (
    id INT AUTO_INCREMENT PRIMARY KEY,               
    id_keterangan_pakai VARCHAR(50) NOT NULL UNIQUE,  
    nama_keterangan_pakai VARCHAR(200) NOT NULL,      
    created_at DATETIME NOT NULL,
    keterangan VARCHAR(255) NULL                        
) ;

CREATE TABLE nomor_batch (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_nomor_batch VARCHAR(100) NOT NULL UNIQUE,
    no_batch VARCHAR(200) NOT NULL,
    kadaluarsa DATE NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NULL,
    keterangan VARCHAR(255)
)

CREATE TABLE kartu_stok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_depo VARCHAR(10) NOT NULL,
    id_obat VARCHAR(100) NOT NULL,
    id_kartustok VARCHAR(100) NOT NULL,
    stok_barang INT NOT NULL,
    created_at DATETIME NOT NULL,
    created_by VARCHAR(10) NOT NULL,
    updated_at DATETIME NULL,
    updated_by VARCHAR(10) NULL,
    deleted_at DATETIME NULL,
    deleted_by VARCHAR(10) NULL,
    keterangan VARCHAR(255),
    CONSTRAINT fk_kartu_stock_depo FOREIGN KEY (id_depo) REFERENCES Depo(id_depo),
    CONSTRAINT fk_kartu_stok_obat FOREIGN KEY (id_obat) REFERENCES obat_jadi(id_obat)
);

CREATE TABLE detail_kartustok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_detail_kartu_stok VARCHAR(100) UNIQUE NOT NULL, 
    id_kartustok VARCHAR(100) NOT NULL,
    id_transaksi VARCHAR(100) NULL,
    id_distribusi VARCHAR (50) NULL,
    id_retur VARCHAR(50) NULL,
    id_depo VARCHAR(10),
    id_stokopname VARCHAR(50) NULL,
    id_batch_penerimaan VARCHAR(100) NULL,
    id_nomor_batch VARCHAR(100),
    masuk INT NOT NULL DEFAULT 0,    
    keluar INT NOT NULL DEFAULT 0,    
    sisa INT NOT NULL DEFAULT 0,      
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    deleted_at DATETIME,
    CONSTRAINT fk_detail_kartustok_kartu_stok
        FOREIGN KEY (id_kartustok)
        REFERENCES kartu_stok(id_kartustok)
        ON UPDATE CASCADE
        ON DELETE RESTRICT 
);


CREATE TABLE IF NOT EXISTS `detail_kartustok` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `id_detail_kartu_stok` varchar(100) UNIQUE NOT NULL,
  `id_kartustok` varchar(100) NOT NULL,
  `id_transaksi` varchar(100) DEFAULT NULL,
  `id_distribusi` varchar(100) DEFAULT NULL,
  `id_batch_penerimaan` varchar(100) DEFAULT NULL,
  `id_nomor_batch` varchar(100) DEFAULT NULL,
  `masuk` int(11) NOT NULL DEFAULT 0,
  `keluar` int(11) NOT NULL DEFAULT 0,
  `sisa` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  KEY `fk_detail_kartustok__kartu_stok` (`id_kartustok`),
  CONSTRAINT `fk_detail_kartustok__kartu_stok` FOREIGN KEY (`id_kartustok`) REFERENCES `kartu_stok` (`id_kartustok`) ON UPDATE CASCADE
)

CREATE TABLE obat_jadi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_obat VARCHAR(100) NOT NULL UNIQUE,
    id_satuan VARCHAR(10) NOT NULL,
    id_kategori VARCHAR(15) NOT NULL,
    nama_obat VARCHAR(150) NOT NULL,
    harga_jual FLOAT UNSIGNED NOT NULL,
    harga_beli FLOAT UNSIGNED NOT NULL,
    stok_minimum INT UNSIGNED NOT NULL,
    uprate FLOAT UNSIGNED NULL,
    created_at DATETIME NOT NULL,
    created_by VARCHAR(10) NOT NULL,
    updated_at DATETIME ,
    updated_by VARCHAR(10) NULL,
    deleted_at DATETIME,
    deleted_by VARCHAR(10) NULL,
    link_gambar_obat TEXT NULL, 
    keterangan VARCHAR(255),
    keterangan_hapus VARCHAR(255),
    CONSTRAINT fk_obat_jadi_kategori FOREIGN KEY (id_kategori) REFERENCES Kategori(id_kategori),
    CONSTRAINT fk_obat_satuan FOREIGN KEY (id_satuan) REFERENCES satuan(id_satuan)

);



CREATE TABLE satuan(
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_satuan VARCHAR(10) NOT NULL UNIQUE,
    nama_satuan VARCHAR(50) NOT NULL,
    catatan VARCHAR(255),
    created_at DATETIME
);


CREATE TABLE pembelian_penerimaan(
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pembelian_penerimaan_obat VARCHAR(50) NOT NULL UNIQUE,
    id_supplier VARCHAR(50) NOT NULL,
    total_harga DECIMAL(15,3) UNSIGNED NOT NULL,
    keterangan VARCHAR(255) NULL,
    tanggal_pemesanan DATE NOT NULL,
    tanggal_penerimaan DATE NULL,
    tanggal_pembayaran DATE NULL,
    pemesan VARCHAR(10) NULL,
    penerima VARCHAR(10) NULL,
    created_at DATETIME NOT NULL,
    created_by VARCHAR(10) NOT NULL,
    updated_at DATETIME NULL,
    updated_by VARCHAR(10) NULL,
    deleted_at DATETIME NULL,
    deleted_by VARCHAR(10) NULL,
    constraint fk_supplier FOREIGN KEY (id_supplier) REFERENCES supplier(id_supplier),
    constraint fk_pemesan FOREIGN KEY (pemesan) REFERENCES Karyawan(id_karyawan),
    constraint fk_penerima FOREIGN KEY (penerima) REFERENCES Karyawan(id_karyawan)

)

CREATE TABLE detail_pembelian_penerimaan(
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pembelian_penerimaan_obat VARCHAR(50) NOT NULL, 
    id_detail_pembelian_penerimaan_obat VARCHAR(50) NOT NULL UNIQUE,
    id_kartustok VARCHAR(100) NOT NULL,
    id_depo VARCHAR(10) NOT NULL,
    id_status VARCHAR(50) NOT NULL,
    nama_obat VARCHAR(255) NOT NULL,
    jumlah_dipesan INT UNSIGNED NOT NULL,
    jumlah_diterima INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NULL,
    created_by VARCHAR (10) NOT NULL, 
    updated_by VARCHAR(10) NULL,
    constraint fk_pembelian_penerimaan_obat FOREIGN KEY (id_pembelian_penerimaan_obat) REFERENCES pembelian_penerimaan(id_pembelian_penerimaan_obat),
    constraint fk_kartu_stok FOREIGN KEY (id_kartustok, id_depo) REFERENCES kartu_stok(id_kartustok, id_depo),
    constraint fk_status FOREIGN KEY (id_status) REFERENCES status(id_status)

) 
// jangan lupa ini created_by di heidi masih null, harus diganti ke not null

CREATE TABLE status(
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_status VARCHAR(50) NOT NULL UNIQUE,
    nama_status VARCHAR(255) NOT NULL,
    keterangan VARCHAR(255) NULL
)

CREATE TABLE supplier (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_supplier VARCHAR(15) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    no_telp VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NULL,
    deleted_at DATETIME,
    keterangan VARCHAR(255)
);

CREATE TABLE batch_penerimaan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_batch_penerimaan VARCHAR(100) NOT NULL UNIQUE,  -- New business ID field
    id_detail_pembelian_penerimaan VARCHAR(50) NOT NULL,
    id_nomor_batch VARCHAR(100) NOT NULL,
    jumlah_diterima INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_batch_detail 
        FOREIGN KEY (id_detail_pembelian_penerimaan)
        REFERENCES detail_pembelian_penerimaan(id_detail_pembelian_penerimaan_obat),
    CONSTRAINT fk_nomor_batch 
        FOREIGN KEY (id_nomor_batch)
        REFERENCES nomor_batch(id_nomor_batch)
);


CREATE TABLE transaksi (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    id_transaksi         VARCHAR(100) NOT NULL UNIQUE,   
    id_karyawan          VARCHAR(10) NOT NULL,          
    total_harga          DECIMAL(15,2) UNSIGNED NOT NULL,
    metode_pembayaran    VARCHAR(30)  NOT NULL,         
    keterangan           VARCHAR(255),   
     id_status                   TINYINT NOT NULL,               
    created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at           DATETIME,
    CONSTRAINT fk_transaksi_karyawan
        FOREIGN KEY (id_karyawan)
        REFERENCES Karyawan(id_karyawan),

    CONSTRAINT fk_transaksi_status
        FOREIGN KEY (id_status)
        REFERENCES status_transaksi(id_status)
);


CREATE TABLE aturan_pakai (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    id_aturan_pakai  VARCHAR(50) NOT NULL UNIQUE,
    aturan_pakai    VARCHAR(255) NOT NULL,
    created_at       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    keterangan       VARCHAR(255)
);


CREATE TABLE cara_pakai (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    id_cara_pakai   VARCHAR(50) NOT NULL UNIQUE,
    nama_cara_pakai VARCHAR(255) NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    keterangan      VARCHAR(255)
);


CREATE TABLE keterangan_pakai (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    id_keterangan_pakai    VARCHAR(50) NOT NULL UNIQUE,
    nama_keterangan_pakai  VARCHAR(255) NOT NULL,
    created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    keterangan             VARCHAR(255)
);

CREATE TABLE detail_transaksi_penjualan_obat (
    id                          INT AUTO_INCREMENT PRIMARY KEY,   
    id_kartustok                VARCHAR(100) NOT NULL,   
    id_e_resep                  VARCHAR(50),             
    id_transaksi                VARCHAR(100)  NOT NULL,   
    id_aturan_pakai             VARCHAR(50),
    id_cara_pakai               VARCHAR(50),                
    id_keterangan_pakai         VARCHAR(50),             
    id_nomor_batch              VARCHAR(100) NOT NULL,   
    id_kustomer                 VARCHAR(15) NULL, 
               
    total_harga                 DECIMAL(15,2) UNSIGNED NOT NULL,
    kadaluarsa                  DATE NOT NULL,
    jumlah                      INT UNSIGNED NOT NULL,

    CONSTRAINT fk_dtp_kartustok
        FOREIGN KEY (id_kartustok)
        REFERENCES kartu_stok(id_kartustok),

    CONSTRAINT fk_dtp_transaksi
        FOREIGN KEY (id_transaksi)
        REFERENCES transaksi(id_transaksi),

    CONSTRAINT fk_dtp_nomor_batch
        FOREIGN KEY (id_nomor_batch)
        REFERENCES nomor_batch(id_nomor_batch),

    CONSTRAINT fk_dtp_kustomer
        FOREIGN KEY (id_kustomer)
        REFERENCES Kustomer(id_kustomer)    

    
);



CREATE TABLE status_transaksi (
    id_status    TINYINT  PRIMARY KEY,      
    nama_status  VARCHAR(20) NOT NULL UNIQUE,
    keterangan   VARCHAR(255)
);

INSERT INTO status_transaksi (id_status, nama_status, keterangan) VALUES
  (1, 'berhasil', 'Transaksi lunas, stok sudah keluar'),
  (2, 'cancel',   'Transaksi dibatalkan, stok tidak keluar');






/* =================================================================== */
/*  COUNTER  (if you use the same pattern)                             */
/* =================================================================== */
CREATE TABLE IF NOT EXISTS distribusicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO distribusicounter (count) VALUES (1);

CREATE TABLE IF NOT EXISTS detaildistribusicounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO detaildistribusicounter (count) VALUES (1);

CREATE TABLE IF NOT EXISTS stok_opnamecounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT INTO stok_opnamecounter (count) VALUES (1);

CREATE TABLE IF NOT EXISTS detail_stokopnamecounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO detail_stokopnamecounter (count) VALUES (1);

CREATE TABLE IF NOT EXISTS stok_opname_batchcounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO stok_opname_batchcounter (count) VALUES (1);

/* =================================================================== */
/* 1.  distribusi  – header                                            */
/* =================================================================== */
CREATE TABLE distribusi (
    id INT AUTO_INCREMENT PRIMARY KEY,

    id_distribusi        VARCHAR(50) NOT NULL UNIQUE,   -- business ID e.g. "DIS37"
    id_depo_asal         VARCHAR(10) NOT NULL,          -- Gudang, Apotik, dll.
    id_depo_tujuan       VARCHAR(10) NOT NULL,

    tanggal_permohonan   DATE NOT NULL,                 -- request date
    tanggal_pengiriman   DATE,                          -- filled when shipped

            
    keterangan           VARCHAR(255),

    created_at           DATETIME NOT NULL,
    created_by           VARCHAR(10) NOT NULL,
    updated_at           DATETIME,
    updated_by           VARCHAR(10),
    deleted_at           DATETIME,
    deleted_by           VARCHAR(10),
    id_status    VARCHAR(50)

    CONSTRAINT fk_distribusi_depo_asal
        FOREIGN KEY (id_depo_asal)   REFERENCES Depo(id_depo),
    CONSTRAINT fk_distribusi_depo_tujuan
        FOREIGN KEY (id_depo_tujuan) REFERENCES Depo(id_depo)
    
);

/* =================================================================== */
/* 2.  detail_distribusi  – line items                                 */
/* =================================================================== */
CREATE TABLE detail_distribusi (
    id INT AUTO_INCREMENT PRIMARY KEY,

    id_detail_distribusi  VARCHAR(50) NOT NULL UNIQUE,   -- e.g. "DDS99"
    id_distribusi         VARCHAR(50) NOT NULL,          -- FK → header
      -- exact batch
    jumlah_diminta        INT UNSIGNED NOT NULL,
    jumlah_dikirim        INT UNSIGNED NOT NULL,
id_status            VARCHAR(50) NOT NULL DEFAULT '0', //jangan lupa ini di dump harus diganti 
    created_at            DATETIME NOT NULL,
    created_by            VARCHAR(10),
    updated_at            DATETIME,
    updated_by            VARCHAR(10),
    created_by            VARCHAR(10),
    deleted_at            DATETIME,
    deleted_by            VARCHAR(10)

    CONSTRAINT fk_detail_distribusi_header
        FOREIGN KEY (id_distribusi)  REFERENCES distribusi(id_distribusi),

    CONSTRAINT fk_detail_distribusi_kartu
        FOREIGN KEY (id_kartustok)   REFERENCES kartu_stok(id_kartustok),
    CONSTRAINT fk_distribusi_status
        FOREIGN KEY (id_status)      REFERENCES status(id_status)
);



CREATE TABLE batch_detail_distribusi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_batch_detail_distribusi VARCHAR(50) NOT NULL UNIQUE,
    id_detail_distribusi VARCHAR(50) NOT NULL,       -- FK ke detail_distribusi
    id_nomor_batch VARCHAR(100) NOT NULL,            -- batch yg digunakan
    jumlah INT UNSIGNED NOT NULL,                    -- jumlah dari batch ini
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_detail_distribusi) REFERENCES detail_distribusi(id_detail_distribusi),
    FOREIGN KEY (id_nomor_batch) REFERENCES nomor_batch(id_nomor_batch)
);



CREATE TABLE stok_opname (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_stokopname VARCHAR(50) UNIQUE NOT NULL,
    id_depo VARCHAR(10) NOT NULL,
    tanggal_stokopname DATE NOT NULL, 
    catatan VARCHAR(255),
    created_at DATETIME NOT NULL,
    created_by VARCHAR(10) NOT NULL,
    updated_at      DATETIME,
    updated_by      VARCHAR(10),
    FOREIGN KEY (id_depo) REFERENCES Depo(id_depo)
);



CREATE TABLE detail_stokopname (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_stokopname VARCHAR(50) NOT NULL,
    id_detail_stokopname VARCHAR(100) NOT NULL UNIQUE,
    id_kartustok VARCHAR(15) NOT NULL,
    sistem_qty      INT        NOT NULL,       
    fisik_qty       INT        DEFAULT 0,     
    selisih         INT        DEFAULT 0,
    catatan VARCHAR(255),
    created_at DATETIME NOT NULL,
    created_by      VARCHAR(10) NOT NULL,
    updated_at DATETIME,
    updated_by      VARCHAR(10) NULL,
    CONSTRAINT fk_detail_stokopname_stokopname FOREIGN KEY (id_stokopname) REFERENCES stok_opname(id_stokopname),
    CONSTRAINT fk_detail_stokopname_kartustok FOREIGN KEY (id_kartustok) REFERENCES kartu_stok(id_kartustok)
);


CREATE TABLE stok_opname_batch(
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_stok_opname_batch VARCHAR(100) NOT NULL UNIQUE,
    id_detail_stokopname VARCHAR(100) NOT NULL,
    id_nomor_batch VARCHAR(100) NOT NULL,
    sistem_qty      INT        NOT NULL,       
    fisik_qty       INT        DEFAULT 0,     
    selisih         INT        DEFAULT 0,
    catatan VARCHAR(255),
    created_at      DATETIME   NOT NULL,
    created_by      VARCHAR(10) NOT NULL,
    updated_at      DATETIME,
    updated_by      VARCHAR(10),
    FOREIGN KEY (id_detail_stokopname)    REFERENCES detail_stokopname(id_detail_stokopname),
    FOREIGN KEY (id_nomor_batch) REFERENCES nomor_batch(id_nomor_batch)
)


CREATE TABLE retur_barang (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    id_retur         VARCHAR(50)  NOT NULL UNIQUE,
    id_depo          VARCHAR(10)  NOT NULL,        
    tanggal_retur    DATE         NOT NULL,
    tujuan_retur     VARCHAR(100) NOT NULL,       
    catatan          VARCHAR(255),
    created_at       DATETIME     NOT NULL,
    created_by       VARCHAR(10)  NOT NULL,
    updated_at       DATETIME,
    updated_by       VARCHAR(10),
    FOREIGN KEY (id_depo) REFERENCES Depo(id_depo)
)

CREATE TABLE detail_retur_barang (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    id_detail_retur_barang     VARCHAR(50) NOT NULL UNIQUE,
    id_retur          VARCHAR(50) NOT NULL,
    id_kartustok      VARCHAR(100) NOT NULL,
    total_qty         INT  NOT NULL,
    catatan           VARCHAR(255),
    created_at        DATETIME NOT NULL,
    created_by        VARCHAR(10) NOT NULL,
    updated_at        DATETIME,
    updated_by        VARCHAR(10),
    FOREIGN KEY (id_retur)     REFERENCES retur_barang(id_retur),
    FOREIGN KEY (id_kartustok) REFERENCES kartu_stok(id_kartustok)
)


CREATE TABLE batch_retur_barang(
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    id_batch_retur_barang     VARCHAR(50)  NOT NULL UNIQUE,
    id_detail_retur_barang      VARCHAR(50)  NOT NULL,
    id_nomor_batch     VARCHAR(100) NOT NULL,
    qty                INT NOT NULL,
    catatan            VARCHAR(255),
    created_at         DATETIME NOT NULL,
    created_by         VARCHAR(10) NOT NULL,
    updated_at         DATETIME,
    updated_by         VARCHAR(10),
    FOREIGN KEY (id_detail_retur_barang)  REFERENCES detail_retur_barang(id_detail_retur_barang),
    FOREIGN KEY (id_nomor_batch) REFERENCES nomor_batch(id_nomor_batch)
) 

CREATE TABLE IF NOT EXISTS retur_barangcounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO retur_barangcounter (count) VALUES (1);

CREATE TABLE IF NOT EXISTS detail_retur_barangcounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO detail_retur_barangcounter (count) VALUES (1);

CREATE TABLE IF NOT EXISTS batch_retur_barangcounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY
);
INSERT IGNORE INTO batch_retur_barangcounter (count) VALUES (1);

/home/rs/farmasi/backend/Apotik-Batarangin/Backend