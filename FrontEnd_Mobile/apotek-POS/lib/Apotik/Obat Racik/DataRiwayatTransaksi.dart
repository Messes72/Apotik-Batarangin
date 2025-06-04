import 'dart:convert';

import 'package:apotek/global.dart';
import 'package:http/http.dart' as http;
class BahanObatRacik {
  final String idDetailObatRacik;
  final String idObatRacik;
  final String idObat;
  final String namaObat;
  final String catatan;
  final DateTime createdAt;
  double? jumlahKuantitas;
  String? dosis;

  BahanObatRacik({
    required this.idDetailObatRacik,
    required this.idObatRacik,
    required this.idObat,
    required this.namaObat,
    required this.catatan,
    required this.createdAt,
  });

  factory BahanObatRacik.fromJson(Map<String, dynamic> json) {
    return BahanObatRacik(
      idDetailObatRacik: json["id_detail_obat_racik"],
      idObatRacik: json["id_obat_racik"],
      idObat: json["id_obat"],
      namaObat: json["nama_obat"],
      catatan: json["catatan"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_detail_obat_racik": idDetailObatRacik,
      "id_obat_racik": idObatRacik,
      "id_obat": idObat,
      "nama_obat": namaObat,
      "catatan": catatan,
      "created_at": createdAt.toIso8601String(),
    };
  }
}

class ObatRacikData {
  final String idObatRacik;
  final String namaRacik;
  final String catatan;
  final DateTime createdAt;
  final DateTime? updatedAt;
  String? aturanPakai;
  String? carapakai;
  String? keteranganPakai;
  final List<BahanObatRacik>? bahan;

  ObatRacikData({
    required this.idObatRacik,
    required this.namaRacik,
    required this.catatan,
    required this.createdAt,
    this.updatedAt,
    required this.bahan,
  });

  factory ObatRacikData.fromJson(Map<String, dynamic> json) {
    return ObatRacikData(
      idObatRacik: json["id_obat_racik"],
      namaRacik: json["nama_racik"],
      catatan: json["catatan"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"])
          : null,
      bahan: json['bahan'] != null
          ? (json['bahan'] as List).map((e) => BahanObatRacik.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_obat_racik": idObatRacik,
      "nama_racik": namaRacik,
      "catatan": catatan,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "bahan": bahan?.map((e) => e.toJson()).toList(),
    };
  }

  static Future<List<ObatRacikData>> getDataObatRacik() async {
    String url =
        "http://leap.crossnet.co.id:2688/product/racik?page=1&page_size=20";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    List<ObatRacikData> produkObatRacik = [];

    if (response.statusCode == 200) {
      for (int i = 0; i < data.length; i++) {
        produkObatRacik.add(ObatRacikData.fromJson(data[i]));
      }
      // print("Testtt");
      // print(produkObatRacik);
      return produkObatRacik;
    } else {
      throw Exception("Gagal Load Data Obat Racik");
    }
  }

  static Future<ObatRacikData> getDetailObatRacik(String idDetail) async {
    String url = "http://leap.crossnet.co.id:2688/product/racik/${idDetail}";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

    if (response.statusCode == 200) {
      var jsonObject = jsonDecode(response.body);
      var data = jsonObject['data'];
      // print('data: $data');
      ObatRacikData isiDetail = ObatRacikData.fromJson(data);
      return isiDetail;
    } else {
      throw Exception("Gagal Load Data Detail Obat Racik");
    }
  }
}

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
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
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