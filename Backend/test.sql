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
    catatan VARCHAR(255)
);

-- Create the Privilege table
CREATE TABLE Privilege (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_privilege VARCHAR(10) NOT NULL UNIQUE,
    nama_privilege VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    catatan VARCHAR(255)
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
    catatan VARCHAR(255)
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




CREATE TABLE stok_opname (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_stokopname VARCHAR(10) UNIQUE NOT NULL,
    id_satuan
    stok_barang INT UNSIGNED NOT NULL,
    catatan VARCHAR(255),
    created_at DATETIME NOT NULL
);



CREATE TABLE detail_stokopname (
    id_depo VARCHAR(10) NOT NULL,
    id_stokopname VARCHAR(10) NOT NULL,
    id_kartustok VARCHAR(15) NOT NULL,
    inputjumlah INT UNSIGNED NOT NULL, 
    catatan VARCHAR(255),
    created_at DATETIME NOT NULL,
    updated_at DATETIME,
    deleted_at DATETIME,
    CONSTRAINT fk_detail_stokopname_stokopname FOREIGN KEY (id_stokopname) REFERENCES stok_opname(id_stokopname),
    CONSTRAINT fk_detail_stokopname_kartustok FOREIGN KEY (id_kartustok) REFERENCES kartu_stok(id_kartustok)
); //berubah , lihat erd

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
    id_distribusi VARCHAR(100) NULL,
    id_pembelian_penerimaan_obat VARCHAR(100) NULL,
    id_nomor_batch VARCHAR(100),
    masuk INT NOT NULL DEFAULT 0,    
    keluar INT NOT NULL DEFAULT 0,    
    sisa INT NOT NULL DEFAULT 0,      
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    deleted_at DATETIME,
    CONSTRAINT fk_detail_kartustok__kartu_stok
        FOREIGN KEY (id_kartustok)
        REFERENCES kartu_stok (id_kartustok)
        ON UPDATE CASCADE
        ON DELETE RESTRICT, 
);

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
    total_harga FLOAT UNSIGNED NOT NULL,
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
    constraint fk_pembelian_penerimaan_obat FOREIGN KEY (id_pembelian_penerimaan_obat) REFERENCES pembelian_penerimaan(id_pembelian_penerimaan_obat),
    constraint fk_kartu_stok FOREIGN KEY (id_kartustok, id_depo) REFERENCES kartu_stok(id_kartustok, id_depo),
    constraint fk_status FOREIGN KEY (id_status) REFERENCES status(id_status)

)

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


/home/rs/farmasi/backend/Apotik-Batarangin/Backend