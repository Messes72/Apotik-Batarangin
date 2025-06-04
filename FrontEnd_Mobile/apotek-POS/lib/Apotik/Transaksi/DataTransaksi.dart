import 'dart:convert';

import 'package:apotek/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KustomerResponse {
  final int status;
  final String message;
  final List<Kustomer> data;
  final Metadata metadata;

  KustomerResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.metadata,
  });

  factory KustomerResponse.fromJson(Map<String, dynamic> json) {
    return KustomerResponse(
      status: json['status'],
      message: json['message'],
      data: List<Kustomer>.from(json['data'].map((x) => Kustomer.fromJson(x))),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'metadata': metadata.toJson(),
    };
  }
}

class Kustomer {
  final int id;
  final String idKustomer;
  final String nama;
  final String alamat;
  final String noTelp;
  final String createdAt;
  final String updatedAt;
  final String catatan;

  Kustomer({
    required this.id,
    required this.idKustomer,
    required this.nama,
    required this.alamat,
    required this.noTelp,
    required this.createdAt,
    required this.updatedAt,
    required this.catatan,
  });

  factory Kustomer.fromJson(Map<String, dynamic> json) {
    return Kustomer(
      id: json['id'],
      idKustomer: json['id_kustomer'],
      nama: json['nama'],
      alamat: json['alamat'],
      noTelp: json['no_telp'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_kustomer': idKustomer,
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'catatan': catatan,
    };
  }

  static Future<List<Kustomer>> getData() async {
    String url = "http://leap.crossnet.co.id:2688/kustomer?page=1&page_size=20";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    List<Kustomer> namaKustomer = [];

    if (response.statusCode == 200) {
      for (int i = 0; i < data.length; i++) {
        namaKustomer.add(Kustomer.fromJson(data[i]));
      }
      print(namaKustomer);
      return namaKustomer;
    } else {
      throw Exception("Gagal Load Data");
    }
  }
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

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'page_size': pageSize,
      'total_pages': totalPages,
      'total_records': totalRecords,
    };
  }
}

class TransaksiRequest {
  final String idKustomer;
  final Pembayaran pembayaran;
  final List<Item> items;

  TransaksiRequest({
    required this.idKustomer,
    required this.pembayaran,
    required this.items,
  });

  factory TransaksiRequest.fromJson(Map<String, dynamic> json) {
    return TransaksiRequest(
      idKustomer: json['id_kustomer'],
      pembayaran: Pembayaran.fromJson(json['pembayaran']),
      items: List<Item>.from(json['items'].map((x) => Item.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kustomer': idKustomer,
      'pembayaran': pembayaran.toJson(),
      'items': items.map((x) => x.toJson()).toList(),
    };
  }
}

class Pembayaran {
  final String metodeBayar;

  Pembayaran({required this.metodeBayar});

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      metodeBayar: json['metode_bayar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metode_bayar': metodeBayar,
    };
  }
}

class Item {
  final String idObat;
  final int kuantitas;
  final String namaObat;
  final String aturanPakai;
  final String caraPakai;
  final double hargaObat;
  final String keteranganPakai;
  final int jumlahObatReal;

  Item(
      {required this.idObat,
      required this.kuantitas,
      required this.aturanPakai,
      required this.caraPakai,
      required this.namaObat,
      required this.hargaObat,
      required this.keteranganPakai,
      required this.jumlahObatReal});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        idObat: json['id_obat'],
        kuantitas: json['kuantitas'],
        aturanPakai: json['aturan_pakai'],
        caraPakai: json['cara_pakai'],
        namaObat: json['nama_obat'],
        keteranganPakai: json['keterangan_pakai'],
        jumlahObatReal: json['jumlah_obat'],
        hargaObat: json['harga_obat']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id_obat': idObat,
      'kuantitas': kuantitas,
      'aturan_pakai': aturanPakai,
      'cara_pakai': caraPakai,
      'keterangan_pakai': keteranganPakai,
    };
  }
}

List<Item> keranjang = [];
List<ObatRacik> daftarObatRacik = [];

class ProdukSemua {
  final int id;
  final String idObat;
  final String idSatuan;
  final String idKategori;
  final String namaObat;
  final double hargaJual;
  final double hargaBeli;
  final int stokMinimum;
  final double uprate;
  int? stokObatReal;
  final DateTime createdAt;
  final String createdBy;
  final String linkGambarObat;
  final String keterangan;
  final String namaSatuan;

  ProdukSemua({
    required this.id,
    required this.idObat,
    required this.idSatuan,
    required this.idKategori,
    required this.namaObat,
    required this.hargaJual,
    required this.hargaBeli,
    required this.stokMinimum,
    required this.uprate,
    required this.stokObatReal,
    required this.createdAt,
    required this.createdBy,
    required this.linkGambarObat,
    required this.keterangan,
    required this.namaSatuan,
  });

  factory ProdukSemua.fromJson(Map<String, dynamic> json) {
    return ProdukSemua(
      id: json['id'] ?? 0,
      idObat: json['id_obat'] ?? '',
      idSatuan: json['id_satuan'] ?? '',
      idKategori: json['id_kategori'] ?? '',
      namaObat: json['nama_obat'] ?? '',
      hargaJual: (json['harga_jual'] ?? 0).toDouble(),
      hargaBeli: (json['harga_beli'] ?? 0).toDouble(),
      stokMinimum: json['stok_minimun'] ?? 0,
      uprate: (json['uprate'] ?? 0).toDouble(),
      stokObatReal: json['stok_obatReal'] ?? 0,
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
      'uprate': uprate,
      "stok_obatReal": stokObatReal,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'link_gambar_obat': linkGambarObat,
      'keterangan': keterangan,
      'nama_satuan': namaSatuan,
    };
  }

