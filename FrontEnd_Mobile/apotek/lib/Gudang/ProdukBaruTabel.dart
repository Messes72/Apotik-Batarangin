import 'package:flutter/material.dart';

class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final List<Map<String, dynamic>> _data = List.generate(
    52, // Total 52 data
    (index) => {
      "kode": "OB001",
      "nama": "Paracetamol",
      "kategori": "Obat Panas",
      "stok": 10,
    },
  );

  int _rowsPerPage = 10; // Default jumlah baris per halaman
  int _currentPage = 0; // Halaman saat ini

  @override
  Widget build(BuildContext context) {
    int totalPages = (_data.length / _rowsPerPage).ceil();
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex =
        (startIndex + _rowsPerPage).clamp(0, _data.length); // Batas aman
    List<Map<String, dynamic>> paginatedData =
        _data.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(title: Text('PRODUK')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown di atas tabel
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Rows per page:"),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: [5, 10, 20, 50]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.toString())))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _rowsPerPage = value!;
                      _currentPage = 0; // Reset ke halaman pertama
                    });
                  },
                ),
                Text("Page $endIndex of ${_data.length}"),
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
            SizedBox(height: 10),
            // Tabel
            // Table with Fixed Header
            Expanded(
              child: Column(
                children: [
                  // HEADER TABLE (Tetap di Tempat)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    // color: Colors.grey[200], // Background header
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        _buildHeaderCell("Kode Obat"),
                        _buildHeaderCell("Nama Obat"),
                        _buildHeaderCell("Kategori"),
                        _buildHeaderCell("Stock Barang"),
                        _buildHeaderCell("Actions"),
                      ],
                    ),
                  ),

                  // SCROLLABLE TABLE CONTENT
                  Expanded(
                    child: ListView.builder(
                      itemCount: paginatedData.length,
                      itemBuilder: (context, index) {
                        var item = paginatedData[index];
                        return Container(
                          decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Row(
                            children: [
                              _buildCell(item["kode"]),
                              _buildCell(item["nama"]),
                              _buildCell(item["kategori"]),
                              _buildCell(item["stok"].toString()),
                              _buildCellActions(),
                            ],
                          ),
                        );
                      },
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

  // Fungsi untuk membuat header tabel
  Widget _buildHeaderCell(String text) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Fungsi untuk membuat isi sel tabel
  Widget _buildCell(String text) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }

  // Fungsi untuk membuat kolom Actions
  Widget _buildCellActions() {
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.open_in_new), onPressed: () {}),
          IconButton(icon: Icon(Icons.edit), onPressed: () {}),
          IconButton(icon: Icon(Icons.delete), onPressed: () {}),
        ],
      ),
    );
  }
}
