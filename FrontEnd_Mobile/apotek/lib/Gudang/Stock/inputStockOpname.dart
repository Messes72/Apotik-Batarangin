import 'dart:convert';

import 'package:apotek/Gudang/Stock/DataStockOpname.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/global.dart';
import 'package:apotek/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:apotek/global.dart' as global;

class Inputstockopname extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const Inputstockopname(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<Inputstockopname> createState() => inputStock();
}

class inputStock extends State<Inputstockopname> {
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
  List<StockOpnameList> filterData = [];
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

  List<StockOpnameList> _data = [];
  bool loadingData = false;

  List<SpesifikBatch> spesifikBatch = [];
  late String tanggalHariIni;
  Future<void> postStockOpname() async {
  String url = "http://leap.crossnet.co.id:2688/stokopname/create";

  String temp = '''{
  "id_depo": "20",
  "tanggal_stok_opname": "${tanggalHariIni}",
  "catatan": "${catatan.text}",
  "items": [''';

  for (var i = 0; i < _data.length; i++) {
    temp += '''
    {
      "id_kartustok": "${_data[i].idKartustok}",
      "batches": [''';

    for (var j = 0; j < _data[i].batches.length; j++) {
      final batch = _data[i].batches[j];
      final jumlah = batch.jumlah.text.trim();
      final keterangan = batch.keterangan.text.trim();

      temp += '''
        {
          "id_nomor_batch": "${batch.idNomorBatch}",
          "kuantitas_fisik": ${jumlah.isEmpty ? 0 : jumlah},
          "catatan": "${keterangan.replaceAll('"', '\\"')}"
        }''';

      // Tambahkan koma jika bukan item terakhir
      if (j != _data[i].batches.length - 1) {
        temp += ',';
      }
    }

    temp += ']';

    // Tambahkan koma antar item jika bukan yang terakhir
    temp += (i == _data.length - 1) ? '}' : '},';
  }

  temp += ']}';

  print("Final JSON:\n$temp");

  var response = await http.post(
    Uri.parse(url),
    headers: {
      "Authorization": token,
      "x-api-key": xApiKey,
      "Content-Type": "application/json"
    },
    body: temp,
  );

  if (response.statusCode == 200) {
    print("✅ Sukses mengirim input penerimaan");
  } else {
    print("❌ Gagal: ${response.statusCode}");
    print(response.body);
  }
}


