import 'package:flutter/material.dart';


class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool isExpanded = false; // Untuk animasi memanjang ke bawah
  bool showMoreCategories = false;
  List<Map<String, dynamic>> allItems = [
    {"title": "Obat Panas", "isChecked": false},
    {"title": "Obat Flu", "isChecked": false},
    {"title": "Obat Batuk", "isChecked": false},
    {"title": "Suplemen", "isChecked": false},
    {"title": "Vitamin", "isChecked": false},
    {"title": "Antibiotik", "isChecked": false},
  ];

  List<String> stockOptions = [">5", ">10", "<5", "<10"];
  String? selectedUnit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Filter dengan animasi
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Filter",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black,
                  )
                ],
              ),
            ),
            
            SizedBox(height: 8),

            // Animated Container untuk ekspansi
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isExpanded ? 500 : 0, // Memanjang ke bawah
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),

                    // Kategori Obat
                    Text("Kategori Obat", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...allItems.sublist(0, 4).map((item) {
                      return CheckboxListTile(
                        title: Text(item["title"]),
                        value: item["isChecked"],
                        onChanged: (value) {
                          setState(() {
                            item["isChecked"] = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),

                    // Tombol "Lainnya"
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showMoreCategories = !showMoreCategories;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(showMoreCategories
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_right),
                            Text("Lainnya", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),

                    // Kategori tambahan
                    if (showMoreCategories)
                      Column(
                        children: allItems.sublist(4).map((item) {
                          return CheckboxListTile(
                            title: Text(item["title"]),
                            value: item["isChecked"],
                            onChanged: (value) {
                              setState(() {
                                item["isChecked"] = value!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      ),

                    Divider(),

                    // Nomor Batch & Kadaluarsa
                    _buildFilterOption("Nomor Batch"),
                    _buildFilterOption("Kadaluarsa Obat"),

                    Divider(),

                    // Jumlah Stock
                    Text("Jumlah Stock", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...stockOptions.map((option) {
                      return CheckboxListTile(
                        title: Text(option),
                        value: false,
                        onChanged: (value) {},
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),

                    Divider(),

                    // Dropdown Satuan
                    Text("Satuan", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      hint: Text("Pilih Satuan"),
                      value: selectedUnit,
                      items: ["Pcs", "Box", "Botol"].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value;
                        });
                      },
                    ),

                    Divider(),

                    // Batas Harga
                    Text("Batas Harga", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Rp. Minimal",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Rp. Maximal",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
          Icon(Icons.filter_list),
        ],
      ),
    );
  }
}
