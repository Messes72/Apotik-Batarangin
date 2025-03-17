import 'package:apotek/Gudang/Pembelian/DataPembelian.dart';
import 'package:apotek/Gudang/Penerimaan/DataPenerimaan.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Pembeliaanbarang extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const Pembeliaanbarang(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<Pembeliaanbarang> createState() => pagePembelian();
}

class pagePembelian extends State<Pembeliaanbarang>
    with SingleTickerProviderStateMixin {
  bool triggerAnimation = false; // Tambahkan variabel isExpanded
  final List<int> rowItems = [10, 25, 50, 100];
  final List<String> rowStatus = ["Selesai", "Batal", "Proses"];
  final List<String> rowKategori = ["Obat Panas", "Obat Batuk", "Obat Flu"];
  final List<String> rowSatuan = ["Strip", "Botol", "Pcs"];
  String? _selectedStatus;

  String? selectedValue;

  String? _selectedKategori;
  String? _selectedSatuan;
  String? _selectedKategoriEdit;
  String? _selectedSatuanEdit;
  final _formKey = GlobalKey<FormState>();

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  var text = TextEditingController();
  var text2 = TextEditingController();

  var text3 = TextEditingController();
  var text4 = TextEditingController();

  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  List<TextEditingController> isi = [];
  List<TextEditingController> isi2 = [];

  // untuk menambahkan input untuk barang

  List<Widget> inputBarang = [];
  void tambahInputForm() {
    setState(() {
      inputBarang.add(InputForm(
          "Nama Obat",
          "Nama Obat",
          "Jumlah Barang yang Dipesan",
          "Jumlah Barang yang Dipesan",
          isi[inputBarang.length],
          isi2[inputBarang.length]));
    });
  }

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

  void _viewDetails(DataPembelianBarang item) {
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
                            "Informasi Penerimaan Barang",
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                detailField(
                                    "Tanggal Pemesanan",
                                    DateFormat('dd/MM/yyyy')
                                        .format(item.kadaluarsa)),
                                detailField(
                                    "Tanggal Penerimaan",
                                    DateFormat('dd/MM/yyyy')
                                        .format(item.kadaluarsa)),
                                detailField("Nama Supplier", item.namaSupplier),
                                SizedBox(
                                  height: 15,
                                ),
                                Divider(),
                                SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Text(
                                    "Daftar Barang",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(height: 15),
                                // hrs e di  loop
                                DetailForm(
                                    "Nama Obat",
                                    item.nama,
                                    "Jumlah Barang yang Dipesan",
                                    "${item.stokBarang.toString()} ${item.satuan}")

                                // detailField("Kode Obat", item.kode),
                                // detailField(
                                //     "Kategori Obat", item.kategoriBarang),
                                // detailField("Nama Obat", item.namaBarang),
                                // detailField(
                                //     "Jumlah Obat yang Diterima", item.stok),
                                // detailField(
                                //     "Kadaluarsa",
                                //     DateFormat('dd/MM/yyyy')
                                //         .format(item.kadaluarsa)),
                                // detailField("Satuan", item.satuan),
                                // detailField("Harga Beli", item.hargaBeli),
                                // detailField("Nama Supplier", item.namaSupplier),
                                // detailField("Nama Penerima Barang",
                                //     item.namaPenerimaBarang),
                                // detailField(
                                //     "Tanggal Penerimaan Barang",
                                //     DateFormat('dd/MM/yyyy')
                                //         .format(item.tanggalPenerimaan))
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
    DataPenerimaanBarang item,
    TextEditingController nomorBatch,
    TextEditingController kode,
    TextEditingController kategori,
    TextEditingController namaObat,
    TextEditingController kadaluarsa,
    TextEditingController satuan,
    TextEditingController jumlah,
    TextEditingController hargaBeli,
    TextEditingController namaSupplier,
    TextEditingController namaPenerimaBarang,
  ) {
    setState(() {
      // 🔹 Ini yang memastikan UI diperbarui
      item.noBatch = nomorBatch.text;
      item.kode = kode.text;
      item.kategoriBarang = kategori.text;
      item.namaBarang = namaObat.text;
      item.kadaluarsa = DateFormat('dd/MM/yyyy').parse(kadaluarsa.text);
      item.satuan = satuan.text;
      item.stok = jumlah.text;
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
  void _editProduk(DataPembelianBarang item) {
    // TextEditingController nomorBatchController =
    //     TextEditingController(text: item.noBatch);
    // TextEditingController kodeController =
    //     TextEditingController(text: item.kode);
    // TextEditingController kategoriController =
    //     TextEditingController(text: item.kategoriBarang);
    // TextEditingController namaObatController =
    //     TextEditingController(text: item.namaBarang);
    // TextEditingController kadaluarsaController = TextEditingController(
    //     text: DateFormat('dd/MM/yyyy').format(item.kadaluarsa));
    // TextEditingController satuanController =
    //     TextEditingController(text: item.satuan);
    // TextEditingController jumlahController =
    //     TextEditingController(text: item.stok);

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
                    SizedBox(height: 16),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Column(
                              children: [
                                // editFeld("Nomor Batch", item.noBatch,
                                //     nomorBatchController),
                                // editFeld("Kode", item.kode, kodeController),
                                // editFeld("Kategori", item.kategoriBarang,
                                //     kategoriController),
                                // editFeld("Nama Obat", item.namaBarang,
                                //     namaObatController),
                                // editFeld(
                                //     "Kadaluarsa",
                                //     DateFormat('dd/MM/yyyy')
                                //         .format(item.kadaluarsa),
                                //     kadaluarsaController),
                                // editFeld(
                                //     "Satuan", item.satuan, satuanController),
                                // editFeld("Jumlah Barang", item.stok,
                                //     jumlahController),
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

                                          // item.noBatch =
                                          //     nomorBatchController.text;
                                          // item.kode = kodeController.text;
                                          // item.kategoriBarang =
                                          //     kategoriController.text;
                                          // item.namaBarang =
                                          //     namaObatController.text;
                                          // item.kadaluarsa =
                                          //     DateFormat('dd/MM/yyyy').parse(
                                          //         kadaluarsaController.text);
                                          // item.satuan = satuanController.text;
                                          // item.stok = jumlahController.text;
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

  void _inputPenerimaanBaru() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState2) {
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
                                    color: ColorStyle.button_grey, width: 1))),
                        padding:
                            const EdgeInsets.only(top: 8, left: 23, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Input Data Pembelian Barang",
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
                      SizedBox(height: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              Column(
                                children: [
                                  tanggalInput("Tanggal Pemesanan",
                                      "DD/MM/YYYY", tanggalController),
                                  tanggalInput2("Tanggal Penerimaan",
                                      "DD/MM/YYYY", tanggalController),
                                  inputField("Nama Supplier", "Nama Supplier",
                                      nomorKartu_text),
                                  Divider(),
                                  Padding(padding: EdgeInsets.only(bottom: 16)),
                                  Row(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 16)),
                                      Text("Daftar Barang",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: ColorStyle.tulisan_form)),
                                      Spacer(),
                                      SizedBox(
                                        width: 120,
                                        height: 30,
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.refresh,
                                              color: ColorStyle.button_yellow,
                                              size: 22),
                                          label: const Text("Muat Ulang",
                                              style: TextStyle(
                                                  color:
                                                      ColorStyle.button_yellow,
                                                  fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                    color: ColorStyle
                                                        .button_yellow)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 16)),
                                      SizedBox(
                                        width: 150,
                                        height: 30,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState2(() {
                                              TextEditingController isiNama =
                                                  TextEditingController();
                                              TextEditingController
                                                  jumlahBarang =
                                                  TextEditingController();

                                              isi.add(isiNama);
                                              isi2.add(jumlahBarang);

                                              tambahInputForm();
                                            });
                                            print(inputBarang.length);
                                          },
                                          icon: Icon(Icons.add,
                                              color:
                                                  ColorStyle.text_dalam_kolom,
                                              size: 22),
                                          label: const Text("Tambah Barang",
                                              style: TextStyle(
                                                  color: ColorStyle
                                                      .text_dalam_kolom,
                                                  fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 2),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                    color: ColorStyle
                                                        .text_dalam_kolom)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 16)),
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 16)),
                                  // Column(
                                  //   children: inputBarang
                                  // ),
                                  Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: inputBarang.length,
                                        itemBuilder: (context, index) {
                                          return inputBarang[index];
                                        },
                                      ),
                                    ],
                                  ),
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

                      SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  void _modalKosongkanObat(DataPembelianBarang item) {
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
                              "Catatan Pembelian Barang",
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
                                  "Apakah ada Catatan untuk Barang ini?",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 23, right: 23),
                              child: Container(
                                height: 225,
                                // decoration: BoxDecoration(
                                //   color: ColorStyle.fill_form,
                                //   border:
                                //       Border.all(color: ColorStyle.fill_stroke),
                                //   borderRadius: BorderRadius.circular(8),
                                // ),
                                // padding:
                                //     const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  controller: text2,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: ColorStyle.fill_form,
                                    hintText: "Catatan",
                                    hintStyle: TextStyle(
                                      color: ColorStyle.tulisan_form,
                                      fontSize: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorStyle.fill_stroke,
                                          width: 1), // Warna abu-abu
                                      borderRadius: BorderRadius.circular(8),
                                    ),

                                    // Border saat ditekan (fokus)
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1), // Warna biru saat fokus
                                      borderRadius: BorderRadius.circular(8),
                                    ),

                                    // Border saat error
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorStyle.button_red,
                                          width: 1), // Warna merah jika error
                                      borderRadius: BorderRadius.circular(8),
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
                                        // _alertDelete(item);
                                        _alertInput();
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

  void _alertDelete(DataPembelianBarang item) {
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
                        "Apakah Anda yakin \n menghapus data ini?",
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

  // Tab
  late TabController _tabController;
  final List<String> _titles = [
    "PEMBELIAN BARANG",
    "LAPORAN PEMBELIAN BARANG",
    "RIWAYAT PEMBELIAN BARANG"
  ];
  int _selectedTabIndex = 0;

  int _rowsPerPage = 10; // Default jumlah baris per halaman
  int _currentPage = 0;

  List<DataPembelianBarang> filterData = [];
  final List<DataPembelianBarang> _data = List.generate(
    100,
    (index) => DataPembelianBarang(
      nama: "Barang $index",
      kategori: "Kategori ${(index % 5) + 1}",
      kode: "Kode-$index",
      harga: (1000 + index * 10).toDouble(),
      kadaluarsa: DateTime.now().add(Duration(days: index * 10)),
      stokBarang: (index % 20) + 1, // Stok antara 1 - 20
      hargaBeli: (900 + index * 8).toDouble(),
      satuan: "PCS",
      noBatch: "Batch-$index",
      namaSupplier: "Supplier ${(index % 3) + 1}",
      namaPenerimaBarang: "Penerima ${(index % 4) + 1}",
      catatan:
          "Catatan untuk Barang $index adalah ada yang cacat , banyak obatnya yang glundung dan botol pecah semua sampai basah kotaknya",
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {
    //   inputBarang.add(InputForm(
    //       "Nama Obat",
    //       "Nama Obat",
    //       "Jumlah Barang yang Dipesan",
    //       "Jumlah Barang yang Dipesan",
    //       textController1,
    //       textController2));
    //   inputBarang.add(InputForm(
    //       "Nama Obat",
    //       "Nama Obat",
    //       "Jumlah Barang yang Dipesan",
    //       "Jumlah Barang yang Dipesan",
    //       textController1,
    //       textController2));
    //   inputBarang.add(InputForm(
    //       "Nama Obat",
    //       "Nama Obat",
    //       "Jumlah Barang yang Dipesan",
    //       "Jumlah Barang yang Dipesan",
    //       textController1,
    //       textController2));
    // });
    filterData = List.from(_data);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  void filtering(String query) {
    setState(() {
      if (query.isEmpty) {
        filterData = List.from(_data);
      } else {
        filterData = _data.where((item) {
          return item.nama.toLowerCase().contains(query.toLowerCase()) ||
              item.stokBarang
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
      _currentPage = 0; // Reset ke halaman pertama setelah filter
    });
  }

  void filterByStatus(String status) {
    setState(() {
      if (status == "Selesai") {
        filterData = _data.where((item) => item.stokBarang == 10).toList();
      } else if (status == "Batal") {
        filterData = _data.where((item) => item.stokBarang != 10).toList();
      } else {
        filterData =
            List.from(_data); // Jika pilih "Semua", tampilkan semua data
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filterData.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex =
        (startIndex + _rowsPerPage).clamp(0, filterData.length); // Batas aman
    List<DataPembelianBarang> paginatedData =
        filterData.sublist(startIndex, endIndex);
    return Scaffold(
      // appBar: NavbarTop(title: "PENERIMAAN BARANG", onMenuPressed: onMenuPressed, isExpanded: isExpanded),
      appBar: NavbarTop(
          title: _titles[_selectedTabIndex],
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
              TabBar(
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.zero,
                controller: _tabController,
                labelColor: ColorStyle.primary, // Warna teks saat aktif
                unselectedLabelColor:
                    Colors.black, // Warna teks saat tidak aktif
                indicatorColor:
                    ColorStyle.primary, // Warna garis bawah tab aktif
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                isScrollable: true,
                labelPadding: const EdgeInsets.only(left: 0, right: 16),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: "Pembelian"),
                  Tab(text: "Statistik"),
                  Tab(text: "Riwayat"),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 16)),
              Expanded(
                child:
                    TabBarView(controller: _tabController, children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _inputPenerimaanBaru();
                                },
                                icon: Transform.translate(
                                  offset: Offset(
                                      5, 0), // Geser ikon lebih dekat ke teks
                                  child: Icon(Icons.add,
                                      color: Colors.white, size: 22),
                                ),
                                label: const Text("Input Pembelian",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorStyle.button_green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 3),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Expanded(
                              child: Container(
                                height: 40,
                                // width: 242,
                                // decoration: BoxDecoration(
                                //   border: Border.all(
                                //       color: ColorStyle.fill_stroke, width: 1),
                                //   color: ColorStyle.fill_form,
                                //   borderRadius: BorderRadius.circular(4),
                                // ),
                                child: TextField(
                                  controller: text,
                                  onChanged: filtering,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: ColorStyle.fill_form,

                                    // Menambahkan ikon di dalam TextField
                                    prefixIcon: Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Icon(
                                        Icons.search_outlined,
                                        color: Color(0XFF1B1442),
                                        size: 30, // Sesuaikan ukuran ikon
                                      ),
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(left: 8, bottom: 12.5),
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: ColorStyle.text_hint,
                                      fontSize: 16,
                                    ),

                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorStyle.fill_stroke,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Center(
                              child: SizedBox(
                                width:
                                    200, // Sesuaikan lebar agar tidak terlalu besar
                                height:
                                    40, // Tinggi dropdown agar sesuai dengan contoh gambar
                                child: DropdownButtonFormField2<String>(
                                  isExpanded:
                                      false, // Jangan meluaskan dropdown ke full width
                                  value: _selectedStatus,
                                  hint: Text(
                                    "-- Pilih Status --",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ColorStyle.text_hint),
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    constraints: BoxConstraints(maxHeight: 30),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Border radius halus
                                      borderSide: BorderSide(
                                          color: ColorStyle.button_grey),
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
                                    width:
                                        200, // Lebar dropdown harus sama dengan input
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.grey),
                                      color: ColorStyle.fill_form,
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
                                    icon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        size: 20,
                                        color: Colors.black),
                                    openMenuIcon: Icon(
                                        Icons.keyboard_arrow_up_outlined,
                                        size: 20,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
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
                                  Expanded(
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minWidth: constraints.maxWidth),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              headingRowColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                              columnSpacing:
                                                  80, // Menambah jarak antar kolom
                                              dataRowMinHeight:
                                                  60, // Menambah tinggi minimum baris
                                              dataRowMaxHeight:
                                                  60, // Menambah tinggi maksimum baris
                                              columns: const [
                                                DataColumn(
                                                    label: Expanded(
                                                        child: Center(
                                                            child: Text('ID',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))))),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Nama Obat',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Nama Supplier',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Jumlah Barang',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Status',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Actions',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                              ],
                                              rows: paginatedData.map((item) {
                                                return DataRow(
                                                  color:
                                                      MaterialStateProperty.all(
                                                          Colors.white),
                                                  cells: [
                                                    DataCell(Center(
                                                        child: Text(item.kode,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            )))),
                                                    DataCell(Center(
                                                        child: Text(item.nama,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              fontSize: 14,
                                                            )))),
                                                    DataCell(
                                                      Center(
                                                        child: SizedBox(
                                                          width: 100,
                                                          child: Text(
                                                            item.namaSupplier,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center, // Batas maksimal baris teks
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // DataCell(Text(item.quantity.toString())),
                                                    DataCell(Center(
                                                        child: Text(
                                                            item.stokBarang
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              fontSize: 14,
                                                            )))),
                                                    DataCell(
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        14,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: item.stokBarang ==
                                                                      10
                                                                  ? ColorStyle
                                                                      .status_green
                                                                      .withOpacity(
                                                                          0.8)
                                                                  : ColorStyle
                                                                      .status_red
                                                                      .withOpacity(
                                                                          0.8),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              border:
                                                                  Border.all(
                                                                color: item.stokBarang ==
                                                                        10
                                                                    ? ColorStyle
                                                                        .status_green
                                                                    : ColorStyle
                                                                        .status_red,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              item.stokBarang ==
                                                                      10
                                                                  ? "SELESAI"
                                                                  : "BATAL",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .open_in_new_outlined,
                                                                color: ColorStyle
                                                                    .text_secondary,
                                                                size: 24,
                                                              ),
                                                              onPressed: () {
                                                                _viewDetails(
                                                                    item);
                                                              }),
                                                          IconButton(
                                                              icon: Icon(
                                                                Icons.done,
                                                                color: ColorStyle
                                                                    .text_secondary,
                                                                size: 24,
                                                              ),
                                                              onPressed: () {
                                                                _modalKosongkanObat(
                                                                    item);
                                                                // _editProduk(
                                                                //     item);
                                                              }),
                                                          IconButton(
                                                              icon: Icon(
                                                                Icons.close,
                                                                color: ColorStyle
                                                                    .text_secondary,
                                                                size: 24,
                                                              ),
                                                              onPressed: () {
                                                                // _alertDelete(
                                                                //     item);
                                                                _modalKosongkanObat(
                                                                    item);
                                                              }),
                                                        ],
                                                      ),
                                                    ))
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Rows per page:",
                                style: TextStyle(
                                    color: ColorStyle.text_hint, fontSize: 14)),
                            Padding(padding: EdgeInsets.only(right: 8)),
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    constraints: BoxConstraints(maxHeight: 30),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Border radius halus
                                      borderSide: BorderSide(
                                          color: ColorStyle.button_grey),
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
                                    width:
                                        65, // Lebar dropdown harus sama dengan input
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: ColorStyle.button_grey),
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
                                    icon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        size: 20,
                                        color: Colors.black),
                                    openMenuIcon: Icon(
                                        Icons.keyboard_arrow_up_outlined,
                                        size: 20,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Text("Page $endIndex of ${filterData.length}",
                                style: TextStyle(
                                    color: ColorStyle.text_hint, fontSize: 14)),
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
                  Container(
                    child: Column(
                      children: [
                        _buildStatCards(),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Expanded(
                              child: Container(
                                height: 40,
                                // width: 242,
                                // decoration: BoxDecoration(
                                //   border: Border.all(
                                //       color: ColorStyle.fill_stroke, width: 1),
                                //   color: ColorStyle.fill_form,
                                //   borderRadius: BorderRadius.circular(4),
                                // ),
                                child: TextField(
                                  controller: text,
                                  onChanged: filtering,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: ColorStyle.fill_form,

                                    // Menambahkan ikon di dalam TextField
                                    prefixIcon: Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Icon(
                                        Icons.search_outlined,
                                        color: Color(0XFF1B1442),
                                        size: 30, // Sesuaikan ukuran ikon
                                      ),
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(left: 8, bottom: 12.5),

                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: ColorStyle.text_hint,
                                      fontSize: 16,
                                    ),

                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ColorStyle.fill_stroke,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Center(
                              child: SizedBox(
                                width:
                                    200, // Sesuaikan lebar agar tidak terlalu besar
                                height:
                                    40, // Tinggi dropdown agar sesuai dengan contoh gambar
                                child: DropdownButtonFormField2<String>(
                                  isExpanded:
                                      false, // Jangan meluaskan dropdown ke full width
                                  value: _selectedStatus,
                                  hint: Text(
                                    "-- Pilih Status --",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ColorStyle.text_hint),
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    constraints: BoxConstraints(maxHeight: 30),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Border radius halus
                                      borderSide: BorderSide(
                                          color: ColorStyle.button_grey),
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
                                    width:
                                        200, // Lebar dropdown harus sama dengan input
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.grey),
                                      color: ColorStyle.fill_form,
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
                                    icon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        size: 20,
                                        color: Colors.black),
                                    openMenuIcon: Icon(
                                        Icons.keyboard_arrow_up_outlined,
                                        size: 20,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
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
                                  Expanded(
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minWidth: constraints.maxWidth),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              headingRowColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                              columnSpacing:
                                                  80, // Menambah jarak antar kolom
                                              dataRowMinHeight:
                                                  60, // Menambah tinggi minimum baris
                                              dataRowMaxHeight:
                                                  60, // Menambah tinggi maksimum baris
                                              columns: const [
                                                DataColumn(
                                                    label: Expanded(
                                                        child: Center(
                                                            child: Text('ID',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))))),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Nama Obat',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Nama Supplier',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Jumlah Barang',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Status',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text('Catatan',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                )),
                                              ],
                                              rows: paginatedData.map((item) {
                                                return DataRow(
                                                  color:
                                                      MaterialStateProperty.all(
                                                          Colors.white),
                                                  cells: [
                                                    DataCell(Center(
                                                        child: Text(item.kode,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            )))),
                                                    DataCell(Center(
                                                        child: Text(item.nama,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              fontSize: 14,
                                                            )))),
                                                    DataCell(
                                                      Center(
                                                        child: SizedBox(
                                                          width: 100,
                                                          child: Text(
                                                            item.namaSupplier,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center, // Batas maksimal baris teks
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // DataCell(Text(item.quantity.toString())),
                                                    DataCell(Center(
                                                        child: Text(
                                                            item.stokBarang
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              fontSize: 14,
                                                            )))),
                                                    DataCell(
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        14,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: item.stokBarang ==
                                                                      10
                                                                  ? ColorStyle
                                                                      .status_green
                                                                      .withOpacity(
                                                                          0.8)
                                                                  : ColorStyle
                                                                      .status_red
                                                                      .withOpacity(
                                                                          0.8),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              border:
                                                                  Border.all(
                                                                color: item.stokBarang ==
                                                                        10
                                                                    ? ColorStyle
                                                                        .status_green
                                                                    : ColorStyle
                                                                        .status_red,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              item.stokBarang ==
                                                                      10
                                                                  ? "SELESAI"
                                                                  : "BATAL",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Center(
                                                        child: SizedBox(
                                                          width: 300,
                                                          child: Text(
                                                            item.catatan,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .start, // Batas maksimal baris teks
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Rows per page:",
                                style: TextStyle(
                                    color: ColorStyle.text_hint, fontSize: 14)),
                            Padding(padding: EdgeInsets.only(right: 8)),
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    constraints: BoxConstraints(maxHeight: 30),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Border radius halus
                                      borderSide: BorderSide(
                                          color: ColorStyle.button_grey),
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
                                    width:
                                        65, // Lebar dropdown harus sama dengan input
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: ColorStyle.button_grey),
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
                                    icon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        size: 20,
                                        color: Colors.black),
                                    openMenuIcon: Icon(
                                        Icons.keyboard_arrow_up_outlined,
                                        size: 20,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Text("Page $endIndex of ${filterData.length}",
                                style: TextStyle(
                                    color: ColorStyle.text_hint, fontSize: 14)),
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
                ]),
              ),
            ],
          ),
        ),
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

  Widget InputForm(String label1, String hint1, String label2, String hint2,
      TextEditingController edit, TextEditingController edit2) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Nama Obat",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
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
                    height: 35,
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: ColorStyle.fill_stroke),
                    //   color: ColorStyle.fill_form,
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    child: TextField(
                      onChanged: (value) {
                        print(isi[0].text);
                      },
                      controller: edit,
                      style: TextStyle(
                        color: ColorStyle.tulisan_form,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorStyle.fill_form,
                        hintText: "Nama Obat",
                        contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
                        hintStyle: TextStyle(
                          color: ColorStyle.tulisan_form,
                          fontSize: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorStyle.fill_stroke,
                              width: 1), // Warna abu-abu
                          borderRadius: BorderRadius.circular(8),
                        ),

                        // Border saat ditekan (fokus)
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black,
                              width: 1), // Warna biru saat fokus
                          borderRadius: BorderRadius.circular(8),
                        ),

                        // Border saat error
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorStyle.button_red,
                              width: 1), // Warna merah jika error
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Jumlah Barang yang Dipesan",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
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
                  Row(
                    children: [
                      Expanded(
                        // Gunakan Expanded agar TextField tidak menyebabkan infinite width error
                        child: Container(
                          height: 35,
                          // decoration: BoxDecoration(
                          //   border: Border.all(color: ColorStyle.fill_stroke),
                          //   color: ColorStyle.fill_form,
                          //   borderRadius: BorderRadius.circular(8),
                          // ),
                          child: TextField(
                            controller: edit2,
                            style: TextStyle(
                              color: ColorStyle.tulisan_form,
                              fontSize: 12,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: ColorStyle.fill_form,
                              hintText: "Jumlah Barang yang Dipesan",
                              contentPadding:
                                  EdgeInsets.only(left: 8, bottom: 12.5),
                              hintStyle: TextStyle(
                                color: ColorStyle.tulisan_form,
                                fontSize: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorStyle.fill_stroke,
                                    width: 1), // Warna abu-abu
                                borderRadius: BorderRadius.circular(8),
                              ),

                              // Border saat ditekan (fokus)
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1), // Warna biru saat fokus
                                borderRadius: BorderRadius.circular(8),
                              ),

                              // Border saat error
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorStyle.button_red,
                                    width: 1), // Warna merah jika error
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {},
                        child: Icon(Icons.delete_outline,
                            color: ColorStyle.button_red, size: 25),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
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

  Widget DetailForm(String label1, String hint1, String label2, String hint2) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nama Obat",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorStyle.fill_stroke),
                      color: ColorStyle.fill_form,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                      child: Text(
                        hint1,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jumlah Barang yang Dipesan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorStyle.fill_stroke),
                      color: ColorStyle.fill_form,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                      child: Text(
                        hint2,
                        style: TextStyle(fontSize: 12),
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
  }

  Widget inputField(String title, String isi, TextEditingController edit) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
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
            // decoration: BoxDecoration(
            //   border: Border.all(color: ColorStyle.fill_stroke),
            //   color: ColorStyle.fill_form,
            //   borderRadius: BorderRadius.circular(8),
            // ),
            child: TextField(
              controller: edit,
              style: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: isi,
                filled: true,
                fillColor: ColorStyle.fill_form,
                contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.fill_stroke, width: 1), // Warna abu-abu
                  borderRadius: BorderRadius.circular(8),
                ),

                // Border saat ditekan (fokus)
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black, width: 1), // Warna biru saat fokus
                  borderRadius: BorderRadius.circular(8),
                ),

                // Border saat error
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.button_red,
                      width: 1), // Warna merah jika error
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField2(String title, String isi, TextEditingController edit) {
    return Column(
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
          // decoration: BoxDecoration(
          //   border: Border.all(color: ColorStyle.fill_stroke),
          //   color: ColorStyle.fill_form,
          //   borderRadius: BorderRadius.circular(8),
          // ),
          child: TextField(
            controller: edit,
            style: TextStyle(
              color: ColorStyle.tulisan_form,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: ColorStyle.fill_form,
              hintText: isi,
              contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
              hintStyle: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorStyle.fill_stroke, width: 1), // Warna abu-abu
                borderRadius: BorderRadius.circular(8),
              ),

              // Border saat ditekan (fokus)
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black, width: 1), // Warna biru saat fokus
                borderRadius: BorderRadius.circular(8),
              ),

              // Border saat error
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorStyle.button_red,
                    width: 1), // Warna merah jika error
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget editFeld(String title, String value, TextEditingController edit) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
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
      padding: const EdgeInsets.only(left: 16, right: 16),
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
      padding: const EdgeInsets.only(left: 16, right: 16),
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
      padding: const EdgeInsets.only(left: 16, right: 16),
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

  Widget inputImage(String label, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
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

  Widget tanggalInput(String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
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
            // decoration: BoxDecoration(
            //   border: Border.all(color: ColorStyle.fill_stroke),
            //   color: ColorStyle.fill_form,
            //   borderRadius: BorderRadius.circular(8),
            // ),
            // padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              // readOnly: true,
              controller: text,

              // onTap: () {
              //   _selectedDate(context);
              // },
              decoration: InputDecoration(
                // isDense: true,
                filled: true,
                fillColor: ColorStyle.fill_form,
                suffixIcon: IconButton(
                  onPressed: () {
                    _selectedDate(context);
                  },
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: ColorStyle.tulisan_form,
                    size: 24,
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
                hintText: hint,
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 12,
                ),
                // Border sebelum ditekan
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.fill_stroke, width: 1), // Warna abu-abu
                  borderRadius: BorderRadius.circular(8),
                ),

                // Border saat ditekan (fokus)
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black, width: 1), // Warna biru saat fokus
                  borderRadius: BorderRadius.circular(8),
                ),

                // Border saat error
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.button_red,
                      width: 1), // Warna merah jika error
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget tanggalInput2(String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
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
            // decoration: BoxDecoration(
            //   border: Border.all(color: ColorStyle.fill_stroke),
            //   color: ColorStyle.fill_form,
            //   borderRadius: BorderRadius.circular(8),
            // ),
            // padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              // readOnly: true,
              controller: text,

              // onTap: () {
              //   _selectedDate(context);
              // },
              decoration: InputDecoration(
                // isDense: true,
                filled: true,
                fillColor: ColorStyle.fill_form,
                suffixIcon: IconButton(
                  onPressed: () {
                    _selectedDate(context);
                  },
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: ColorStyle.tulisan_form,
                    size: 24,
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
                hintText: hint,
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 12,
                ),
                // Border sebelum ditekan
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.fill_stroke, width: 1), // Warna abu-abu
                  borderRadius: BorderRadius.circular(8),
                ),

                // Border saat ditekan (fokus)
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black, width: 1), // Warna biru saat fokus
                  borderRadius: BorderRadius.circular(8),
                ),

                // Border saat error
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.button_red,
                      width: 1), // Warna merah jika error
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 2.04,
          ),
          Text(
            "Ketik (-) jika tidak ada kepastian tanggal penerimaan",
            style: TextStyle(fontSize: 10, color: ColorStyle.text_dalam_kolom),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard("TOTAL PEMBELIAN BARANG", "100 Produk", Colors.blue),
        _buildStatCard("TOTAL BARANG DIPROSES", "100 Produk", Colors.amber),
        _buildStatCard("TOTAL BARANG SELESAI", "100 Produk", Colors.green),
        _buildStatCard("TOTAL BARANG BATAL", "100 Produk", Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
   Widget dropdownKategori() {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Kategori Obat",
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
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth, // Ikuti lebar parent
              height: 35,
              child: DropdownButtonFormField2<String>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _selectedKategori,
                hint: Text(
                  "Pilih Kategori Obat",
                  style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                ),
                items: rowKategori
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                ),

                // **Atur Tampilan Dropdown Menu**
                dropdownStyleData: DropdownStyleData(
                  width: constraints.maxWidth, // Ikuti lebar input field
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: ColorStyle.button_grey),
                    color: ColorStyle.fill_form,
                  ),
                ),

                // **Atur Posisi Item Dropdown**
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),

                // **Ganti Icon Dropdown**
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                      size: 20, color: Colors.black),
                  openMenuIcon: Icon(Icons.keyboard_arrow_up_outlined,
                      size: 20, color: Colors.black),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
Widget dropdownKategoriEdit(String isi) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Kategori Obat",
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
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth, // Ikuti lebar parent
              height: 35,
              child: DropdownButtonFormField2<String>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _selectedKategoriEdit,
                hint: Text(
                  isi,
                  style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                ),
                items: rowKategori
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategoriEdit = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                ),

                // **Atur Tampilan Dropdown Menu**
                dropdownStyleData: DropdownStyleData(
                  width: constraints.maxWidth, // Ikuti lebar input field
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: ColorStyle.button_grey),
                    color: ColorStyle.fill_form,
                  ),
                ),

                // **Atur Posisi Item Dropdown**
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),

                // **Ganti Icon Dropdown**
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                      size: 20, color: Colors.black),
                  openMenuIcon: Icon(Icons.keyboard_arrow_up_outlined,
                      size: 20, color: Colors.black),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
  Widget dropdownSatuan() {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Satuan",
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
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth, // Ikuti lebar parent
              height: 35,
              child: DropdownButtonFormField2<String>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _selectedSatuan,
                hint: Text(
                  "Pilih Satuan",
                  style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                ),
                items: rowSatuan
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSatuan = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                ),

                // **Atur Tampilan Dropdown Menu**
                dropdownStyleData: DropdownStyleData(
                  width: constraints.maxWidth, // Ikuti lebar input field
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: ColorStyle.button_grey),
                    color: ColorStyle.fill_form,
                  ),
                ),

                // **Atur Posisi Item Dropdown**
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),

                // **Ganti Icon Dropdown**
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                      size: 20, color: Colors.black),
                  openMenuIcon: Icon(Icons.keyboard_arrow_up_outlined,
                      size: 20, color: Colors.black),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
Widget dropdownSatuanEdit(String isi) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Satuan",
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
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth, // Ikuti lebar parent
              height: 35,
              child: DropdownButtonFormField2<String>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _selectedSatuanEdit,
                hint: Text(
                  isi,
                  style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                ),
                items: rowSatuan
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSatuanEdit = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                ),

                // **Atur Tampilan Dropdown Menu**
                dropdownStyleData: DropdownStyleData(
                  width: constraints.maxWidth, // Ikuti lebar input field
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: ColorStyle.button_grey),
                    color: ColorStyle.fill_form,
                  ),
                ),

                // **Atur Posisi Item Dropdown**
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),

                // **Ganti Icon Dropdown**
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                      size: 20, color: Colors.black),
                  openMenuIcon: Icon(Icons.keyboard_arrow_up_outlined,
                      size: 20, color: Colors.black),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
}
