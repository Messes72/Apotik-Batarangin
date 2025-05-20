import 'package:apotek/Apotik/Transaksi/DataTransaksi.dart';
import 'package:apotek/Gudang/Penerimaan/DataPenerimaan.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/retry.dart';
import 'package:intl/intl.dart';

class KustomerApotek extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const KustomerApotek(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<KustomerApotek> createState() => _kustomerApotek();
}

class _kustomerApotek extends State<KustomerApotek>
    with SingleTickerProviderStateMixin {
  bool triggerAnimation = false; // Tambahkan variabel isExpanded
  final List<int> rowItems = [10, 25, 50, 100];
  final List<String> rowStatus = ["Selesai", "Batal", "Proses"];

  final List<String> rowKategori = ["Obat Panas", "Obat Batuk", "Obat Flu"];
  final List<String> rowSatuan = ["Strip", "Botol", "Pcs"];

  String? selectedValue;
  String? _selectedStatus;
  String? _selectedKategori;
  String? _selectedSatuan;
  String? _selectedKategoriEdit;
  String? _selectedSatuanEdit;

  var text = TextEditingController();
  var text2 = TextEditingController();

  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Tab

  int _selectedTabIndex = 0;

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
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
                    constraints.maxWidth * 0.7, // Sesuaikan dengan ukuran layar
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 21, right: 21),
                                      child: Text(
                                        "John Smith",
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18),
                                      ),
                                    ),
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
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Container(
                                    width: constraints.maxWidth *
                                        0.65, // Sesuaikan dengan ukuran layar
                                    height: constraints.maxHeight * 0.5,
                                    // padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorStyle.shadow
                                              .withOpacity(0.25),
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
                                                    minWidth:
                                                        constraints.maxWidth),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
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
                                                          // color: Colors
                                                          //     .grey.shade300,
                                                          // padding: EdgeInsets
                                                          //     .symmetric(
                                                          //         vertical: 12,
                                                          //         horizontal:
                                                          //             8),
                                                          child: Center(
                                                            child: Text(
                                                              "Nama Obat",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Expanded(
                                                          // color: Colors
                                                          //     .grey.shade300,
                                                          // padding: EdgeInsets
                                                          //     .symmetric(
                                                          //         vertical: 12,
                                                          //         horizontal:
                                                          //             8),
                                                          child: Center(
                                                            child: Text(
                                                              "Jumlah",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Expanded(
                                                          // color: Colors
                                                          //     .grey.shade300,
                                                          // padding: EdgeInsets
                                                          //     .symmetric(
                                                          //         vertical: 12,
                                                          //         horizontal:
                                                          //             8),
                                                          child: Center(
                                                            child: Text(
                                                              "Harga",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    rows: keranjang
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      final obat = entry.value;
                                                      return DataRow(
                                                        cells: [
                                                          DataCell(Center(
                                                            child: Text(
                                                              obat.namaObat,
                                                              textAlign:
                                                              TextAlign.center,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          )),
                                                          DataCell(Center(
                                                            child: Text(
                                                              obat.kuantitas
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          )),
                                                          DataCell(Center(
                                                            child: Text(
                                                              "${formatRupiah(obat.hargaObat)},00",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12,
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
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                //           headingRowColor: MaterialStateProperty
                                //               .resolveWith<Color?>(
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
                                //                     textAlign: TextAlign.center,
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
                                //                     textAlign: TextAlign.center,
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
                                //                     textAlign: TextAlign.center,
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
                                //           rows: keranjang
                                //               .asMap()
                                //               .entries
                                //               .map((entry) {
                                //             final obat = entry.value;
                                //             return DataRow(
                                //               cells: [
                                //                 DataCell(Text(
                                //                   obat.namaObat,
                                //                   style: GoogleFonts.inter(
                                //                     fontWeight: FontWeight.w400,
                                //                     fontSize: 12,
                                //                   ),
                                //                 )),
                                //                 DataCell(Center(
                                //                   child: Text(
                                //                     obat.kuantitas.toString(),
                                //                     textAlign: TextAlign.center,
                                //                     style: GoogleFonts.inter(
                                //                       fontWeight:
                                //                           FontWeight.w400,
                                //                       fontSize: 12,
                                //                     ),
                                //                   ),
                                //                 )),
                                //                 DataCell(Center(
                                //                   child: Text(
                                //                     obat.hargaObat.toString(),
                                //                     textAlign: TextAlign.center,
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
            Padding(padding: EdgeInsets.only(bottom: 16)),
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
                        //       // setState(() {
                        //       //   global.selectedIndex = 3;
                        //       //   global.selectedScreen = 0;
                        //       // });
                        //     },
                        //     icon: Transform.translate(
                        //       offset: Offset(
                        //           1, 0), // Geser ikon lebih dekat ke teks
                        //       child: Icon(Icons.add,
                        //           color: Colors.white, size: 22),
                        //     ),
                        //     label: Transform.translate(
                        //       offset: Offset(-3, 0),
                        //       child: const Text("Input Kustomer",
                        //           style: TextStyle(
                        //               color: Colors.white, fontSize: 16)),
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
                                              60, // Menambah jarak antar kolom
                                          dataRowMinHeight:
                                              60, // Menambah tinggi minimum baris
                                          dataRowMaxHeight:
                                              60, // Menambah tinggi maksimum baris
                                          columns: [
                                            DataColumn(
                                                label: Expanded(
                                                    child: Center(
                                                        child: Text(
                                                            'ID Transaksi',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))))),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Tanggal Transaksi',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            )),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Nama Kasir',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            )),
                                            DataColumn(
                                                label: Expanded(
                                              child: Center(
                                                child: Text('Actions',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            )),
                                          ],
                                          rows: paginatedData.map((item) {
                                            return DataRow(
                                              color: MaterialStateProperty.all(
                                                  Colors.white),
                                              cells: [
                                                DataCell(Center(
                                                    child: Text(item.kode,
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
                                                    child: Text(item.namaBarang,
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
                                                      child: Text(
                                                        item.namaSupplier,
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

                                                // DataCell(Text(item.quantity.toString())),

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
                                                            _viewDetails(item);
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
                                width:
                                    65, // Lebar dropdown harus sama dengan input
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: ColorStyle.button_grey),
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
