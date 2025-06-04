import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:apotek/global.dart';

class StokOpnameData {
  String nama;
  String kategori;
  String kode;
  double harga;
  DateTime kadaluarsa;
  int stok;
  int masuk;
  int keluar;
  double hargaJual;
  double hargaBeli;
  String satuan;
  double uprate;
  String noKartu;
  String noBatch;
  String catatan;

  StokOpnameData({
    required this.nama,
    required this.kategori,
    required this.kode,
    required this.harga,
    required this.kadaluarsa,
    required this.stok,
    required this.masuk,
    required this.keluar,
    required this.hargaJual,
    required this.hargaBeli,
    required this.satuan,
    required this.uprate,
    required this.noKartu,
    required this.noBatch,
    required this.catatan,
  });

  factory StokOpnameData.fromJson(Map<String, dynamic> json) {
    return StokOpnameData(
      nama: json['nama'],
      kategori: json['kategori'],
      kode: json['kode'],
      harga: json['harga'].toDouble(),
      kadaluarsa: DateTime.parse(json['kadaluarsa']),
      stok: json['stok'],
      masuk: json['masuk'],
      keluar: json['keluar'],
      hargaJual: json['hargaJual'].toDouble(),
      hargaBeli: json['hargaBeli'].toDouble(),
      satuan: json['satuan'],
      uprate: json['uprate'].toDouble(),
      noKartu: json['noKartu'],
      noBatch: json['noBatch'],
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kategori': kategori,
      'kode': kode,
      'harga': harga,
      'kadaluarsa': kadaluarsa.toIso8601String(),
      'stok': stok,
      'masuk': masuk,
      'keluar': keluar,
      'hargaJual': hargaJual,
      'hargaBeli': hargaBeli,
      'satuan': satuan,
      'uprate': uprate,
      'noKartu': noKartu,
      'noBatch': noBatch,
      'catatan': catatan,
    };
  }
}

class StokOpnameModel {
  final String idStokOpname;
  final DateTime tanggalStokOpname;
  final int totalSelisih;
  final String catatan;
  final DateTime createdAt;
  final String createdBy;

  StokOpnameModel({
    required this.idStokOpname,
    required this.tanggalStokOpname,
    required this.totalSelisih,
    required this.catatan,
    required this.createdAt,
    required this.createdBy,
  });

