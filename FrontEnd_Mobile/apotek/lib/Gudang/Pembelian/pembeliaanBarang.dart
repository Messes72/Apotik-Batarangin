import 'package:apotek/Gudang/Pembelian/DataPembelian.dart';
import 'package:apotek/Gudang/Penerimaan/DataPenerimaan.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

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
  final List<String> rowStatus = ["Berhasil", "Gagal"];
  String? _selectedStatus;

  String? selectedValue;

  final _formKey = GlobalKey<FormState>();

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
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
  var text = TextEditingController();
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
                            ElevatedButton.icon(
                              onPressed: () {},
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
                            Padding(padding: EdgeInsets.only(right: 8)),
                            Expanded(
                              child: Container(
                                height: 40,
                                // width: 242,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorStyle.fill_stroke, width: 1),
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
                                            fontSize: 14,
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
                                        fontSize: 14,
                                        color: ColorStyle.text_hint),
                                  ),
                                  items: rowStatus
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: ColorStyle.text_hint),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value!;
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
                                    icon: Icon(Icons.arrow_drop_down,
                                        size: 20, color: Colors.black),
                                    openMenuIcon: Icon(Icons.arrow_drop_up,
                                        size: 20, color: Colors.black),
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
                                                                  ? "BERHASIL"
                                                                  : "GAGAL",
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
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          PopupMenuButton<int>(
                                                            icon: Icon(Icons
                                                                .more_horiz),
                                                            offset: Offset(0,
                                                                40), // Mengatur posisi dropdown ke bawah
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8), // Membuat sudut melengkung
                                                            ),
                                                            itemBuilder:
                                                                (context) => [
                                                              PopupMenuItem(
                                                                value: 1,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: ColorStyle
                                                                            .text_secondary),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                        "Edit"),
                                                                  ],
                                                                ),
                                                              ),
                                                              PopupMenuItem(
                                                                value: 2,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: ColorStyle
                                                                            .text_secondary),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                        "Hapus"),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          // IconButton(
                                                          //     icon: Icon(Icons.more_horiz),
                                                          //
                                                        ],
                                                      ),
                                                    )
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
                                    icon: Icon(Icons.arrow_drop_down,
                                        size: 20, color: Colors.black),
                                    openMenuIcon: Icon(Icons.arrow_drop_up,
                                        size: 20, color: Colors.black),
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
                      child: Center(
                    child: Text("data"),
                  )),
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
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorStyle.fill_stroke, width: 1),
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
                                            fontSize: 14,
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
                                        fontSize: 14,
                                        color: ColorStyle.text_hint),
                                  ),
                                  items: rowStatus
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: ColorStyle.text_hint),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value!;
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
                                    icon: Icon(Icons.arrow_drop_down,
                                        size: 20, color: Colors.black),
                                    openMenuIcon: Icon(Icons.arrow_drop_up,
                                        size: 20, color: Colors.black),
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
                                                                  ? "BERHASIL"
                                                                  : "GAGAL",
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
                                    icon: Icon(Icons.arrow_drop_down,
                                        size: 20, color: Colors.black),
                                    openMenuIcon: Icon(Icons.arrow_drop_up,
                                        size: 20, color: Colors.black),
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
}
