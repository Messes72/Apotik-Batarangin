import 'package:apotek/Gudang/Produk/DataProduk.dart';
import 'package:apotek/Gudang/Stock/coba2.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:apotek/global.dart' as global;
import 'package:intl/intl.dart';

class produk extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const produk(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<produk> createState() => PageProduk();
}

class PageProduk extends State<produk> {
  bool triggerAnimation = false; // Tambahkan variabel isExpanded

  final List<int> rowItems = [10, 25, 50, 100];

  String? selectedValue;

  final _formKey = GlobalKey<FormState>();

  var text = TextEditingController();
  var text2 = TextEditingController();

  // var nomorKartu_text = TextEditingController();
  // var nomorBatch_text = TextEditingController();
  // var kodeObat_text = TextEditingController();
  // var kategori_text = TextEditingController();
  // var namaObat_text = TextEditingController();
  // var jumlahBarang_text = TextEditingController();
  // var caraPemakaian_text = TextEditingController();
  // var stokBarang_text = TextEditingController();
  // var satuan_text = TextEditingController();
  // var tanggalController = TextEditingController();

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  List<Produk> filterData = [];

  final List<Produk> _data = [
    Produk(
        nomorKartu: "C14220131",
        nomorBatch: "0833276",
        kategori: "Obat Panas",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "D1425",
        namaObat: "Paracetamol",
        caraPemakaian:
            "Dihancurkan hiingga lembur lalu diminumm 2 kali dalam sehari aaa sharon sharon sharon iwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiwnenkqjgegdbghqbdhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa haloooooooooooooooooooooooo   ooooooooooooooooooooo ooooooooooooooooooooooooooooo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        satuan: "strip"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "Obat Nyeri",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 10,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
  ];

  void _viewDetails(Produk item) {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width:
                    constraints.maxWidth * 0.6, // Sesuaikan dengan ukuran layar
                height: constraints.maxHeight *
                    0.7, // Batasi tinggi agar tidak terlalu besar
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        color: ColorStyle.alert_ungu,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      padding:
                          const EdgeInsets.only(top: 8, left: 23, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Informasi Obat",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 23),
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            RowForm("Nomor Kartu", item.nomorKartu,
                                "Nomor Batch", item.nomorBatch),
                            RowForm(
                                "Kode", item.kode, "Kategori", item.kategori),
                            RowForm(
                                "Nama Obat",
                                item.namaObat,
                                "Kadaluarsa",
                                DateFormat('dd/MM/yyyy')
                                    .format(item.kadaluarsa)),
                            RowForm("Satuan", item.satuan, "Jumlah Barang",
                                item.jumlah.toString()),
                            buildFormCaraPemakaian(
                                "Cara Pemakaian", item.caraPemakaian)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateProduk(
    Produk item,
    TextEditingController nomorKartu,
    TextEditingController nomorBatch,
    TextEditingController kode,
    TextEditingController kategori,
    TextEditingController namaObat,
    TextEditingController kadaluarsa,
    TextEditingController satuan,
    TextEditingController jumlah,
    TextEditingController caraPemakaian,
  ) {
    setState(() {
      // 🔹 Ini yang memastikan UI diperbarui
      item.nomorKartu = nomorKartu.text;
      item.nomorBatch = nomorBatch.text;
      item.kode = kode.text;
      item.kategori = kategori.text;
      item.namaObat = namaObat.text;
      item.kadaluarsa = DateFormat('dd/MM/yyyy').parse(kadaluarsa.text);
      item.satuan = satuan.text;
      item.jumlah = int.parse(jumlah.text);
      item.caraPemakaian = caraPemakaian.text;
    });

    // Navigator.pop(context); // 🔹 Menutup dialog setelah menyimpan
    _alertDone(item, "diedit"); // 🔹 Tampilkan alert bahwa produk telah diedit
  }

  void _editProduk(Produk item) {
    TextEditingController nomorKartuController =
        TextEditingController(text: item.nomorKartu);
    TextEditingController nomorBatchController =
        TextEditingController(text: item.nomorBatch);
    TextEditingController kodeController =
        TextEditingController(text: item.kode);
    TextEditingController kategoriController =
        TextEditingController(text: item.kategori);
    TextEditingController namaObatController =
        TextEditingController(text: item.namaObat);
    TextEditingController kadaluarsaController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(item.kadaluarsa));
    TextEditingController satuanController =
        TextEditingController(text: item.satuan);
    TextEditingController jumlahController =
        TextEditingController(text: item.jumlah.toString());
    TextEditingController caraPemakaianController =
        TextEditingController(text: item.caraPemakaian);
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width:
                    constraints.maxWidth * 0.6, // Sesuaikan dengan ukuran layar
                height: constraints.maxHeight *
                    0.7, // Batasi tinggi agar tidak terlalu besar
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border(
                              bottom: BorderSide(
                                  color: ColorStyle.button_grey, width: 1))),
                      padding:
                          const EdgeInsets.only(top: 8, left: 23, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Edit Produk",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorStyle.text_dalam_kolom,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 23),
                            child: IconButton(
                              icon: Icon(Icons.close,
                                  color: ColorStyle.text_dalam_kolom),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            RowEditForm(
                                "Nomor Kartu",
                                item.nomorKartu,
                                "Nomor Batch",
                                item.nomorBatch,
                                nomorKartuController,
                                nomorBatchController),
                            RowEditForm(
                                "Kode",
                                item.kode,
                                "Kategori",
                                item.kategori,
                                kodeController,
                                kategoriController),
                            RowEditForm(
                                "Nama Obat",
                                item.namaObat,
                                "Kadaluarsa",
                                DateFormat('dd/MM/yyyy')
                                    .format(item.kadaluarsa),
                                namaObatController,
                                kadaluarsaController),
                            RowEditForm(
                                "Satuan",
                                item.satuan,
                                "Jumlah Barang",
                                item.jumlah.toString(),
                                satuanController,
                                jumlahController),
                            buildFormCaraPemakaian2("Cara Pemakaian",
                                item.caraPemakaian, caraPemakaianController),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 23, right: 23),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // _alertDone(item, "diedit");
                                        setState(() {
                                          // 🔹 Ini yang memastikan UI diperbarui
                                          item.nomorKartu =
                                              nomorKartuController.text;
                                          item.nomorBatch =
                                              nomorBatchController.text;
                                          item.kode = kodeController.text;
                                          item.kategori =
                                              kategoriController.text;
                                          item.namaObat =
                                              namaObatController.text;
                                          item.kadaluarsa =
                                              DateFormat('dd/MM/yyyy').parse(
                                                  kadaluarsaController.text);
                                          item.satuan = satuanController.text;
                                          item.jumlah =
                                              int.parse(jumlahController.text);
                                          item.caraPemakaian =
                                              caraPemakaianController.text;
                                        });
                                        _alertDone(item, "diedit");
                                        // _updateProduk(
                                        //     item,
                                        //     nomorKartuController,
                                        //     nomorBatchController,
                                        //     kodeController,
                                        //     kategoriController,
                                        //     namaObatController,
                                        //     kadaluarsaController,
                                        //     satuanController,
                                        //     jumlahController,
                                        //     caraPemakaianController);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        backgroundColor:
                                            ColorStyle.button_green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("SAVE",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _modalKosongkanObat(Produk item) {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width:
                    constraints.maxWidth * 0.6, // Sesuaikan dengan ukuran layar
                height: constraints.maxHeight *
                    0.7, // Batasi tinggi agar tidak terlalu besar
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        color: ColorStyle.alert_ungu,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 8, left: 23, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Alasan Kosongkan Obat",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 23),
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 23, right: 23),
                              child: Text(
                                  "Alasan \"${item.namaObat}\" Kosongkan Obat",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 23, right: 23),
                              child: Container(
                                height: 225,
                                decoration: BoxDecoration(
                                  color: ColorStyle.fill_form,
                                  border:
                                      Border.all(color: ColorStyle.fill_stroke),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  controller: text2,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Alasan",
                                    hintStyle: TextStyle(
                                      color: ColorStyle.tulisan_form,
                                      fontSize: 14,
                                    ),
                                  ),
                                  maxLines: 10,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 23, right: 23),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _alertDelete(item);
                                        // Navigator.pop(
                                        //     context); // Tutup dialog sebelumnya jika masih terbuka
                                        // Future.delayed(Duration(milliseconds: 200),
                                        //     () {
                                        //   // Delay untuk menghindari error
                                        //   _alertDelete(item);
                                        // });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        backgroundColor:
                                            ColorStyle.button_green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("KONFIRMASI",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _alertDelete(Produk item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FractionallySizedBox(
                widthFactor: 0.5, // 50% dari lebar layar
                heightFactor: 0.55, // 50% dari tinggi layar
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Tidak bisa di-scroll
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/delete.png",
                        width: constraints.maxWidth *
                            0.08, // Ukuran gambar responsif
                        height: constraints.maxWidth * 0.08,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Apakah Anda yakin \n mengosongkan \"${item.namaObat}\" ini?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: constraints.maxWidth *
                              0.02, // Ukuran teks responsif
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth *
                                  0.15, // Ukuran button responsif
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _modalKosongkanObat(item);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorStyle.fill_stroke,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Tidak",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: constraints.maxWidth * 0.15,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _alertDone(item, "dikosongkan");
                                  text2.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorStyle.button_red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Iya, hapus",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _alertDone(Produk item, String isi) {
    showDialog(
      context: context,
      builder: (context) {
        // Tutup dialog otomatis setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FractionallySizedBox(
                widthFactor: 0.5, // 50% dari lebar layar
                heightFactor: 0.4, // 40% dari tinggi layar
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Supaya tidak bisa di-scroll
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/done.png",
                          width: constraints.maxWidth *
                              0.08, // Sesuaikan ukuran gambar
                          height: constraints.maxWidth * 0.08,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Data berhasil $isi !",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: constraints.maxWidth *
                                0.025, // Ukuran teks dinamis
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterData = List.from(_data);
  }

  void filtering(String query) {
    setState(() {
      if (query.isEmpty) {
        filterData = List.from(_data);
      } else {
        filterData = _data.where((item) {
          return item.kode.toLowerCase().contains(query.toLowerCase()) ||
              item.namaObat.toLowerCase().contains(query.toLowerCase()) ||
              item.kategori.toLowerCase().contains(query.toLowerCase()) ||
              item.jumlah
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
      _currentPage = 0; // Reset ke halaman pertama setelah filter
    });
  }

  int _rowsPerPage = 10; // Default jumlah baris per halaman
  int _currentPage = 0; // Halaman saat ini

  @override
  Widget build(BuildContext context) {
    int totalPages = (filterData.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex =
        (startIndex + _rowsPerPage).clamp(0, filterData.length); // Batas aman
    List<Produk> paginatedData = filterData.sublist(startIndex, endIndex);
    return Scaffold(
      appBar: NavbarTop(
          title: "PRODUK",
          onMenuPressed: widget.toggleSidebar,
          isExpanded: widget.isExpanded,
          animationTrigger: onMenuPressed,
          animation: triggerAnimation),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    global.selectedIndex = 3;
                    global.selectedScreen = 0;
                  });
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                icon: Transform.translate(
                  offset: Offset(5, 0), // Geser ikon lebih dekat ke teks
                  child: Icon(Icons.add, color: Colors.white, size: 22),
                ),
                label: const Text("Input Produk",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.button_green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorStyle.putih_background,
                    boxShadow: [
                      BoxShadow(
                        color: ColorStyle.shadow.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(0, 1), // x dan y
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  height: 32,
                                  width: 242,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorStyle.fill_stroke,
                                        width: 1),
                                    color: ColorStyle.fill_form,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 8)),
                                      Icon(
                                        Icons.search_outlined,
                                        color: ColorStyle.text_secondary,
                                        size: 24,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: text,
                                          onChanged: filtering,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: "Search",
                                            hintStyle: TextStyle(
                                              color: ColorStyle.tulisan_form,
                                              fontSize: 14,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 8))
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text("Rows per page:"),
                              Padding(padding: EdgeInsets.only(right: 8)),
                              // isi
                              Center(
                                child: SizedBox(
                                  width:
                                      65, // Sesuaikan lebar agar tidak terlalu besar
                                  height:
                                      25, // Tinggi dropdown agar sesuai dengan contoh gambar
                                  child: DropdownButtonFormField2<int>(
                                    isExpanded:
                                        false, // Jangan meluaskan dropdown ke full width
                                    value: _rowsPerPage,
                                    items: rowItems
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e.toString(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _rowsPerPage = value!;
                                      });
                                    },

                                    // **Atur Tampilan Input**
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      constraints:
                                          BoxConstraints(maxHeight: 30),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Border radius halus
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: ColorStyle
                                                .button_grey), // Saat aktif, border lebih gelap
                                      ),
                                    ),

                                    // **Atur Tampilan Dropdown**
                                    buttonStyleData: ButtonStyleData(
                                      height: 25, // Tinggi tombol dropdown
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              6), // Jarak dalam dropdown
                                    ),

                                    // **Atur Tampilan Dropdown yang Muncul**
                                    dropdownStyleData: DropdownStyleData(
                                      width:
                                          65, // Lebar dropdown harus sama dengan input
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.white,
                                      ),
                                    ),

                                    // **Atur Posisi Item Dropdown**
                                    menuItemStyleData: const MenuItemStyleData(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              8), // Padding antar item dropdown
                                    ),

                                    // **Ganti Icon Dropdown**
                                    iconStyleData: IconStyleData(
                                      icon: Icon(Icons.arrow_drop_down,
                                          size: 20, color: Colors.black),
                                      openMenuIcon: Icon(Icons.arrow_drop_up,
                                          size: 20, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(padding: EdgeInsets.only(right: 8)),

                              Text("Page $endIndex of ${filterData.length}"),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 0
                                        ? () {
                                            setState(() {
                                              _currentPage--;
                                            });
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed: _currentPage < totalPages - 1
                                        ? () {
                                            setState(() {
                                              _currentPage++;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection:
                                  Axis.horizontal, // Scroll kiri-kanan
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: constraints
                                        .maxWidth), // Buat tabel full width
                                child: SingleChildScrollView(
                                  scrollDirection:
                                      Axis.vertical, // Scroll atas-bawah
                                  child: DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.all(Colors.white),
                                    columnSpacing: 80, // Jarak antar kolom
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: 60,
                                    columns: const [
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Kode Obat',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Nama Obat',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Kategori',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Jumlah Barang',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Actions',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: paginatedData.map((item) {
                                      return DataRow(
                                        color: MaterialStateProperty.all(
                                            Colors.white),
                                        cells: [
                                          DataCell(Center(
                                            child: Text(
                                              item.kode,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    ColorStyle.text_secondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              item.namaObat,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color:
                                                    ColorStyle.text_secondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              item.kategori,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color:
                                                    ColorStyle.text_secondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              item.jumlah.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color:
                                                    ColorStyle.text_secondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                      Icons
                                                          .open_in_new_outlined,
                                                      size: 24,
                                                      color: ColorStyle
                                                          .text_secondary),
                                                  onPressed: () =>
                                                      _viewDetails(item),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.edit_outlined,
                                                      size: 24,
                                                      color: ColorStyle
                                                          .text_secondary),
                                                  onPressed: () =>
                                                      _editProduk(item),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.delete_outline,
                                                      size: 24,
                                                      color: ColorStyle
                                                          .text_secondary),
                                                  onPressed: () =>
                                                      _modalKosongkanObat(item),
                                                ),
                                              ],
                                            ),
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget RowForm(String label1, String hint1, String label2, String hint2) {
    return Padding(
      padding: const EdgeInsets.only(left: 23),
      child: Row(
        children: [
          Expanded(child: detailField(label1, hint1)),
          const SizedBox(width: 19),
          if (label2.isNotEmpty)
            Expanded(
                child: detailField(
              label2,
              hint2,
            )),
          Padding(padding: EdgeInsets.only(right: 24))
        ],
      ),
    );
  }

  Widget RowEditForm(String label1, String hint1, String label2, String hint2,
      TextEditingController edit, TextEditingController edit2) {
    return Padding(
      padding: const EdgeInsets.only(left: 23),
      child: Row(
        children: [
          Expanded(child: editFeld(label1, hint1, edit)),
          const SizedBox(width: 19),
          if (label2.isNotEmpty)
            Expanded(child: editFeld(label2, hint2, edit2)),
          Padding(padding: EdgeInsets.only(right: 24))
        ],
      ),
    );
  }

  Widget detailField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: ColorStyle.fill_stroke),
            color: ColorStyle.fill_form,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
          ),
        )
      ],
    );
  }

  Widget editFeld(String title, String value, TextEditingController edit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: ColorStyle.fill_stroke),
            color: ColorStyle.fill_form,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: edit,
            style: TextStyle(
              color: ColorStyle.tulisan_form,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              hintText: value,
              contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
              hintStyle: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFormCaraPemakaian(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 23, right: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: 150, // Batasi tinggi agar bisa di-scroll
            ),
            decoration: BoxDecoration(
              color: ColorStyle.fill_form,
              border: Border.all(color: ColorStyle.fill_stroke),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                value,
                style: TextStyle(fontSize: 12),
                softWrap: true,
                // biar turun kebawah
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormCaraPemakaian2(
      String label, String value, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 23, right: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: 150, // Batasi tinggi agar bisa di-scroll
            ),
            decoration: BoxDecoration(
              color: ColorStyle.fill_form,
              border: Border.all(color: ColorStyle.fill_stroke),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            alignment: Alignment.topLeft,
            child: TextField(
              controller: text,
              style: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Cara Pemakaian",
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 12,
                ),
              ),
              maxLines: 10,
              // biar turun kebawah
            ),
          ),
        ],
      ),
    );
  }
}
