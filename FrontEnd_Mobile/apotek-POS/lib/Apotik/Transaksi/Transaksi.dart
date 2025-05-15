import 'dart:io';
import 'dart:typed_data';
import 'package:apotek/Gudang/Produk/DataProduk.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:apotek/global.dart' as global;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart' as im;
import 'package:http/http.dart' as http;

class TransaksiPage extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const TransaksiPage(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<TransaksiPage> createState() => _TransaksiPage();
}

class _TransaksiPage extends State<TransaksiPage> {
  bool triggerAnimation = false; // Tambahkan variabel isExpanded

  // Ini buat listnya kalau kaetgori dana jumlah stock di filter
  List<Map<String, dynamic>> kategoriObatPick = [
    {"title": "Obat Panas", "isChecked": false},
    {"title": "Obat Flu", "isChecked": false},
    {"title": "Obat Batuk", "isChecked": false},
    {"title": "Suplemen", "isChecked": false},
    {"title": "Vitamin", "isChecked": false},
    {"title": "Antibiotik", "isChecked": false},
    {"title": "Antiseptik", "isChecked": false},
    {"title": "Obat Mata", "isChecked": false},
  ];
  bool isExpanded2 = false; // Untuk animasi memanjang ke bawah
  bool showMoreCategories = false;
  List<String> stockOptions = [">5", ">10", "<5", "<10"];
  String? selectedUnit;

  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  bool isExpanded = false;

  final List<String> rowKategori = ["Obat Panas", "Obat Batuk", "Obat Flu"];
  final List<String> rowSatuan = ["Strip", "Botol", "Pcs"];

  String? _selectedKategori;
  String? _selectedSatuan;
  KategoriObat? _selectedKategoriEdit;
  SatuanObat? _selectedSatuanEdit;

  KategoriObat? _pilihKategori;
  SatuanObat? _pilihSatuan;

  String? selectedSatuan;
  final TextEditingController minHargaController = TextEditingController();
  final TextEditingController maxHargaController = TextEditingController();

  final List<int> rowItems = [10, 25, 50, 100];
  String? _selectedStatus;
  final List<String> rowStatus = ["Habis", "Sisa"];

  String? selectedValue;
  bool isAscending = true; // Menyimpan status sorting

  var text = TextEditingController();
  var text2 = TextEditingController();
  var searchFilterKategori = TextEditingController();

  // Image picker
  im.ImagePicker picker = im.ImagePicker();
  File? pickedImage;
  bool uploadFile = false;
  Uint8List pickedImageByte = Uint8List(0);

  // image picker 2
  im.ImagePicker picker2 = im.ImagePicker();
  File? pickedImage2;
  bool uploadFile2 = false;
  Uint8List pickedImageByte2 = Uint8List(0);

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  List<Products> filterData = [];

  List<Products> listProduk = [];

  List<KategoriObat> listKategori = [];

  List<SatuanObat> listSatuan = [];

  bool _validasiTerisi = false;