  Future<void> getListStockOpname() async {
    try {
      setState(() => loadingData = true); // Mulai loading

      StockOpnameList.fetchObatList().then((value) {
        // if (!mounted) return; // ⛑️ Hindari error jika widget sudah disposed
        setState(() {
          _data = value;
          filterData = List.from(_data);
          loadingData = false;
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> getnamaBatch(String id) async {
  //   try {
  //     setState(() => loadingData = true); // Mulai loading

  //     SpesifikBatch.getData(id).then((value) {
  //       // if (!mounted) return; // ⛑️ Hindari error jika widget sudah disposed
  //       setState(() {
  //         spesifikBatch = value;
  //         loadingData = false;
  //       });
  //     });
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

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

  void _alertInput2(String condition, String isi, String isi2) {
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
                                      await postStockOpname();
                                      Navigator.pop(context);
                                      _alertDone(context,"diinput");
                                      setState(() {
                                        global.selectedIndex = 1;
                                        global.selectedScreen = 1;
                                      });
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MyHomePage()));
                                    }
                                    // else if (condition == "put") {
                                    //   await putData(idObatPut);
                                    //   Navigator.pop(context);
                                    //   _alertDone("diedit");
                                    // }
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

  var catatan = TextEditingController();

  List<TextEditingController> jumlah_fisik = [];
  List<TextEditingController> keterangan_fisik = [];

  void _inputDataUpdate(StockOpnameList item) {
    // setState(() {

    // });
    showDialog(
      context: context,
      builder: (context) {
        bool dataLoaded =
            false; // ⬅️ FLAG untuk memastikan hanya panggil data sekali
        bool loading = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        color: ColorStyle.alert_ungu,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 23),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Input Data Stock Opname ${item.namaObat}",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
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
                                SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: detailField(
                                              "Nama Obat", item.namaObat)),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                          child: detailField(
                                              "Tanggal Stock Opname",
                                              tanggalHariIni))
                                    ],
                                  ),
                                ),
                                Divider(),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Text("Daftar Barang",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          color: ColorStyle.tulisan_form,
                                          fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 16,
                                          headingRowHeight: 48,
                                          dataRowMinHeight: 36,
                                          dataRowMaxHeight: 40,
                                          headingRowColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              return Colors.grey
                                                  .shade300; // Warna latar seluruh baris header
                                            },
                                          ),
                                          columns: [
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "No",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Nomor Batch",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Jumlah Stock Sistem",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Jumlah Stock Fisik",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Keterangan",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: item!.batches
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            final obat = entry.value;
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(
                                                  "${index + 1}",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                  ),
                                                )),
                                                DataCell(Center(
                                                  child: Text(
                                                    obat.idNomorBatch
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )),
                                                DataCell(Center(
                                                  child: Text(
                                                    obat.kuantitasSistem
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )),
                                                DataCell(SizedBox(
                                                  height: 30,
                                                  child: Center(
                                                    child: TextFormField(
                                                      controller: obat.jumlah,
                                                      style: TextStyle(
                                                        color: ColorStyle
                                                            .tulisan_form,
                                                        fontSize: 12,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: "0",
                                                        filled: true,
                                                        fillColor: ColorStyle
                                                            .fill_form,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 8,
                                                                bottom: 12.5),
                                                        hintStyle: TextStyle(
                                                          color: ColorStyle
                                                              .tulisan_form,
                                                          fontSize: 12,
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: ColorStyle
                                                                  .fill_stroke,
                                                              width:
                                                                  1), // Warna abu-abu
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),

                                                        // Border saat ditekan (fokus)
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width:
                                                                  1), // Warna biru saat fokus
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),

                                                        // Border saat error
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: ColorStyle
                                                                  .button_red,
                                                              width:
                                                                  1), // Warna merah jika error
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                                DataCell(SizedBox(
                                                  height: 30,
                                                  child: Center(
                                                    child: TextFormField(
                                                      controller:
                                                          obat.keterangan,
                                                      style: TextStyle(
                                                        color: ColorStyle
                                                            .tulisan_form,
                                                        fontSize: 12,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: "Keterangan",
                                                        filled: true,
                                                        fillColor: ColorStyle
                                                            .fill_form,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 8,
                                                                bottom: 12.5),
                                                        hintStyle: TextStyle(
                                                          color: ColorStyle
                                                              .tulisan_form,
                                                          fontSize: 12,
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: ColorStyle
                                                                  .fill_stroke,
                                                              width:
                                                                  1), // Warna abu-abu
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),

                                                        // Border saat ditekan (fokus)
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width:
                                                                  1), // Warna biru saat fokus
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),

                                                        // Border saat error
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: ColorStyle
                                                                  .button_red,
                                                              width:
                                                                  1), // Warna merah jika error
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
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
                                        setState(() {
                                          for (var batch in item.batches) {
                                            // Simpan hasil input dari TextField ke field class
                                            batch.inputJumlah =
                                                batch.jumlah.text.trim();
                                            batch.inputKeterangan =
                                                batch.keterangan.text.trim();
                                            print(batch.inputJumlah);
                                          }
                                        });
                                        Navigator.pop(context);
                                        // _alertDone(item, "diedit");
                                        _alertInput();
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

  void _inputDataStockOpname(StockOpnameList item) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: detailField(
                                              "Nama Obat", item.namaObat)),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                          child: detailField(
                                              "Tanggal Stock Opname",
                                              tanggalHariIni))
                                    ],
                                  ),
                                ),
                                Divider(),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Text("Daftar Barang",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          color: ColorStyle.tulisan_form,
                                          fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 16,
                                          headingRowHeight: 48,
                                          dataRowMinHeight: 36,
                                          dataRowMaxHeight: 40,
                                          headingRowColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              return Colors.grey
                                                  .shade300; // Warna latar seluruh baris header
                                            },
                                          ),
                                          columns: [
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "No",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Nomor Batch",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Jumlah Stock Sistem",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Jumlah Stock Fisik",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                color: Colors.grey.shade300,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 8),
                                                child: Center(
                                                  child: Text(
                                                    "Keterangan",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: spesifikBatch!
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            final obat = entry.value;
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(
                                                  "${index + 1}",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                  ),
                                                )),
                                                DataCell(Center(
                                                  child: Text(
                                                    obat.noBatch.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )),
                                                DataCell(Center(
                                                  child: Text(
                                                    obat.sisa.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )),
                                                DataCell(Center(
                                                  child: TextFormField(
                                                    controller:
                                                        jumlah_fisik[index],
                                                    style: TextStyle(
                                                      color: ColorStyle
                                                          .tulisan_form,
                                                      fontSize: 12,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: "0",
                                                      filled: true,
                                                      fillColor:
                                                          ColorStyle.fill_form,
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 8,
                                                              bottom: 12.5),
                                                      hintStyle: TextStyle(
                                                        color: ColorStyle
                                                            .tulisan_form,
                                                        fontSize: 12,
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: ColorStyle
                                                                .fill_stroke,
                                                            width:
                                                                1), // Warna abu-abu
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),

                                                      // Border saat ditekan (fokus)
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black,
                                                            width:
                                                                1), // Warna biru saat fokus
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),

                                                      // Border saat error
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: ColorStyle
                                                                .button_red,
                                                            width:
                                                                1), // Warna merah jika error
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                                DataCell(Center(
                                                  child: TextFormField(
                                                    controller:
                                                        keterangan_fisik[index],
                                                    style: TextStyle(
                                                      color: ColorStyle
                                                          .tulisan_form,
                                                      fontSize: 12,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: "Keterangan",
                                                      filled: true,
                                                      fillColor:
                                                          ColorStyle.fill_form,
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 8,
                                                              bottom: 12.5),
                                                      hintStyle: TextStyle(
                                                        color: ColorStyle
                                                            .tulisan_form,
                                                        fontSize: 12,
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: ColorStyle
                                                                .fill_stroke,
                                                            width:
                                                                1), // Warna abu-abu
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),

                                                      // Border saat ditekan (fokus)
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black,
                                                            width:
                                                                1), // Warna biru saat fokus
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),

                                                      // Border saat error
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: ColorStyle
                                                                .button_red,
                                                            width:
                                                                1), // Warna merah jika error
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
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
                                  _alertDone(context,"diinput");
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

 // ⬇️ TARUH DI LUAR build(), setState(), atau try-catch manapun
void _alertDone(BuildContext context, String isi) {
  showDialog(
    context: context,
    builder: (context) {
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
              widthFactor: 0.5,
              heightFactor: 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/done.png",
                        width: constraints.maxWidth * 0.08,
                        height: constraints.maxWidth * 0.08,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Data berhasil $isi!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: constraints.maxWidth * 0.025,
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


  String tanggalNow = '';
  int _rowsPerPage = 10;
  int _currentPage = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initLocaleAndSetTanggal();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedDate2 = DateFormat('dd-MM-yyyy').format(now);

    // Masukkan ke controller
    tanggalNow = formattedDate2;
    tanggalHariIni = formattedDate;
    getListStockOpname();
    filterData = List.from(_data);
  }

  void filtering(String query) {
    setState(() {
      if (query.isEmpty) {
        filterData = List.from(_data);
      } else {
        filterData = _data.where((item) {
          return item.namaObat.toLowerCase().contains(query.toLowerCase());
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
    List<StockOpnameList> paginatedData =
        filterData.sublist(startIndex, endIndex);
    if (_data.isEmpty && loadingData) {
      return Positioned.fill(
        child: Container(
          color: Colors.white.withOpacity(0.7),
          child: Center(
            child: LoadingAnimationWidget.flickr(
              leftDotColor: Colors.red,
              rightDotColor: Colors.blue,
              size: 50,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      // appBar: NavbarTop(
      //     title: "INPUT DATA STOCK OPNAME",
      //     onMenuPressed: widget.toggleSidebar,
      //     isExpanded: widget.isExpanded,
      //     animationTrigger: onMenuPressed,
      //     animation: triggerAnimation),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //  hrs diganti jd tgl skrg
                  Text(
                    "Stock Opaname ${tanggalNow}",
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        _alertInput2("post", "diinput", "input");
                      },
                      icon: Image.asset(
                        "images/download.png",
                        width: 22,
                        height: 22,
                      ),
                      label: Text("Simpan Stock Opname",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorStyle.hover.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                      ),
                    ),
                  ),
                  // Padding(padding: EdgeInsets.only(right: 8)),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 25)),
              inputField("Catatan Umum Stock Opaname", "catatan", catatan),
              Padding(padding: EdgeInsets.only(top: 16)),
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
                                            'Nama Obat',
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
                                            'Kode Obat',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text('Jumlah Obat di Sistem',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text('Total Batches',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      )),
                                    ],
                                    rows: paginatedData
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      StockOpnameList item = entry.value;
                                      return DataRow(
                                        color: MaterialStateProperty.all(
                                            Colors.white),
                                        cells: [
                                          DataCell(Center(
                                            child: Text("${index + 1}",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                )),
                                          )),
                                          // DataCell(Center(
                                          //   child: Text(
                                          //     item.namaObat,
                                          //     textAlign: TextAlign.center,
                                          //     style: GoogleFonts.inter(
                                          //         color:
                                          //             ColorStyle.text_secondary,
                                          //         fontSize: 14,
                                          //         fontWeight: FontWeight.w400),
                                          //   ),
                                          // )),
                                          DataCell(
                                            Center(
                                              child: InkWell(
                                                onTap: () async {
                                                  // Aksi ketika teks diklik
                                                  // _inputDataStockOpname(item);
                                                  _inputDataUpdate(item);
                                                  // atau bisa navigasi/detail
                                                },
                                                child: Text(
                                                  item.namaObat,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    color: Colors
                                                        .blue, // Sesuaikan dengan ColorStyle.text_secondary jika perlu
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    decoration: TextDecoration
                                                        .underline, // 🔽 GARIS BAWAH
                                                    decorationColor:
                                                        Colors.blue,
                                                    decorationThickness:
                                                        1.5, // Optional: tebal garis
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Center(
                                            child: Text(
                                              item.idKartustok,
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
                                              item.kuantitasSistem.toString(),
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
                                              item.batches.length.toString(),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
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
              Padding(padding: EdgeInsets.only(bottom: 4)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget detailField(String title, String value) {
    return Column(
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
              style:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ),
        )
      ],
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
      padding: const EdgeInsets.only(left: 5, right: 5),
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
}
