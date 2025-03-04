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

CREATE TABLE ObatCounter (
    count BIGINT NOT NULL DEFAULT 1 PRIMARY KEY 
);

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
    id_depo VARCHAR(10) NOT NULL,             -- FK: Foreign Key referencing Depo
    id_kategori VARCHAR(15) NOT NULL UNIQUE,   -- UQ: Unique constraint
    nama VARCHAR(100) NOT NULL,        -- NN: Not Null constraint
    created_at DATETIME NOT NULL,       -- NN: Not Null constraint
    deleted_at DATETIME,               -- 0: Optional (NULL allowed)
    updated_at DATETIME NOT NULL,       -- NN: Not Null constraint
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

CREATE TABLE kartu_stok (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_satuan VARCHAR(10) NOT NULL,
    id_depo VARCHAR(10) NOT NULL,
    id_kartustok VARCHAR(15) UNIQUE NOT NULL,
    stok_barang INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL,
    created_by VARCHAR(10) NOT NULL,
    updated_at DATETIME,
    updated_by VARCHAR(10) NULL,
    deleted_at DATETIME,
    deleted_by VARCHAR(10) NULL,
    catatan VARCHAR(255),
    CONSTRAINT fk_kartu_stock_depo FOREIGN KEY (id_depo) REFERENCES Depo(id_depo),
    CONSTRAINT fk_kartu_stock_satuan FOREIGN KEY (id_satuan) REFERENCES satuan(id_satuan)

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
);


CREATE TABLE obat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_obat VARCHAR(15) NOT NULL UNIQUE,
    id_satuan VARCHAR(10) NOT NULL,
    id_depo VARCHAR(10) NOT NULL,
    id_kartustok VARCHAR(15) NOT NULL,
    id_kategori VARCHAR(15) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    harga_jual INT UNSIGNED NOT NULL,
    harga_beli INT UNSIGNED NOT NULL,
    stok_barang INT UNSIGNED NOT NULL,
    uprate INT UNSIGNED NOT NULL,
    no_batch VARCHAR(20) NOT NULL,
    kadaluarsa DATE NOT NULL,
    created_at DATETIME NOT NULL,
    created_by VARCHAR(10) NOT NULL,
    updated_at DATETIME ,
    updated_by VARCHAR(10) NULL,
    deleted_at DATETIME,
    deleted_by VARCHAR(10) NULL,
    catatan VARCHAR(255),
    CONSTRAINT fk_obat_jadi_kartu_stok FOREIGN KEY (id_kartustok) REFERENCES kartu_stok(id_kartustok),
    CONSTRAINT fk_obat_jadi_depo FOREIGN KEY (id_depo) REFERENCES Depo(id_depo),
    CONSTRAINT fk_obat_jadi_kategori FOREIGN KEY (id_kategori) REFERENCES Kategori(id_kategori),
    CONSTRAINT fk_obat_satuan FOREIGN KEY (id_satuan) REFERENCES satuan(id_satuan)

);


CREATE TABLE satuan(
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_satuan VARCHAR(10) NOT NULL UNIQUE,
    nama_satuan VARCHAR(50) NOT NULL,
    jumlah INT UNSIGNED NOT NULL,
    catatan VARCHAR(255),
    created_at DATETIME
);