  Future<void> getDataAPI() async {
    try {
      listProduk = await Products.getData();
      // print();
      setState(() {
        filterData = List.from(listProduk);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getDataSatuan() async {
    try {
      listSatuan = await SatuanObat.getDataSatuan();
      // print();
      // print("PPPPPPPPPPPPPPPPPPPPPPPP");
      // print(listSatuan[0]);
      setState(() {});
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getDataKategori() async {
    try {
      listKategori = await KategoriObat.getDataKategori();
      print("pppppppppppppp");
      print(listKategori.length);
      // print();
      setState(() {});
    } catch (e) {
      print("Error: $e");
    }
  }

  String? getNamaKategori(String idKategori) {
    try {
      return listKategori
          .firstWhere(
            (item) => item.idKategori == idKategori,
          )
          .nama;
    } catch (e) {
      return null; // jika tidak ditemukan
    }
  }

  KategoriObat? getNamaKategori2(String idKategori) {
    try {
      return listKategori.firstWhere(
        (item) => item.idKategori == idKategori,
      );
    } catch (e) {
      return null; // jika tidak ditemukan
    }
  }

  SatuanObat? getNamaSatuan2(String idSatuan) {
    try {
      return listSatuan.firstWhere(
        (item) => item.idSatuan == idSatuan,
      );
    } catch (e) {
      return null; // jika tidak ditemukan
    }
  }

  String? getNamaSatuan(String idSatuan) {
    try {
      return listSatuan
          .firstWhere(
            (item) => item.idSatuan == idSatuan,
          )
          .namaSatuan;
    } catch (e) {
      return null; // jika tidak ditemukan
    }
  }

  // isi data field

  final _formKey = GlobalKey<FormState>();

  var namaObat_text = TextEditingController();
  var keterangan_text = TextEditingController();
  var stokBarang_text = TextEditingController();
  var hargajual_text = TextEditingController();
  var hargaBeli_Text = TextEditingController();

  Future<void> postData() async {
    String url = "http://leap.crossnet.co.id:2688/product/create";
    var response = await http.MultipartRequest('POST', Uri.parse(url));
    response.headers.addAll(
        {'Authorization': '${global.token}', 'x-api-key': '${global.xApiKey}'});
    var imageInput = await http.MultipartFile.fromBytes(
        "image", pickedImageByte,
        filename: "test");
    // print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    // print(hargajual_text.text);

    // print(pickedImageByte.toString());
    response.files.add(imageInput);
    response.fields['nama_obat'] = namaObat_text.text;
    response.fields['id_satuan'] = _pilihSatuan!.idSatuan;
    response.fields['harga_jual'] = hargajual_text.text;
    response.fields['harga_beli'] = hargaBeli_Text.text;
    response.fields['stok_minimum'] = stokBarang_text.text;
    response.fields['keterangan'] = keterangan_text.text;
    response.fields['id_kategori'] = _pilihKategori!.idKategori;
    var menerimaResponse = await response.send();
    var body = await http.Response.fromStream(menerimaResponse);
    String stringbody = body.body;
    print(stringbody);
  }

  TextEditingController namaObatController = TextEditingController();
  TextEditingController hargaBeliController = TextEditingController();
  TextEditingController hargaJualController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController stockMinimumController = TextEditingController();
  var idObatPut;

  Future<void> putData(String id) async {
    String url = "http://leap.crossnet.co.id:2688/product/${id}/edit";
    var response = await http.MultipartRequest('POST', Uri.parse(url));
    response.headers.addAll(
        {'Authorization': '${global.token}', 'x-api-key': '${global.xApiKey}'});
    if (pickedImageByte2 != null) {
      var imageInput = await http.MultipartFile.fromBytes(
          "image", pickedImageByte2,
          filename: "test");
      response.files.add(imageInput);
    }
    response.fields['nama_obat'] = namaObatController.text;
    response.fields['id_satuan'] = _selectedSatuanEdit!.idSatuan;
    response.fields['harga_jual'] = hargaJualController.text;
    response.fields['harga_beli'] = hargaBeliController.text;
    response.fields['stok_minimum'] = stockMinimumController.text;
    response.fields['keterangan'] = keteranganController.text;
    response.fields['id_kategori'] = _selectedKategoriEdit!.idKategori;
    var menerimaResponse = await response.send();
    var body = await http.Response.fromStream(menerimaResponse);
    String stringbody = body.body;
    print("ini messagenya");
    print(stringbody);
    // }else{
    //   var response = await http.post(Uri.parse(url), headers: {
    //   'Authorization': '${global.token}',
    //   'x-api-key': '${global.xApiKey}'
    // }, body: {
    //   'nama_obat': namaObatController.text,
    //   'id_satuan': _selectedSatuanEdit!.idSatuan,
    //   'harga_jual' : hargaJualController.text,
    //   'harga_beli' : hargaBeliController.text,
    //   'stok_minimu' : stockMinimumController.text,
    //   'keterangan' : keteranganController.text,
    //   'id_kategori' :_selectedKategoriEdit!.idKategori,

    // });
  }

  var idObatDelete;

  Future<void> deleteData(String id) async {
    String url = "http://leap.crossnet.co.id:2688/product/${id}/delete";
    var response = await http.delete(Uri.parse(url), headers: {
      'Authorization': '${global.token}',
      'x-api-key': '${global.xApiKey}'
    }, body: {
      "keterangan_hapus": text2.text
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

  void filterByStatus(String status) {
    setState(() {
      if (status == "Habis") {
        filterData = listProduk.where((item) => item.stokMinimum == 0).toList();
      } else if (status == "Sisa") {
        filterData = listProduk
            .where((item) => item.stokMinimum > 0 && item.stokMinimum <= 10)
            .toList();
      } else {
        filterData =
            List.from(listProduk); // Tampilkan semua jika tidak ada filter
      }
    });
  }

  String formatRupiah(num number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  void _viewDetails(Products item) {
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
                            "Informasi Data Obat",
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
                                // detailField("Nomor Kartu", item.nomorKartu),
                                // detailField("Nomor Batch", item.nomorBatch),
                                // detailField("Kode", item.kode),
                                detailField("Nama Obat", item.namaObat),
                                detailField(
                                    "Kategori Obat",
                                    getNamaKategori(item.idKategori) ??
                                        "Tidak Ada"),
                                detailField(
                                    "Harga Beli", formatRupiah(item.hargaBeli)),
                                detailField(
                                    "Harga Jual", formatRupiah(item.hargaJual)),
                                detailField("Satuan", item.namaSatuan),
                                // detailField("Jumlah Barang", "null"),
                                detailField("Stock Minimum",
                                    item.stokMinimum.toString()),
                                detailImage(item.linkGambarObat),
                                detailField("Keterangan", item.keterangan),

                                // detailField(
                                //     "Kadaluarsa",
                                //     DateFormat('dd/MM/yyyy')
                                //         .format(item.kadaluarsa)),
                                // detailField("Satuan", item.satuan),
                                // detailField(
                                //     "Jumlah Barang", item.jumlah.toString()),
                                // inputImage(),
                                // buildFormCaraPemakaian(
                                //     "Cara Pemakaian", item.caraPemakaian)
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

  Future<void> _editProduk(Products item) async {
    String url = "http://leap.crossnet.co.id:2688/${item.linkGambarObat}";
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': '${global.token}',
      'x-api-key': '${global.xApiKey}'
    });
    print(response.bodyBytes);
    setState(() {
      _selectedKategoriEdit = getNamaKategori2(item.idKategori);
      _selectedSatuanEdit = getNamaSatuan2(item.idSatuan);
      namaObatController.text = item.namaObat.toString();
      hargaBeliController.text = item.hargaBeli.toString();
      hargaJualController.text = item.hargaJual.toString();
      stockMinimumController.text = item.stokMinimum.toString();
      keteranganController.text = item.keterangan.toString();
      idObatPut = item.idObat;
      pickedImageByte2 = response.bodyBytes;
      print(_selectedKategoriEdit!.idKategori);
    });

    // TextEditingController namaObatController =
    //     TextEditingController(text: item.namaObat);
    // TextEditingController hargaBeliController =
    //     TextEditingController(text: item.hargaBeli.toString());
    // TextEditingController hargaJualController =
    //     TextEditingController(text: item.hargaJual.toString());
    // TextEditingController keteraanganController =
    //     TextEditingController(text: item.keterangan);
    // TextEditingController stockMinimumController =
    //     TextEditingController(text: item.stokMinimum.toString());

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
                              "Edit Data Obat",
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // idKategori = item.idKategori,
                                    editFeld("Nama Obat", item.namaObat,
                                        namaObatController),
                                    dropdownKategoriEdit(
                                        getNamaKategori(item.idKategori) ??
                                            "Tidak ada"),
                                    editFeld(
                                        "Harga Beli",
                                        item.hargaBeli.toString(),
                                        hargaBeliController),
                                    editFeld(
                                        "Harga Jual",
                                        item.hargaJual.toString(),
                                        hargaJualController),
                                    dropdownSatuanEdit(item.namaSatuan),
                                    editFeld(
                                        "Stock Minimum",
                                        item.stokMinimum.toString(),
                                        stockMinimumController),
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
                                                style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                " *",
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        ColorStyle.button_red),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          InkWell(
                                            onTap: () async {
                                              final im.XFile? photos =
                                                  await picker2.pickImage(
                                                      source: im
                                                          .ImageSource.gallery);
                                              if (photos != null) {
                                                print(
                                                    "Berhasil pick photo edit");
                                                setState2(() {
                                                  pickedImage2 =
                                                      File(photos.path);
                                                  uploadFile2 = true;
                                                });
                                                pickedImageByte2 = await photos
                                                    .readAsBytes()
                                                    .whenComplete(() {
                                                  setState2(() {
                                                    uploadFile2 = true;
                                                  });
                                                });
                                              }
                                            },
                                            child: Container(
                                                width: double.infinity,
                                                height: 150,
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
                                                        child: uploadFile2 ==
                                                                true
                                                            ? Image.file(
                                                                pickedImage2!,
                                                                height:
                                                                    90, // Atur ukuran sesuai kebutuhan
                                                                width: 90,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Column(
                                                                children: [
                                                                  Image.memory(
                                                                    response
                                                                        .bodyBytes,
                                                                    height:
                                                                        80, // Atur ukuran sesuai kebutuhan
                                                                    width: 80,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(
                                                                          bottom:
                                                                              8)),
                                                                  Text(
                                                                    "Click to Upload",
                                                                    style: GoogleFonts.inter(
                                                                        color: ColorStyle
                                                                            .alert_ungu,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  )
                                                                ],
                                                              ),
                                                      ),
                                                    ))),
                                          ),
                                          Text(
                                            "Note:Gambar hanya bisa jpg, jpeg, png dan maksimal 2MB",
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),
                                    editFeldNonMandatory("Keterangan",
                                        item.keterangan, keteranganController),
                                    // tanggalEdit(
                                    //     "Kadaluarsa",
                                    //     DateFormat('dd/MM/yyyy')
                                    //         .format(item.kadaluarsa),
                                    //     kadaluarsaController),
                                    // dropdownSatuanEdit(item.satuan),
                                    // editFeld("Harga Beli", value, edit)
                                    // editFeld("Jumlah Barang",
                                    //     item.jumlah.toString(), jumlahController),
                                    // inputImage(),
                                    // buildFormCaraPemakaian2(
                                    //     "Cara Pemakaian",
                                    //     item.caraPemakaian,
                                    //     caraPemakaianController),
                                  ],
                                ),
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
                                          _validasiTerisi = true;
                                          if (_formKey.currentState!
                                              .validate()) {
                                            Navigator.pop(context);
                                            _alertInput(
                                                "put", "mengedit", "edit");
                                          }
                                          // Navigator.pop(context);
                                          // _alertDone(item, "diedit");
                                          // setState(() {
                                          //   _alertInput("put", "diedit", item.idObat);
                                          //   print(item.idObat);
                                          // 🔹 Ini yang memastikan UI diperbarui
                                          // item.nomorKartu =
                                          //     nomorKartuController.text;
                                          // item.nomorBatch =
                                          //     nomorBatchController.text;
                                          // item.kode = kodeController.text;
                                          // item.kategori =
                                          //     _selectedKategoriEdit ??
                                          //         item.kategori;
                                          // item.namaObat =
                                          //     namaObatController.text;
                                          // item.kadaluarsa =
                                          //     DateFormat('dd/MM/yyyy').parse(
                                          //         kadaluarsaController.text);
                                          // item.satuan = _selectedSatuanEdit ??
                                          //     item.satuan;
                                          // item.jumlah =
                                          //     int.parse(jumlahController.text);
                                          // item.caraPemakaian =
                                          //     caraPemakaianController.text;
                                          // }
                                          // );
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
                                        child: Text("SIMPAN",
                                            style: GoogleFonts.inter(
                                                color: ColorStyle.button_green,
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
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      inputField("Nama Obat", "Nama Obat",
                                          namaObat_text),
                                      dropdownKategori(),
                                      inputField("Harga Beli", "Harga Beli",
                                          hargaBeli_Text),
                                      inputField("Harga Jual", "Harga Jual",
                                          hargajual_text),
                                      dropdownSatuan(),
                                      inputField("Stock Minimum",
                                          "Stock Minimum", stokBarang_text),
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
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  " *",
                                                  style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: ColorStyle
                                                          .button_red),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            InkWell(
                                              onTap: () async {
                                                final im.XFile? photo =
                                                    await picker.pickImage(
                                                        source: im.ImageSource
                                                            .gallery);
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
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                    ),
                                                                    Padding(
                                                                        padding:
                                                                            EdgeInsets.only(bottom: 8)),
                                                                    Text(
                                                                      "Click to Upload",
                                                                      style: GoogleFonts.inter(
                                                                          color: ColorStyle
                                                                              .alert_ungu,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    )
                                                                  ],
                                                                ),
                                                        ),
                                                      ))),
                                            ),
                                            Text(
                                              "Note:Gambar hanya bisa jpg, jpeg, png dan maksimal 2MB",
                                              style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      inputFieldNonMandatory("Keterangan",
                                          "Keterangan", keterangan_text),
                                    ],
                                  ),
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
                                            _validasiTerisi = true;
                                            if (_formKey.currentState!
                                                .validate()) {
                                              Navigator.pop(context);
                                              _alertInput(
                                                  "post", "diinput", "input");
                                            }
                                            // Navigator.pop(context);
                                            // _alertDone(item, "diedit");
                                            // _alertInput();
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
                                                  color:
                                                      ColorStyle.button_green,
                                                  width: 1),
                                            ),
                                          ),
                                          child: Text("KONFIRMASI",
                                              style: GoogleFonts.inter(
                                                  color:
                                                      ColorStyle.button_green,
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

  void _modalKosongkanObat(Products item) {
    setState(() {
      idObatDelete = item.idObat;
    });
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
                                  "Alasan \"${item.namaObat}\" Kosongkan Obat :",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
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
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: ColorStyle.fill_form,
                                    hintText: "Alasan",
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
                                  const EdgeInsets.only(left: 42, right: 42),
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
                    SizedBox(height: 28.57),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _alertDelete(Products item) {
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
                                onPressed: () async {
                                  await deleteData(item.idObat);
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

  void _alertInput(String condition, String isi, String isi2) {
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
                        "Apakah Anda yakin akan \n ${isi} data ini?",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
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
                                child: Text(
                                  "Tidak",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: constraints.maxWidth * 0.15,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    if (condition == "post") {
                                      await postData();
                                      Navigator.pop(context);
                                      _alertDone("diinput");
                                    } else if (condition == "put") {
                                      await putData(idObatPut);
                                      Navigator.pop(context);
                                      _alertDone("diedit");
                                    }
                                  } catch (e) {
                                    print("Error saat simpan: $e");
                                    // tampilkan dialog error juga kalau perlu
                                  }
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
                                child: Text(
                                  "Iya, ${isi2}",
                                  style: GoogleFonts.inter(
                                    color: ColorStyle.button_yellow,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyHomePage()));
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
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
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
    getDataAPI();
    getDataKategori();
    getDataSatuan();
    filterData = List.from(listProduk);
  }

  void filtering(String query) {
    setState(() {
      if (query.isEmpty) {
        filterData = List.from(listProduk);
      } else {
        filterData = listProduk.where((item) {
          return item.idObat.toLowerCase().contains(query.toLowerCase()) ||
              item.namaObat.toLowerCase().contains(query.toLowerCase()) ||
              item.idKategori.toLowerCase().contains(query.toLowerCase()) ||
              item.stokMinimum
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
    List<Products> paginatedData = filterData.sublist(startIndex, endIndex);
    return Scaffold(
      // appBar: NavbarTop(
      //     title: "PRODUK",
      //     onMenuPressed: widget.toggleSidebar,
      //     isExpanded: widget.isExpanded,
      //     animationTrigger: onMenuPressed,
      //     animation: triggerAnimation),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                          contentPadding: EdgeInsets.only(bottom: 12.5),
                          hintStyle: GoogleFonts.notoSans(
                            color: ColorStyle.text_hint,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorStyle.fill_stroke, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
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
                      label: Text("Sort Ascending",
                          style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
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
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: ColorStyle.text_hint,
                              fontWeight: FontWeight.w400),
                        ),
                        items: rowStatus
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: ColorStyle.text_hint,
                                        fontWeight: FontWeight.w400),
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
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            // width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: ColorStyle.putih_background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text("Obat",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 100,
                            // width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: ColorStyle.putih_background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text("Racikan",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
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
                                  width: 65,
                                  offset: Offset(0,
                                      200), // Lebar dropdown harus sama dengan input
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
                                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                                      size: 20, color: Colors.black),
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
                  Text("Dugonggg")
                ],
              ),
              SizedBox(height: 15),
              Expanded(
                child: Container(
                  height: double.infinity,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          2, // Agar item 1 per baris (sesuai contoh gambar)
                      childAspectRatio: 2.7, // Lebih panjang secara horizontal
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: paginatedData.length,
                    shrinkWrap: true,
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
                                  child: Image.network(
                                    Uri.parse(
                                            "http://leap.crossnet.co.id:2688/${produk.linkGambarObat}")
                                        .toString(),
                                    headers: {
                                      'Authorization': '${global.token}',
                                      'x-api-key': '${global.xApiKey}'
                                    },
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "images/gambarObat.png",
                                        fit: BoxFit.cover,
                                      );
                                    },
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
                                                style: GoogleFonts.inter(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow
                                                    .ellipsis, // Nama panjang terpotong jika melebihi
                                              ),
                                            ),
                                            if (produk.stokMinimum <= 10)
                                              Container(
                                                width: 61,
                                                height: 20,
                                                alignment: Alignment.center,
                                                // padding:
                                                //     const EdgeInsets.symmetric(
                                                //         horizontal: 15,
                                                //         vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: produk.stokMinimum == 0
                                                      ? ColorStyle.button_red
                                                          .withOpacity(0.8)
                                                      : ColorStyle.button_yellow
                                                          .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  border: Border.all(
                                                    color: produk.stokMinimum ==
                                                            0
                                                        ? ColorStyle.button_red
                                                        : ColorStyle
                                                            .button_yellow,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  produk.stokMinimum == 0
                                                      ? "HABIS"
                                                      : "SISA",
                                                  style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                          ],
                                        ),
                                        Transform.translate(
                                          offset: Offset(0, -6),
                                          child: Text(
                                            produk.idObat,
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Stock: ${produk.stokMinimum} ${produk.namaSatuan}",
                                              style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                            // Status Stock: "Sisa" jika <= 10, "Habis" jika 0
                                            SizedBox(
                                              width: 100,
                                              // width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  backgroundColor:
                                                      ColorStyle.primary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                                child: Text("Tambah",
                                                    style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600)),
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
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                " *",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: edit,
            onChanged: (value) {
              if (_validasiTerisi == true) {
                _formKey.currentState?.validate();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Tidak boleh kosong";
              }
              return null;
            },
            style: GoogleFonts.inter(
                color: ColorStyle.tulisan_form,
                fontSize: 13,
                fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              isDense: true,
              hintText: isi,
              filled: true,
              fillColor: ColorStyle.fill_form,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              hintStyle: GoogleFonts.inter(
                  color: ColorStyle.tulisan_form,
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorStyle.fill_stroke, width: 1), // Warna abu-abu
                borderRadius: BorderRadius.circular(5),
              ),

              // Border saat ditekan (fokus)
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorStyle.button_red,
                    width: 1), // Warna biru saat fokus
                borderRadius: BorderRadius.circular(5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorStyle.button_red,
                    width: 1), // Warna biru saat fokus
                borderRadius: BorderRadius.circular(5),
              ),

              // Border saat error
            ),
          ),
        ],
      ),
    );
  }

  Widget inputFieldNonMandatory(
      String title, String isi, TextEditingController edit) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              // Text(
              //   " *",
              //   style: TextStyle(
              //       fontSize: 14,
              //       fontWeight: FontWeight.bold,
              //       color: ColorStyle.button_red),
              // ),
            ],
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: edit,
            onChanged: (value) {
              _formKey.currentState?.validate();
            },
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return "Tidak boleh kosong";
            //   }
            //   return null;
            // },
            style: GoogleFonts.inter(
                color: ColorStyle.tulisan_form,
                fontSize: 13,
                fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              isDense: true,
              hintText: isi,
              filled: true,
              fillColor: ColorStyle.fill_form,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              hintStyle: GoogleFonts.inter(
                  color: ColorStyle.tulisan_form,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: ColorStyle.fill_stroke, width: 1), // Warna abu-abu
                borderRadius: BorderRadius.circular(5),
              ),

              // Border saat ditekan (fokus)
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              // focusedErrorBorder: OutlineInputBorder(
              //   borderSide: BorderSide(
              //       color: ColorStyle.button_red,
              //       width: 1), // Warna biru saat fokus
              //   borderRadius: BorderRadius.circular(5),
              // ),
              // errorBorder: OutlineInputBorder(
              //   borderSide: BorderSide(
              //       color: ColorStyle.button_red,
              //       width: 1), // Warna biru saat fokus
              //   borderRadius: BorderRadius.circular(5),
              // ),

              // Border saat error
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
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                " *",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 35,
            // decoration: BoxDecoration(
            //   border: Border.all(color: ColorStyle.fill_stroke),
            //   color: ColorStyle.fill_form,
            //   borderRadius: BorderRadius.circular(8),
            // ),
            child: TextFormField(
              controller: edit,
              style: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                // hintText: value,
                filled: true,
                fillColor: ColorStyle.fill_form,
                contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 13,
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

  Widget editFeldNonMandatory(
      String title, String value, TextEditingController edit) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
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
            // decoration: BoxDecoration(
            //   border: Border.all(color: ColorStyle.fill_stroke),
            //   color: ColorStyle.fill_form,
            //   borderRadius: BorderRadius.circular(8),
            // ),
            child: TextField(
              controller: edit,
              style: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: value,
                filled: true,
                fillColor: ColorStyle.fill_form,
                contentPadding: EdgeInsets.only(left: 8, bottom: 12.5),
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 13,
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

  Widget detailImage(String image) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10.27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gambar Kategori Obat",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          SizedBox(height: 8),
          Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.network(
                          Uri.parse("http://leap.crossnet.co.id:2688/${image}")
                              .toString(),
                          headers: {
                            'Authorization': '${global.token}',
                            'x-api-key': '${global.xApiKey}'
                          },
                          height: 90,
                          width: 90,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox.shrink();
                          },
                        ),
                        // Image.asset(
                        //   "images/upload_pict.png",
                        //   height: 50,
                        //   width: 50,
                        // ),
                      ],
                    ),
                  ))),
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
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
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
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                " *",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownButtonFormField2<KategoriObat>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _pilihKategori,
                validator: (value) {
                  if (value == null) {
                    return "Silahkan Pilih Satuan";
                  }
                },
                hint: Text(
                  "Pilih Kategori Obat",
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ColorStyle.text_hint,
                      fontWeight: FontWeight.w400),
                ),
                items: listKategori
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.nama,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: ColorStyle.text_hint,
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  _formKey.currentState?.validate();
                  setState(() {
                    _pilihKategori = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

                // **Atur Tampilan Dropdown Menu**
                dropdownStyleData: DropdownStyleData(
                  width: constraints.maxWidth,
                  maxHeight: 150, // Ikuti lebar input field
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
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                " *",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownButtonFormField2<KategoriObat>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _selectedKategoriEdit,
                validator: (value) {
                  if (value == null) {
                    return "Silahkan Pilih Satuan";
                  }
                },
                hint: Text(
                  isi,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ColorStyle.text_hint,
                      fontWeight: FontWeight.w400),
                ),
                items: listKategori
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.nama,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: ColorStyle.text_hint,
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  _formKey.currentState?.validate();
                  setState(() {
                    _selectedKategoriEdit = value!;
                    print(value.idKategori);
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

                // **Atur Tampilan Dropdown Menu**
                dropdownStyleData: DropdownStyleData(
                  width: constraints.maxWidth,
                  maxHeight: 150, // Ikuti lebar input field
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
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                " *",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownButtonFormField2<SatuanObat>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _pilihSatuan,

                validator: (value) {
                  if (value == null) {
                    return "Silahkan Pilih Satuan";
                  }
                },
                hint: Text(
                  "Pilih Satuan",
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ColorStyle.text_hint,
                      fontWeight: FontWeight.w400),
                ),
                items: listSatuan
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.namaSatuan,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: ColorStyle.text_hint,
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  _formKey.currentState?.validate();
                  setState(() {
                    _pilihSatuan = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

                // **Atur Tampilan Dropdown Menu**
                dropdownStyleData: DropdownStyleData(
                  width: constraints.maxWidth,
                  maxHeight: 150, // Ikuti lebar input field
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget dropdownSatuanFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                  width: constraints.maxWidth,
                  maxHeight: 150, // Ikuti lebar input field
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
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                " *",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.button_red),
              ),
            ],
          ),
          SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownButtonFormField2<SatuanObat>(
                isExpanded: true, // Supaya input field tidak terpotong
                value: _selectedSatuanEdit,
                validator: (value) {
                  if (value == null) {
                    return "Silahkan Pilih Satuan";
                  }
                },
                hint: Text(
                  isi,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ColorStyle.text_hint,
                      fontWeight: FontWeight.w400),
                ),
                items: listSatuan
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.namaSatuan,
                            style: TextStyle(
                                fontSize: 13, color: ColorStyle.text_hint),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  _formKey.currentState?.validate();
                  setState(() {
                    _selectedSatuanEdit = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor: ColorStyle.fill_form,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.button_grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: ColorStyle.text_secondary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorStyle.button_red,
                        width: 1), // Warna biru saat fokus
                    borderRadius: BorderRadius.circular(5),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(bool cek) {
    return Positioned(
      top: 0,
      right: 0,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            left: BorderSide(
              color: ColorStyle.button_grey, // Warna border
              width: 1, // Ketebalan border
            ),
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.2), // Warna bayangan
          //     blurRadius: 10, // Blur bayangan
          //     spreadRadius: 2, // Penyebaran bayangan
          //     offset: Offset(0, 4), // Posisi bayangan (X, Y)
          //   ),
          // ],
        ),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 208,
        height: cek ? 550 : 0, // Memanjang ke bawah
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, color: Colors.black, size: 22),
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Text(
                      "Filter",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Divider(),
              // Kategori Obat
              Padding(
                padding: const EdgeInsets.only(left: 11, top: 7, bottom: 4),
                child: Text("Kategori Obat",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...kategoriObatPick.sublist(0, 4).map((item) {
                return CheckboxListTile(
                  // contentPadding: EdgeInsets.zero,
                  // visualDensity: VisualDensity.compact,
                  title: Text(item["title"]),
                  value: item["isChecked"],
                  onChanged: (value) {
                    setState(() {
                      item["isChecked"] = value!;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, // Checkbox di kiri
                  visualDensity: VisualDensity.compact, // Rapatkan elemen
                  activeColor:
                      ColorStyle.button_grey, // Warna checkbox saat aktif
                  checkColor: Colors.white, // Warna centang di dalam checkbox
                );
              }).toList(),

              // Tombol "Lainnya"
              GestureDetector(
                onTap: () {
                  setState(() {
                    showMoreCategories = !showMoreCategories;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 24.3),
                  child: Row(
                    children: [
                      Icon(showMoreCategories
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_right),
                      Padding(padding: EdgeInsets.only(right: 20)),
                      Text("Lainnya", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

              // Kategori tambahan
              if (showMoreCategories)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.3),
                  child: Expanded(
                    child: Container(
                      height: 35,
                      // width: 242,
                      // decoration: BoxDecoration(
                      //   border:
                      //       Border.all(color: ColorStyle.fill_stroke, width: 1),
                      //   color: ColorStyle.fill_form,
                      //   borderRadius: BorderRadius.circular(4),
                      // ),
                      child: TextField(
                        controller: searchFilterKategori,
                        // onChanged: filtering,
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
                              size: 25, // Sesuaikan ukuran ikon
                            ),
                          ),

                          hintText: "Search",
                          contentPadding:
                              EdgeInsets.only(bottom: 12.5, right: 8),
                          hintStyle: TextStyle(
                            color: ColorStyle.text_hint,
                            fontSize: 16,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorStyle.fill_stroke, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              Divider(),

              // Nomor Batch & Kadaluarsa
              Padding(
                padding: const EdgeInsets.all(4.5),
                child: _buildFilterOption("Nomor Batch"),
              ),
              Padding(
                padding: const EdgeInsets.all(4.5),
                child: _buildFilterOption("Kadaluarsa Obat"),
              ),

              Divider(),

              // Jumlah Stock
              Padding(
                padding: const EdgeInsets.only(left: 11, top: 7, bottom: 4),
                child: Text("Jumlah Stock",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              ...stockOptions.map((option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: false,
                  onChanged: (value) {},
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),

              Divider(),

              // Dropdown Satuan
              Padding(
                padding: const EdgeInsets.only(left: 11, top: 7, bottom: 4),
                child: Text("Satuan",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 11, top: 7, bottom: 4),
                child: dropdownSatuanFilter(),
              ),

              Divider(),

              // Batas Harga
              Padding(
                padding: const EdgeInsets.only(left: 11, top: 7, bottom: 4),
                child: Text("Batas Harga",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 11, top: 7, bottom: 4),
                    child: Container(
                      height: 35,
                      child: TextField(
                        controller: searchFilterKategori,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: ColorStyle.fill_form,
                          hintText: "Rp. Minimal",
                          contentPadding:
                              EdgeInsets.only(bottom: 12.5, right: 8, left: 8),
                          hintStyle: TextStyle(
                            color: ColorStyle.text_hint,
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorStyle.fill_stroke, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 11, top: 7, bottom: 4),
                    child: Container(
                      height: 35,
                      child: TextField(
                        controller: searchFilterKategori,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: ColorStyle.fill_form,
                          hintText: "Rp. Maximal",
                          contentPadding:
                              EdgeInsets.only(bottom: 12.5, right: 8, left: 8),
                          hintStyle: TextStyle(
                            color: ColorStyle.text_hint,
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorStyle.fill_stroke, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.filter_list),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
