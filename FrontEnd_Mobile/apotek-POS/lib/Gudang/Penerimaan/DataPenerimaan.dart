class DataPenerimaanBarang {
  String namaBarang;
  String kategoriBarang;
  String kode;
  String hargaJual;
  DateTime kadaluarsa;
  String stok;
  String hargaBeli;
  String satuan;
  String noBatch;
  String namaSupplier;
  String namaPenerimaBarang;
  DateTime tanggalPenerimaan;
  String catatan;

  DataPenerimaanBarang(
      {required this.namaBarang,
      required this.kategoriBarang,
      required this.kode,
      required this.hargaJual,
      required this.hargaBeli,
      required this.kadaluarsa,
      required this.stok,
      required this.satuan,
      required this.noBatch,
      required this.namaSupplier,
      required this.namaPenerimaBarang,
      required this.tanggalPenerimaan,
      required this.catatan});
}
