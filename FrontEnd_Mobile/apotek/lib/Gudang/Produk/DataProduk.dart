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
