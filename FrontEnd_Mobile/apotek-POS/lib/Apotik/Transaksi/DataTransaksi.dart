import 'dart:convert';

import 'package:apotek/global.dart';
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
    String url =
        "http://leap.crossnet.co.id:2688/kustomer?page=1&page_size=20";
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

  Item({
    required this.idObat,
    required this.kuantitas,
    required this.aturanPakai,
    required this.caraPakai,
    required this.namaObat,
    required this.hargaObat,
    required this.keteranganPakai,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      idObat: json['id_obat'],
      kuantitas: json['kuantitas'],
      aturanPakai: json['aturan_pakai'],
      caraPakai: json['cara_pakai'],
      namaObat: json['nama_obat'],
      keteranganPakai: json['keterangan_pakai'],
      hargaObat: json['harga_obat']
    );
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

