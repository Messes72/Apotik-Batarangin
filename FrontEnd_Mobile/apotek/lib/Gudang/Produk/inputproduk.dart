import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apotek/global.dart' as global;

class Inputproduk extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const Inputproduk(
      {super.key, required this.isExpanded, required this.toggleSidebar});
  @override
  State<Inputproduk> createState() => pageInputProduk();
}

class pageInputProduk extends State<Inputproduk> {
  var nomorKartu_text = TextEditingController();
  var nomorBatch_text = TextEditingController();
  var kodeObat_text = TextEditingController();
  var kategori_text = TextEditingController();
  var namaObat_text = TextEditingController();
  var jumlahBarang_text = TextEditingController();
  var caraPemakaian_text = TextEditingController();
  var stokBarang_text = TextEditingController();
  var satuan_text = TextEditingController();
  bool triggerAnimation = false; // Tambahkan variabel isExpanded

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

  String dropdownvalue = 'Item 1';

  var items = [
    'Strip',
    'Botol',
    'Pcs',
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

  @override
  Widget build(BuildContext context) {
    bool isExpanded = false; // Tambahkan variabel isExpanded

    void onMenuPressed() {
      setState(() {
        isExpanded = !isExpanded; // Toggle sidebar
      });
    }

    return Scaffold(
      appBar: NavbarTop(
          title: "INPUT PRODUK",
          onMenuPressed: widget.toggleSidebar,
          isExpanded: widget.isExpanded,
          animationTrigger: onMenuPressed,
          animation: triggerAnimation),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    global.selectedIndex = 0;
                    global.selectedScreen = 0;
                  });
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text("Kembali",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorStyle.warna_form,
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 24)),
                        _buildFormRow(
                            "Nomer Kartu",
                            "Nomer Kartu",
                            "Nomer Batch",
                            "Nomer Batch",
                            nomorKartu_text,
                            nomorBatch_text),
                        _buildFormRow("Kode Obat", "Kode Obat", "Kategori",
                            "Kategori", kodeObat_text, kategori_text),
                        // _buildFormRow("Nama Obat", "Nama Obat", "", "",
                        //     namaObat_text, namaObat_text),
                        // _buildInputField2(
                        //     "Nama Obat", "Nama Obat", namaObat_text),
                        // formDateDropDown("Kadaluarsaa", "DD/MM/YYYY", "Satuan",
                        //     "Pilih", tanggalController, satuan_text),
                        // _buildFormRow(
                        //     "Jumlah Barang Masuk",
                        //     "Barang Masuk",
                        //     "Stock Barang",
                        //     "Stock Barang",
                        //     jumlahBarang_text,
                        //     stokBarang_text),
                        _buildFormDate("Nama Obat", "Nama Obat", "Kadaluarsa",
                            "DD/MM/YYYY", namaObat_text, tanggalController),
                        _buildFormDropdown(
                            "Satuan",
                            "Pilih Satuan",
                            "Jumlah Barang",
                            "Jumlah Barang",
                            satuan_text,
                            jumlahBarang_text),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24), // Tambahkan right padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("Cara Pemakaian",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(" *",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ColorStyle.button_red)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: ColorStyle.fill_form,
                                  border:
                                      Border.all(color: ColorStyle.fill_stroke),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  controller: caraPemakaian_text,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Cara Pemakaian",
                                    hintStyle: TextStyle(
                                      color: ColorStyle.tulisan_form,
                                      fontSize: 14,
                                    ),
                                  ),
                                  maxLines: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorStyle.button_green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("SAVE",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

// buat form biasa
  Widget _buildFormRow(String label1, String hint1, String label2, String hint2,
      TextEditingController text, TextEditingController text2) {
    return Row(
      children: [
        Expanded(child: _buildInputField(label1, hint1, text)),
        const SizedBox(width: 16),
        if (label2.isNotEmpty)
          Expanded(child: _buildInputField(label2, hint2, text2)),
        Padding(padding: EdgeInsets.only(right: 24))
      ],
    );
  }

  Widget _buildFormDate(String label1, String hint1, String label2,
      String hint2, TextEditingController text, TextEditingController text2) {
    return Row(
      children: [
        Expanded(child: _buildInputField(label1, hint1, text)),
        const SizedBox(width: 16),
        if (label2.isNotEmpty)
          Expanded(child: tanggalInput(label2, hint2, text2)),
        Padding(padding: EdgeInsets.only(right: 24))
      ],
    );
  }

  Widget _buildFormDropdown(String label1, String hint1, String label2,
      String hint2, TextEditingController text, TextEditingController text2) {
    return Row(
      children: [
        Expanded(child: dropDownSatuan(label1, hint1, text)),
        const SizedBox(width: 16),
        if (label2.isNotEmpty)
          Expanded(child: _buildInputField(label2, hint2, text2)),
        Padding(padding: EdgeInsets.only(right: 24))
      ],
    );
  }

// buat pilih tanggal dan dropdown
  // Widget formDateDropDown(String label1, String hint1, String label2,
  //     String hint2, TextEditingController text, TextEditingController text2) {
  //   return Row(
  //     children: [
  //       Expanded(child: tanggalInput(label1, hint1, text)),
  //       const SizedBox(width: 16),
  //       if (label2.isNotEmpty)
  //         Expanded(child: dropDownSatuan(label2, hint2, text2)),
  //       Padding(padding: EdgeInsets.only(right: 24))
  //     ],
  //   );
  // }

// custom form
  Widget _buildInputField(
      String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(" *",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.button_red)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: ColorStyle.fill_stroke),
              color: ColorStyle.fill_form,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: text,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInputField2(
      String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(" *",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.button_red)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: ColorStyle.fill_stroke),
              color: ColorStyle.fill_form,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: text,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: ColorStyle.tulisan_form,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

// custom tanggal
  Widget tanggalInput(String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: ColorStyle.fill_stroke),
              color: ColorStyle.fill_form,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  readOnly: true,
                  controller: text,
                  onTap: () {
                    _selectedDate(context);
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: ColorStyle.tulisan_form,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _selectedDate(context);
                  },
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: ColorStyle.tulisan_form,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

// custom dropdown (masih bermasalah)
  Widget dropDown(String label, String hint, TextEditingController text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: ColorStyle.fill_stroke),
              color: ColorStyle.fill_form,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  readOnly: true,
                  controller: text,
                  onTap: () {},
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: ColorStyle.tulisan_form,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: ColorStyle.tulisan_form,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Custom dropdown dengan DropdownButtonFormField
  Widget dropDownSatuan(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(" *",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.button_red)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: ColorStyle.fill_stroke),
              color: ColorStyle.fill_form,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: controller.text.isNotEmpty ? controller.text : null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12), // Padding lebih rapi
              ),
              isExpanded: true, // Agar tidak terlalu lebar
              dropdownColor: ColorStyle.fill_form, // Warna dropdown
              icon: const Icon(Icons.arrow_drop_down), // Icon lebih jelas
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style:
                        TextStyle(color: ColorStyle.tulisan_form, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                controller.text = newValue!;
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
