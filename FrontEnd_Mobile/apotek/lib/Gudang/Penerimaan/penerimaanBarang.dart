import 'package:apotek/Gudang/Penerimaan/DataPenerimaan.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

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

  String? selectedValue;

  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Tab
  final _selectedColor = Color(0xff1a73e8);
  final _unselectedColor = Color(0xff5f6368);
  final _tabs = [
    Tab(text: 'Penerimaan'),
    Tab(text: 'Statistik'),
    Tab(text: 'Riwayat'),
  ];

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  int _rowsPerPage = 10; // Default jumlah baris per halaman
  int _currentPage = 0;
  var text = TextEditingController();
  List<DataPenerimaanBarang> filterData = [];
  final List<DataPenerimaanBarang> _data = [
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "PT Primax Pharna XXXXXXXXXXXXXXX",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
    DataPenerimaanBarang(
        namaBarang: "namaBarang",
        kategoriBarang: "kategoriBarang",
        kode: "kode",
        hargaJual: "hargaJual",
        hargaBeli: "hargaBeli",
        kadaluarsa: "kadaluarsa",
        stok: "stok",
        satuan: "satuan",
        noBatch: "noBatch",
        namaSupplier: "namaSupplier",
        namaPenerimaBarang: "namaPenerimaBarang"),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterData = List.from(_data);
    _tabController = TabController(length: 3, vsync: this);
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
      appBar: NavbarTop(
          title: "PENERIMAAN BARANG",
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
                isScrollable: true, // Tab hanya selebar teksnya
                labelColor: Colors.blue, // Warna teks aktif
                unselectedLabelColor: Colors.black, // Warna teks tidak aktif
                indicatorColor: Colors.blue, // Warna indikator bawah
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                labelPadding: const EdgeInsets.only(left: 0, right: 16),
                tabs: [
                  Tab(text: "Penerimaan"),
                  Tab(text: "Statistik"),
                  Tab(text: "Riwayat"),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 16)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Input",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.button_green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                ),
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  height: 32,
                                  width: 242,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorStyle.fill_stroke,
                                        width: 1),
                                    color: ColorStyle.fill_form,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 8)),
                                      Icon(
                                        Icons.search_outlined,
                                        color: Color(0XFF1B1442),
                                        size: 30,
                                      ),
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
                                              color: ColorStyle.tulisan_form,
                                              fontSize: 14,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 8))
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text("Rows per page:"),
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
                                                    color: Colors.black),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _rowsPerPage = value!;
                                      });
                                    },

                                    // **Atur Tampilan Input**
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      constraints:
                                          BoxConstraints(maxHeight: 30),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Border radius halus
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: ColorStyle
                                                .button_grey), // Saat aktif, border lebih gelap
                                      ),
                                    ),

                                    // **Atur Tampilan Dropdown**
                                    buttonStyleData: ButtonStyleData(
                                      height: 25, // Tinggi tombol dropdown
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              6), // Jarak dalam dropdown
                                    ),

                                    // **Atur Tampilan Dropdown yang Muncul**
                                    dropdownStyleData: DropdownStyleData(
                                      width:
                                          65, // Lebar dropdown harus sama dengan input
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey),
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
                              Text("Page $endIndex of ${filterData.length}"),
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
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Expanded(child: LayoutBuilder(
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
                                  columns: const [
                                    DataColumn(
                                        label: Expanded(
                                            child: Center(
                                                child: Text('ID',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Center(
                                                child: Text('Nama Obat',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Center(
                                                child: Text('Nama Supplier',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Center(
                                                child: Text('Jumlah Barang',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Center(
                                                child: Text('Status',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Center(
                                                child: Text('Actions',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ],
                                  rows: paginatedData.map((item) {
                                    return DataRow(
                                      color: MaterialStateProperty.all(
                                          Colors.white),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(item.kode,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                )))),
                                        DataCell(Center(
                                            child: Text(item.namaBarang,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                )))),
                                        DataCell(
                                          Center(
                                            child: SizedBox(
                                              width: 100,
                                              child: Text(
                                                item.namaSupplier,
                                                overflow: TextOverflow.visible,
                                                style: TextStyle(
                                                  color:
                                                      ColorStyle.text_secondary,
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
                                            child: Text(item.stok,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      ColorStyle.text_secondary,
                                                  fontSize: 14,
                                                )))),
                                        DataCell(
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: item.stok == '10'
                                                      ? Colors.green
                                                      : Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.stok == '10'
                                                      ? "BERHASIL"
                                                      : "'GAGAL",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              PopupMenuButton<int>(
                                                icon: Icon(Icons.more_horiz),
                                                offset: Offset(0,
                                                    40), // Mengatur posisi dropdown ke bawah
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // Membuat sudut melengkung
                                                ),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 1,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            color: ColorStyle
                                                                .text_secondary),
                                                        SizedBox(width: 8),
                                                        Text("Edit"),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 2,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete,
                                                            color: ColorStyle
                                                                .text_secondary),
                                                        SizedBox(width: 8),
                                                        Text("Hapus"),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // IconButton(
                                              //     icon: Icon(Icons.more_horiz),
                                              //     onPressed: () {}),
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
                        },
                      )),
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
}
