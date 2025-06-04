import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:apotek/Apotik/Obat%20Racik/obatRacik.dart';
import 'package:apotek/Apotik/Transaksi/DataTransaksi.dart';
import 'package:apotek/Gudang/Produk/DataProduk.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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

  List<Widget> inputFormObat = [];

  List<TextEditingController> jumlahObatRacikan = [];
  List<TextEditingController> dosisRacikan = [];

  TextEditingController jumlahObatRacik = TextEditingController();
  ObatRacikModel? isiIdObat; // obat yg dipilih
  ObatRacikModel? isiIdObatEdit; // obat yg dipilih

  Future<void> tambahInputForm(
      void Function(void Function()) setDialogState2) async {
    // Obat? isiNama;
    TextEditingController hargaTotal = TextEditingController();
    TextEditingController kemasan = TextEditingController();
    TextEditingController jumlahObatRacik = TextEditingController();

    setState(() {
      // isi.add(isiNama);
      // isi2.add(nomorBatch);
      // isi3.add(jumlahBarang);
      // isi4.add(namaObat);
      // tanggal.add(tanggalInput);
      // int index = isi.length - 1;
      // inputBarang.add(
      //   InputForm(
      //     "Nama Obat",
      //     "Nama Obat",
      //     "Jumlah Barang yang Dipesan",
      //     "Jumlah Barang yang Dipesan",
      //     index,
      //     index == 0 ? null : () => hapusInputForm(index, setDialogState2),
      //   ),
      // );
    });
  }

  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  bool isExpanded = false;

  KategoriObat? _selectedKategoriEdit;

  KategoriObat? _pilihKategori;

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

  List<ProdukSemua> filterData = [];

  List<ProdukSemua> listProduk = [];

  List<ObatRacikModel> listObatRacik = [];

  List<SatuanObat> listSatuan = [];

  List<int> jumObatRacikTransaksi = [];
  List<String> dosisTransaksi = [];

  bool _validasiTerisi = false;

  ObatRacikModel? detailObatRacik;

  Future<void> getDetailObatRacik(ObatRacikModel id) async {
    try {
      ObatRacikModel.getDetailObatRacik(id.idObatRacik).then((value) {
        setState(() {
          detailObatRacik = value;
          for (var item in detailObatRacik!.bahan) {
            komposisiList.add(KomposisiInput(
                namaObat: item.namaObat.toString(),
                idObat: item.idObat.toString(),
                jumlahController: TextEditingController(),
                dosisController: TextEditingController()));
          }
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getDataAPI() async {
    try {
      listProduk = await ProdukSemua.getData();
      for (var item in listProduk) {
        int detail = await ProdukSemua.getDataStok(item.idObat);
        item.stokObatReal = detail;
      }
      // print();
      setState(() {
        filterData = List.from(listProduk);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  SatuanObat? isiSatuan;
  SatuanObat? isiSatuanEdit;

  var isiJumlah = TextEditingController();
  Future<void> getDataAPIObatRacik() async {
    try {
      ObatRacikModel.getDataObatRacik().then((value) {
        setState(() {
          listObatRacik = value;
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getDataAPISatuan() async {
    try {
      SatuanObat.getDataSatuan().then((value) {
        setState(() {
          listSatuan = value;
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // Untuk simpen data yag dimasukkan
  double hitungHargaperObat(int kuantitas, double hargaObat) {
    return kuantitas * hargaObat;
  }

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
    // response.fields['id_satuan'] = _pilihSatuan!.idSatuan;
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
    // response.fields['id_satuan'] = _selectedSatuanEdit!.idSatuan;
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

  void _viewDetails(ProdukSemua item) {
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
                                // detailField(
                                //     "Kategori Obat",
                                //     getNamaKategori(item.idKategori) ??
                                //         "Tidak Ada"),
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

  ObatRacikModel? getNamaObatRacik(String idKategori) {
    try {
      return listObatRacik.firstWhere(
        (item) => item.idObatRacik == idKategori,
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

  int? indexEdit; // untuk menyimpan index item yang sedang diedit

  TextEditingController jumlahObatRacikEdit = TextEditingController();
  Future<void> _editObatRacik(ObatRacik item, int index) async {
    indexEdit = index; // Simpan index data yang sedang diedit

    List<KomposisiInput> komposisiEdit = [];

    setState(() {
      isiIdObatEdit = getNamaObatRacik(item.idnamaRacik);
      isiSatuanEdit = getNamaSatuan2(item.idsatuan);
      jumlahObatRacikEdit.text = item.jumlah.toString();
      for (var i = 0; i < item.komposisi.length; i++) {
        komposisiEdit.add(KomposisiInput(
            namaObat: item.komposisi[i].namaObat,
            idObat: item.komposisi[i].idObat,
            jumlahController: TextEditingController(),
            dosisController: TextEditingController()));

        komposisiEdit[i].jumlahController.text =
            item.komposisi[i].jumlah.toString();

        komposisiEdit[i].dosisController.text =
            item.komposisi[i].dosis.toString();
      }
    });

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
                              "Edit Data Obat Racik",
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
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, top: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: ColorStyle.warna_form,
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorStyle.shadow
                                                  .withOpacity(0.25),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 1), // x dan y
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Nama Obat Racik",
                                                          style:
                                                              GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                        SizedBox(height: 6),
                                                        SizedBox(
                                                          // width:
                                                          //     80, // Sesuaikan lebar
                                                          // height:
                                                          //     40, // Untuk jaga tinggi agar konsisten
                                                          child: TextFormField(
                                                            // controller:
                                                            //     jumlahObatRacikEdit,
                                                            // keyboardType:
                                                            //     TextInputType
                                                            //         .number,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    14), // Font kecil
                                                            decoration:
                                                                InputDecoration(
                                                              isDense:
                                                                  true, // Mengurangi tinggi padding
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          8), // Padding minimal
                                                              hintText:
                                                                  isiIdObatEdit!
                                                                      .namaRacik
                                                                      .toString(),
                                                              hintStyle: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              enabledBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              focusedBorder:
                                                                  UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 1.5),
                                                              ),
                                                            ),
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Wajib isi';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 32,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Satuan",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      SizedBox(height: 6),
                                                      LayoutBuilder(
                                                        builder: (context,
                                                            constraints) {
                                                          return Container(
                                                            width: 100,
                                                            child:
                                                                DropdownButtonFormField2<
                                                                    SatuanObat>(
                                                              isExpanded: true,
                                                              value:
                                                                  isiSatuanEdit,
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                    null) {
                                                                  return "Silahkan Pilih Satuan";
                                                                }
                                                                return null;
                                                              },
                                                              hint: Text(
                                                                "Pilih Satuan",
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 13,
                                                                  color: ColorStyle
                                                                      .text_hint,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                              items: listSatuan!
                                                                  .map((e) =>
                                                                      DropdownMenuItem(
                                                                        value:
                                                                            e,
                                                                        child:
                                                                            Text(
                                                                          "${e.namaSatuan}",
                                                                          style:
                                                                              GoogleFonts.inter(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                ColorStyle.text_hint,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                              onChanged:
                                                                  (value) {
                                                                _formKey
                                                                    .currentState
                                                                    ?.validate();
                                                                setState(() {
                                                                  isiSatuan =
                                                                      value!;
                                                                });
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4), // tipis
                                                                hintStyle:
                                                                    GoogleFonts.inter(
                                                                        fontSize:
                                                                            13),
                                                                filled: false,
                                                                border:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.black),
                                                                ),
                                                                enabledBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.black),
                                                                ),
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1.5),
                                                                ),
                                                                errorBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: ColorStyle
                                                                          .button_red,
                                                                      width: 1),
                                                                ),
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                width: 100,
                                                                maxHeight: 200,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: ColorStyle
                                                                          .button_grey),
                                                                  color: ColorStyle
                                                                      .fill_form,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                              ),
                                                              menuItemStyleData:
                                                                  const MenuItemStyleData(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                              ),
                                                              iconStyleData:
                                                                  const IconStyleData(
                                                                icon: Icon(
                                                                    Icons
                                                                        .arrow_drop_down,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .black),
                                                                openMenuIcon: Icon(
                                                                    Icons
                                                                        .arrow_drop_up,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 32,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Jumlah",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      SizedBox(height: 6),
                                                      SizedBox(
                                                        width:
                                                            80, // Sesuaikan lebar
                                                        // height:
                                                        //     40, // Untuk jaga tinggi agar konsisten
                                                        child: TextFormField(
                                                          controller:
                                                              jumlahObatRacikEdit,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  14), // Font kecil
                                                          decoration:
                                                              InputDecoration(
                                                            isDense:
                                                                true, // Mengurangi tinggi padding
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        8), // Padding minimal
                                                            hintText: '0',
                                                            hintStyle: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey),
                                                            border:
                                                                UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            enabledBorder:
                                                                UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            focusedBorder:
                                                                UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.5),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Wajib isi';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "KOMPOSISI",
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                              SizedBox(
                                                height: 15.5,
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    komposisiEdit!.length ?? 0,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 20),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Nama Obat",
                                                                style: GoogleFonts.inter(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                              SizedBox(
                                                                  height: 6),
                                                              SizedBox(
                                                                // width: 100, // Sesuaikan lebar
                                                                // height:
                                                                //     40, // Untuk jaga tinggi agar konsisten
                                                                child:
                                                                    TextFormField(
                                                                  // onChanged: (value) =>
                                                                  //     komposisiList[index].namaObat = namaObat,
                                                                  readOnly:
                                                                      true,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14), // Font kecil
                                                                  decoration:
                                                                      InputDecoration(
                                                                    isDense:
                                                                        true, // Mengurangi tinggi padding
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            bottom:
                                                                                8), // Padding minimal
                                                                    hintText: komposisiEdit[
                                                                            index]
                                                                        .namaObat,
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey),
                                                                    border:
                                                                        UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black),
                                                                    ),
                                                                    enabledBorder:
                                                                        UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black),
                                                                    ),
                                                                    focusedBorder:
                                                                        UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .black,
                                                                          width:
                                                                              1.5),
                                                                    ),
                                                                  ),
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Wajib isi';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 32,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Jumlah",
                                                              style: GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            SizedBox(height: 6),
                                                            SizedBox(
                                                              width:
                                                                  100, // Sesuaikan lebar
                                                              // height:
                                                              //     40, // Untuk jaga tinggi agar konsisten
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    komposisiEdit[
                                                                            index]
                                                                        .jumlahController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14), // Font kecil
                                                                decoration:
                                                                    InputDecoration(
                                                                  isDense:
                                                                      true, // Mengurangi tinggi padding
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          bottom:
                                                                              8), // Padding minimal
                                                                  hintText: '0',
                                                                  hintStyle: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .grey),
                                                                  border:
                                                                      UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.black),
                                                                  ),
                                                                  enabledBorder:
                                                                      UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.black),
                                                                  ),
                                                                  focusedBorder:
                                                                      UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            1.5),
                                                                  ),
                                                                ),
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                          null ||
                                                                      value
                                                                          .isEmpty) {
                                                                    return 'Wajib isi';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 32,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Dosis",
                                                                style: GoogleFonts.inter(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                              SizedBox(
                                                                  height: 6),
                                                              SizedBox(
                                                                // width: 100, // Sesuaikan lebar
                                                                // height:
                                                                //     40, // Untuk jaga tinggi agar konsisten
                                                                child:
                                                                    TextFormField(
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  controller: komposisiEdit[
                                                                          index]
                                                                      .dosisController,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14), // Font kecil
                                                                  decoration:
                                                                      InputDecoration(
                                                                    isDense:
                                                                        true, // Mengurangi tinggi padding
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            bottom:
                                                                                8), // Padding minimal
                                                                    hintText:
                                                                        'Dosis',
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey),
                                                                    border:
                                                                        UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black),
                                                                    ),
                                                                    enabledBorder:
                                                                        UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black),
                                                                    ),
                                                                    focusedBorder:
                                                                        UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .black,
                                                                          width:
                                                                              1.5),
                                                                    ),
                                                                  ),
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Wajib isi';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            height: 35,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // Validasi
                                                if (komposisiEdit.isEmpty ||
                                                    isiIdObatEdit == null ||
                                                    isiSatuanEdit == null ||
                                                    jumlahObatRacikEdit
                                                        .text.isEmpty) {
                                                  // Tampilkan notifikasi / alert
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Harap lengkapi semua data racikan')),
                                                  );
                                                  return;
                                                }
                                                // Buat ObatRacik baru
                                                ObatRacik racikBaru = ObatRacik(
                                                  namaRacik:
                                                      isiIdObatEdit!.namaRacik,
                                                  satuan:
                                                      isiSatuanEdit!.namaSatuan,
                                                  idnamaRacik: isiIdObatEdit!
                                                      .idObatRacik,
                                                  idsatuan:
                                                      isiSatuanEdit!.idSatuan,
                                                  jumlah:
                                                      jumlahObatRacikEdit.text,
                                                  totalHarga: 0,
                                                  aturanPakai: "",
                                                  caraPakai: "",
                                                  keteranganPakai: "",
                                                  komposisi: [],
                                                );

// Tambahkan komposisi
                                                for (var i = 0;
                                                    i < komposisiEdit.length;
                                                    i++) {
                                                  racikBaru.komposisi
                                                      .add(KomposisiObat(
                                                    idObat:
                                                        komposisiEdit[i].idObat,
                                                    namaObat: komposisiEdit[i]
                                                        .namaObat,
                                                    jumlah: num.parse(
                                                        komposisiEdit[i]
                                                            .jumlahController
                                                            .text),
                                                    dosis: komposisiEdit[i]
                                                        .dosisController
                                                        .text,
                                                  ));
                                                }
                                                String temp =
                                                    '''{"kuantitas": ${item.jumlah},
"ingredients": [''';
                                                for (var i = 0;
                                                    i <
                                                        racikBaru
                                                            .komposisi.length;
                                                    i++) {
                                                  setState(() {
                                                    if (i ==
                                                        racikBaru.komposisi
                                                                .length -
                                                            1) {
                                                      temp = temp +
                                                          '{"id_obat": "${racikBaru.komposisi[i].idObat}","jumlah_decimal": ${racikBaru.komposisi[i].jumlah}}';
                                                    } else
                                                      temp = temp +
                                                          '{"id_obat": "${racikBaru.komposisi[i].idObat}","jumlah_decimal": ${racikBaru.komposisi[i].jumlah}},';
                                                  });
                                                }
                                                setState(() {
                                                  temp = temp + ']}';
                                                });
                                                print("TEST TEMP");
                                                print(temp);
                                                String url =
                                                    "http://leap.crossnet.co.id:2688/PoS/calculateharga";
                                                var response = await http.post(
                                                    Uri.parse(url),
                                                    headers: {
                                                      'Authorization':
                                                          '${global.token}',
                                                      'x-api-key':
                                                          '${global.xApiKey}',
                                                      "Content-Type":
                                                          "application/json" // Tambahkan ini juga!
                                                    },
                                                    body: temp);
                                                print(response.statusCode);
                                                print(response.body);
                                                if (response.statusCode ==
                                                    200) {
                                                  var jsonObject =
                                                      jsonDecode(response.body);
                                                  print(jsonObject);
                                                  // print('data: $data');
                                                  setState(() {
                                                    racikBaru.totalHarga =
                                                        jsonObject["data"]
                                                            ["total_harga"];
                                                  });
                                                } else {
                                                  throw Exception(
                                                      "Gagal Load Data Detail Obat Racik");
                                                }

                                                setState(() {
                                                  if (indexEdit != null) {
                                                    // Mode edit
                                                    daftarObatRacik[
                                                        indexEdit!] = racikBaru;
                                                    indexEdit = null;
                                                  } else {
                                                    // Mode tambah baru
                                                    daftarObatRacik
                                                        .add(racikBaru);
                                                  }

                                                  // // Reset form
                                                  // komposisiEdit.clear();
                                                  // isiIdObatEdit = null;
                                                  // isiSatuanEdit = null;
                                                  // jumlahObatRacikEdit.clear();
                                                });

                                                // Simpan ke daftar racikan
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                backgroundColor:
                                                    ColorStyle.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              child: Text(
                                                "SIMPAN",
                                                style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
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

  void _alertDelete(ProdukSemua item) {
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
                                  // _modalKosongkanObat(item);
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
    getDataAPIObatRacik();
    getDataAPISatuan();

    // if (isiIdObat!.idObatRacik != null) {
    //   setState(() {
    //     getDetailObatRacik();
    //   });
    // }

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

  void tambahJumlah(int index) {
    final oldItem = keranjang[index];
    final newItem = Item(
        idObat: oldItem.idObat,
        kuantitas: oldItem.kuantitas + 1,
        namaObat: oldItem.namaObat,
        aturanPakai: oldItem.aturanPakai,
        caraPakai: oldItem.caraPakai,
        hargaObat: oldItem.hargaObat,
        keteranganPakai: oldItem.keteranganPakai,
        jumlahObatReal: oldItem.jumlahObatReal);

    setState(() {
      keranjang[index] = newItem;
    });
  }

  void kurangJumlah(int index) {
    final oldItem = keranjang[index];

    if (oldItem.kuantitas > 1) {
      final newItem = Item(
          idObat: oldItem.idObat,
          kuantitas: oldItem.kuantitas - 1,
          aturanPakai: oldItem.aturanPakai,
          caraPakai: oldItem.caraPakai,
          hargaObat: oldItem.hargaObat,
          namaObat: oldItem.namaObat,
          keteranganPakai: oldItem.keteranganPakai,
          jumlahObatReal: oldItem.jumlahObatReal);

      setState(() {
        keranjang[index] = newItem;
      });
    } else if (oldItem.kuantitas == 1) {
      // Kalau kuantitas sekarang 1, kalau dikurang jadi 0 berarti hapus item
      setState(() {
        keranjang.removeAt(index);
      });
    }
  }

  // ISI LISTAN
  // List<ObatRacik> daftarObatRacik = [];
  List<KomposisiInput> komposisiList = [];
  void tambahKomposisi(String namaObat, String idObat) {
    setState(() {
      komposisiList.add(KomposisiInput(
          namaObat: namaObat,
          idObat: idObat,
          jumlahController: TextEditingController(),
          dosisController: TextEditingController()));
    });
  }

  double hitungTotalHarga(
    List<Item> keranjang,
  ) {
    return keranjang.fold(
        0, (total, item) => total + item.hargaObat * item.kuantitas);
  }

//  double hitungTotalHarga2(List<ObatRacik> obatRacik, ) {
//     return obatRacik.fold(
//         0, (total, item) => item.totalHarga.toDouble());
//   }
  double hitungTotalHarga2(List<ObatRacik> obatRacik) {
    double total = 0.0;
    for (var item in obatRacik) {
      total += item.totalHarga.toDouble();
    }
    return total;
  }

  bool pilihButton = true;

  @override
  Widget build(BuildContext context) {
    int totalPages = (filterData.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex =
        (startIndex + _rowsPerPage).clamp(0, filterData.length); // Batas aman
    List<ProdukSemua> paginatedData = filterData.sublist(startIndex, endIndex);
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
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  // width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        pilihButton = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: pilihButton
                                          ? ColorStyle.primary
                                          : ColorStyle.putih_background,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text("Obat",
                                        style: GoogleFonts.montserrat(
                                            color: pilihButton
                                                ? Colors.white
                                                : Colors.black,
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
                                    onPressed: () {
                                      setState(() {
                                        pilihButton = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: !pilihButton
                                          ? ColorStyle.primary
                                          : ColorStyle.putih_background,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text("Racikan",
                                        style: GoogleFonts.montserrat(
                                            color: !pilihButton
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        pilihButton
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    child: GridView.builder(
                                      padding: EdgeInsets.all(8),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisExtent:
                                            150, // ubah tinggi kotak
                                        childAspectRatio: 2.7,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: paginatedData.length,
                                      itemBuilder: (context, index) {
                                        var produk = paginatedData[index];
                                        return Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: Offset(0, 0),
                                                  blurRadius: 4,
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 59,
                                                  width: 59,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      Uri.parse(
                                                              "http://leap.crossnet.co.id:2688/${produk.linkGambarObat}")
                                                          .toString(),
                                                      headers: {
                                                        'Authorization':
                                                            '${global.token}',
                                                        'x-api-key':
                                                            '${global.xApiKey}'
                                                      },
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                            "images/gambarObat.png",
                                                            fit: BoxFit.cover);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              produk.namaObat,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          if (produk
                                                                  .stokObatReal! <=
                                                              10)
                                                            Container(
                                                              width: 61,
                                                              height: 20,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: produk
                                                                            .stokObatReal ==
                                                                        0
                                                                    ? ColorStyle
                                                                        .button_red
                                                                        .withOpacity(
                                                                            0.8)
                                                                    : ColorStyle
                                                                        .button_yellow
                                                                        .withOpacity(
                                                                            0.8),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            2),
                                                                border:
                                                                    Border.all(
                                                                  color: produk
                                                                              .stokObatReal ==
                                                                          0
                                                                      ? ColorStyle
                                                                          .button_red
                                                                      : ColorStyle
                                                                          .button_yellow,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                produk.stokObatReal ==
                                                                        0
                                                                    ? "HABIS"
                                                                    : "SISA",
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 13,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      Text(
                                                        produk.idObat,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: 100,
                                                            child: Text(
                                                              "Stock: ${produk.stokObatReal} ${produk.namaSatuan}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          ),

                                                          // SizedBox(
                                                          //   width: 100,
                                                          //   child: ElevatedButton(
                                                          //     onPressed: () {},
                                                          //     style: ElevatedButton
                                                          //         .styleFrom(
                                                          //       padding: const EdgeInsets
                                                          //           .symmetric(
                                                          //           vertical: 12),
                                                          //       backgroundColor:
                                                          //           ColorStyle.primary,
                                                          //       shape:
                                                          //           RoundedRectangleBorder(
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(4),
                                                          //       ),
                                                          //     ),
                                                          //     child: Text("Tambah",
                                                          //         style:
                                                          //             GoogleFonts.inter(
                                                          //                 color: Colors
                                                          //                     .white,
                                                          //                 fontWeight:
                                                          //                     FontWeight
                                                          //                         .w600)),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      produk.stokObatReal! > 0
                                                          ? SizedBox(
                                                              width: 100,
                                                              height: 35,
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  final selected =
                                                                      Item(
                                                                    idObat: produk
                                                                        .idObat,
                                                                    kuantitas:
                                                                        1,
                                                                    aturanPakai:
                                                                        "",
                                                                    caraPakai:
                                                                        "",
                                                                    keteranganPakai:
                                                                        "",
                                                                    namaObat: produk
                                                                        .namaObat,
                                                                    hargaObat:
                                                                        produk
                                                                            .hargaJual,
                                                                    jumlahObatReal:
                                                                        produk.stokObatReal ??
                                                                            0,
                                                                  );
                                                                  setState(() {
                                                                    keranjang.add(
                                                                        selected);
                                                                  });
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          5),
                                                                  backgroundColor:
                                                                      ColorStyle
                                                                          .primary,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(4),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  "Tambah",
                                                                  style: GoogleFonts.inter(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox
                                                              .shrink(), // <- Tidak tampil sama sekali jika stok 0
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("Rows per page:",
                                          style: TextStyle(
                                              color: ColorStyle.text_hint,
                                              fontSize: 14)),
                                      Padding(
                                          padding: EdgeInsets.only(right: 8)),
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
                                                            color: ColorStyle
                                                                .text_hint),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                  EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                              constraints:
                                                  BoxConstraints(maxHeight: 30),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5), // Border radius halus
                                                borderSide: BorderSide(
                                                    color:
                                                        ColorStyle.button_grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                borderSide: BorderSide(
                                                    color: ColorStyle
                                                        .text_secondary), // Saat aktif, border lebih gelap
                                              ),
                                            ),

                                            // **Atur Tampilan Dropdown**
                                            buttonStyleData: ButtonStyleData(
                                              height:
                                                  25, // Tinggi tombol dropdown
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      6), // Jarak dalam dropdown
                                            ),

                                            // **Atur Tampilan Dropdown yang Muncul**
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              width: 65,
                                              offset: Offset(0,
                                                  200), // Lebar dropdown harus sama dengan input
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color:
                                                        ColorStyle.button_grey),
                                                color: Colors.white,
                                              ),
                                            ),

                                            // **Atur Posisi Item Dropdown**
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      8), // Padding antar item dropdown
                                            ),

                                            // **Ganti Icon Dropdown**
                                            iconStyleData: IconStyleData(
                                              icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_outlined,
                                                  size: 20,
                                                  color: Colors.black),
                                              openMenuIcon: Icon(
                                                  Icons
                                                      .keyboard_arrow_up_outlined,
                                                  size: 20,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 8)),
                                      Text(
                                          "Page $endIndex of ${filterData.length}",
                                          style: TextStyle(
                                              color: ColorStyle.text_hint,
                                              fontSize: 14)),
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
                                            onPressed:
                                                _currentPage < totalPages - 1
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
                              )
                            : SizedBox(
                                // ISIAN OBAT RACIK
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: ColorStyle.warna_form,
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorStyle.shadow
                                                  .withOpacity(0.25),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 1), // x dan y
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Nama Racik",
                                                          style:
                                                              GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                        SizedBox(height: 6),
                                                        LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                            return Container(
                                                              // width: 300,
                                                              child: DropdownButtonFormField2<
                                                                  ObatRacikModel>(
                                                                isExpanded:
                                                                    true,
                                                                value:
                                                                    isiIdObat,
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                      null) {
                                                                    return "Silahkan Pilih Nama Racik";
                                                                  }
                                                                  return null;
                                                                },
                                                                hint: Text(
                                                                  "Pilih Nama Racik",
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        13,
                                                                    color: ColorStyle
                                                                        .text_hint,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                items:
                                                                    listObatRacik!
                                                                        .map((e) =>
                                                                            DropdownMenuItem(
                                                                              value: e,
                                                                              child: Text(
                                                                                "${e.namaRacik}",
                                                                                style: GoogleFonts.inter(
                                                                                  fontSize: 13,
                                                                                  color: ColorStyle.text_hint,
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ))
                                                                        .toList(),
                                                                onChanged:
                                                                    (value) {
                                                                  _formKey
                                                                      .currentState
                                                                      ?.validate();
                                                                  setState(() {
                                                                    isiIdObat =
                                                                        value!;
                                                                    getDetailObatRacik(
                                                                        value);
                                                                  });
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  isDense: true,
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              4), // tipis
                                                                  hintStyle:
                                                                      GoogleFonts.inter(
                                                                          fontSize:
                                                                              13),
                                                                  filled: false,
                                                                  border:
                                                                      UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.black),
                                                                  ),
                                                                  enabledBorder:
                                                                      UnderlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.black),
                                                                  ),
                                                                  focusedBorder:
                                                                      UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            1.5),
                                                                  ),
                                                                  errorBorder:
                                                                      UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: ColorStyle
                                                                            .button_red,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                ),
                                                                dropdownStyleData:
                                                                    DropdownStyleData(
                                                                  // width: 300,
                                                                  maxHeight:
                                                                      200,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: ColorStyle
                                                                            .button_grey),
                                                                    color: ColorStyle
                                                                        .fill_form,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(4),
                                                                  ),
                                                                ),
                                                                menuItemStyleData:
                                                                    const MenuItemStyleData(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4),
                                                                ),
                                                                iconStyleData:
                                                                    const IconStyleData(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .arrow_drop_down,
                                                                      size: 16,
                                                                      color: Colors
                                                                          .black),
                                                                  openMenuIcon: Icon(
                                                                      Icons
                                                                          .arrow_drop_up,
                                                                      size: 16,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 32,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Satuan",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      SizedBox(height: 6),
                                                      LayoutBuilder(
                                                        builder: (context,
                                                            constraints) {
                                                          return Container(
                                                            width: 100,
                                                            child:
                                                                DropdownButtonFormField2<
                                                                    SatuanObat>(
                                                              isExpanded: true,
                                                              value: isiSatuan,
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                    null) {
                                                                  return "Silahkan Pilih Satuan";
                                                                }
                                                                return null;
                                                              },
                                                              hint: Text(
                                                                "Pilih Satuan",
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 13,
                                                                  color: ColorStyle
                                                                      .text_hint,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                              items: listSatuan!
                                                                  .map((e) =>
                                                                      DropdownMenuItem(
                                                                        value:
                                                                            e,
                                                                        child:
                                                                            Text(
                                                                          "${e.namaSatuan}",
                                                                          style:
                                                                              GoogleFonts.inter(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                ColorStyle.text_hint,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                              onChanged:
                                                                  (value) {
                                                                _formKey
                                                                    .currentState
                                                                    ?.validate();
                                                                setState(() {
                                                                  isiSatuan =
                                                                      value!;
                                                                });
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4), // tipis
                                                                hintStyle:
                                                                    GoogleFonts.inter(
                                                                        fontSize:
                                                                            13),
                                                                filled: false,
                                                                border:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.black),
                                                                ),
                                                                enabledBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.black),
                                                                ),
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1.5),
                                                                ),
                                                                errorBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: ColorStyle
                                                                          .button_red,
                                                                      width: 1),
                                                                ),
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                width: 100,
                                                                maxHeight: 200,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: ColorStyle
                                                                          .button_grey),
                                                                  color: ColorStyle
                                                                      .fill_form,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                              ),
                                                              menuItemStyleData:
                                                                  const MenuItemStyleData(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                              ),
                                                              iconStyleData:
                                                                  const IconStyleData(
                                                                icon: Icon(
                                                                    Icons
                                                                        .arrow_drop_down,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .black),
                                                                openMenuIcon: Icon(
                                                                    Icons
                                                                        .arrow_drop_up,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 32,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Jumlah",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      SizedBox(height: 6),
                                                      SizedBox(
                                                        width:
                                                            80, // Sesuaikan lebar
                                                        // height:
                                                        //     40, // Untuk jaga tinggi agar konsisten
                                                        child: TextFormField(
                                                          controller: isiJumlah,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  14), // Font kecil
                                                          decoration:
                                                              InputDecoration(
                                                            isDense:
                                                                true, // Mengurangi tinggi padding
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        8), // Padding minimal
                                                            hintText: '0',
                                                            hintStyle: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey),
                                                            border:
                                                                UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            enabledBorder:
                                                                UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            focusedBorder:
                                                                UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.5),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Wajib isi';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "KOMPOSISI",
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                              SizedBox(
                                                height: 15.5,
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: detailObatRacik
                                                        ?.bahan!.length ??
                                                    0,
                                                itemBuilder: (context, index) {
                                                  final item = detailObatRacik!
                                                      .bahan[index];
                                                  return listInputDataObatRacik(
                                                      index, item.namaObat);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            height: 35,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // Validasi
                                                if (komposisiList.isEmpty ||
                                                    isiIdObat == null ||
                                                    isiSatuan == null ||
                                                    isiJumlah.text.isEmpty) {
                                                  // Tampilkan notifikasi / alert
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Harap lengkapi semua data racikan')),
                                                  );
                                                  return;
                                                }
                                                ObatRacik racikBaru = ObatRacik(
                                                    namaRacik:
                                                        isiIdObat!.namaRacik,
                                                    satuan:
                                                        isiSatuan!.namaSatuan,
                                                    idnamaRacik:
                                                        isiIdObat!.idObatRacik,
                                                    idsatuan:
                                                        isiSatuan!.idSatuan,
                                                    jumlah: isiJumlah.text,
                                                    totalHarga: 0,
                                                    aturanPakai: "",
                                                    caraPakai: "",
                                                    keteranganPakai: "",
                                                    komposisi: []); // copy list
                                                for (var i = 0;
                                                    i < komposisiList.length;
                                                    i++) {
                                                  setState(() {
                                                    racikBaru.komposisi.add(
                                                        KomposisiObat(
                                                            idObat:
                                                                komposisiList[i]
                                                                    .idObat,
                                                            namaObat:
                                                                komposisiList[i]
                                                                    .namaObat,
                                                            jumlah: num.parse(
                                                                komposisiList[i]
                                                                    .jumlahController
                                                                    .text),
                                                            dosis: komposisiList[
                                                                    i]
                                                                .dosisController
                                                                .text));
                                                  });
                                                }
                                                setState(() {
                                                  daftarObatRacik
                                                      .add(racikBaru);
                                                  komposisiList
                                                      .clear(); // reset komposisi
                                                  detailObatRacik!.bahan
                                                      .clear();
                                                  isiIdObat = null;
                                                  isiSatuan = null;
                                                  isiJumlah.clear();
                                                });

                                                String temp =
                                                    '''{"kuantitas": ${racikBaru.jumlah},
"ingredients": [''';
                                                for (var i = 0;
                                                    i <
                                                        racikBaru
                                                            .komposisi.length;
                                                    i++) {
                                                  setState(() {
                                                    if (i ==
                                                        racikBaru.komposisi
                                                                .length -
                                                            1) {
                                                      temp = temp +
                                                          '{"id_obat": "${racikBaru.komposisi[i].idObat}","jumlah_decimal": ${racikBaru.komposisi[i].jumlah}}';
                                                    } else
                                                      temp = temp +
                                                          '{"id_obat": "${racikBaru.komposisi[i].idObat}","jumlah_decimal": ${racikBaru.komposisi[i].jumlah}},';
                                                  });
                                                }
                                                setState(() {
                                                  temp = temp + ']}';
                                                });
                                                print("TEST TEMP");
                                                print(temp);
                                                String url =
                                                    "http://leap.crossnet.co.id:2688/PoS/calculateharga";
                                                var response = await http.post(
                                                    Uri.parse(url),
                                                    headers: {
                                                      'Authorization':
                                                          '${global.token}',
                                                      'x-api-key':
                                                          '${global.xApiKey}',
                                                      "Content-Type":
                                                          "application/json" // Tambahkan ini juga!
                                                    },
                                                    body: temp);
                                                print(response.statusCode);
                                                print(response.body);
                                                if (response.statusCode ==
                                                    200) {
                                                  var jsonObject =
                                                      jsonDecode(response.body);
                                                  print(jsonObject);
                                                  // print('data: $data');
                                                  setState(() {
                                                    racikBaru.totalHarga =
                                                        jsonObject["data"]
                                                            ["total_harga"];
                                                  });
                                                } else {
                                                  throw Exception(
                                                      "Gagal Load Data Detail Obat Racik");
                                                }

                                                // Simpan ke daftar racikan
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                backgroundColor:
                                                    ColorStyle.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              child: Text(
                                                "Tambah",
                                                style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: ColorStyle.shadow.withOpacity(0.25),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: Offset(0, 1))
                            ],
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kwintansi Obat",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500, fontSize: 20),
                            ),
                            SizedBox(
                              height: 19,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          ColorStyle.shadow.withOpacity(0.25),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 1))
                                ],
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                width: MediaQuery.of(context).size.width *
                                    0.47, // Lebih lebar
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: constraints.maxWidth,
                                          ),
                                          child: DataTable(
                                            columnSpacing: 24,
                                            columns: [
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text("Nama Obat",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text("Jumlah",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text("Harga",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                            ],
                                            rows: keranjang
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              final item = entry.value;
                                              return DataRow(
                                                cells: [
                                                  DataCell(Expanded(
                                                      child: Center(
                                                          child: Text(
                                                    item.namaObat,
                                                    textAlign: TextAlign.center,
                                                  )))),
                                                  DataCell(Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons
                                                            .remove_circle_outline),
                                                        onPressed: () =>
                                                            kurangJumlah(index),
                                                      ),
                                                      Text(item.kuantitas
                                                          .toString()),
                                                      IconButton(
                                                        icon: const Icon(Icons
                                                            .add_circle_outline),
                                                        onPressed: item
                                                                    .kuantitas <
                                                                item
                                                                    .jumlahObatReal
                                                            ? () =>
                                                                tambahJumlah(
                                                                    index)
                                                            : null,
                                                      ),
                                                    ],
                                                  )),
                                                  DataCell(Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        "${formatRupiah(hitungHargaperObat(item.kuantitas, item.hargaObat))},00",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
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
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          ColorStyle.shadow.withOpacity(0.25),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 1))
                                ],
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.20,
                                width: MediaQuery.of(context).size.width *
                                    0.47, // Lebih lebar
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: constraints.maxWidth,
                                          ),
                                          child: DataTable(
                                            columnSpacing: 24,
                                            columns: [
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text("Nama Obat Racik",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text("Jumlah",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text("Harga",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text("Action",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                            ],
                                            rows: daftarObatRacik
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              final item = entry.value;
                                              return DataRow(
                                                cells: [
                                                  DataCell(Expanded(
                                                      child: Center(
                                                          child: InkWell(
                                                    onTap: () {
                                                      _editObatRacik(
                                                          item, index);
                                                    },
                                                    child: Text(
                                                      item.namaRacik,
                                                      style: GoogleFonts.inder(
                                                        color: Colors
                                                            .blue, // Sesuaikan dengan ColorStyle.text_secondary jika perlu
                                                        // fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )))),
                                                  DataCell(Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      // IconButton(
                                                      //   icon: const Icon(Icons
                                                      //       .remove_circle_outline),
                                                      //   onPressed: () =>
                                                      //       kurangJumlah(index),
                                                      // ),
                                                      Text(item.jumlah
                                                          .toString()),
                                                      // IconButton(
                                                      //   icon: const Icon(Icons
                                                      //       .add_circle_outline),
                                                      //   onPressed: item
                                                      //               .kuantitas <
                                                      //           item
                                                      //               .jumlahObatReal
                                                      //       ? () =>
                                                      //           tambahJumlah(
                                                      //               index)
                                                      //       : null,
                                                      // ),
                                                    ],
                                                  )),
                                                  DataCell(Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        "${formatRupiah(item.totalHarga)},00",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                      child: InkWell(
                                                    child: Icon(Icons.delete),
                                                    onTap: () {
                                                      setState(() {
                                                        daftarObatRacik
                                                            .removeAt(index);
                                                      });
                                                    },
                                                  ))),
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
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Total Harga",
                                        style: GoogleFonts.inter(fontSize: 18)),
                                    Text(
                                      "${formatRupiah(hitungTotalHarga(keranjang) + hitungTotalHarga2(daftarObatRacik))},00",
                                      style: GoogleFonts.inter(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ColorStyle.hover.withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    global.selectedIndex =
                                        3; // ini halaman yang ditampilkan
                                    global.selectedScreen =
                                        0; // ini di sidebarnya
                                  });
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Centering content
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Selanjutnya",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listInputDataObatRacik(int index, String namaObat) {
    final item = komposisiList[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nama Obat",
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                SizedBox(
                  // width: 100, // Sesuaikan lebar
                  // height:
                  //     40, // Untuk jaga tinggi agar konsisten
                  child: TextFormField(
                    // onChanged: (value) =>
                    //     komposisiList[index].namaObat = namaObat,
                    readOnly: true,
                    style: TextStyle(fontSize: 14), // Font kecil
                    decoration: InputDecoration(
                      isDense: true, // Mengurangi tinggi padding
                      contentPadding:
                          EdgeInsets.only(bottom: 8), // Padding minimal
                      hintText: namaObat,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib isi';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 32,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jumlah",
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: 100, // Sesuaikan lebar
                // height:
                //     40, // Untuk jaga tinggi agar konsisten
                child: TextFormField(
                  controller: item.jumlahController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14), // Font kecil
                  decoration: InputDecoration(
                    isDense: true, // Mengurangi tinggi padding
                    contentPadding:
                        EdgeInsets.only(bottom: 8), // Padding minimal
                    hintText: '0',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib isi';
                    }
                    return null;
                  },
                ),
              )
            ],
          ),
          SizedBox(
            width: 32,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dosis",
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                SizedBox(
                  // width: 100, // Sesuaikan lebar
                  // height:
                  //     40, // Untuk jaga tinggi agar konsisten
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: item.dosisController,
                    style: TextStyle(fontSize: 14), // Font kecil
                    decoration: InputDecoration(
                      isDense: true, // Mengurangi tinggi padding
                      contentPadding:
                          EdgeInsets.only(bottom: 8), // Padding minimal
                      hintText: 'Dosis',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib isi';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          )
        ],
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
}
