import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class COBATRANSAKSI extends StatefulWidget {
  @override
  _COBATRANSAKSIState createState() => _COBATRANSAKSIState();
}

class _COBATRANSAKSIState extends State<COBATRANSAKSI> {
  List<Map<String, dynamic>> paginatedData = List.generate(15, (index) {
    return {
      'namaObat': 'Nama Obat',
      'idObat': 'Kode Obat',
      'stokMinimum': index % 5 == 0 ? 0 : (index % 4 == 0 ? 8 : 20),
      'namaSatuan': 'Strip',
    };
  });

  List<Map<String, dynamic>> kwitansi = [
    {'nama': 'Paracetamol', 'jumlah': 0, 'harga': 3500},
    {'nama': 'Allopurinol', 'jumlah': 0, 'harga': 4000},
    {'nama': 'Ibuprofen', 'jumlah': 0, 'harga': 5500},
  ];

  String formatRupiah(int number) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  // int hitungTotalHarga() {
  //   return kwitansi.fold(0, (total, item) => total + (item['jumlah'] * item['harga']));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff4d7d4),
      body: SafeArea(
        child: Row(
          children: [
            // KIRI
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChoiceChip(label: Text('Obat'), selected: true),
                      SizedBox(width: 8),
                      ChoiceChip(label: Text('Racikan'), selected: false),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: paginatedData.map((obat) {
                        Color? badgeColor;
                        String? badgeText;
                        if (obat['stokMinimum'] == 0) {
                          badgeColor = Colors.red;
                          badgeText = 'Habis';
                        } else if (obat['stokMinimum'] <= 10) {
                          badgeColor = Colors.orange;
                          badgeText = 'Sisa';
                        }
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.medical_services, size: 32),
                                SizedBox(height: 8),
                                Text("${obat['namaObat']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("${obat['idObat']}",
                                    style: TextStyle(fontSize: 12)),
                                Text(
                                    "Stock : ${obat['stokMinimum']} ${obat['namaSatuan']}",
                                    style: TextStyle(fontSize: 12)),
                                if (badgeText != null)
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: Text("Tambah"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    children: [Text("ayam mabawa")],
                  ),
                ],
              ),
            ),

            // KANAN
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Kwitansi Obat",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        CircleAvatar(child: Icon(Icons.person))
                      ],
                    ),
                    SizedBox(height: 16),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnWidths: {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(
                          decoration:
                              BoxDecoration(color: Colors.grey.shade200),
                          children: [
                            _tableCell('Nama Obat', true),
                            _tableCell('Jumlah', true),
                            _tableCell('Harga', true),
                          ],
                        ),
                        ...kwitansi.map((item) {
                          return TableRow(children: [
                            _tableCell(item['nama']),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () {
                                      setState(() {
                                        if (item['jumlah'] > 0)
                                          item['jumlah']--;
                                      });
                                    },
                                  ),
                                  Text('${item['jumlah']}'),
                                  IconButton(
                                    icon: Icon(Icons.add_circle),
                                    onPressed: () {
                                      setState(() {
                                        item['jumlah']++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            _tableCell(formatRupiah(item['harga'])),
                          ]);
                        }).toList(),
                      ],
                    ),
                    Spacer(),
                    Text("Total Harga", style: TextStyle(fontSize: 16)),
                    // Text(formatRupiah(hitungTotalHarga()),
                    //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Selanjutnya"),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tableCell(String text, [bool isHeader = false]) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
