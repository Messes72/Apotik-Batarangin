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
