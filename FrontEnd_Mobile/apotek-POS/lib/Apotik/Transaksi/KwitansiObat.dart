import 'dart:convert';

import 'package:apotek/Apotik/Transaksi/DataTransaksi.dart';
import 'package:apotek/Gudang/Penerimaan/DataPenerimaan.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/retry.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:apotek/global.dart' as global;

class KwitansiObat extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const KwitansiObat(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<KwitansiObat> createState() => _KwitansiObat();
}

class _KwitansiObat extends State<KwitansiObat>
    with SingleTickerProviderStateMixin {
  bool triggerAnimation = false; // Tambahkan variabel isExpanded
  final List<int> rowItems = [10, 25, 50, 100];
  final List<String> rowPembayaran = ["Cash", "Debit", "QRIS"];

  final List<String> rowKategori = ["Obat Panas", "Obat Batuk", "Obat Flu"];
  final List<String> rowSatuan = ["Strip", "Botol", "Pcs"];

  String? selectedValue;
  String? _selectedStatus;
  String? _selectedKategori;
  String? _selectedSatuan;
  String? _selectedKategoriEdit;
  String? _selectedSatuanEdit;

  String? _selectedMetodePembayaran;

  Kustomer? _selectedNamaKustomer;

  var text = TextEditingController();
  var text2 = TextEditingController();

  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  List<Kustomer> listKustomer = [];

  Future<void> getDataKustomer() async {
    try {
      listKustomer = await Kustomer.getData();
    } catch (e) {
      print("Error: $e");
    }
  }

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  int _rowsPerPage = 10; // Default jumlah baris per halaman
  int _currentPage = 0;
  List<DataPenerimaanBarang> filterData = [];
  final List<DataPenerimaanBarang> _data = [
    DataPenerimaanBarang(
        namaBarang: "Joy",
        kategoriBarang: "kategoriBarang",
        kode: "1",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "084937483",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "Jln Mentari no 9",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "Joy",
        kategoriBarang: "kategoriBarang",
        kode: "2",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "0384239743",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "Jln Mentari no 9",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "Joy",
        kategoriBarang: "kategoriBarang",
        kode: "3",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "03483294739",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "Jln Mentari no 9",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "Joy",
        kategoriBarang: "kategoriBarang",
        kode: "4",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "02382938293",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "Jalan Mentari no 9",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "Joy",
        kategoriBarang: "kategoriBarang",
        kode: "5",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "3",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "Jln Mentari no 9",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "10",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: DateTime(2030, 2, 12),
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang",
        tanggalPenerimaan: DateTime(2025, 3, 12),
        catatan: "Tolong diperiksa kembali"),
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

  void _viewDetails(DataPenerimaanBarang item) {
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
                    0.6, // Batasi tinggi agar tidak terlalu besar
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
                            "Kwitansi Obat",
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
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
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 21, right: 21),
                                      child: Text(
                                        "01 Januari 2025",
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18),
                                      ),
                                    )
                                  ],
                                ),

                                SizedBox(height: 15),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 16),
                                //   child: LayoutBuilder(
                                //     builder: (context, constraints) {
                                //       return SingleChildScrollView(
                                //         scrollDirection: Axis.horizontal,
                                //         child: DataTable(
                                //           columnSpacing: 16,
                                //           headingRowHeight: 48,
                                //           dataRowMinHeight: 36,
                                //           dataRowMaxHeight: 40,
                                //           headingRowColor:
                                //               MaterialStateProperty
                                //                   .resolveWith<Color?>(
                                //             (Set<MaterialState> states) {
                                //               return Colors.grey
                                //                   .shade300; // Warna latar seluruh baris header
                                //             },
                                //           ),
                                //           columns: [
                                //             DataColumn(
                                //               label: Container(
                                //                 color: Colors.grey.shade300,
                                //                 padding: EdgeInsets.symmetric(
                                //                     vertical: 12,
                                //                     horizontal: 8),
                                //                 child: Center(
                                //                   child: Text(
                                //                     "Nama Obat",
                                //                     textAlign:
                                //                         TextAlign.center,
                                //                     style: GoogleFonts.inter(
                                //                       fontWeight:
                                //                           FontWeight.w600,
                                //                       fontSize: 13,
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //             DataColumn(
                                //               label: Container(
                                //                 color: Colors.grey.shade300,
                                //                 padding: EdgeInsets.symmetric(
                                //                     vertical: 12,
                                //                     horizontal: 8),
                                //                 child: Center(
                                //                   child: Text(
                                //                     "Jumlah",
                                //                     textAlign:
                                //                         TextAlign.center,
                                //                     style: GoogleFonts.inter(
                                //                       fontWeight:
                                //                           FontWeight.w600,
                                //                       fontSize: 13,
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //             DataColumn(
                                //               label: Container(
                                //                 color: Colors.grey.shade300,
                                //                 padding: EdgeInsets.symmetric(
                                //                     vertical: 12,
                                //                     horizontal: 8),
                                //                 child: Center(
                                //                   child: Text(
                                //                     "Harga",
                                //                     textAlign:
                                //                         TextAlign.center,
                                //                     style: GoogleFonts.inter(
                                //                       fontWeight:
                                //                           FontWeight.w600,
                                //                       fontSize: 13,
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),

                                //           ],
                                //           rows: detailBarangPembelian!
                                //               .obatList
                                //               .asMap()
                                //               .entries
                                //               .map((entry) {
                                //             final obat = entry.value;
                                //             return DataRow(
                                //               cells: [
                                //                 DataCell(Text(
                                //                   obat.namaObat,
                                //                   style: GoogleFonts.inter(
                                //                     fontWeight:
                                //                         FontWeight.w400,
                                //                     fontSize: 12,
                                //                   ),
                                //                 )),
                                //                 DataCell(Center(
                                //                   child: Text(
                                //                     obat.jumlahDipesan
                                //                         .toString(),
                                //                     textAlign:
                                //                         TextAlign.center,
                                //                     style: GoogleFonts.inter(
                                //                       fontWeight:
                                //                           FontWeight.w400,
                                //                       fontSize: 12,
                                //                     ),
                                //                   ),
                                //                 )),
                                //                 DataCell(Center(
                                //                   child: Text(
                                //                     obat.jumlahDiterima
                                //                         .toString(),
                                //                     textAlign:
                                //                         TextAlign.center,
                                //                     style: GoogleFonts.inter(
                                //                       fontWeight:
                                //                           FontWeight.w400,
                                //                       fontSize: 12,
                                //                     ),
                                //                   ),
                                //                 )),

                                //               ],
                                //             );
                                //           }).toList(),
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // ),
                                detailField("Metode Pembayaran", item.catatan),
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

  Future<void> postPenerimaan() async {
    String url = "http://leap.crossnet.co.id:2688/PoS/checkout";
    // Susun obat_list dari isi dan isi2
    List<Map<String, dynamic>> obatList = [];
    // print("ISI LENGTH: ${isi.length}");
    // print("ISI2 LENGTH: ${isi2.length}");
    // print("ISI data: ${isi[0]!.namaObat}");
    // print("ISI LENGTH: ${isi2[0]}");

    // for (int i = 0; i < isi.length; i++) {
    //   if (isi[i] != null && isi2[i].text.isNotEmpty) {
    //     obatList.add({
    //       "id_detail_pembelian_penerimaan_obat": isi[i]!
    //           .idDetailPembelianPenerimaanObat, // contoh ID dummy, ganti sesuai logikamu
    //       "nomor_batch": isi2[i].text,
    //       "kadaluarsa": tanggal[i].text,
    //       "jumlah_diterima": int.tryParse(isi3[i].text),
    //       "id_kartustok": isi[i]!.idKartustok,
    //       "nama_obat": isi[i]!.namaObat,
    //     });
    //   }
    // }
    // final body = {
    //   "id_kustomer": idKustomerController.text,
    //   "pembayaran": {
    //     "metode_bayar": metodeBayarController.text,
    //   },
    //   "items": keranjang // langsung assign
    // };

    var response = await http.post(Uri.parse(url),
        headers: {
          "Authorization": '${global.token}',
          "x-api-key": '${global.xApiKey}',
          "Content-Type": "application/json" // Tambahkan ini juga!
        },
        body: jsonEncode({
          "id_kustomer": _selectedKategoriEdit,
          "pembayaran": tanggalController.text,
        }));
    // print(response.body);
    if (response.statusCode == 200) {
      print("✅ Sukses mengirim input data pembelian di POS");
      print(response.body);
    } else {
      print("❌ Gagal: ${response.statusCode}");
      print(response.body);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataKustomer();
    filterData = List.from(_data);
  }

  void filtering(String query) {
    setState(() {
      if (query.isEmpty) {
        filterData = List.from(_data);
      } else {
        filterData = _data.where((item) {
          return item.namaBarang.toLowerCase().contains(query.toLowerCase()) ||
              item.stok.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _currentPage = 0; // Reset ke halaman pertama setelah filter
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void filterByStatus(String status) {
    setState(() {
      if (status == "Selesai") {
        filterData = _data.where((item) => item.stok == "10").toList();
      } else if (status == "Batal") {
        filterData = _data.where((item) => item.stok != "10").toList();
      } else {
        filterData =
            List.from(_data); // Jika pilih "Semua", tampilkan semua data
      }
    });
  }

  var keterangan = TextEditingController();
  var aturan = TextEditingController();
  var caraPakai = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int totalPages = (filterData.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex =
        (startIndex + _rowsPerPage).clamp(0, filterData.length); // Batas aman
    List<DataPenerimaanBarang> paginatedData =
        filterData.sublist(startIndex, endIndex);
    return Scaffold(
      // appBar: NavbarTop(title: "PENERIMAAN BARANG", onMenuPressed: onMenuPressed, isExpanded: isExpanded),
      // appBar: NavbarTop(
      //     title: _titles[_selectedTabIndex],
      //     onMenuPressed: widget.toggleSidebar,
      //     isExpanded: widget.isExpanded,
      //     animationTrigger: onMenuPressed,
      //     animation: triggerAnimation),

      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Padding(padding: EdgeInsets.only(bottom: 16)),
            Expanded(
              child: Container(
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
                            //   border: Border.all(
                            //       color: ColorStyle.fill_stroke, width: 1),
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
                                contentPadding:
                                    EdgeInsets.only(left: 8, bottom: 12.5),
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
                        Padding(padding: EdgeInsets.only(right: 8)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          // padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: ColorStyle.shadow.withOpacity(0.25),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: Offset(0, 1), // x dan y
                              ),
                            ],
                            // borderRadius: BorderRadius.circular(4),
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
                                          // headingRowColor:
                                          //     MaterialStateProperty.all(
                                          //         Colors.white),
                                          columnSpacing:
                                              60, // Menambah jarak antar kolom
                                          dataRowMinHeight:
                                              60, // Menambah tinggi minimum baris
                                          dataRowMaxHeight:
                                              60, // Menambah tinggi maksimum baris
                                          columns: [
                                            DataColumn(
                                                label: Expanded(
                                                    child: Center(
                                                        child: Text('Nama Obat',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))))),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Jumlah',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            )),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Aturan Pakai',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            )),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Cara Pakai',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            )),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Keterangan Pakai',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            )),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Harga',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            )),
                                          ],
                                          rows: paginatedData.map((item) {
                                            return DataRow(
                                              // color: MaterialStateProperty.all(
                                              //     Colors.white),
                                              cells: [
                                                DataCell(Center(
                                                    child: Text("obat",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: ColorStyle
                                                              .text_secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        )))),
                                                DataCell(Center(
                                                    child: Text(item.kode,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: ColorStyle
                                                              .text_secondary,
                                                          fontSize: 14,
                                                        )))),
                                                DataCell(
                                                  Center(
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: SizedBox(
                                                        width: 100,
                                                        child: TextFormField(
                                                          controller: aturan,
                                                          style: GoogleFonts.inter(
                                                              color: ColorStyle
                                                                  .tulisan_form,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: SizedBox(
                                                        width: 100,
                                                        child: TextFormField(
                                                          controller: caraPakai,
                                                          style: GoogleFonts.inter(
                                                              color: ColorStyle
                                                                  .tulisan_form,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: TextFormField(
                                                        controller: keterangan,
                                                        style: GoogleFonts.inter(
                                                            color: ColorStyle
                                                                .tulisan_form,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // DataCell(Text(item.quantity.toString())),

                                                DataCell(
                                                  Center(
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        item.hargaBeli,
                                                        overflow: TextOverflow
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
                    Padding(padding: EdgeInsets.only(bottom: 8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Total Harga",
                                style: GoogleFonts.inter(fontSize: 18)),
                            Text(
                              "500000",
                              // "Rp. ${hitungTotal().toString().replaceAll('.', ',')},00",
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
                      height: 8,
                    ),
                    Text(
                      "Nama Customer",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: SizedBox(
                        width: double
                            .infinity, // Sesuaikan lebar agar tidak terlalu besar
                        height:
                            40, // Tinggi dropdown agar sesuai dengan contoh gambar
                        child: DropdownButtonFormField2<Kustomer>(
                          isExpanded:
                              false, // Jangan meluaskan dropdown ke full width
                          value: _selectedNamaKustomer,
                          hint: Text(
                            "Pilih Nama Customer",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: ColorStyle.text_hint,
                                fontWeight: FontWeight.w400),
                          ),
                          items: listKustomer
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
                            setState(() {
                              _selectedNamaKustomer = value!;
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
                            width: MediaQuery.of(context).size.width * 0.89,
                            maxHeight: 150, // Ikuti lebar input field
                            // Lebar dropdown harus sama dengan input
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
                    SizedBox(
                      height: 14,
                    ),
                    Text(
                      "Metode Pembayaran",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: SizedBox(
                        width: double
                            .infinity, // Sesuaikan lebar agar tidak terlalu besar
                        height:
                            40, // Tinggi dropdown agar sesuai dengan contoh gambar
                        child: DropdownButtonFormField2<String>(
                          isExpanded:
                              false, // Jangan meluaskan dropdown ke full width
                          value: _selectedMetodePembayaran,
                          hint: Text(
                            "Pilih Pembayaran",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: ColorStyle.text_hint,
                                fontWeight: FontWeight.w400),
                          ),
                          items: rowPembayaran
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
                              _selectedMetodePembayaran = value!;
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
                            width: MediaQuery.of(context).size.width *
                                0.89, // Lebar dropdown harus sama dengan input
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
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Container(
                        height: 35,
                        width: 350,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon:
                              Icon(Icons.print, color: Colors.white, size: 22),
                          label: Transform.translate(
                            offset: Offset(-3, 0),
                            child: Text("Cetak Struk",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorStyle.hover.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                        ),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Text("Rows per page:",
                    //         style: TextStyle(
                    //             color: ColorStyle.text_hint, fontSize: 14)),
                    //     Padding(padding: EdgeInsets.only(right: 8)),
                    //     Center(
                    //       child: SizedBox(
                    //         width:
                    //             65, // Sesuaikan lebar agar tidak terlalu besar
                    //         height:
                    //             25, // Tinggi dropdown agar sesuai dengan contoh gambar
                    //         child: DropdownButtonFormField2<int>(
                    //           isExpanded:
                    //               false, // Jangan meluaskan dropdown ke full width
                    //           value: _rowsPerPage,
                    //           items: rowItems
                    //               .map((e) => DropdownMenuItem(
                    //                     value: e,
                    //                     child: Text(
                    //                       e.toString(),
                    //                       style: TextStyle(
                    //                           fontSize: 14,
                    //                           color: ColorStyle.text_hint),
                    //                       overflow: TextOverflow.ellipsis,
                    //                     ),
                    //                   ))
                    //               .toList(),
                    //           onChanged: (value) {
                    //             setState(() {
                    //               _rowsPerPage = value!;
                    //             });
                    //           },
                    //           decoration: InputDecoration(
                    //             contentPadding: EdgeInsets.symmetric(
                    //                 horizontal: 4, vertical: 2),
                    //             constraints: BoxConstraints(maxHeight: 30),
                    //             enabledBorder: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(
                    //                   5), // Border radius halus
                    //               borderSide:
                    //                   BorderSide(color: ColorStyle.button_grey),
                    //             ),
                    //             focusedBorder: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(5),
                    //               borderSide: BorderSide(
                    //                   color: ColorStyle
                    //                       .text_secondary), // Saat aktif, border lebih gelap
                    //             ),
                    //           ),

                    //           // **Atur Tampilan Dropdown**
                    //           buttonStyleData: ButtonStyleData(
                    //             height: 25, // Tinggi tombol dropdown
                    //             padding: EdgeInsets.symmetric(
                    //                 horizontal: 6), // Jarak dalam dropdown
                    //           ),

                    //           // **Atur Tampilan Dropdown yang Muncul**
                    //           dropdownStyleData: DropdownStyleData(
                    //             width:
                    //                 65, // Lebar dropdown harus sama dengan input
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(5),
                    //               border:
                    //                   Border.all(color: ColorStyle.button_grey),
                    //               color: Colors.white,
                    //             ),
                    //           ),

                    //           // **Atur Posisi Item Dropdown**
                    //           menuItemStyleData: const MenuItemStyleData(
                    //             padding: EdgeInsets.symmetric(
                    //                 horizontal:
                    //                     8), // Padding antar item dropdown
                    //           ),

                    //           // **Ganti Icon Dropdown**
                    //           iconStyleData: IconStyleData(
                    //             icon: Icon(Icons.keyboard_arrow_down_outlined,
                    //                 size: 20, color: Colors.black),
                    //             openMenuIcon: Icon(
                    //                 Icons.keyboard_arrow_up_outlined,
                    //                 size: 20,
                    //                 color: Colors.black),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     Padding(padding: EdgeInsets.only(right: 8)),
                    //     Text("Page $endIndex of ${filterData.length}",
                    //         style: TextStyle(
                    //             color: ColorStyle.text_hint, fontSize: 14)),
                    //     Row(
                    //       children: [
                    //         IconButton(
                    //           icon: Icon(Icons.chevron_left),
                    //           onPressed: _currentPage > 0
                    //               ? () {
                    //                   setState(() {
                    //                     _currentPage--;
                    //                   });
                    //                 }
                    //               : null,
                    //         ),
                    //         IconButton(
                    //           icon: Icon(Icons.chevron_right),
                    //           onPressed: _currentPage < totalPages - 1
                    //               ? () {
                    //                   setState(() {
                    //                     _currentPage++;
                    //                   });
                    //                 }
                    //               : null,
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            )
          ]),
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
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
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
                  borderRadius: BorderRadius.circular(5),
                ),

                // Border saat ditekan (fokus)
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black, width: 1), // Warna biru saat fokus
                  borderRadius: BorderRadius.circular(5),
                ),

                // Border saat error
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.button_red,
                      width: 1), // Warna merah jika error
                  borderRadius: BorderRadius.circular(5),
                ),
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
                  borderRadius: BorderRadius.circular(5),
                ),

                // Border saat ditekan (fokus)
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black, width: 1), // Warna biru saat fokus
                  borderRadius: BorderRadius.circular(5),
                ),

                // Border saat error
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorStyle.button_red,
                      width: 1), // Warna merah jika error
                  borderRadius: BorderRadius.circular(5),
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
                border: InputBorder.none,
                hintText: "Cara Pemakaian",
                filled: true,
                fillColor: ColorStyle.fill_form,
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
