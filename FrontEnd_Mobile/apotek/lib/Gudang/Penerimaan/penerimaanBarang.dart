import 'dart:convert';

import 'package:apotek/Gudang/Pembelian/DataPembelian.dart';
import 'package:apotek/Gudang/Penerimaan/DataPenerimaan.dart';
import 'package:apotek/Gudang/Produk/DataProduk.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/global.dart' as global;
import 'package:apotek/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PenerimaanBarang extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const PenerimaanBarang(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<PenerimaanBarang> createState() => pagePenerimaan();
}

class pagePenerimaan extends State<PenerimaanBarang>
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

  // untuk menambahkan input untuk barang
  List<Obat?> isi = []; // obat yg dipilih
  List<TextEditingController> isi2 = []; // nomor batch
  List<TextEditingController> isi3 = []; // isi untuk jumlah penerimaan
  List<TextEditingController> isi4 = []; //ini aslinya buat namanya cmn ..
  List<TextEditingController> tanggal = []; // isi tanggal kadaluarsa
  List<Widget> inputBarang = [];

  Future<void> tambahInputForm(
      void Function(void Function()) setDialogState2) async {
    Obat? isiNama;
    TextEditingController jumlahBarang = TextEditingController();
    TextEditingController nomorBatch = TextEditingController();
    TextEditingController namaObat = TextEditingController();
    var tanggalInput = TextEditingController();

    setState(() {
      isi.add(isiNama);
      isi2.add(nomorBatch);
      isi3.add(jumlahBarang);
      isi4.add(namaObat);
      tanggal.add(tanggalInput);
      int index = isi.length - 1;
      inputBarang.add(
        InputForm(
          "Nama Obat",
          "Nama Obat",
          "Jumlah Barang yang Dipesan",
          "Jumlah Barang yang Dipesan",
          index,
          index == 0 ? null : () => hapusInputForm(index, setDialogState2),
        ),
      );
    });
  }

  void muatUlang(void Function(void Function()) setDialogState2) {
    isi.clear();
    isi2.clear();
    inputBarang.clear();
    tambahInputForm(setDialogState2);
  }

  void hapusInputForm(
      int index, void Function(void Function()) setDialogState2) {
    setDialogState2(() {
      if (index < inputBarang.length) {
        inputBarang.removeAt(index);
        isi.removeAt(index);
        isi2.removeAt(index);
      }
    });
  }

  List<PembelianBarangObat> listPembelianBarang = [];
  DetailPembelianBarang? detailBarangPembelian;
  var idPembelian;
  Future<void> getDataDetailBarang(String id) async {
    detailBarangPembelian = await DetailPembelianBarang.getDataDetail(id);
  }

  DetailPembelianBarang? detailBarangPembelian2;
  var idPembelian2;
  Future<void> getListObat(String id) async {
    detailBarangPembelian2 = await DetailPembelianBarang.getDataDetail(id);
  }

  Future<void> getDataAllPembelian() async {
    try {
      listPembelianBarang = await PembelianBarangObat.getData();
      // detailBarangPembelian = await DetailPembelianBarang.getDataDetail(idPembelian);
      for (var item in listPembelianBarang) {
        String detail = await DetailPembelianBarang.getDataNamaDetail(
            item.idPembelianBarangObat);
        item.namaSupplier = detail;
      }
      // print();
      setState(() {
        filterData = List.from(listPembelianBarang);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  String formatRupiah(num number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(number);
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
        tanggalController.text = DateFormat("yyyy-MM-dd").format(selectedDate);
      });
    }
  }

  DateTime selectedDate2 = DateTime.now();
  var tanggalController2 = TextEditingController();

  void _selectedDate2(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate2,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2100));

    if (picked != null && picked != selectedDate2) {
      setState(() {
        selectedDate2 = picked;
        tanggal[index].text = DateFormat("yyyy-MM-dd").format(selectedDate2);
      });
    }
  }

  void _viewDetails(PembelianBarangObat item) {
    showDialog(
      context: context,
      builder: (context) {
        bool dataLoaded =
            false; // ⬅️ FLAG untuk memastikan hanya panggil data sekali

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Panggil data hanya sekali saat data belum dimuat
            if (!dataLoaded) {
              dataLoaded = true;
              detailBarangPembelian = null; // reset data
              Future.microtask(() async {
                try {
                  final result = await DetailPembelianBarang.getDataDetail(
                      item.idPembelianBarangObat);
                  setDialogState(() {
                    detailBarangPembelian = result;
                  });
                } catch (e) {
                  setDialogState(() {
                    // Optional: tampilkan error jika ingin
                    detailBarangPembelian = null;
                  });
                }
              });
            }

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
                child: detailBarangPembelian == null
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            decoration: BoxDecoration(
                              color: ColorStyle.alert_ungu,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 23),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Informasi Penerimaan Barang",
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
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  detailField(
                                    "Nomor Pembelian",
                                    detailBarangPembelian!
                                            .idDetailPembelianBarang ??
                                        "Tidak Ada",
                                  ),
                                  detailField(
                                    "Nama Supplier",
                                    detailBarangPembelian!.namaSupplier ??
                                        "Tidak Ada",
                                  ),
                                  detailField(
                                    "Tanggal Pembelian",
                                    detailBarangPembelian!.tanggalPembelian !=
                                            null
                                        ? DateFormat('dd/MM/yyyy').format(
                                            detailBarangPembelian!
                                                .tanggalPembelian!)
                                        : "",
                                  ),
                                  detailField(
                                    "Tanggal Penerimaan",
                                    detailBarangPembelian!.tanggalPenerimaan !=
                                            null
                                        ? DateFormat('dd/MM/yyyy').format(
                                            detailBarangPembelian!
                                                .tanggalPenerimaan!)
                                        : "",
                                  ),
                                  detailField(
                                    "Tanggal Pembayaran",
                                    detailBarangPembelian!.tanggalPembayaran !=
                                            null
                                        ? DateFormat('dd/MM/yyyy').format(
                                            detailBarangPembelian!
                                                .tanggalPembayaran!)
                                        : "",
                                  ),
                                  detailField("Nama Pemesan",
                                      detailBarangPembelian!.pemesan),
                                  detailField(
                                      "Nama Penerima",
                                      detailBarangPembelian!.penerima ??
                                          "tidak ada penerima"),
                                  detailField(
                                    "Total Harga",
                                    formatRupiah(
                                        detailBarangPembelian!.totalHarga),
                                  ),
                                  detailField(
                                    "Keterangan",
                                    detailBarangPembelian!.keterangan ?? "",
                                  ),
                                  SizedBox(height: 15),
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
                                            headingRowColor:
                                                MaterialStateProperty
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
                                                      "Nama Obat",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      "Jumlah Dipesan",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      "Jumlah Diterima",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      "Tanggal Kadaluarsa",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      "Status",
                                                      textAlign:
                                                          TextAlign.center,
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
                                            rows: detailBarangPembelian!
                                                .obatList
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final obat = entry.value;
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text(
                                                    obat.namaObat,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                    child: Text(
                                                      obat.jumlahDipesan
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                    child: Text(
                                                      obat.jumlahDiterima
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                    child: Text(
                                                      obat.nomorBatch,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                    child: Text(
                                                      obat.kadaluarsa != null
                                                          ? DateFormat(
                                                                  'dd/MM/yyyy')
                                                              .format(obat
                                                                  .kadaluarsa!)
                                                          : "",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                    child: Container(
                                                      height: 30,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: obat.idStatus ==
                                                                "0"
                                                            ? Colors
                                                                .red.shade100
                                                            : obat.idStatus ==
                                                                    "1"
                                                                ? Colors.green
                                                                    .shade100
                                                                : Colors.yellow
                                                                    .shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          obat.idStatus == "0"
                                                              ? "Belum"
                                                              : obat.idStatus ==
                                                                      "1"
                                                                  ? "Selesai"
                                                                  : "Sebagian",
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis, // agar tidak kebablasan
                                                          softWrap: false,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: obat.idStatus ==
                                                                    "0"
                                                                ? Colors.red
                                                                : obat.idStatus ==
                                                                        "1"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .orange,
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

  List<Obat> namaObat = [];
  List<TextEditingController> nomorBatchControllers = [];
  List<TextEditingController> kadaluarsaControllers = [];
  void _selectedExpired(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate2,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2100));

    if (picked != null && picked != selectedDate2) {
      setState(() {
        selectedDate2 = picked;
        kadaluarsaControllers[index].text =
            DateFormat("yyyy-MM-dd").format(selectedDate2);
      });
    }
  }

  List<TextEditingController> jumlahControllers = [];
  var nomorPembelianEdit = TextEditingController();
  var idPenerimaan;
  Future<void> putPenerimaan(String id) async {
    String url =
        "http://leap.crossnet.co.id:2688/penerimaanbarang/${idPenerimaan}/edit";
    // Susun obat_list dari isi dan isi2
    List<Map<String, dynamic>> obatList = [];
    // print("ISI LENGTH: ${isi.length}");
    // print("ISI2 LENGTH: ${isi2.length}");
    // print("ISI data: ${isi[0]!.namaObat}");
    // print("ISI LENGTH: ${isi2[0]}");

    for (int i = 0; i < namaObat.length; i++) {
      if (nomorBatchControllers[i].text.isNotEmpty &&
          kadaluarsaControllers[i].text.isNotEmpty &&
          jumlahControllers[i].text.isNotEmpty) {
        obatList.add({
          "id_detail_pembelian_penerimaan_obat": namaObat[i]!
              .idDetailPembelianPenerimaanObat, // contoh ID dummy, ganti sesuai logikamu
          "nomor_batch": nomorBatchControllers[i].text,
          "kadaluarsa": kadaluarsaControllers[i].text,
          "jumlah_diterima": int.tryParse(jumlahControllers[i].text),
          "id_kartustok": namaObat[i]!.idKartustok,
          "id_batch_penerimaan": namaObat[i]!.idBatchPenerimaan,
          "id_nomor_batch": namaObat[i]!.idnomorBatch,
        });
      }
    }
    var response = await http.put(Uri.parse(url),
        headers: {
          "Authorization": '${global.token}',
          "x-api-key": '${global.xApiKey}',
          "Content-Type": "application/json" // Tambahkan ini juga!
        },
        body: jsonEncode(obatList));

    // print("dataaaa");
    // print(obatList);
    if (response.statusCode == 200) {
      print("✅ Sukses mengirim pembelian");
      print(response.body);
    } else {
      print("❌ Gagal: ${response.statusCode}");
      print(response.body);
    }
  }

  void _editPenerimaan(PembelianBarangObat item) {
    setState(() {
      idPenerimaan = item.idPembelianBarangObat;
    });
    showDialog(
      context: context,
      builder: (context) {
        bool dataLoaded =
            false; // ⬅️ FLAG untuk memastikan hanya panggil data sekali

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Panggil data hanya sekali saat data belum dimuat
            if (!dataLoaded) {
              dataLoaded = true;
              detailBarangPembelian = null; // reset data
              Future.microtask(() async {
                try {
                  final result = await DetailPembelianBarang.getDataDetail(
                      item.idPembelianBarangObat);
                  setDialogState(() {
                    detailBarangPembelian = result;
                    // Isi data dari detailBarangPembelian
                    nomorPembelianEdit.text =
                        result.idDetailPembelianBarang ?? "";

                    nomorBatchControllers.clear();
                    kadaluarsaControllers.clear();
                    jumlahControllers.clear();

                    //
                    for (var obat in result.obatList) {
                      namaObat.add(obat);
                      nomorBatchControllers
                          .add(TextEditingController(text: obat.nomorBatch));
                      kadaluarsaControllers.add(TextEditingController(
                          text: obat.kadaluarsa != null
                              ? DateFormat("yyyy-MM-dd")
                                  .format(obat.kadaluarsa!)
                              : ""));
                      jumlahControllers.add(TextEditingController(
                          text: obat.jumlahDiterima.toString()));
                    }
                  });
                } catch (e) {
                  setDialogState(() {
                    // Optional: tampilkan error jika ingin
                    detailBarangPembelian = null;
                  });
                }
              });
            }
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: detailBarangPembelian == null
                    ? Center(child: CircularProgressIndicator())
                    : Column(
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
                                  "Edit Data Penerimaan Barang",
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
                          SizedBox(height: 16),

                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      editFeld(
                                          "Nomor Pembelian",
                                          detailBarangPembelian!
                                              .idDetailPembelianBarang,
                                          nomorPembelianEdit),
                                      SizedBox(height: 9),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Divider(),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16, bottom: 16),
                                        child: Text("Daftar Barang",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 18,
                                                color: ColorStyle.tulisan_form,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: detailBarangPembelian!
                                              .obatList.length,
                                          itemBuilder: (context, index) {
                                            final obat = detailBarangPembelian!
                                                .obatList[index];
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                left: 16,
                                                right: 16,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "ID Detail Obat",
                                                                  style: GoogleFonts.inter(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
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
                                                            SizedBox(height: 8),
                                                            TextFormField(
                                                              readOnly: true,
                                                              onChanged:
                                                                  (value) {
                                                                // print(isi[0].text);
                                                              },
                                                              // controller: isi2[index],
                                                              style: TextStyle(
                                                                color: ColorStyle
                                                                    .tulisan_form,
                                                                fontSize: 12,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                filled: true,
                                                                fillColor:
                                                                    ColorStyle
                                                                        .fill_form,
                                                                hintText: obat
                                                                    .idDetailPembelianPenerimaanObat,
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            8),
                                                                hintStyle:
                                                                    TextStyle(
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
                                                                          .circular(
                                                                              8),
                                                                ),

                                                                // Border saat ditekan (fokus)
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1), // Warna biru saat fokus
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
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
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                            ),
                                                            // Text("ID Detail Obat tidak dapat diubah", style: GoogleFonts.inter(fontWeight: FontWeight.w400),)
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Nomor Batch",
                                                                  style: GoogleFonts.inter(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
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
                                                            SizedBox(height: 8),
                                                            TextFormField(
                                                              // readOnly: true,
                                                              onChanged:
                                                                  (value) {
                                                                // print(isi[0].text);
                                                              },
                                                              controller:
                                                                  nomorBatchControllers[
                                                                      index],
                                                              style: TextStyle(
                                                                color: ColorStyle
                                                                    .tulisan_form,
                                                                fontSize: 12,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                filled: true,
                                                                fillColor:
                                                                    ColorStyle
                                                                        .fill_form,
                                                                hintText: obat
                                                                    .nomorBatch,
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            8),
                                                                hintStyle:
                                                                    TextStyle(
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
                                                                          .circular(
                                                                              8),
                                                                ),

                                                                // Border saat ditekan (fokus)
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1), // Warna biru saat fokus
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
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
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        "Kadaluarsa",
                                                                        style: GoogleFonts.inter(
                                                                            fontWeight:
                                                                                FontWeight.w600)),
                                                                    // Text(
                                                                    //   " *",
                                                                    //   style: GoogleFonts.inter(
                                                                    //       fontSize:
                                                                    //           14,
                                                                    //       fontWeight: FontWeight
                                                                    //           .w600,
                                                                    //       color:
                                                                    //           ColorStyle.button_red),
                                                                    // ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                Container(
                                                                  height: 35,
                                                                  // decoration: BoxDecoration(
                                                                  //   border: Border.all(color: ColorStyle.fill_stroke),
                                                                  //   color: ColorStyle.fill_form,
                                                                  //   borderRadius: BorderRadius.circular(8),
                                                                  // ),
                                                                  // padding: const EdgeInsets.symmetric(horizontal: 12),
                                                                  child:
                                                                      TextFormField(
                                                                    // readOnly: true,
                                                                    controller:
                                                                        kadaluarsaControllers[
                                                                            index],

                                                                    // onTap: () {
                                                                    //   _selectedDate(context);
                                                                    // },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      // isDense: true,
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          ColorStyle
                                                                              .fill_form,
                                                                      suffixIcon:
                                                                          IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          _selectedExpired(
                                                                              context,
                                                                              index);
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .calendar_month_outlined,
                                                                          color:
                                                                              ColorStyle.tulisan_form,
                                                                          size:
                                                                              24,
                                                                        ),
                                                                      ),
                                                                      contentPadding: EdgeInsets.only(
                                                                          left:
                                                                              8,
                                                                          bottom:
                                                                              12.5),
                                                                      hintText:
                                                                          "DD/MM/YYYY",
                                                                      hintStyle:
                                                                          TextStyle(
                                                                        color: ColorStyle
                                                                            .tulisan_form,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                      // Border sebelum ditekan
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                ColorStyle.fill_stroke,
                                                                            width: 1), // Warna abu-abu
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),

                                                                      // Border saat ditekan (fokus)
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                            width: 1), // Warna biru saat fokus
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),

                                                                      // Border saat error
                                                                      errorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                ColorStyle.button_red,
                                                                            width: 1), // Warna merah jika error
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  //
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "ID Detail Obat tidak dapat diubah",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 7.03,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
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
                                                                // Text(
                                                                //   " *",
                                                                //   style: TextStyle(
                                                                //       fontSize: 14,
                                                                //       fontWeight: FontWeight.bold,
                                                                //       color: ColorStyle.button_red),
                                                                // ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 8),
                                                            TextFormField(
                                                              readOnly: true,
                                                              onChanged:
                                                                  (value) {
                                                                // print(isi[0].text);
                                                              },
                                                              // controller: isi2[index],
                                                              style: TextStyle(
                                                                color: ColorStyle
                                                                    .tulisan_form,
                                                                fontSize: 12,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                filled: true,
                                                                fillColor:
                                                                    ColorStyle
                                                                        .fill_form,
                                                                hintText: obat
                                                                    .namaObat,
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            8),
                                                                hintStyle:
                                                                    TextStyle(
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
                                                                          .circular(
                                                                              8),
                                                                ),

                                                                // Border saat ditekan (fokus)
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1), // Warna biru saat fokus
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
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
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                            ),
                                                            // Text("ID Detail Obat tidak dapat diubah", style: GoogleFonts.inter(fontWeight: FontWeight.w400),)
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Jumlah Barang yang Diterima",
                                                                  style: GoogleFonts.inter(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
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
                                                            SizedBox(height: 8),
                                                            TextFormField(
                                                              // readOnly: true,
                                                              onChanged:
                                                                  (value) {
                                                                // print(isi[0].text);
                                                              },
                                                              controller:
                                                                  jumlahControllers[
                                                                      index],
                                                              style: TextStyle(
                                                                color: ColorStyle
                                                                    .tulisan_form,
                                                                fontSize: 12,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                filled: true,
                                                                fillColor:
                                                                    ColorStyle
                                                                        .fill_form,
                                                                hintText: obat
                                                                    .jumlahDiterima
                                                                    .toString(),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            8),
                                                                hintStyle:
                                                                    TextStyle(
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
                                                                          .circular(
                                                                              8),
                                                                ),

                                                                // Border saat ditekan (fokus)
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1), // Warna biru saat fokus
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
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
                                                                          .circular(
                                                                              8),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Nama Obat tidak dapat diubah",
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 11,
                                                  ),
                                                  Divider(),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      )
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
                                              _alertInput(
                                                  "edit", "mengedit", "edit");
                                              // _alertDone(item, "diedit");
                                              // setState(() {});
                                              // _alertDone("diedit");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                            child: const Text("SAVE",
                                                style: TextStyle(
                                                    color:
                                                        ColorStyle.button_green,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold)),
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

  List<Products> listProduk = [];
  Future<void> getDataProduct() async {
    try {
      listProduk = await Products.getData();
    } catch (e) {
      print("Error: $e");
    }
  }

  var nomorPembelian = TextEditingController();
  var keteranganPembelian = TextEditingController();
  Future<void> postPenerimaan() async {
    String url = "http://leap.crossnet.co.id:2688/penerimaanbarang/create";
    // Susun obat_list dari isi dan isi2
    List<Map<String, dynamic>> obatList = [];
    // print("ISI LENGTH: ${isi.length}");
    // print("ISI2 LENGTH: ${isi2.length}");
    // print("ISI data: ${isi[0]!.namaObat}");
    // print("ISI LENGTH: ${isi2[0]}");

    for (int i = 0; i < isi.length; i++) {
      if (isi[i] != null && isi2[i].text.isNotEmpty) {
        obatList.add({
          "id_detail_pembelian_penerimaan_obat": isi[i]!
              .idDetailPembelianPenerimaanObat, // contoh ID dummy, ganti sesuai logikamu
          "nomor_batch": isi2[i].text,
          "kadaluarsa": tanggal[i].text,
          "jumlah_diterima": int.tryParse(isi3[i].text),
          "id_kartustok": isi[i]!.idKartustok,
          "nama_obat": isi[i]!.namaObat,
        });
      }
    }
    var response = await http.post(Uri.parse(url),
        headers: {
          "Authorization": '${global.token}',
          "x-api-key": '${global.xApiKey}',
          "Content-Type": "application/json" // Tambahkan ini juga!
        },
        body: jsonEncode({
          "id_pembelian_penerimaan_obat": nomorPembelian.text,
          "tanggal_penerimaan": tanggalController.text,
          "obat_list": obatList
        }));
    // print(response.body);
    if (response.statusCode == 200) {
      print("✅ Sukses mengirim input penerimaan");
      print(response.body);
    } else {
      print("❌ Gagal: ${response.statusCode}");
      print(response.body);
    }
  }

  Future<void> _inputPenerimaanBaru(PembelianBarangObat item) async {
    setState(() {
      nomorPembelian.text = item.idPembelianBarangObat;
      idPembelian2 = item.idPembelianBarangObat;
      isi.clear();
      isi2.clear();
      inputBarang.clear();
    });

    await getListObat(item.idPembelianBarangObat);
    await tambahInputForm((fn) => fn());
    showDialog(
        context: context,
        builder: (context) {
          bool dataLoaded = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              // if (!dataLoaded) {
              //   dataLoaded = true;
              //   detailBarangPembelian2 = null;
              //   Future.microtask(() async {
              //     try {
              //       final result = await DetailPembelianBarang.getDataDetail(
              //           item.idPembelianBarangObat);
              //       setDialogState(() {
              //         detailBarangPembelian2 = result;
              //       });
              //     } catch (e) {
              //       setDialogState(() {
              //         detailBarangPembelian2 = null;
              //       });
              //     }
              //   });
              // }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: ColorStyle.button_grey,
                              width: 1,
                            ),
                          ),
                        ),
                        padding:
                            const EdgeInsets.only(top: 8, left: 23, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Input Data Penerimaan Barang",
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
                                  inputField(
                                      "Nomor Pembelian",
                                      detailBarangPembelian2!
                                          .idDetailPembelianBarang,
                                      nomorPembelian),
                                  tanggalInput("Tanggal Penerimaan",
                                      "DD/MM/YYYY", tanggalController),
                                  Divider(),
                                  Padding(padding: EdgeInsets.only(bottom: 16)),
                                  Row(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 16)),
                                      Text("Daftar Barang",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              color: ColorStyle.tulisan_form,
                                              fontWeight: FontWeight.w600)),
                                      Spacer(),
                                      SizedBox(
                                        width: 120,
                                        height: 30,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setDialogState(() {
                                              muatUlang(setDialogState);
                                            });
                                          },
                                          icon: Icon(Icons.refresh,
                                              color: ColorStyle.button_yellow,
                                              size: 22),
                                          label: const Text("Muat Ulang",
                                              style: TextStyle(
                                                  color:
                                                      ColorStyle.button_yellow,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
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
                                            setDialogState(() {
                                              tambahInputForm(setDialogState);
                                            });
                                            // print(inputBarang.length);
                                          },
                                          icon: Icon(Icons.add,
                                              color:
                                                  ColorStyle.text_dalam_kolom,
                                              size: 22),
                                          label: const Text("Tambah Barang",
                                              style: TextStyle(
                                                  color: ColorStyle
                                                      .text_dalam_kolom,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
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
                                  Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
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
                                          _alertInput(
                                              "input", "menginput", "input");
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
        });
  }

  void _alertDelete(PembelianBarangObat item) {
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
                        "Apakah Anda yakin akan \n${isi} data ini?",
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
                                  // await postPenerimaan();
                                  // Navigator.pop(
                                  //     context); // Tutup dialog konfirmasi
                                  // _alertDone("diinput");
                                  try {
                                    if (condition == "input") {
                                      await postPenerimaan();
                                      Navigator.pop(context);
                                      _alertDone("diinput");
                                    } else if (condition == "edit") {
                                      await putPenerimaan(
                                          nomorPembelianEdit.toString());
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
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          }
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

  int _rowsPerPage = 10; // Default jumlah baris per halaman
  int _currentPage = 0;

  List<PembelianBarangObat> filterData = [];

  void urutan() async {
    if (idPembelian != null) {
      await getDataDetailBarang(idPembelian);
    }
    if (idPembelian2 != null) {
      await getListObat(idPembelian2);
    }
    await tambahInputForm(
        (fn) => fn()); // Default panggil satu kali saat pertama
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataAllPembelian();
    getDataProduct();

    // getDataDetailBarang(idPembelian);
    // if(idPembelian != null){
    //   getDataDetailBarang(idPembelian);
    // }
    // getDataDetailBarang("PO18");
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
    filterData = List.from(listPembelianBarang);
  }

  void filtering(String query) {
    setState(() {
      if (query.isEmpty) {
        filterData = List.from(listPembelianBarang);
      } else {
        filterData = listPembelianBarang.where((item) {
          return item.idPembelianBarangObat
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item.tanggalPembayaran
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
      _currentPage = 0; // Reset ke halaman pertama setelah filter
    });
  }

  // harus dicek lagi

  void filterByStatus(String status) {
    setState(() {
      if (status == "Selesai") {
        filterData =
            listPembelianBarang.where((item) => item.id == 10).toList();
      } else if (status == "Batal") {
        filterData =
            listPembelianBarang.where((item) => item.id != 10).toList();
      } else {
        filterData = List.from(
            listPembelianBarang); // Jika pilih "Semua", tampilkan semua data
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filterData.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex =
        (startIndex + _rowsPerPage).clamp(0, filterData.length); // Batas aman
    List<PembelianBarangObat> paginatedData =
        filterData.sublist(startIndex, endIndex);
    return Scaffold(
      // appBar: NavbarTop(title: "PENERIMAAN BARANG", onMenuPressed: onMenuPressed, isExpanded: isExpanded),
      // appBar: NavbarTop(
      //     title: "PENERIMAAN BARANG",
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
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Container(
                          //   height: 40,
                          //   child: ElevatedButton.icon(
                          //     onPressed: () {
                          //       _inputPenerimaanBaru();
                          //     },
                          //     icon: Icon(Icons.add,
                          //         color: Colors.white, size: 22),
                          //     label: Transform.translate(
                          //       offset: Offset(-3, 0),
                          //       child: Text("Input Penerimaan",
                          //           style: GoogleFonts.inter(
                          //               color: Colors.white,
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w600)),
                          //     ),
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor:
                          //           ColorStyle.hover.withOpacity(0.7),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(5),
                          //       ),
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 10, vertical: 5),
                          //     ),
                          //   ),
                          // ),
                          // Padding(padding: EdgeInsets.only(right: 8)),
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
                                    padding: EdgeInsets.only(left: 8, right: 8),
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
                                            columns: [
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text('No',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts.inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600))))),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text('Nomor Pembelian',
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
                                                  child: Text('Nama Supplier',
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
                                                  child: Text(
                                                      'Tanggal Penerimaan',
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
                                                  child: Text('Total Harga',
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
                                                  child: Text('Actions',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              )),
                                            ],
                                            rows: paginatedData
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              PembelianBarangObat item =
                                                  entry.value;
                                              // print(entry
                                              //     .value.idPembelianBarangObat);
                                              return DataRow(
                                                color:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                                cells: [
                                                  DataCell(Center(
                                                      child: Text(
                                                          "${index + 1}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: ColorStyle
                                                                .text_secondary,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          )))),
                                                  DataCell(Center(
                                                      child: Text(
                                                          item
                                                              .idPembelianBarangObat,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts.inter(
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)))),
                                                  DataCell(
                                                    Center(
                                                      child: SizedBox(
                                                        width: 100,
                                                        child: Text(
                                                          item.namaSupplier ??
                                                              "Tidsk Ada",
                                                          overflow: TextOverflow
                                                              .visible,
                                                          style:
                                                              GoogleFonts.inter(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                          maxLines: 2,
                                                          textAlign: TextAlign
                                                              .center, // Batas maksimal baris teks
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(Center(
                                                      child: Text(
                                                          item!.tanggalPenerimaan !=
                                                                  null
                                                              ? DateFormat(
                                                                      'dd/MM/yyyy')
                                                                  .format(item!
                                                                      .tanggalPenerimaan!)
                                                              : "Belum diterima",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: ColorStyle
                                                                .text_secondary,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          )))),
                                                  DataCell(Center(
                                                      child: Text(
                                                          formatRupiah(
                                                              item.totalHarga),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: ColorStyle
                                                                .text_secondary,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          )))),
                                                  DataCell(Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        IconButton(
                                                            icon: Icon(
                                                              Icons.add,
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              size: 24,
                                                            ),
                                                            onPressed: () {
                                                              _inputPenerimaanBaru(
                                                                  item);
                                                            }),
                                                        IconButton(
                                                            icon: Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              color: ColorStyle
                                                                  .text_secondary,
                                                              size: 24,
                                                            ),
                                                            onPressed: () {
                                                              _editPenerimaan(
                                                                  item);
                                                            }),
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
                ),
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
      int index, VoidCallback? onDelete) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [dropdownObatList(index)],
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
                            "Nomor Batch",
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
                        child: TextFormField(
                          onChanged: (value) {
                            // print(isi[0].text);
                          },
                          controller: isi2[index],
                          style: TextStyle(
                            color: ColorStyle.tulisan_form,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ColorStyle.fill_form,
                            hintText: "Nomor Batch",
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
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Kadaluarsa",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
                              Text(
                                " *",
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                              controller: tanggal[index],

                              // onTap: () {
                              //   _selectedDate(context);
                              // },
                              decoration: InputDecoration(
                                // isDense: true,
                                filled: true,
                                fillColor: ColorStyle.fill_form,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _selectedDate2(context, index);
                                  },
                                  icon: Icon(
                                    Icons.calendar_month_outlined,
                                    color: ColorStyle.tulisan_form,
                                    size: 24,
                                  ),
                                ),
                                contentPadding:
                                    EdgeInsets.only(left: 8, bottom: 12.5),
                                hintText: "DD/MM/YYYY",
                                hintStyle: TextStyle(
                                  color: ColorStyle.tulisan_form,
                                  fontSize: 12,
                                ),
                                // Border sebelum ditekan
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
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
                      TextFormField(
                        onChanged: (value) {
                          // print(isi[0].text);
                        },
                        controller: isi4[index],
                        readOnly: true,
                        style: TextStyle(
                          color: ColorStyle.tulisan_form,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          // enabled: false,
                          isDense: true,
                          fillColor: ColorStyle.fill_form,
                          hintText: "Belum Pilih ID",
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                              child: TextFormField(
                                controller: isi3[index],
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
                          if (onDelete != null) ...[
                            InkWell(
                              onTap: () {
                                onDelete();
                              },
                              child: Icon(Icons.delete_outline,
                                  color: ColorStyle.button_red, size: 25),
                            )
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Divider()
          ],
        ),
      ),
    );
  }

  Widget EditForm(String idObat, String nomorBatch, String namaObatID,
      String kadaluarsaObat, String jumlahObat, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "ID Detail Obat",
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
                      SizedBox(height: 8),
                      TextFormField(
                        readOnly: true,
                        onChanged: (value) {
                          // print(isi[0].text);
                        },
                        // controller: isi2[index],
                        style: TextStyle(
                          color: ColorStyle.tulisan_form,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: ColorStyle.fill_form,
                          hintText: idObat,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                            "Nomor Batch",
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
                      SizedBox(height: 8),
                      TextFormField(
                        onChanged: (value) {
                          // print(isi[0].text);
                        },
                        controller: nomorBatchControllers[index],
                        style: TextStyle(
                          color: ColorStyle.tulisan_form,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: ColorStyle.fill_form,
                          hintText: nomorBatch,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Kadaluarsa",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
                              // Text(
                              //   " *",
                              //   style: GoogleFonts.inter(
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.w600,
                              //       color: ColorStyle.button_red),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            // readOnly: true,
                            controller: kadaluarsaControllers[index],

                            // onTap: () {
                            //   _selectedDate(context);
                            // },
                            decoration: InputDecoration(
                              // isDense: true,
                              filled: true,
                              fillColor: ColorStyle.fill_form,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _selectedDate2(context, index);
                                },
                                icon: Icon(
                                  Icons.calendar_month_outlined,
                                  color: ColorStyle.tulisan_form,
                                  size: 24,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              hintText: kadaluarsaObat,
                              hintStyle: TextStyle(
                                color: ColorStyle.tulisan_form,
                                fontSize: 12,
                              ),
                              // Border sebelum ditekan
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Nama Obat",
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
                      SizedBox(height: 8),
                      TextFormField(
                        onChanged: (value) {
                          // print(isi[0].text);
                        },
                        controller: isi4[index],
                        readOnly: true,
                        style: TextStyle(
                          color: ColorStyle.tulisan_form,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          // enabled: false,
                          isDense: true,
                          fillColor: ColorStyle.fill_form,
                          hintText: namaObatID,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            // Gunakan Expanded agar TextField tidak menyebabkan infinite width error
                            child: TextFormField(
                              controller: jumlahControllers[index],
                              style: TextStyle(
                                color: ColorStyle.tulisan_form,
                                fontSize: 12,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: ColorStyle.fill_form,
                                hintText: jumlahObat,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Divider()
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
                style: GoogleFonts.inter(fontSize: 12),
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
            child: TextFormField(
              controller: edit,
              readOnly: true,
              style: TextStyle(
                color: ColorStyle.tulisan_form,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: isi,
                // enabled: false,
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
      padding: const EdgeInsets.only(left: 16, right: 16),
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
            child: TextFormField(
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
          Text(
            "Nomor Pembelian tidak dapat diubah",
            style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 10),
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
                    // _selectedDate2(context);
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

  Widget dropdownObatList(int index) {
    // Cek jika data belum tersedia
    // if (detailBarangPembelian2 == null) {
    //   return Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 12),
    //     child: Row(
    //       children: [
    //         SizedBox(
    //           width: 18,
    //           height: 18,
    //           child: CircularProgressIndicator(strokeWidth: 2),
    //         ),
    //         SizedBox(width: 10),
    //         Text(
    //           "Memuat daftar obat...",
    //           style: GoogleFonts.inter(fontSize: 13),
    //         ),
    //       ],
    //     ),
    //   );
    // }
    print("ZZZZZZZZZZZ");
    print(detailBarangPembelian2!.keterangan);
    // Jika sudah ada data, tampilkan dropdown seperti biasa
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "ID Detail Obat",
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
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
        SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownButtonFormField2<Obat>(
              isExpanded: true,
              value: isi[index],
              validator: (value) {
                if (value == null) {
                  return "Silahkan Pilih Nama Obat";
                }
                return null;
              },
              hint: Text(
                "Pilih Nama Obat",
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ColorStyle.text_hint,
                    fontWeight: FontWeight.w400),
              ),
              items: detailBarangPembelian2!.obatList
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          "${e.idDetailPembelianPenerimaanObat} - ${e.namaObat}",
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
                  isi[index] = value!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                isDense: true,
                fillColor: ColorStyle.fill_form,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorStyle.button_grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorStyle.text_secondary),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorStyle.button_red, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorStyle.button_red, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                width: constraints.maxWidth,
                maxHeight: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorStyle.button_grey),
                  color: ColorStyle.fill_form,
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
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
    );
  }
}
