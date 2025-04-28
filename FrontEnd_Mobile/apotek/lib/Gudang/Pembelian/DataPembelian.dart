class DataPembelianBarang {
  String nama;
  String kategori;
  String kode;
  double harga;
  DateTime kadaluarsa;
  int stokBarang;
  double hargaBeli;
  String satuan;
  String noBatch;
  String namaSupplier;
  String namaPenerimaBarang;
  String catatan;

  DataPembelianBarang({
    required this.nama,
    required this.kategori,
    required this.kode,
    required this.harga,
    required this.kadaluarsa,
    required this.stokBarang,
    required this.hargaBeli,
    required this.satuan,
    required this.noBatch,
    required this.namaSupplier,
    required this.namaPenerimaBarang,
    required this.catatan,
  });

  // Convert object ke Map (untuk database atau API)
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kategori': kategori,
      'kode': kode,
      'harga': harga,
      'kadaluarsa': kadaluarsa.toIso8601String(),
      'stokBarang': stokBarang,
      'hargaBeli': hargaBeli,
      'satuan': satuan,
      'noBatch': noBatch,
      'namaSupplier': namaSupplier,
      'namaPenerimaBarang': namaPenerimaBarang,
      'catatan': catatan,
    };
  }

  // Convert Map ke object
  factory DataPembelianBarang.fromMap(Map<String, dynamic> map) {
    return DataPembelianBarang(
      nama: map['nama'],
      kategori: map['kategori'],
      kode: map['kode'],
      harga: map['harga'].toDouble(),
      kadaluarsa: DateTime.parse(map['kadaluarsa']),
      stokBarang: map['stokBarang'],
      hargaBeli: map['hargaBeli'].toDouble(),
      satuan: map['satuan'],
      noBatch: map['noBatch'],
      namaSupplier: map['namaSupplier'],
      namaPenerimaBarang: map['namaPenerimaBarang'],
      catatan: map['catatan'],
    );
  }
}


// hhhhhhhhhhhhhh
class PembelianPenerimaanObatResponse {
  final int status;
  final String message;
  final List<PembelianPenerimaanObat> data;
  final Metadata metadata;

  PembelianPenerimaanObatResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.metadata,
  });

  factory PembelianPenerimaanObatResponse.fromJson(Map<String, dynamic> json) {
    return PembelianPenerimaanObatResponse(
      status: json['status'],
      message: json['message'],
      data: List<PembelianPenerimaanObat>.from(
          json['data'].map((x) => PembelianPenerimaanObat.fromJson(x))),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }
}

class PembelianPenerimaanObat {
  final int id;
  final String idPembelianPenerimaanObat;
  final String idSupplier;
  final String tanggalPembelian;
  final String tanggalPembayaran;
  final String tanggalPenerimaan;
  final String pemesan;
  final String? penerima;
  final int totalHarga;
  final String keterangan;
  final DateTime createdAt;
  final String createdBy;
  final dynamic obatList; // Bisa diganti kalau struktur obat_list nanti ada

  PembelianPenerimaanObat({
    required this.id,
    required this.idPembelianPenerimaanObat,
    required this.idSupplier,
    required this.tanggalPembelian,
    required this.tanggalPembayaran,
    required this.tanggalPenerimaan,
    required this.pemesan,
    this.penerima,
    required this.totalHarga,
    required this.keterangan,
    required this.createdAt,
    required this.createdBy,
    this.obatList,
  });

  factory PembelianPenerimaanObat.fromJson(Map<String, dynamic> json) {
    return PembelianPenerimaanObat(
      id: json['id'],
      idPembelianPenerimaanObat: json['id_pembelian_penerimaan_obat'],
      idSupplier: json['id_supplier'],
      tanggalPembelian: json['tanggal_pembelian'],
      tanggalPembayaran: json['tanggal_pembayaran'],
      tanggalPenerimaan: json['tanggal_penerimaan'] ?? '',
      pemesan: json['pemesan'],
      penerima: json['penerima'], // Bisa null
      totalHarga: json['total_harga'],
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      obatList: json['obat_list'],
    );
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
}


