import 'package:apotek/Gudang/Stock/DataStockOpname.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:apotek/global.dart' as global;

class Editstockopname extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const Editstockopname(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<Editstockopname> createState() => editStock();
}

class editStock extends State<Editstockopname> {
  bool triggerAnimation = false; // Tambahkan variabel isExpanded

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  final List<String> rowKategori = ["Obat Panas", "Obat Batuk", "Obat Flu"];
  final List<String> rowSatuan = ["Strip", "Botol", "Pcs"];

  String? _selectedKategori;
  String? _selectedSatuan;
  String? _selectedKategoriEdit;
  String? _selectedSatuanEdit;
  var text = TextEditingController();
  var text2 = TextEditingController();

  var jumlahBarang = TextEditingController();
  var nomorOpname = TextEditingController();
  var tanggalOpname = TextEditingController();
  var jumlahUpdate = TextEditingController();

  List<StokOpnameData> filterData = [];
  final List<int> rowItems = [10, 25, 50, 100];

  String? selectedValue;

  final _formKey = GlobalKey<FormState>();
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

  // final List<StokOpnameData> _data = [

  // ];
  final List<StokOpnameData> _data = List.generate(
      30,
      (index) => StokOpnameData(
            nama: 'Barang $index',
            kategori: 'Kategori ${index % 5}',
            kode: 'KODE$index',
            harga: (index + 1) * 1000.0,
            kadaluarsa: DateTime.now().add(Duration(days: index * 30)),
            stok: (index + 1) * 10,
            masuk: (index + 1) * 5,
            keluar: (index + 1) * 3,
            hargaJual: (index + 1) * 1200.0,
            hargaBeli: (index + 1) * 900.0,
            satuan: 'Unit',
            uprate: (index % 3) * 1.1,
            noKartu: 'KARTU$index',
            noBatch: 'BATCH$index',
            catatan: 'Catatan untuk Barang $index',
          ));

  void _viewDetails(StokOpnameData item) {
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
                            "Informasi Stock Opname",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
                    SizedBox(height: 8),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Column(
                              children: [
                                detailField("Nomor Kartu", item.noKartu),
                                detailField("Nomor Batch", item.noBatch),
                                detailField("Kode Obat", item.kode),
                                detailField("Kategori Obat", item.kategori),
                                detailField("Nama Obat", item.kategori),
                                detailField(
                                    "Kadarluarsa",
                                    DateFormat('dd/MM/yyyy')
                                        .format(item.kadaluarsa)),
                                detailField("Satuan", item.satuan),
                                detailField(
                                    "Stock Barang", item.stok.toString()),
                                detailField(
                                    "Barang Masuk", item.masuk.toString()),
                                detailField(
                                    "Barang Keluar", item.keluar.toString()),
                                detailField(
                                    "Harga Jual", item.hargaJual.toString()),
                                detailField(
                                    "Harga Beli", item.hargaBeli.toString()),
                                detailField("Uprate", item.uprate.toString()),
                                buildFormCaraPemakaian(
                                    "Cara Pemakaian", item.catatan)
                              ],
                            )
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

  var nomorKartu_text = TextEditingController();
  var nomorBatch_text = TextEditingController();
  var kodeObat_text = TextEditingController();
  var kategori_text = TextEditingController();
  var namaObat_text = TextEditingController();
  var jumlahBarang_text = TextEditingController();
  var caraPemakaian_text = TextEditingController();
  var stokBarang_text = TextEditingController();
  var satuan_text = TextEditingController();
  void _inputStockOpname() {
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
                                inputField("Nomor Kartu", "Nomor Kartu",
                                    nomorKartu_text),
                                inputField("Nomor Batch", "Nomor Batch",
                                    nomorBatch_text),
                                inputField(
                                    "Kode Obat", "Kode Obat", kodeObat_text),
                                dropdownKategori(),
                                inputField(
                                    "Nama Obat", "Nama Obat", namaObat_text),
                                tanggalInput("Kadaluarsa", "DD/MM/YYYY",
                                    tanggalController),
                                dropdownSatuan(),
                                inputField("Stock Barang", "Stock Barang",
                                    jumlahBarang_text),
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
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: const BorderSide(
                                              color: ColorStyle.button_green,
                                              width: 1),
                                        ),
                                      ),
                                      child: const Text("KONFIRMASI",
                                          style: TextStyle(
                                              color: ColorStyle.button_green,
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

  void _updateProduk(
    StokOpnameData item,
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
      item.noKartu = nomorKartu.text;
      item.noBatch = nomorBatch.text;
      item.kode = kode.text;
      item.kategori = kategori.text;
      item.nama = namaObat.text;
      item.kadaluarsa = DateTime.parse(kadaluarsa.text);
      item.satuan = satuan.text;
      item.stok = int.tryParse(jumlah.text) ?? 0;
      item.catatan = caraPemakaian.text;
    });

    // Navigator.pop(context); // 🔹 Menutup dialog setelah menyimpan
    _alertDone("diedit"); // 🔹 Tampilkan alert bahwa produk telah diedit
  }

