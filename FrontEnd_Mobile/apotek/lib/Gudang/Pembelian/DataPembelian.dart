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

