import 'package:apotek/Gudang/Stock/DataStockOpname.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/SideBar.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:apotek/global.dart' as global;
import 'package:apotek/SideBar.dart';

class stokopname extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const stokopname(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<stokopname> createState() => stokPage();
}

class stokPage extends State<stokopname> {
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
  List<StokOpnameModel> filterData = [];
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

  List<StokOpnameModel> listStokOpname = [];
  Future<void> getListStockOpname() async {
    try {
      StokOpnameModel.getData().then((value) {
        setState(() {
          listStokOpname = value;
          filterData = List.from(listStokOpname);
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }

String convertTanggal(String input) {
  final parsedDate = DateTime.parse(input); // parse ISO 8601 format
  final formatter = DateFormat('dd-MM-yyyy');
  return formatter.format(parsedDate);
}

  int _rowsPerPage = 10;
  int _currentPage = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getListStockOpname();
    filterData = List.from(listStokOpname);
  }

  void filtering(String query) {
    setState(() {
      if (query.isEmpty) {
        filterData = List.from(listStokOpname);
      } else {
        filterData = listStokOpname.where((item) {
          return item.idStokOpname.toLowerCase().contains(query.toLowerCase());
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
    List<StokOpnameModel> paginatedData =
        filterData.sublist(startIndex, endIndex);
    return Scaffold(
      // appBar: NavbarTop(
      //     title: "STOCK OPNAME",
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
                children: [
                  Container(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          global.selectedIndex =
                              3; // ini halaman yang ditampilkan
                          global.selectedScreen = 1; // ini di sidebarnya
                        });
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => MyApp()));
                        // _inputStockOpname();
                      },
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 22),
                      label: Transform.translate(
                        offset: Offset(-3, 0),
                        child: Text("Input Stock Opname",
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
                            horizontal: 20, vertical: 5),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8)),
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
                ],
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
                                            'Nomer Opname',
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
                                            'Tanggal Opname',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text('Total Selisih',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text('Catatan',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            'Actions',
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )),
                                    ],
                                    rows: paginatedData
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      StokOpnameModel item = entry.value;
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
                                          DataCell(Center(
                                            child: Text(
                                              item.idStokOpname,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )),
                                          DataCell(Center(
                                            child: Text(
                                              convertTanggal(item.tanggalStokOpname.toString()),
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
                                              item.totalSelisih.toString(),
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
                                              item.catatan,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
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
                                                      color: ColorStyle
                                                          .text_secondary,
                                                      size: 24,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        global.selectedIndex =
                                                            5; // ini halaman yang ditampilkan
                                                        global.selectedScreen =
                                                            1; // ini di sidebarnya
                                                        global.idStockOpnameInfo = item.idStokOpname;
                                                      });
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      MyApp()));
                                                      // _viewDetails(item);
                                                    }),
                                                // IconButton(
                                                //     icon: Icon(
                                                //       Icons.edit_outlined,
                                                //       color: ColorStyle
                                                //           .text_secondary,
                                                //       size: 24,
                                                //     ),
                                                //     onPressed: () {
                                                //       setState(() {
                                                //         global.selectedIndex =
                                                //             6; // ini halaman yang ditampilkan
                                                //         global.selectedScreen =
                                                //             1; // ini di sidebarnya
                                                //       });
                                                //       Navigator.pushReplacement(
                                                //           context,
                                                //           MaterialPageRoute(
                                                //               builder:
                                                //                   (context) =>
                                                //                       MyApp()));
                                                //       // _editStockOpname(item);
                                                //     }),
                                                // IconButton(
                                                //     icon: Icon(
                                                //       Icons
                                                //           .delete_outline_outlined,
                                                //       color: ColorStyle
                                                //           .text_secondary,
                                                //       size: 24,
                                                //     ),
                                                //     onPressed: () {
                                                //       _modalKosongkanObat(item);
                                                //     }),
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
}
