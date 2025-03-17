import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FilterScreen(),
  ));
}

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // State untuk checkbox
  Map<String, bool> kategoriObat = {
    "Obat Panas": false,
    "Obat Flu": false,
    "Obat Batuk": false,
    "Suplemen": false,
  };

  Map<String, bool> jumlahStock = {
    "> 5": false,
    "> 10": false,
    "< 5": false,
    "< 10": false,
  };

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_alt, size: 20, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      "Filter",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Kategori Obat
                _buildFilterSection("Kategori Obat", kategoriObat),

                // Sorting
                _buildSortingOption("Nomor Batch"),
                _buildSortingOption("Kadaluarsa Obat"),

                // Jumlah Stock
                _buildFilterSection("Jumlah Stock", jumlahStock),

                // Satuan
                _buildDropdown("Satuan", "Pilih Satuan", ["Kg", "L", "Pcs", "Box"]),

                // Batas Harga
                _buildFilterSectionTextFields("Batas Harga"),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Center(
                    child: Text("Terapkan Filter", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget: Checkbox List dengan State
  Widget _buildFilterSection(String title, Map<String, bool> options) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...options.keys.map((key) => CheckboxListTile(
                title: Text(key, style: const TextStyle(fontSize: 14)),
                value: options[key],
                onChanged: (bool? value) {
                  setState(() {
                    options[key] = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              )),
        ],
      ),
    );
  }

  // Widget: Sorting Option
  Widget _buildSortingOption(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        "$title ⬍",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget: Dropdown
  Widget _buildDropdown(String title, String hint, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            hint: Text(hint, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  // Widget: Text Field untuk Batas Harga
  Widget _buildFilterSectionTextFields(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              hintText: "Rp. Minimal",
              hintStyle: const TextStyle(fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              hintText: "Rp. Maximal",
              hintStyle: const TextStyle(fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filter Example"), backgroundColor: Colors.black),
      body: Center(
        child: SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () => _showFilterModal(context),
            icon: const Icon(Icons.filter_alt, color: Colors.black, size: 22),
            label: const Text("Filter", style: TextStyle(color: Colors.black, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
