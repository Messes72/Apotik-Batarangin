import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';

class Coba2 extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const Coba2(
      {super.key, required this.isExpanded, required this.toggleSidebar});

  @override
  State<Coba2> createState() => stokPage();
}

class StockOpnameModel {
  String name;
  int quantity;
  String status;

  StockOpnameModel(
      {required this.name, required this.quantity, required this.status});
}

class stokPage extends State<Coba2> {
  bool triggerAnimation = false; // Tambahkan variabel isExpanded
  final List<String> genderItems = [
    'Male',
    'Female',
  ];
  String? selectedValue;

  final _formKey = GlobalKey<FormState>();

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  var text = TextEditingController();
  List<StockOpnameModel> _filteredData = [];
  final List<StockOpnameModel> _data = [
    StockOpnameModel(name: 'Product A', quantity: 50, status: 'Berhasil'),
    StockOpnameModel(name: 'Product B', quantity: 20, status: 'Gagal'),
    StockOpnameModel(name: 'Product C', quantity: 30, status: 'Berhasil'),
  ];

  int _rowsPerPage = 5;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(_data);
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = query.isEmpty
          ? List.from(_data)
          : _data
              .where((item) =>
                  item.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
      _currentPage = 0;
    });
  }

  void _editItem(StockOpnameModel item) {
    TextEditingController nameController =
        TextEditingController(text: item.name);
    TextEditingController quantityController =
        TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Nama Produk")),
              TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Jumlah Stok")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Batal")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  int index = _data.indexWhere((e) => e.name == item.name);
                  if (index != -1) {
                    _data[index] = StockOpnameModel(
                      name: nameController.text,
                      quantity: int.tryParse(quantityController.text) ??
                          item.quantity,
                      status: item.status,
                    );
                  }
                  _filterData(text.text);
                });
                Navigator.pop(context);
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_filteredData.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = (startIndex + _rowsPerPage).clamp(0, _filteredData.length);
    List<StockOpnameModel> paginatedData =
        _filteredData.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: NavbarTop(
          title: "STOK OPNAME",
          onMenuPressed: onMenuPressed,
          isExpanded: widget.isExpanded,
          animationTrigger: onMenuPressed,
          animation: triggerAnimation),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: text,
              onChanged: _filterData,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: "Search"),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama Obat')),
                    DataColumn(label: Text('Stock Opname')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: paginatedData.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item.name)),
                        DataCell(Text(item.quantity.toString())),
                        DataCell(Text(item.status)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editItem(item)),
                              IconButton(
                                  icon: Icon(Icons.delete), onPressed: () {}),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text("Page ${_currentPage + 1} of $totalPages"),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButtonFormField2<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        // Add Horizontal padding using menuItemStyleData.padding so it matches
                        // the menu padding when button's width is not specified.
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // Add more decoration..
                      ),
                      hint: const Text(
                        'Select Your Gender',
                        style: TextStyle(fontSize: 14),
                      ),
                      items: genderItems
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select gender.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        //Do something when selected item is changed.
                      },
                      onSaved: (value) {
                        selectedValue = value.toString();
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.only(right: 8),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 24,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                        }
                      },
                      child: const Text('Submit Button'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