  static List<ProdukSemua> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProdukSemua.fromJson(json)).toList();
  }

 static Future<int> getDataStok(String idDetail) async {
  String url = "http://leap.crossnet.co.id:2688/PoS/stok/${idDetail}";
  var response = await http.get(Uri.parse(url),
      headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

  if (response.statusCode == 200) {
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    int stokObatReal = data['stok_barang'] ?? 0;
    return stokObatReal;
  } else {
    print("Status: ${response.statusCode}");
    print("Response Body: ${response.body}");
    // Tidak ditemukan atau error lain → anggap stok = 0
    return 0;
  }
}


  static Future<List<ProdukSemua>> getData() async {
    String url =
        "http://leap.crossnet.co.id:2688/product/info?page=1&page_size=20";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    List<ProdukSemua> produkObat = [];

    if (response.statusCode == 200) {
      for (int i = 0; i < data.length; i++) {
        produkObat.add(ProdukSemua.fromJson(data[i]));
      }
      print(produkObat);
      return produkObat;
    } else {
      throw Exception("Gagal Load Data");
    }
  }
}

class BahanModel {
  final String idDetailObatRacik;
  final String idObatRacik;
  final String idObat;
  final String namaObat;
  final String catatan;
  final DateTime createdAt;
  double? jumlahKuantitas;
  String? dosis;

  BahanModel({
    required this.idDetailObatRacik,
    required this.idObatRacik,
    required this.idObat,
    required this.namaObat,
    required this.catatan,
    required this.createdAt,
  });

  factory BahanModel.fromJson(Map<String, dynamic> json) {
    return BahanModel(
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

class ObatRacikModel {
  final String idObatRacik;
  final String namaRacik;
  final String catatan;
  final DateTime createdAt;
  final DateTime? updatedAt;
  String? aturanPakai;
  String? carapakai;
  String? keteranganPakai;
  final List<BahanModel> bahan;

  ObatRacikModel({
    required this.idObatRacik,
    required this.namaRacik,
    required this.catatan,
    required this.createdAt,
    this.updatedAt,
    required this.bahan,
  });

  factory ObatRacikModel.fromJson(Map<String, dynamic> json) {
    return ObatRacikModel(
      idObatRacik: json["id_obat_racik"],
      namaRacik: json["nama_racik"],
      catatan: json["catatan"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"])
          : null,
      bahan: json['bahan'] != null
          ? (json['bahan'] as List).map((e) => BahanModel.fromJson(e)).toList()
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

  static Future<List<ObatRacikModel>> getDataObatRacik() async {
    String url =
        "http://leap.crossnet.co.id:2688/product/racik?page=1&page_size=2";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    List<ObatRacikModel> produkObatRacik = [];

    if (response.statusCode == 200) {
      for (int i = 0; i < data.length; i++) {
        produkObatRacik.add(ObatRacikModel.fromJson(data[i]));
      }
      // print("Testtt");
      // print(produkObatRacik);
      return produkObatRacik;
    } else {
      throw Exception("Gagal Load Data Obat Racik");
    }
  }

  static Future<ObatRacikModel> getDetailObatRacik(String idDetail) async {
    String url = "http://leap.crossnet.co.id:2688/product/racik/${idDetail}";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

    if (response.statusCode == 200) {
      var jsonObject = jsonDecode(response.body);
      var data = jsonObject['data'];
      // print('data: $data');
      ObatRacikModel isiDetail = ObatRacikModel.fromJson(data);
      return isiDetail;
    } else {
      throw Exception("Gagal Load Data Detail Obat Racik");
    }
  }
}

// BUAT LIST YG DIBELI
class KomposisiObat {
  final String namaObat;
  final String idObat;
  final num jumlah;
  final String dosis;

  KomposisiObat({
    required this.idObat,
    required this.namaObat,
    required this.jumlah,
    required this.dosis,
  });

  Map<String, dynamic> toJson() => {
        'nama_obat': namaObat,
        'jumlah': jumlah,
        'dosis': dosis,
      };
}

class ObatRacik {
  final String namaRacik;
  final String satuan;
  final String idnamaRacik;
  final String idsatuan;
  String aturanPakai;
  String caraPakai;
  String keteranganPakai;
  num totalHarga;
  final String jumlah;
  List<KomposisiObat> komposisi;

  ObatRacik({
    required this.namaRacik,
    required this.satuan,
    required this.idnamaRacik,
    required this.idsatuan,
    required this.totalHarga,
    required this.jumlah,
    required this.komposisi,
    required this.aturanPakai,
    required this.caraPakai,
    required this.keteranganPakai,
  });

  Map<String, dynamic> toJson() => {
        'nama_racik': namaRacik,
        'satuan': satuan,
        'jumlah': jumlah,
        'komposisi': komposisi.map((e) => e.toJson()).toList(),
      };
}

class KomposisiInput {
  final String namaObat;
  final String idObat;
  final TextEditingController jumlahController;
  final TextEditingController dosisController;
  // final TextEditingController aturanPkaiaController;
  // final TextEditingController caraPakaiController;
  // final TextEditingController keteranganPakaiController;

  KomposisiInput(
      {required this.namaObat,
      required this.idObat,
      required this.jumlahController,
      // required this.aturanPkaiaController,
      // required this.caraPakaiController,
      // required this.keteranganPakaiController,
      required this.dosisController});
}