  void _editStockOpname(StokOpnameData item) {
    TextEditingController nomorKartuController =
        TextEditingController(text: item.noKartu);
    TextEditingController nomorBatchController =
        TextEditingController(text: item.noBatch);
    TextEditingController kodeController =
        TextEditingController(text: item.kode);
    TextEditingController kategoriController =
        TextEditingController(text: item.kategori);
    TextEditingController namaObatController =
        TextEditingController(text: item.nama);
    TextEditingController hargaControlller =
        TextEditingController(text: item.harga.toString());
    TextEditingController kadaluarsaController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(item.kadaluarsa));
    TextEditingController satuanController =
        TextEditingController(text: item.satuan);
    TextEditingController masukController =
        TextEditingController(text: item.masuk.toString());
    TextEditingController keluarController =
        TextEditingController(text: item.keluar.toString());
    TextEditingController hargaJualController =
        TextEditingController(text: item.hargaJual.toString());
    TextEditingController hargaBeliController =
        TextEditingController(text: item.hargaBeli.toString());
    TextEditingController uprateController =
        TextEditingController(text: item.uprate.toString());
    TextEditingController jumlahController =
        TextEditingController(text: item.stok.toString());
    TextEditingController caraPemakaianController =
        TextEditingController(text: item.catatan);
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
                            "Edit Stock Opname",
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
                                editFeld("Nomor Kartu", item.noKartu,
                                    nomorKartuController),
                                editFeld("Nomor Batch", item.noBatch,
                                    nomorBatchController),
                                editFeld(
                                    "Kode Obat", item.kode, kodeController),
                                editFeld(
                                    "Nama Obat", item.nama, namaObatController),
                                dropdownKategoriEdit(item.kategori),
                                // editFeld("Katgeori", item.kategori,
                                //     kategoriController),
                                editFeld("Harga", item.harga.toString(),
                                    hargaControlller),
                                editFeld(
                                    "Kadaluarsa",
                                    DateFormat('dd/MM/yyyy')
                                        .format(item.kadaluarsa),
                                    kadaluarsaController),
                                editFeld("Stock Obat", item.stok.toString(),
                                    jumlahController),
                                editFeld("Obat Masuk", item.masuk.toString(),
                                    masukController),
                                editFeld("Obat Keluar", item.keluar.toString(),
                                    keluarController),
                                dropdownSatuanEdit(item.satuan),
                                editFeld(
                                    "Harga Jual",
                                    item.hargaJual.toString(),
                                    hargaJualController),
                                editFeld(
                                    "Harga Beli",
                                    item.hargaBeli.toString(),
                                    hargaBeliController),
                                editFeld("Uprate", item.uprate.toString(),
                                    uprateController),
                                buildFormCaraPemakaian2("Cara Pmekaian",
                                    item.catatan, caraPemakaianController),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 8),
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
                                              item.noKartu =
                                                  nomorKartuController.text;
                                              item.noBatch =
                                                  nomorBatchController.text;
                                              item.kode = kodeController.text;
                                              item.kategori =
                                                  _selectedKategoriEdit ??
                                                      item.kategori;
                                              item.nama =
                                                  namaObatController.text;
                                              item.kadaluarsa =
                                                  DateFormat('dd/MM/yyyy')
                                                      .parse(
                                                          kadaluarsaController
                                                              .text);
                                              item.satuan =
                                                  _selectedSatuanEdit ??
                                                      item.satuan;
                                              item.stok = int.parse(
                                                  jumlahController.text);
                                              item.harga = double.parse(
                                                  hargaControlller.text);
                                              item.hargaJual = double.parse(
                                                  hargaJualController.text);
                                              item.hargaBeli = double.parse(
                                                  hargaBeliController.text);
                                              item.uprate = double.parse(
                                                  uprateController.text);
                                              item.catatan =
                                                  caraPemakaianController.text;
                                            });
                                            _alertDone("diedit");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: const BorderSide(
                                                  color:
                                                      ColorStyle.button_green,
                                                  width: 1),
                                            ),
                                          ),
                                          child: const Text("SIMPAN",
                                              style: TextStyle(
                                                  color:
                                                      ColorStyle.button_green,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

  void _modalKosongkanObat(StokOpnameData item) {
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
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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
                    SizedBox(height: 47),

                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 42, right: 42),
                              child: Text(
                                  "Alasan \"${item.nama}\" Kosongkan Obat",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 42, right: 42),
                              child: Container(
                                height: 150,
                                // decoration: BoxDecoration(
                                //   color: ColorStyle.fill_form,
                                //   border:
                                //       Border.all(color: ColorStyle.fill_stroke),
                                //   borderRadius: BorderRadius.circular(8),
                                // ),
                                // padding:
                                //     const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.topLeft,
                                child: TextFormField(
                                  controller: text2,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: ColorStyle.fill_form,
                                    hintText: "Alasan",
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
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: const BorderSide(
                                              color: ColorStyle.primary,
                                              width: 1),
                                        ),
                                      ),
                                      child: Text("KONFIRMASI",
                                          style: GoogleFonts.inter(
                                              color: ColorStyle.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
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

  void _alertDelete(StokOpnameData item) {
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
                        "Apakah Anda yakin \n mengosongkan \"${item.nama}\" ini?",
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
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: ColorStyle.button_red, width: 1),
                                  ),
                                ),
                                child: const Text(
                                  "Iya, hapus",
                                  style: TextStyle(
                                    color: ColorStyle.button_red,
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
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: ColorStyle.button_yellow,
                                        width: 1),
                                  ),
                                ),
                                child: const Text(
                                  "Iya, input",
                                  style: TextStyle(
                                    color: ColorStyle.button_yellow,
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

  int _rowsPerPage = 10;
  int _currentPage = 0;
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
          return item.nama.toLowerCase().contains(query.toLowerCase()) ||
              item.stok.toString().contains(query);
        }).toList();
      }
      _currentPage = 0; // Reset ke halaman pertama setelah filter
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filterData.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = (startIndex + _rowsPerPage).clamp(0, filterData.length);
    List<StokOpnameData> paginatedData =
        filterData.sublist(startIndex, endIndex);
    return Scaffold(
      appBar: NavbarTop(
          title: "EDIT DATA STOCK OPNAME",
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
                    global.selectedIndex = 1;
                    global.selectedScreen = 1;
                  });
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text("Kembali",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 25)),
              InputForm("Nomor Opname", "0977656", "Tanggal Stock Opname",
                  "21/01/2025", nomorOpname, tanggalOpname),
              InputForm("Jumlah Barang", "10", "Jumlah Update Stock", "10",
                  jumlahBarang, jumlahUpdate),
              Divider(),
              Container(
                height: 40,
                // width: 242,
                // decoration: BoxDecoration(
                //   border:
                //       Border.all(color: ColorStyle.fill_stroke, width: 1),
                //   color: ColorStyle.fill_form,
                //   borderRadius: BorderRadius.circular(4),
                // ),

                child: TextFormField(
                  controller: text,
                  onChanged: filtering,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: ColorStyle.fill_form,

                    // Menambahkan ikon di dalam TextField
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Icon(
                        Icons.search_outlined,
                        color: Color(0XFF1B1442),
                        size: 30, // Sesuaikan ukuran ikon
                      ),
                    ),

                    hintText: "Search",
                    contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),

                    hintStyle: TextStyle(
                      color: ColorStyle.text_hint,
                      fontSize: 16,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: ColorStyle.fill_stroke, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 25)),
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
                      SizedBox(
                        height: 16,
                      ),
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
                                        MaterialStateProperty.all(Colors.white),
                                    columnSpacing:
                                        80, // Menambah jarak antar kolom
                                    dataRowMinHeight:
                                        60, // Menambah tinggi minimum baris
                                    dataRowMaxHeight:
                                        60, // Menambah tinggi maksimum baris
                                    columns: [
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text('Nomor',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Nomer Obat',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Jumlah Stock',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text('Jumlah Barang Asli',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text('Keterangan',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      )),
                                    ],
                                    rows: paginatedData.map((item) {
                                      return DataRow(
                                        color: MaterialStateProperty.all(
                                            Colors.white),
                                        cells: [
                                          DataCell(Center(
                                            child: Text(item.noKartu,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                )),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              item.nama,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              item.kategori,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )),
                                          DataCell(Center(
                                              child: SizedBox(
                                            width: 100,
                                            height: 35,
                                            child: TextFormField(
                                              initialValue:
                                                  item.stok.toString(),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          )
                                              // child: Text(
                                              //   item.stok.toString(),
                                              //   textAlign: TextAlign.center,
                                              //   style: GoogleFonts.inter(
                                              //     color:
                                              //         ColorStyle.text_secondary,
                                              //     fontSize: 14,fontWeight: FontWeight.w400
                                              //   ),
                                              // ),
                                              )),
                                          DataCell(Center(
                                              child: SizedBox(
                                            width: 250,
                                            height: 35,
                                            child: TextFormField(
                                              initialValue:
                                                  item.catatan.toString(),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          )
                                              // child: Text(
                                              //   item.stok.toString(),
                                              //   textAlign: TextAlign.center,
                                              //   style: GoogleFonts.inter(
                                              //     color:
                                              //         ColorStyle.text_secondary,
                                              //     fontSize: 14,fontWeight: FontWeight.w400
                                              //   ),
                                              // ),
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
              Padding(padding: EdgeInsets.only(bottom: 4)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              width: 65, // Lebar dropdown harus sama dengan input
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
                  ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorStyle.hover,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "SIMPAN",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                      //         ElevatedButton(
                      //   onPressed: () {

                      //   },
                      //   const Text("Kembali",
                      //       style: TextStyle(color: Colors.white)),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.red,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(5),
                      //     ),
                      //     padding:
                      //         const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      //   ),
                      // ),
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
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
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
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ),
          )
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
                hintText: value,
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
            // decoration: BoxDecoration(
            //   color: ColorStyle.fill_form,
            //   border: Border.all(color: ColorStyle.fill_stroke),
            //   borderRadius: BorderRadius.circular(8),
            // ),
            // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            alignment: Alignment.topLeft,
            child: TextField(
              controller: text,
              style: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorStyle.fill_form,
                hintText: "Cara Pemakaian",
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
            // decoration: BoxDecoration(
            //   color: ColorStyle.fill_form,
            //   border: Border.all(color: ColorStyle.fill_stroke),
            //   borderRadius: BorderRadius.circular(8),
            // ),
            // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            alignment: Alignment.topLeft,
            child: TextField(
              controller: text,
              style: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorStyle.fill_form,
                hintText: "Cara Pemakaian",
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
              maxLines: 10,
              // biar turun kebawah
            ),
          ),
        ],
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
                              style: TextStyle(
                                  fontSize: 12, color: ColorStyle.text_hint),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                              style: TextStyle(
                                  fontSize: 12, color: ColorStyle.text_hint),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                              style: TextStyle(
                                  fontSize: 12, color: ColorStyle.text_hint),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                              style: TextStyle(
                                  fontSize: 12, color: ColorStyle.text_hint),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  Widget InputForm(String label1, String hint1, String label2, String hint2,
      TextEditingController edit, TextEditingController edit2) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label1,
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
                        // print(isi[0].text);
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
                        label2,
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
                      // SizedBox(width: 10),
                      // InkWell(
                      //   onTap: () {
                      //     onDelete;
                      //   },
                      //   child: Icon(Icons.delete_outline,
                      //       color: ColorStyle.button_red, size: 25),
                      // )
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
}
