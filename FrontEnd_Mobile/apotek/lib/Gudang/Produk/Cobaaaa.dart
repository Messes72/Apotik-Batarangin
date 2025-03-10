import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<Map<String, dynamic>> kategoriObat = [
    {"name": "Obat Panas", "selected": false},
    {"name": "Obat Flu", "selected": false},
    {"name": "Obat Batuk", "selected": false},
    {"name": "Suplemen", "selected": false},
  ];

  bool showMoreKategori = false; // Untuk expand kategori "Lainnya"

  List<Map<String, dynamic>> jumlahStock = [
    {"name": "> 5", "selected": false},
    {"name": "> 10", "selected": false},
    {"name": "< 5", "selected": false},
    {"name": "< 10", "selected": false},
  ];

  String? selectedSatuan;
  final TextEditingController minHargaController = TextEditingController();
  final TextEditingController maxHargaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produk')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupMenuButton<int>(
              onSelected: (value) {},
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        width: 300, // Lebar popup
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Kategori Obat"),
                              _buildCheckboxList(kategoriObat, setState),

                              // Expandable "Lainnya"
                              ListTile(
                                title: Text("Lainnya"),
                                trailing: Icon(showMoreKategori
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down),
                                onTap: () {
                                  setState(() {
                                    showMoreKategori = !showMoreKategori;
                                  });
                                },
                              ),
                              if (showMoreKategori) ...[
                                CheckboxListTile(
                                  title: Text("Vitamin"),
                                  value: false,
                                  onChanged: (val) {},
                                ),
                                CheckboxListTile(
                                  title: Text("Obat Herbal"),
                                  value: false,
                                  onChanged: (val) {},
                                ),
                              ],

                              Divider(),
                              _buildSectionTitle("Jumlah Stock"),
                              _buildCheckboxList(jumlahStock, setState),

                              Divider(),
                              _buildSectionTitle("Satuan"),
                              DropdownButtonFormField<String>(
                                value: selectedSatuan,
                                hint: Text("Pilih Satuan"),
                                onChanged: (value) {
                                  setState(() => selectedSatuan = value);
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                                items: ["Tablet", "Kapsul", "Sirup"].map((satuan) {
                                  return DropdownMenuItem(
                                    value: satuan,
                                    child: Text(satuan),
                                  );
                                }).toList(),
                              ),

                              Divider(),
                              _buildSectionTitle("Batas Harga"),
                              TextField(
                                controller: minHargaController,
                                decoration: InputDecoration(
                                  labelText: "Rp. Minimal",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: maxHargaController,
                                decoration: InputDecoration(
                                  labelText: "Rp. Maximal",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Tutup popup
                                  print("Filter diterapkan");
                                },
                                child: Text("Terapkan Filter"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              child: ElevatedButton.icon(
                onPressed: null,
                icon: Icon(Icons.filter_alt, color: Colors.black, size: 22),
                label: const Text("Filter",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: Colors.grey, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCheckboxList(List<Map<String, dynamic>> data, Function setState) {
    return Column(
      children: data.map((item) {
        return CheckboxListTile(
          title: Text(item["name"]),
          value: item["selected"],
          onChanged: (val) {
            setState(() => item["selected"] = val);
          },
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }
}
