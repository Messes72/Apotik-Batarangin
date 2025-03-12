import 'dart:io';
import 'dart:typed_data';

import 'package:apotek/Gudang/Produk/DataProduk.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:apotek/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart' as im;

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

  // Ini buat listnya kalau kaetgori dana jumlah stock di filter
  List<Map<String, dynamic>> kategoriObat = [
    {"name": "Obat Panas", "selected": false},
    {"name": "Obat Flu", "selected": false},
    {"name": "Obat Batuk", "selected": false},
    {"name": "Suplemen", "selected": false},
  ];

  List<Map<String, dynamic>> jumlahStock = [
    {"name": "> 5", "selected": false},
    {"name": "> 10", "selected": false},
    {"name": "< 5", "selected": false},
    {"name": "< 10", "selected": false},
  ];

  String? selectedSatuan;
  final TextEditingController minHargaController = TextEditingController();
  final TextEditingController maxHargaController = TextEditingController();

  final List<int> rowItems = [10, 25, 50, 100];
  String? _selectedStatus;
  final List<String> rowStatus = ["Habis", "Sisa"];

  String? selectedValue;
  bool isAscending = true; // Menyimpan status sorting

  final _formKey = GlobalKey<FormState>();

  var text = TextEditingController();
  var text2 = TextEditingController();

  // Image picker
  im.ImagePicker picker = im.ImagePicker();
  File? pickedImage;
  bool uploadFile = false;
  Uint8List pickedImageByte = Uint8List(0);

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
        jumlah: 89,
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
        namaObat: "Panadol",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 0,
        kode: "kode",
        namaObat: "A obat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 50,
        kode: "kode",
        namaObat: " Bobat B",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 100,
        kode: "kode",
        namaObat: "namaObat",
        caraPemakaian: "caraPemakaian",
        satuan: "satuan"),
    Produk(
        nomorKartu: "nomorKartu",
        nomorBatch: "nomorBatch",
        kategori: "kategori",
        kadaluarsa: DateTime(2030, 2, 12),
        jumlah: 9,
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
  DateFormat dateformat = DateFormat("dd/MM/yyyy");
  DateTime selectedDate = DateTime.now();
  var tanggalController = TextEditingController();

  void _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2100));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        tanggalController.text = DateFormat("dd/MM/yyyy").format(selectedDate);
      });
    }
  }

  void filterByStatus(String status) {
    setState(() {
      if (status == "Habis") {
        filterData = _data.where((item) => item.jumlah == 0).toList();
      } else if (status == "Sisa") {
        filterData = _data
            .where((item) => item.jumlah > 0 && item.jumlah <= 10)
            .toList();
      } else {
        filterData = List.from(_data); // Tampilkan semua jika tidak ada filter
      }
    });
  }

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
                    0.9, // Batasi tinggi agar tidak terlalu besar
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
                    // SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Column(
                              children: [
                                detailField("Nomor Kartu", item.nomorKartu),
                                detailField("Nomor Batch", item.nomorBatch),
                                detailField("Kode", item.kode),
                                detailField("Kategori", item.kategori),
                                detailField("Nama Obat", item.namaObat),
                                detailField(
                                    "Kadaluarsa",
                                    DateFormat('dd/MM/yyyy')
                                        .format(item.kadaluarsa)),
                                detailField("Satuan", item.satuan),
                                detailField(
                                    "Jumlah Barang", item.jumlah.toString()),
                                inputImage(),
                                buildFormCaraPemakaian(
                                    "Cara Pemakaian", item.caraPemakaian)
                              ],
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
    _alertDone("diedit"); // 🔹 Tampilkan alert bahwa produk telah diedit
  }

  var nomorKartu_text = TextEditingController();
  var nomorBatch_text = TextEditingController();
  var kodeObat_text = TextEditingController();
  var kategori_text = TextEditingController();
  var namaObat_text = TextEditingController();
  var jumlahBarang_text = TextEditingController();
  var caraPemakaian_text = TextEditingController();
  var stokBarang_text = TextEditingController();
  var satuan_text = TextEditingController();
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
                    0.9, // Batasi tinggi agar tidak terlalu besar
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
                            "Edit Data Obat",
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
                    // SizedBox(height: 16),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Column(
                              children: [
                                editFeld("Nomor Kartu", item.nomorKartu,
                                    nomorKartuController),
                                editFeld("Nomor Batch", item.nomorBatch,
                                    nomorBatchController),
                                editFeld("Kode", item.kode, kodeController),
                                editFeld("Kategori", item.kategori,
                                    kategoriController),
                                editFeld("Nama Obat", item.namaObat,
                                    namaObatController),
                                tanggalEdit("Kadaluarsa", DateFormat('dd/MM/yyyy')
                                        .format(item.kadaluarsa), kadaluarsaController),
                                editFeld(
                                    "Satuan", item.satuan, satuanController),
                                editFeld("Jumlah Barang",
                                    item.jumlah.toString(), jumlahController),
                                inputImage(),
                                buildFormCaraPemakaian2(
                                    "Cara Pemakaian",
                                    item.caraPemakaian,
                                    caraPemakaianController),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
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
                                        _alertDone("diedit");
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

  void _inputProdukBaru() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState2) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: constraints.maxWidth *
                        0.6, // Sesuaikan dengan ukuran layar
                    height: constraints.maxHeight *
                        0.9, // Batasi tinggi agar tidak terlalu besar
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
                                      color: ColorStyle.button_grey,
                                      width: 1))),
                          padding: const EdgeInsets.only(
                              top: 8, left: 23, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Input Data Obat",
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
                        // SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                Column(
                                  children: [
                                    inputField("Nomor Kartu", "Nomor Kartu",
                                        nomorKartu_text),
                                    inputField("Nomor Batch", "Nomor Batch",
                                        nomorBatch_text),
                                    inputField("Kode", "Kode", kodeObat_text),
                                    inputField(
                                        "Kategori", "Kategori", kategori_text),
                                    inputField("Nama Obat", "Nama Obat",
                                        namaObat_text),
                                    tanggalInput("Kadaluarsa", "DD/MM/YYYY",
                                        tanggalController),
                                    inputField("Jumlah Barang", "Jumlah Barang",
                                        jumlahBarang_text),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16, top: 10.27),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Upload Gambar Kategori Obat",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                " *",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        ColorStyle.button_red),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          InkWell(
                                            onTap: () async {
                                              final im.XFile? photo =
                                                  await picker.pickImage(
                                                      source: im
                                                          .ImageSource.gallery);
                                              if (photo != null) {
                                                print("Berhasil pick photo");
                                                setState2(() {
                                                  pickedImage =
                                                      File(photo.path);
                                                  uploadFile = true;
                                                });
                                                pickedImageByte = await photo
                                                    .readAsBytes()
                                                    .whenComplete(() {
                                                  setState2(() {
                                                    uploadFile = true;
                                                  });
                                                });
                                              }
                                            },
                                            child: Container(
                                                width: double.infinity,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: ColorStyle.fill_form,
                                                ),
                                                child: DottedBorder(
                                                    color: Colors.black,
                                                    strokeWidth: 1,
                                                    dashPattern: [14, 8],
                                                    borderType:
                                                        BorderType.RRect,
                                                    // radius: Radius.circular(10),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: uploadFile ==
                                                                true
                                                            ? Image.file(
                                                                pickedImage!,
                                                                height:
                                                                    80, // Atur ukuran sesuai kebutuhan
                                                                width: 80,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Column(
                                                                children: [
                                                                  Image.asset(
                                                                    "images/upload_pict.png",
                                                                    height: 50,
                                                                    width: 50,
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(
                                                                          bottom:
                                                                              8)),
                                                                  Text(
                                                                    "Click to Upload",
                                                                    style: TextStyle(
                                                                        color: ColorStyle
                                                                            .alert_ungu,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                ],
                                                              ),
                                                      ),
                                                    ))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    inputCaraPemakaian(
                                        "Cara Pemakaian", caraPemakaian_text),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
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
                                            _alertInput();
                                            // _alertDone("diinput");
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
                                  _alertDone("dikosongkan");
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

  void _alertInput() {
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
                        "images/input.png",
                        width: constraints.maxWidth *
                            0.08, // Ukuran gambar responsif
                        height: constraints.maxWidth * 0.08,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Apakah Anda yakin akan \nmenginput data ini?",
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
                                  _alertDone("diinput");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorStyle.button_red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Iya, input",
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

  void _alertDone(String isi) {
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

  void sortByName() {
    setState(() {
      filterData.sort((a, b) => isAscending
          ? a.namaObat.compareTo(b.namaObat)
          : b.namaObat.compareTo(a.namaObat));
      isAscending = !isAscending; // Toggle sorting state
    });
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
              Row(
                children: [
                  Container(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // setState(() {
                        //   global.selectedIndex = 3;
                        //   global.selectedScreen = 0;
                        // });
                        _inputProdukBaru();
                      },
                      icon: Transform.translate(
                        offset: Offset(1, 0), // Geser ikon lebih dekat ke teks
                        child: Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                      label: Transform.translate(
                        offset: Offset(-3, 0),
                        child: const Text("Input Produk",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorStyle.button_green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8)),
                  Expanded(
                    child: Container(
                      height: 40,
                      // width: 242,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: ColorStyle.fill_stroke, width: 1),
                        color: ColorStyle.fill_form,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.only(left: 8)),
                          Icon(
                            Icons.search_outlined,
                            color: Color(0XFF1B1442),
                            size: 30,
                          ),
                          Padding(padding: EdgeInsets.only(right: 8)),
                          Expanded(
                            child: TextField(
                              controller: text,
                              onChanged: filtering,
                              decoration: InputDecoration(
                                isDense: true,
                                // contentPadding: EdgeInsets.only(
                                //     left: 8, bottom: 13),
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  color: ColorStyle.text_hint,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(right: 8))
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8)),
                  Container(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        sortByName();
                      },
                      icon: Transform.translate(
                        offset: Offset(5, 0), // Geser ikon lebih dekat ke teks
                        child: Icon(Icons.sort_by_alpha_outlined,
                            color: Colors.black, size: 22),
                      ),
                      label: const Text("Sort Ascending",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: ColorStyle.button_grey, width: 1)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 5),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8)),
                  Center(
                    child: SizedBox(
                      width: 160, // Sesuaikan lebar agar tidak terlalu besar
                      height:
                          40, // Tinggi dropdown agar sesuai dengan contoh gambar
                      child: DropdownButtonFormField2<String>(
                        isExpanded:
                            false, // Jangan meluaskan dropdown ke full width
                        value: _selectedStatus,
                        hint: Text(
                          "-- Pilih Status --",
                          style: TextStyle(
                              fontSize: 16, color: ColorStyle.text_hint),
                        ),
                        items: rowStatus
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ColorStyle.text_hint),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            filterByStatus(value);
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorStyle.fill_form,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          constraints: BoxConstraints(maxHeight: 30),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(5), // Border radius halus
                            borderSide:
                                BorderSide(color: ColorStyle.button_grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                                color: ColorStyle
                                    .text_secondary), // Saat aktif, border lebih gelap
                          ),
                        ),

                        // **Atur Tampilan Dropdown**
                        buttonStyleData: ButtonStyleData(
                          height: 25, // Tinggi tombol dropdown
                          padding: EdgeInsets.symmetric(
                              horizontal: 6), // Jarak dalam dropdown
                        ),

                        // **Atur Tampilan Dropdown yang Muncul**
                        dropdownStyleData: DropdownStyleData(
                          width: 160, // Lebar dropdown harus sama dengan input
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                            color: ColorStyle.fill_form,
                          ),
                        ),

                        // **Atur Posisi Item Dropdown**
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8), // Padding antar item dropdown
                        ),

                        // **Ganti Icon Dropdown**
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_outlined,
                              size: 20, color: Colors.black),
                          openMenuIcon: Icon(Icons.keyboard_arrow_up_outlined,
                              size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8)),
                  Container(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon:
                          Icon(Icons.filter_alt, color: Colors.black, size: 22),
                      label: const Text("Filter",
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: ColorStyle.button_grey, width: 1)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Container(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          3, // Agar item 1 per baris (sesuai contoh gambar)
                      childAspectRatio: 2.7, // Lebih panjang secara horizontal
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: paginatedData.length,
                    itemBuilder: (context, index) {
                      var produk = paginatedData[index];
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Gambar dengan latar belakang abu-abu
                              Container(
                                height: 59,
                                width: 59,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    "images/background.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: 20), // Jarak antara gambar dan teks
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Transform.translate(
                                    offset: Offset(0, -2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Nama obat dan menu 3 titik di satu baris
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                produk.namaObat,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow
                                                    .ellipsis, // Nama panjang terpotong jika melebihi
                                              ),
                                            ),
                                            PopupMenuButton<int>(
                                              icon: Icon(Icons.more_horiz,
                                                  color: Colors.black),
                                              offset: Offset(0, 40),
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              onSelected: (value) {
                                                // Tutup menu otomatis dan jalankan aksi sesuai pilihan
                                                switch (value) {
                                                  case 1:
                                                    _viewDetails(produk);
                                                    break;
                                                  case 2:
                                                    _editProduk(produk);
                                                    break;
                                                  case 3:
                                                    _modalKosongkanObat(produk);
                                                    break;
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .open_in_new_outlined,
                                                          color:
                                                              Colors.black54),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Lihat Data Obat",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 2,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit_outlined,
                                                          color:
                                                              Colors.black54),
                                                      SizedBox(width: 8),
                                                      Text("Edit Data Obat",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 3,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .delete_outline_outlined,
                                                          color:
                                                              Colors.black54),
                                                      SizedBox(width: 8),
                                                      Text("Hapus Data Obat",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Transform.translate(
                                          offset: Offset(0, -6),
                                          child: Text(
                                            produk.kode,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Stock: ${produk.jumlah} ${produk.satuan}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                            // Status Stock: "Sisa" jika <= 10, "Habis" jika 0
                                            if (produk.jumlah <= 10)
                                              Container(
                                                width: 61,
                                                height: 20,
                                                alignment: Alignment.center,
                                                // padding:
                                                //     const EdgeInsets.symmetric(
                                                //         horizontal: 15,
                                                //         vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: produk.jumlah == 0
                                                      ? ColorStyle.button_red
                                                          .withOpacity(0.8)
                                                      : ColorStyle.button_yellow
                                                          .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  border: Border.all(
                                                    color: produk.jumlah == 0
                                                        ? ColorStyle.button_red
                                                        : ColorStyle
                                                            .button_yellow,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  produk.jumlah == 0
                                                      ? "HABIS"
                                                      : "SISA",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontSize: 13),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Rows per page:",
                      style:
                          TextStyle(color: ColorStyle.text_hint, fontSize: 14)),
                  Padding(padding: EdgeInsets.only(right: 8)),
                  Center(
                    child: SizedBox(
                      width: 65, // Sesuaikan lebar agar tidak terlalu besar
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
                                        color: ColorStyle.text_hint),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _rowsPerPage = value!;
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          constraints: BoxConstraints(maxHeight: 30),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(5), // Border radius halus
                            borderSide:
                                BorderSide(color: ColorStyle.button_grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                                color: ColorStyle
                                    .text_secondary), // Saat aktif, border lebih gelap
                          ),
                        ),

                        // **Atur Tampilan Dropdown**
                        buttonStyleData: ButtonStyleData(
                          height: 25, // Tinggi tombol dropdown
                          padding: EdgeInsets.symmetric(
                              horizontal: 6), // Jarak dalam dropdown
                        ),

                        // **Atur Tampilan Dropdown yang Muncul**
                        dropdownStyleData: DropdownStyleData(
                          width: 65,
                          offset: Offset(
                              0, 200), // Lebar dropdown harus sama dengan input
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: ColorStyle.button_grey),
                            color: Colors.white,
                          ),
                        ),

                        // **Atur Posisi Item Dropdown**
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8), // Padding antar item dropdown
                        ),

                        // **Ganti Icon Dropdown**
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_outlined,
                              size: 20, color: Colors.black),
                          openMenuIcon: Icon(Icons.keyboard_arrow_up_outlined,
                              size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8)),
                  Text("Page $endIndex of ${filterData.length}",
                      style:
                          TextStyle(color: ColorStyle.text_hint, fontSize: 14)),
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
            ],
          ),
        ),
      ),
    );
  }

 Widget detailField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
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
      ),
    );
  }

  Widget inputField(String title, String isi, TextEditingController edit) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                " *",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorStyle.button_red),
              ),
            ],
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
                hintText: isi,
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
      ),
    );
  }

  Widget editFeld(String title, String value, TextEditingController edit) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                " *",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorStyle.button_red),
              ),
            ],
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
      ),
    );
  }

  Widget buildFormCaraPemakaian(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
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

  Widget inputCaraPemakaian(String label, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget inputImage() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Upload Gambar Kategori Obat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                " *",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final im.XFile? photo =
                  await picker.pickImage(source: im.ImageSource.gallery);
              if (photo != null) {
                print("Berhasil pick photo");
                setState(() {
                  pickedImage = File(photo.path);
                  uploadFile = true;
                });
                pickedImageByte = await photo.readAsBytes().whenComplete(() {
                  setState(() {
                    uploadFile = true;
                  });
                });
              }
            },
            child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: ColorStyle.fill_form,
                ),
                child: DottedBorder(
                    color: Colors.black,
                    strokeWidth: 1,
                    dashPattern: [14, 8],
                    borderType: BorderType.RRect,
                    // radius: Radius.circular(10),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: uploadFile == true
                            ? Image.file(
                                pickedImage!,
                                height: 80, // Atur ukuran sesuai kebutuhan
                                width: 80,
                                fit: BoxFit.cover,
                              )
                            : Column(
                                children: [
                                  Image.asset(
                                    "images/upload_pict.png",
                                    height: 50,
                                    width: 50,
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 8)),
                                  Text(
                                    "Click to Upload",
                                    style: TextStyle(
                                        color: ColorStyle.alert_ungu,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                      ),
                    ))),
          ),
        ],
      ),
    );
  }

  Widget tanggalEdit(String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                " *",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: ColorStyle.fill_stroke),
              color: ColorStyle.fill_form,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  readOnly: true,
                  controller: text,
                  onTap: () {
                    _selectedDate(context);
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    contentPadding: EdgeInsets.only(left: 8, bottom: 17),
                    hintStyle: TextStyle(
                      color: ColorStyle.tulisan_form,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      _selectedDate(context);
                    },
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: ColorStyle.tulisan_form,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget tanggalInput(String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                " *",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: ColorStyle.fill_stroke),
              color: ColorStyle.fill_form,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  readOnly: true,
                  controller: text,
                  onTap: () {
                    _selectedDate(context);
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    contentPadding: EdgeInsets.only(left: 8, bottom: 17),
                    hintStyle: TextStyle(
                      color: ColorStyle.tulisan_form,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      _selectedDate(context);
                    },
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: ColorStyle.tulisan_form,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 16),
        ],
      ),
    );
  }
}
