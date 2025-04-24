import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:apotek/global.dart';

class Produk {
  String nomorKartu;
  String nomorBatch;
  String kategori;
  String kode;
  String namaObat;
  int jumlah;
  DateTime kadaluarsa;
  String satuan;
  String caraPemakaian;

  Produk(
      {required this.nomorKartu,
      required this.nomorBatch,
      required this.kategori,
      required this.kadaluarsa,
      required this.jumlah,
      required this.kode,
      required this.namaObat,
      required this.caraPemakaian,
      required this.satuan});
}

// yg di api
class ObatResponse {
  final int status;
  final String message;
  final List<Products> data;
  final Metadata metadata;

  ObatResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.metadata,
  });

  factory ObatResponse.fromJson(Map<String, dynamic> json) {
    return ObatResponse(
      status: json['status'],
      message: json['message'],
      data: List<Products>.from(json['data'].map((x) => Products.fromJson(x))),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
        'metadata': metadata.toJson(),
      };
}

class Metadata {
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalRecords;

  Metadata({
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.totalRecords,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      currentPage: json['current_page'],
      pageSize: json['page_size'],
      totalPages: json['total_pages'],
      totalRecords: json['total_records'],
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'page_size': pageSize,
        'total_pages': totalPages,
        'total_records': totalRecords,
      };
}

//

class Products {
  final int id;
  final String idObat;
  final String idSatuan;
  final String idKategori;
  final String namaObat;
  final double hargaJual;
  final double hargaBeli;
  final int stokMinimum;
  // final double uprate;
  final DateTime createdAt;
  final String createdBy;
  final String linkGambarObat;
  final String keterangan;
  final String namaSatuan;

  Products({
    required this.id,
    required this.idObat,
    required this.idSatuan,
    required this.idKategori,
    required this.namaObat,
    required this.hargaJual,
    required this.hargaBeli,
    required this.stokMinimum,
    // required this.uprate,
    required this.createdAt,
    required this.createdBy,
    required this.linkGambarObat,
    required this.keterangan,
    required this.namaSatuan,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'] ?? 0,
      idObat: json['id_obat'] ?? '',
      idSatuan: json['id_satuan'] ?? '',
      idKategori: json['id_kategori'] ?? '',
      namaObat: json['nama_obat'] ?? '',
      hargaJual: (json['harga_jual'] ?? 0).toDouble(),
      hargaBeli: (json['harga_beli'] ?? 0).toDouble(),
      stokMinimum: json['stok_minimun'] ?? 0,
      // uprate: (json['uprate'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] ?? '',
      linkGambarObat: json['link_gambar_obat'] ?? '',
      keterangan: json['keterangan'] ?? '',
      namaSatuan: json['nama_satuan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_obat': idObat,
      'id_satuan': idSatuan,
      'id_kategori': idKategori,
      'nama_obat': namaObat,
      'harga_jual': hargaJual,
      'harga_beli': hargaBeli,
      'stok_minimun': stokMinimum,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'link_gambar_obat': linkGambarObat,
      'keterangan': keterangan,
      'nama_satuan': namaSatuan,
    };
  }

  static List<Products> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Products.fromJson(json)).toList();
  }

  static Future<List<Products>> getData() async {
    String url =
        "http://leap.crossnet.co.id:2688/product/info?page=1&page_size=20";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': 'helopanda'});
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    List<Products> produkObat = [];

    if (response.statusCode == 200) {
      for (int i = 0; i < data.length; i++) {
        produkObat.add(Products.fromJson(data[i]));
      }
      print(produkObat);
      return produkObat;
    } else {
      throw Exception("Gagal Load Data");
    }
  }
}

class KategoriObat {
  final int id;
  final String idDepo;
  final String idKategori;
  final String nama;
  final String createdAt;
  final String updatedAt;

  KategoriObat({
    required this.id,
    required this.idDepo,
    required this.idKategori,
    required this.nama,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KategoriObat.fromJson(Map<String, dynamic> json) {
    return KategoriObat(
      id: json['id'],
      idDepo: json['id_depo'],
      idKategori: json['id_kategori'],
      nama: json['nama'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_depo': idDepo,
        'id_kategori': idKategori,
        'nama': nama,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  static Future<List<KategoriObat>> getDataKategori() async {
    String url = "http://leap.crossnet.co.id:2688/category";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

    if (response.statusCode == 200) {
      var jsonList = jsonDecode(response.body);
      List<KategoriObat> kategoriList = jsonList
          .map<KategoriObat>((json) => KategoriObat.fromJson(json))
          .toList();
      return kategoriList;
    } else {
      throw Exception("Gagal Load Data Kategori");
    }
  }
}

class SatuanObat {
  final int id;
  final String idSatuan;
  final String namaSatuan;
  final String catatan;
  final DateTime createdAt;

  SatuanObat({
    required this.id,
    required this.idSatuan,
    required this.namaSatuan,
    required this.catatan,
    required this.createdAt,
  });

  factory SatuanObat.fromJson(Map<String, dynamic> json) {
    return SatuanObat(
      id: json['id'],
      idSatuan: json['id_satuan'],
      namaSatuan: json['nama_satuan'],
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_satuan': idSatuan,
      'nama_satuan': namaSatuan,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Future<List<SatuanObat>> getDataSatuan() async {
    String url = "http://leap.crossnet.co.id:2688/satuan";
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': '$token',
      'x-api-key': '$xApiKey',
    });
    print("test");
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(response.body);
      List<SatuanObat> satuanList = jsonList
          .map<SatuanObat>((json) => SatuanObat.fromJson(json))
          .toList();
      return satuanList;
    } else {
      throw Exception("Gagal Load Data Satuan");
    }
  }
}
