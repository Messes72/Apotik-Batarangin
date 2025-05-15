import 'dart:convert';

import 'package:apotek/global.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DataPembelian {
  final int status;
  final String message;
  final List<PembelianBarangObat> data;
  final Metadata metadata;

  DataPembelian({
    required this.status,
    required this.message,
    required this.data,
    required this.metadata,
  });

  factory DataPembelian.fromJson(Map<String, dynamic> json) {
    return DataPembelian(
      status: json['status'],
      message: json['message'],
      data: List<PembelianBarangObat>.from(
        json['data'].map((item) => PembelianBarangObat.fromJson(item)),
      ),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}

class PembelianBarangObat {
  final int id;
  final String idPembelianBarangObat;
  final String idSupplier;
  final DateTime tanggalPembelian;
  final DateTime tanggalPembayaran;
  final DateTime? tanggalPenerimaan;
  final String pemesan;
  final String? penerima;
  final int totalHarga;
  final String keterangan;
  final DateTime createdAt;
  final String createdBy;
  final dynamic obatList;
  String? namaSupplier;
  // ubah tipe jika struktur obat_list tersedia

  PembelianBarangObat(
      {required this.id,
      required this.idPembelianBarangObat,
      required this.idSupplier,
      required this.tanggalPembelian,
      required this.tanggalPembayaran,
      required this.tanggalPenerimaan,
      required this.pemesan,
      required this.penerima,
      required this.totalHarga,
      required this.keterangan,
      required this.createdAt,
      required this.createdBy,
      required this.obatList,
      this.namaSupplier});

  factory PembelianBarangObat.fromJson(Map<String, dynamic> json) {
    return PembelianBarangObat(
      id: json['id'],
      idPembelianBarangObat: json['id_pembelian_penerimaan_obat'],
      idSupplier: json['id_supplier'],
      tanggalPembelian: DateTime.parse(json['tanggal_pembelian']),
      tanggalPembayaran: DateTime.parse(json['tanggal_pembayaran']),
      tanggalPenerimaan: (json['tanggal_penerimaan'] != null &&
              (json['tanggal_penerimaan']).toString().isNotEmpty)
          ? DateTime.tryParse(json['tanggal_penerimaan'])
          : null,
      pemesan: json['pemesan'],
      penerima: json['penerima'],
      totalHarga: json['total_harga'],
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      obatList: json['obat_list'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pembelian_penerimaan_obat': idPembelianBarangObat,
      'id_supplier': idSupplier,
      'tanggal_pembelian': tanggalPembelian,
      'tanggal_pembayaran': tanggalPembayaran,
      'tanggal_penerimaan': tanggalPenerimaan,
      'pemesan': pemesan,
      'penerima': penerima,
      'total_harga': totalHarga,
      'keterangan': keterangan,
      'created_at': createdAt,
      'created_by': createdBy,
      'obat_list': obatList,
    };
  }

  static List<PembelianBarangObat> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PembelianBarangObat.fromJson(json)).toList();
  }

  static Future<List<PembelianBarangObat>> getData() async {
    String url = "http://leap.crossnet.co.id:2688/pembelianbarang";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
    var jsonObject = jsonDecode(response.body);
    var data = jsonObject['data'];
    List<PembelianBarangObat> pembelianBarang = [];

    if (response.statusCode == 200) {
      for (int i = 0; i < data.length; i++) {
        pembelianBarang.add(PembelianBarangObat.fromJson(data[i]));
      }
      // print("ini datanya pembeliam");
      return pembelianBarang;
    } else {
      throw Exception("Gagal Load Data Pembelian");
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

// ini untuk get detailnya
class PembelianBarangDetailResponse {
  final int status;
  final String message;
  final DetailPembelianBarang data;
  final Metadata metadata;

  PembelianBarangDetailResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.metadata,
  });

  factory PembelianBarangDetailResponse.fromJson(Map<String, dynamic> json) {
    return PembelianBarangDetailResponse(
      status: json['status'],
      message: json['message'],
      data: DetailPembelianBarang.fromJson(json['data']),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }
}

class DetailPembelianBarang {
  final int id;
  final String idDetailPembelianBarang;
  final String idSupplier;
  final String namaSupplier;
  final DateTime tanggalPembelian;
  final DateTime tanggalPembayaran;
  final DateTime? tanggalPenerimaan;
  final String pemesan;
  final String? penerima;
  final int totalHarga;
  final String keterangan;
  final DateTime createdAt;
  final String createdBy;
  final List<Obat> obatList;

  DetailPembelianBarang({
    required this.id,
    required this.idDetailPembelianBarang,
    required this.idSupplier,
    required this.namaSupplier,
    required this.tanggalPembelian,
    required this.tanggalPembayaran,
    required this.tanggalPenerimaan,
    required this.pemesan,
    required this.penerima,
    required this.totalHarga,
    required this.keterangan,
    required this.createdAt,
    required this.createdBy,
    required this.obatList,
  });

  factory DetailPembelianBarang.fromJson(Map<String, dynamic> json) {
    return DetailPembelianBarang(
      id: json['id'],
      idDetailPembelianBarang: json['id_pembelian_penerimaan_obat'],
      idSupplier: json['id_supplier'],
      namaSupplier: json['nama_supplier'],
      tanggalPembelian: DateTime.parse(json['tanggal_pembelian']),
      tanggalPembayaran: DateTime.parse(json['tanggal_pembayaran']),
      tanggalPenerimaan: json['tanggal_penerimaan'] != null &&
              json['tanggal_penerimaan'].isNotEmpty
          ? DateTime.parse(json['tanggal_penerimaan'])
          : null,
      pemesan: json['pemesan'],
      penerima: json['penerima'],
      totalHarga: json['total_harga'],
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      obatList:
          (json['obat_list'] as List).map((e) => Obat.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pembelian_penerimaan_obat': idDetailPembelianBarang,
      'id_supplier': idSupplier,
      'nama_supplier': namaSupplier,
      'tanggal_pembelian': tanggalPembelian.toIso8601String(),
      'tanggal_pembayaran': tanggalPembayaran.toIso8601String(),
      'tanggal_penerimaan': tanggalPenerimaan?.toIso8601String(),
      'pemesan': pemesan,
      'penerima': penerima,
      'total_harga': totalHarga,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'obat_list': obatList.map((e) => e.toJson()).toList(),
    };
  }

  static Future<String> getDataNamaDetail(String idDetail) async {
    String url = "http://leap.crossnet.co.id:2688/pembelianbarang/${idDetail}";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});
    if (response.statusCode == 200) {
      var jsonObject = jsonDecode(response.body);
      var data = jsonObject['data'];
      String namaSupplier = data['nama_supplier'] ?? 'Tidak diketahui';
      return namaSupplier;
    } else {
      throw Exception("Gagal Load Data Detail Pembelian Barang");
    }
  }

  static Future<DetailPembelianBarang> getDataDetail(String idDetails) async {
    String url = "http://leap.crossnet.co.id:2688/pembelianbarang/${idDetails}";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

    if (response.statusCode == 200) {
      var jsonObject = jsonDecode(response.body);
      var data = jsonObject['data'];
      // print('data: $data');
      DetailPembelianBarang isiDetail = DetailPembelianBarang.fromJson(data);
      // print("SSSSSSSSSSSSSSSSSS");
      // print(isiDetail.keterangan);
      return isiDetail;
    } else {
      throw Exception("Gagal Load Data Detail Pembelian");
    }
    
  }
  
}

class Obat {
  String? idPembelianPenerimaanObat;
  String idDetailPembelianPenerimaanObat;
  String idBatchPenerimaan;
  String idnomorBatch;
  String nomorBatch;
  String idKartustok;
  String idDepo;
  String idStatus;
  String namaObat;
  int jumlahDipesan;
  int jumlahDiterima;
  DateTime? kadaluarsa;
  DateTime? tanggalPembelian;
  DateTime? tanggalPembayaran;
  DateTime? tanggalPenerimaan;
  DateTime? createdAt;
  DateTime? updatedAt;
  String createdBy;
  String? updatedBy;

  Obat({
    this.idPembelianPenerimaanObat,
    required this.idDetailPembelianPenerimaanObat,
    required this.idBatchPenerimaan,
    required this.idnomorBatch,
    required this.nomorBatch,
    required this.idKartustok,
    required this.idDepo,
    required this.idStatus,
    required this.namaObat,
    required this.jumlahDipesan,
    required this.jumlahDiterima,
    required this.kadaluarsa,
    this.tanggalPembelian,
    this.tanggalPembayaran,
    this.tanggalPenerimaan,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      idPembelianPenerimaanObat: json['id_pembelian_penerimaan_obat'] ?? '',
      idDetailPembelianPenerimaanObat:
          json['id_detail_pembelian_penerimaan_obat'] ?? 'N/A',
      idBatchPenerimaan: json['id_batch_penerimaan'] ?? 'N/A',
      idnomorBatch: json['id_nomor_batch'] ?? 'N/A',
      nomorBatch: json['nomor_batch'] ?? 'N/A',
      idKartustok: json['id_kartustok'] ?? 'N/A',
      idDepo: json['id_depo'] ?? 'N/A',
      idStatus: json['id_status'] ?? '0',
      namaObat: json['nama_obat'] ?? 'Unknown',
      jumlahDipesan: json['jumlah_dipesan'] ?? 0,
      jumlahDiterima: json['jumlah_diterima'] ?? 0,
      kadaluarsa: json['kadaluarsa'] != null && json['kadaluarsa'].isNotEmpty
          ? DateTime.parse(json['kadaluarsa'])
          : null,
      tanggalPembelian: json['tanggal_pembelian'] != null &&
              json['tanggal_pembelian'].isNotEmpty
          ? DateTime.parse(json['tanggal_pembelian'])
          : null,
      tanggalPembayaran: json['tanggal_pembayaran'] != null &&
              json['tanggal_pembayaran'].isNotEmpty
          ? DateTime.parse(json['tanggal_pembayaran'])
          : null,
      tanggalPenerimaan: json['tanggal_penerimaan'] != null &&
              json['tanggal_penerimaan'].isNotEmpty
          ? DateTime.parse(json['tanggal_penerimaan'])
          : null,
      createdAt: json['created_at'] != null && json['created_at'].isNotEmpty
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null && json['updated_at'].isNotEmpty
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['created_by'] ?? 'Unknown',
      updatedBy: json['updated_by'], // Can be null
    );
  }

  // To JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id_pembelian_penerimaan_obat': idPembelianPenerimaanObat ?? '',
      'id_detail_pembelian_penerimaan_obat': idDetailPembelianPenerimaanObat,
      'id_batch_penerimaan': idBatchPenerimaan,
      'id_nomor_batch':idnomorBatch,
      'nomor_batch': nomorBatch,
      'id_kartustok': idKartustok,
      'id_depo': idDepo,
      'id_status': idStatus,
      'nama_obat': namaObat,
      'jumlah_dipesan': jumlahDipesan,
      'jumlah_diterima': jumlahDiterima,
      'kadaluarsa': kadaluarsa?.toIso8601String(),
      'tanggal_pembelian':
          tanggalPembelian?.toIso8601String(), // Will be null if not provided
      'tanggal_pembayaran': tanggalPembayaran?.toIso8601String(),
      'tanggal_penerimaan': tanggalPenerimaan?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}

// Karyawan datanya mau di get
class KaryawanResponse {
  final List<Karyawan> data;
  final Metadata metadata;

  KaryawanResponse({required this.data, required this.metadata});

  factory KaryawanResponse.fromJson(Map<String, dynamic> json) {
    return KaryawanResponse(
      data: List<Karyawan>.from(json['data'].map((x) => Karyawan.fromJson(x))),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}

class Karyawan {
  final int id;
  final String idKaryawan;
  final String nama;
  final String alamat;
  final String noTelp;
  final String createdAt;
  final String updatedAt;
  final String catatan;
  final List<Role> roles;
  final List<Privilege> privileges;
  final List<Depo> depo;

  Karyawan({
    required this.id,
    required this.idKaryawan,
    required this.nama,
    required this.alamat,
    required this.noTelp,
    required this.createdAt,
    required this.updatedAt,
    required this.catatan,
    required this.roles,
    required this.privileges,
    required this.depo,
  });

  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      id: json['id'],
      idKaryawan: json['id_karyawan'],
      nama: json['nama'],
      alamat: json['alamat'],
      noTelp: json['no_telp'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      catatan: json['catatan'],
      roles: List<Role>.from(json['roles'].map((x) => Role.fromJson(x))),
      privileges: List<Privilege>.from(
          json['privileges'].map((x) => Privilege.fromJson(x))),
      depo: List<Depo>.from(json['depo'].map((x) => Depo.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_karyawan': idKaryawan,
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'catatan': catatan,
      'roles': roles.map((x) => x.toJson()).toList(),
      'privileges': privileges.map((x) => x.toJson()).toList(),
      'depo': depo.map((x) => x.toJson()).toList(),
    };
  }

 
  Future<List<Karyawan>> fetchKaryawan() async {
  String url = "http://leap.crossnet.co.id:2688/karyawan";
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': '$token', 'x-api-key': '$xApiKey'});

  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    final List<dynamic> dataList = jsonData["data"];

    return dataList.map((item) => Karyawan.fromJson(item)).toList();
  } else {
    throw Exception('Gagal memuat data karyawan');
  }
}
}

class Role {
  final int id;
  final String idRole;
  final String namaRole;
  final String createdAt;
  final String updatedAt;

  Role({
    required this.id,
    required this.idRole,
    required this.namaRole,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      idRole: json['id_role'],
      namaRole: json['nama_role'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_role': idRole,
      'nama_role': namaRole,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Privilege {
  final int id;
  final String idPrivilege;
  final String namaPrivilege;
  final String createdAt;
  final String updatedAt;

  Privilege({
    required this.id,
    required this.idPrivilege,
    required this.namaPrivilege,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Privilege.fromJson(Map<String, dynamic> json) {
    return Privilege(
      id: json['id'],
      idPrivilege: json['id_privilege'],
      namaPrivilege: json['nama_privilege'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_privilege': idPrivilege,
      'nama_privilege': namaPrivilege,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Depo {
  final int id;
  final String idDepo;
  final String nama;
  final String alamat;
  final String noTelp;
  final String catatan;

  Depo({
    required this.id,
    required this.idDepo,
    required this.nama,
    required this.alamat,
    required this.noTelp,
    required this.catatan,
  });

  factory Depo.fromJson(Map<String, dynamic> json) {
    return Depo(
      id: json['id'],
      idDepo: json['id_depo'],
      nama: json['nama'],
      alamat: json['alamat'],
      noTelp: json['no_telp'],
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_depo': idDepo,
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'catatan': catatan,
    };
  }
}
