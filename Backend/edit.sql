-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.6.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.9.0.6999
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for ApotikDB
CREATE DATABASE IF NOT EXISTS `pharmacy` /*!40100 DEFAULT CHARACTER SET utf8mb4  */;
USE `pharmacy`;

-- --------------------------------------------------------
-- Table structure for table Counter
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Counter` (
  `count` bigint(20) NOT NULL DEFAULT 1,
  PRIMARY KEY (`count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

INSERT INTO `Counter` (`count`) VALUES
	(21);

-- --------------------------------------------------------
-- Table structure for table Depo
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Depo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_depo` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` varchar(255) NOT NULL,
  `no_telp` varchar(20) NOT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_depo` (`id_depo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table detail_karyawan
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `detail_karyawan` (
  `id_depo` varchar(10) NOT NULL,
  `id_karyawan` varchar(10) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(10) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(10) DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  KEY `fk_detail_karyawan_karyawan` (`id_karyawan`),
  KEY `fk_detail_karyawan_depo` (`id_depo`),
  CONSTRAINT `fk_detail_karyawan_depo` FOREIGN KEY (`id_depo`) REFERENCES `Depo` (`id_depo`) ON UPDATE CASCADE,
  CONSTRAINT `fk_detail_karyawan_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `Karyawan` (`id_karyawan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table detail_privilege_karyawan
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `detail_privilege_karyawan` (
  `id_privilege` varchar(10) NOT NULL,
  `id_karyawan` varchar(10) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  KEY `fk_detail_privilege_karyawan` (`id_karyawan`),
  KEY `fk_detail_privilege_privilege` (`id_privilege`),
  CONSTRAINT `fk_detail_privilege_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `Karyawan` (`id_karyawan`) ON UPDATE CASCADE,
  CONSTRAINT `fk_detail_privilege_privilege` FOREIGN KEY (`id_privilege`) REFERENCES `Privilege` (`id_privilege`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table detail_role_karyawan
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `detail_role_karyawan` (
  `id_role` varchar(10) NOT NULL,
  `id_karyawan` varchar(10) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  KEY `fk_detail_role_karyawan` (`id_karyawan`),
  KEY `fk_detail_role_role` (`id_role`),
  CONSTRAINT `fk_detail_role_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `Karyawan` (`id_karyawan`) ON UPDATE CASCADE,
  CONSTRAINT `fk_detail_role_role` FOREIGN KEY (`id_role`) REFERENCES `Role` (`id_role`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table kartu_stok_apotik
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `kartu_stok_apotik` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_satuan` varchar(10) NOT NULL,
  `id_depo` varchar(10) NOT NULL,
  `id_kartustok` varchar(15) NOT NULL,
  `stok_barang` int(10) unsigned NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(10) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(10) DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_kartustok` (`id_kartustok`),
  KEY `fk_kartu_stock_depo` (`id_depo`),
  KEY `fk_kartu_stock_satuan` (`id_satuan`),
  CONSTRAINT `fk_kartu_stock_depo` FOREIGN KEY (`id_depo`) REFERENCES `Depo` (`id_depo`),
  CONSTRAINT `fk_kartu_stock_satuan` FOREIGN KEY (`id_satuan`) REFERENCES `satuan` (`id_satuan`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table kartu_stok_gudang
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `kartu_stok_gudang` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_satuan` varchar(10) NOT NULL,
  `id_depo` varchar(10) NOT NULL,
  `id_kartustok` varchar(15) NOT NULL,
  `stok_barang` int(10) unsigned NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(10) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(10) DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_kartustok` (`id_kartustok`),
  KEY `fk_kartu_stock_depo_gudang` (`id_depo`),
  KEY `fk_kartu_stock_satuan_gudang` (`id_satuan`),
  CONSTRAINT `fk_kartu_stock_depo_gudang` FOREIGN KEY (`id_depo`) REFERENCES `Depo` (`id_depo`),
  CONSTRAINT `fk_kartu_stock_satuan_gudang` FOREIGN KEY (`id_satuan`) REFERENCES `satuan` (`id_satuan`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table Karyawan
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Karyawan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_karyawan` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` varchar(255) NOT NULL,
  `no_telp` varchar(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_karyawan` (`id_karyawan`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table Kategori
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Kategori` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_kategori` varchar(15) NOT NULL,
  `id_depo` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(10) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(10) DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_kategori` (`id_kategori`),
  KEY `id_depo` (`id_depo`),
  CONSTRAINT `kategori_ibfk_1` FOREIGN KEY (`id_depo`) REFERENCES `Depo` (`id_depo`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table KategoriCounter
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `KategoriCounter` (
  `count` bigint(20) NOT NULL DEFAULT 1,
  PRIMARY KEY (`count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table Kustomer
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Kustomer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_kustomer` varchar(15) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` varchar(255) NOT NULL,
  `no_telp` varchar(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_kustomer` (`id_kustomer`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table ObatCounter
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ObatCounter` (
  `count` bigint(20) NOT NULL DEFAULT 1,
  PRIMARY KEY (`count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table ObatCounterGudang
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ObatCounterGudang` (
  `count` bigint(20) NOT NULL DEFAULT 1,
  PRIMARY KEY (`count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table obat_apotik
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `obat_apotik` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_obat` varchar(15) NOT NULL,
  `id_satuan` varchar(10) NOT NULL,
  `id_depo` varchar(10) NOT NULL,
  `id_kartustok` varchar(15) NOT NULL,
  `id_kategori` varchar(15) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `harga_jual` int(10) unsigned NOT NULL,
  `harga_beli` int(10) unsigned NOT NULL,
  `stok_barang` int(10) unsigned NOT NULL,
  `uprate` int(10) unsigned NOT NULL,
  `no_batch` varchar(20) NOT NULL,
  `kadaluarsa` date NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(10) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(10) DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_obat` (`id_obat`),
  KEY `fk_obat_jadi_kartu_stok_apotik` (`id_kartustok`),
  KEY `fk_obat_jadi_depo` (`id_depo`),
  KEY `fk_obat_jadi_kategori` (`id_kategori`),
  KEY `fk_obat_satuan` (`id_satuan`),
  CONSTRAINT `fk_obat_jadi_depo` FOREIGN KEY (`id_depo`) REFERENCES `Depo` (`id_depo`),
  CONSTRAINT `fk_obat_jadi_kartu_stok_apotik` FOREIGN KEY (`id_kartustok`) REFERENCES `kartu_stok_apotik` (`id_kartustok`),
  CONSTRAINT `fk_obat_jadi_kategori` FOREIGN KEY (`id_kategori`) REFERENCES `Kategori` (`id_kategori`),
  CONSTRAINT `fk_obat_satuan` FOREIGN KEY (`id_satuan`) REFERENCES `satuan` (`id_satuan`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table obat_gudang
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `obat_gudang` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_obat` varchar(15) NOT NULL,
  `id_satuan` varchar(10) NOT NULL,
  `id_depo` varchar(10) NOT NULL,
  `id_kartustok` varchar(15) NOT NULL,
  `id_kategori` varchar(15) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `harga_jual` int(10) unsigned NOT NULL,
  `harga_beli` int(10) unsigned NOT NULL,
  `stok_barang` int(10) unsigned NOT NULL,
  `uprate` int(10) unsigned NOT NULL,
  `no_batch` varchar(20) NOT NULL,
  `kadaluarsa` date NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` varchar(10) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` varchar(10) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(10) DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_obat` (`id_obat`),
  KEY `fk_obat_jadi_kartu_stok_gudang` (`id_kartustok`),
  KEY `fk_obat_jadi_depo_gudang` (`id_depo`),
  KEY `fk_obat_jadi_kategori_gudang` (`id_kategori`),
  KEY `fk_obat_satuan_gudang` (`id_satuan`),
  CONSTRAINT `fk_obat_jadi_depo_gudang` FOREIGN KEY (`id_depo`) REFERENCES `Depo` (`id_depo`),
  CONSTRAINT `fk_obat_jadi_kartu_stok_gudang` FOREIGN KEY (`id_kartustok`) REFERENCES `kartu_stok_gudang` (`id_kartustok`),
  CONSTRAINT `fk_obat_jadi_kategori_gudang` FOREIGN KEY (`id_kategori`) REFERENCES `Kategori` (`id_kategori`),
  CONSTRAINT `fk_obat_satuan_gudang` FOREIGN KEY (`id_satuan`) REFERENCES `satuan` (`id_satuan`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table Privilege
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Privilege` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_privilege` varchar(10) NOT NULL,
  `nama_privilege` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_privilege` (`id_privilege`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table Role
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_role` varchar(10) NOT NULL,
  `nama_role` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_role` (`id_role`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table satuan
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `satuan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_satuan` varchar(10) NOT NULL,
  `nama_satuan` varchar(50) NOT NULL,
  `jumlah` int(10) unsigned NOT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_satuan` (`id_satuan`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------
-- Table structure for table StaffLogin
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `StaffLogin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_karyawan` varchar(10) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_karyawan` (`id_karyawan`),
  UNIQUE KEY `username` (`username`),
  CONSTRAINT `fk_stafflogin_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `Karyawan` (`id_karyawan`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