  factory StokOpnameModel.fromJson(Map<String, dynamic> json) {
    return StokOpnameModel(
      idStokOpname: json['id_stokopname'],
      tanggalStokOpname: DateTime.parse(json['tanggal_stokopname']),
      totalSelisih: json['total_selisih'],
      catatan: json['catatan'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_stokopname': idStokOpname,
      'tanggal_stokopname': tanggalStokOpname.toIso8601String(),
      'total_selisih': totalSelisih,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  static Future<List<StokOpnameModel>> getData() async {
    String url =
        "http://leap.crossnet.co.id:2688/stokopname/all/20?page=1&pagesize=10";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    List<StokOpnameModel> ProdukStockOpname = [];

    if (response.statusCode == 200) {
      for (int i = 0; i < data.length; i++) {
        ProdukStockOpname.add(StokOpnameModel.fromJson(data[i]));
      }
      // print(ProdukStockOpname);
      return ProdukStockOpname;
    } else {
      throw Exception("Gagal Load Data");
    }
  }
}

class StokOpnameDetailResponse {
  final StokOpname? stokOpname;
  final List<StokOpnameItem> items;

  StokOpnameDetailResponse({
    required this.stokOpname,
    required this.items,
  });

  factory StokOpnameDetailResponse.fromJson(Map<String, dynamic> json) {
    return StokOpnameDetailResponse(
      stokOpname: json['stok_opname'] != null
          ? StokOpname.fromJson(json['stok_opname'])
          : null,
      items: (json['items'] as List)
          .map((item) => StokOpnameItem.fromJson(item))
          .toList(),
    );
  }
  static Future<StokOpnameDetailResponse> getDetailStockOpname(
      String idDetail) async {
    String url = "http://leap.crossnet.co.id:2688/stokopname/${idDetail}";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

    if (response.statusCode == 200) {
      var jsonObject = jsonDecode(response.body);
      var data = jsonObject['data'];
      // print('data: $data');
      StokOpnameDetailResponse isiDetail =
          StokOpnameDetailResponse.fromJson(data);
      return isiDetail;
    } else {
      throw Exception("Gagal Load Data Detail Obat Racik");
    }
  }
}

class StokOpname {
  final String idStokopname;
  final String idDepo;
  final String namaDepo;
  final DateTime tanggalStokopname;
  final int totalSelisih;
  final String catatan;
  final DateTime createdAt;
  final String createdBy;

  StokOpname({
    required this.idStokopname,
    required this.idDepo,
    required this.namaDepo,
    required this.tanggalStokopname,
    required this.totalSelisih,
    required this.catatan,
    required this.createdAt,
    required this.createdBy,
  });

  factory StokOpname.fromJson(Map<String, dynamic> json) {
    return StokOpname(
      idStokopname: json['id_stokopname'],
      idDepo: json['id_depo'],
      namaDepo: json['nama_depo'],
      tanggalStokopname: DateTime.parse(json['tanggal_stokopname']),
      totalSelisih: json['total_selisih'],
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
    );
  }
}

class StokOpnameItem {
  final String idKartustok;
  final String idObat;
  final String namaObat;
  final int kuantitasSistem;
  final int kuantitasFisik;
  final int selisih;
  final String catatan;
  final List<Batch>? batches;

  StokOpnameItem({
    required this.idKartustok,
    required this.idObat,
    required this.namaObat,
    required this.kuantitasSistem,
    required this.kuantitasFisik,
    required this.selisih,
    required this.catatan,
    this.batches,
  });

  factory StokOpnameItem.fromJson(Map<String, dynamic> json) {
    return StokOpnameItem(
      idKartustok: json['id_kartustok'],
      idObat: json['id_obat'],
      namaObat: json['nama_obat'],
      kuantitasSistem: json['kuantitas_sistem'],
      kuantitasFisik: json['kuantitas_fisik'],
      selisih: json['selisih'],
      catatan: json['catatan'] ?? '',
      batches: json['batches'] != null
          ? (json['batches'] as List)
              .map((batch) => Batch.fromJson(batch))
              .toList()
          : null,
    );
  }
}

class Batch {
  final String idNomorBatch;
  final String noBatch;
  final int kuantitasSistem;
  final int kuantitasFisik;
  final int selisih;
  final String catatan;

  Batch({
    required this.idNomorBatch,
    required this.noBatch,
    required this.kuantitasSistem,
    required this.kuantitasFisik,
    required this.selisih,
    required this.catatan,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      idNomorBatch: json['id_nomor_batch'],
      noBatch: json['no_batch'],
      kuantitasSistem: json['kuantitas_sistem'],
      kuantitasFisik: json['kuantitas_fisik'],
      selisih: json['selisih'],
      catatan: json['catatan'] ?? '',
    );
  }
}

// yang baru
class BatchDetail {
  final String idNomorBatch;
  final String noBatch;
  final int kuantitasSistem;
  final int kuantitasFisik;
  final int selisih;
  final String catatan;

  BatchDetail({
    required this.idNomorBatch,
    required this.noBatch,
    required this.kuantitasSistem,
    required this.kuantitasFisik,
    required this.selisih,
    required this.catatan,
  });

  factory BatchDetail.fromJson(Map<String, dynamic> json) => BatchDetail(
        idNomorBatch: json['id_nomor_batch'],
        noBatch: json['no_batch'],
        kuantitasSistem: json['kuantitas_sistem'],
        kuantitasFisik: json['kuantitas_fisik'],
        selisih: json['selisih'],
        catatan: json['catatan'],
      );
}

class StokOpnameObatItem {
  final String idKartuStok;
  final String idObat;
  final String namaObat;
  final int kuantitasSistem;
  final int kuantitasFisik;
  final int selisih;
  final String catatan;
  final List<BatchDetail> detailBatch;

  StokOpnameObatItem({
    required this.idKartuStok,
    required this.idObat,
    required this.namaObat,
    required this.kuantitasSistem,
    required this.kuantitasFisik,
    required this.selisih,
    required this.catatan,
    required this.detailBatch,
  });

  factory StokOpnameObatItem.fromJson(Map<String, dynamic> json) =>
      StokOpnameObatItem(
        idKartuStok: json['id_kartustok'],
        idObat: json['id_obat'],
        namaObat: json['nama_obat'],
        kuantitasSistem: json['kuantitas_sistem'],
        kuantitasFisik: json['kuantitas_fisik'],
        selisih: json['selisih'],
        catatan: json['catatan'],
        detailBatch: json['batches'] == null
            ? []
            : List<BatchDetail>.from(
                json['batches'].map((x) => BatchDetail.fromJson(x))),
      );
}

class StokOpnameResponseDetail {
  final List<StokOpnameObatItem> items;

  StokOpnameResponseDetail({required this.items});

  factory StokOpnameResponseDetail.fromJson(Map<String, dynamic> json) =>
      StokOpnameResponseDetail(
        items: List<StokOpnameObatItem>.from(
            json['data']['items'].map((x) => StokOpnameObatItem.fromJson(x))),
      );

  static Future<StokOpnameResponseDetail> getDetailStockOpname(
      String id) async {
    final response = await http.get(
        Uri.parse("http://leap.crossnet.co.id:2688/stokopname/$id"),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

    if (response.statusCode == 200) {
      return StokOpnameResponseDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal load data");
    }
  }
}

class BatchSystem {
  final String idNomorBatchSystem;
  final int kuantitasSistem;
  final String nomorBatch;
  String obatFisik;
  String keterangan;

  BatchSystem(
      {required this.idNomorBatchSystem,
      required this.kuantitasSistem,
      required this.nomorBatch,
      required this.obatFisik,
      required this.keterangan});

  factory BatchSystem.fromJson(Map<String, dynamic> json) {
    return BatchSystem(
        idNomorBatchSystem: json['id_nomor_batch'] ?? '',
        kuantitasSistem: json['kuantitas_sistem'] ?? 0,
        nomorBatch: json['nomor_batch'] ?? "",
        obatFisik: json['kuantitas_sistem'] ?? 0,
        keterangan: json['kuantitas_sistem'] ?? 0);
  }
}

class ObatStok {
  final String idKartuStok;
  final String namaObat;
  final int kuantitasSistem;
  final List<BatchSystem> batches;

  ObatStok({
    required this.idKartuStok,
    required this.namaObat,
    required this.kuantitasSistem,
    required this.batches,
  });

  factory ObatStok.fromJson(Map<String, dynamic> json) {
    return ObatStok(
      idKartuStok: json['id_kartustok'] ?? '',
      namaObat: json['nama_obat'] ?? '',
      kuantitasSistem: json['kuantitas_sistem'] ?? 0,
      batches: json['batches'] != null
          ? List<BatchSystem>.from(
              json['batches'].map((x) => BatchSystem.fromJson(x)))
          : [],
    );
  }
  static Future<List<ObatStok>> fetchObatList() async {
    final response = await http.get(
      Uri.parse('http://leap.crossnet.co.id:2688/stokopname/stok/20'),
      headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> data = jsonData['data'];
      return data.map((e) => ObatStok.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data');
    }
  }
}

class SpesifikBatch {
  final String idNomorBatch;
  final String noBatch;
  final String kadaluarsa;
  final int sisa;

  SpesifikBatch({
    required this.idNomorBatch,
    required this.noBatch,
    required this.kadaluarsa,
    required this.sisa,
  });

  factory SpesifikBatch.fromJson(Map<String, dynamic> json) {
    return SpesifikBatch(
      idNomorBatch: json['id_nomor_batch'] ?? '',
      noBatch: json['no_batch'] ?? '',
      kadaluarsa: json['kadaluarsa'] ?? '',
      sisa: json['sisa'] ?? 0,
    );
  }
  static Future<List<SpesifikBatch>> getData(String id) async {
    String url =
        "http://leap.crossnet.co.id:2688/stokopname/batch?obat=$id&depo=20";
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'},
    );

    if (response.statusCode == 200) {
      final jsonObject = jsonDecode(response.body);
      final data = jsonObject['data'];

      // ✅ Cek jika data null atau bukan list
      if (data == null || data is! List) {
        return []; // ⬅️ Kembalikan list kosong
      }

      return data
          .map<SpesifikBatch>((item) => SpesifikBatch.fromJson(item))
          .toList();
    } else {
      throw Exception("Gagal Load Data");
    }
  }
}
class StockOpnameList {
  final String idKartustok;
  final String namaObat;
  final int kuantitasSistem;
  final List<StokBatchData> batches;

  StockOpnameList({
    required this.idKartustok,
    required this.namaObat,
    required this.kuantitasSistem,
    required this.batches,
  });

  factory StockOpnameList.fromJson(Map<String, dynamic> json) {
    return StockOpnameList(
      idKartustok: json['id_kartustok'],
      namaObat: json['nama_obat'],
      kuantitasSistem: json['kuantitas_sistem'],
      batches: List<StokBatchData>.from(
        json['batches'].map((b) => StokBatchData.fromJson(b)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_kartustok': idKartustok,
        'nama_obat': namaObat,
        'kuantitas_sistem': kuantitasSistem,
        'batches': batches.map((b) => b.toJson()).toList(),
      };

      static Future<List<StockOpnameList>> fetchObatList() async {
    final response = await http.get(
      Uri.parse('http://leap.crossnet.co.id:2688/stokopname/stok/20'),
      headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> data = jsonData['data'];
      return data.map((e) => StockOpnameList.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data');
    }
  }
}
class StokBatchData {
  final String idNomorBatch;
  final String nomorBatch;
  final int kuantitasSistem;
  TextEditingController keterangan;
  TextEditingController jumlah;
  // Tambahkan field hasil input
  String? inputKeterangan;
  String? inputJumlah;

  StokBatchData({
    required this.idNomorBatch,
    required this.nomorBatch,
    required this.kuantitasSistem,
    TextEditingController? keterangan,
    TextEditingController? jumlah,
  })  : keterangan = keterangan ?? TextEditingController(),
        jumlah = jumlah ?? TextEditingController();

  factory StokBatchData.fromJson(Map<String, dynamic> json) {
    return StokBatchData(
      idNomorBatch: json['id_nomor_batch'],
      nomorBatch: json['nomor_batch'],
      kuantitasSistem: json['kuantitas_sistem'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_nomor_batch': idNomorBatch,
        'nomor_batch': nomorBatch,
        'kuantitas_sistem': kuantitasSistem,
        // TextEditingController tidak bisa disimpan langsung ke JSON
        'keterangan': keterangan.text,
        'jumlah': jumlah.text,
      };
}

