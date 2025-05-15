import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apotek/global.dart' as global;

class inputTransaksi extends StatefulWidget {
  final VoidCallback toggleSidebar;
  final bool isExpanded;
  const inputTransaksi(
      {super.key, required this.isExpanded, required this.toggleSidebar});
  @override
  State<inputTransaksi> createState() => _inputTransaksi();
}

final List<String> genderItems = ['Laki-laki', 'Perempuan'];
final List<String> metodePembayaranItems = ['Tunai', 'Gopay', 'Qris'];

String? _selectedStatus;
String? _selectedMetode;

class _inputTransaksi extends State<inputTransaksi> {
  var nomorRekapMedis = TextEditingController();
  var umurKustomer = TextEditingController();
  var namaObat = TextEditingController();
  var satuanObat = TextEditingController();
  var jumlahObat = TextEditingController();
  var hargaSatuaan = TextEditingController();
  var hargaTotal = TextEditingController();
  var stokBarang_text = TextEditingController();
  var satuan_text = TextEditingController();
  bool triggerAnimation = false; // Tambahkan variabel isExpanded

  void onMenuPressed() {
    setState(() {
      triggerAnimation = !triggerAnimation; // Toggle sidebar
    });
  }

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
      // appBar: NavbarTop(
      //     title: "INPUT TRANSAKSI",
      //     onMenuPressed: widget.toggleSidebar,
      //     isExpanded: widget.isExpanded,
      //     animationTrigger: onMenuPressed,
      //     animation: triggerAnimation),
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
                icon: Image.asset("images/back.png"),
                // icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text("Kembali",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                ),
              ),
              const SizedBox(height: 20),
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 26, right: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 24)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tambah Resep Obat",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "dr. [Nama Dokter]",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "John Dave",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "01 Januari 2025",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Nomor Rekap Medis: "),
                              inputField("Nomor Rekap Medis", nomorRekapMedis),
                              Padding(padding: EdgeInsets.only(right: 25)),
                              Text("Gender: "),
                              _dropdownGender(),
                              Padding(padding: EdgeInsets.only(right: 25)),
                              Text("Umur: "),
                              inputField("Umur", umurKustomer)
                            ],
                          ),
                          Text(
                            "Ketik (-) jika tidak ada nomor rekap medis",
                            style: TextStyle(fontSize: 10),
                          ),
                          Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: buildTextField("Nama Obat", namaObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField("Jumlah", jumlahObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                  child: buildTextField("Satuan", satuanObat)),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField(
                                    "Harga Satuan", hargaSatuaan),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child:
                                    buildTextField("Harga Total", hargaTotal),
                              ),
                              Padding(padding: EdgeInsets.only(right: 112)),
                              InkWell(
                                onTap: () {},
                                child: Icon(Icons.delete_outline,
                                    color: ColorStyle.button_red, size: 24),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: buildTextField("Nama Racikan", namaObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField("Kemasan", jumlahObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                  child: buildTextField("Jumlah", satuanObat)),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField(
                                    "Instruksi Pemakaian", hargaSatuaan),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child:
                                    buildTextField("Harga Total", hargaTotal),
                              ),
                              Padding(padding: EdgeInsets.only(right: 112)),
                              InkWell(
                                onTap: () {},
                                child: Icon(Icons.delete_outline,
                                    color: ColorStyle.button_red, size: 24),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),
                          Text(
                            "KOMPOSISI",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15.5)),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  print('Minus button clicked');
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // sudut melengkung
                                    side: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 2), // border merah
                                  ),
                                  backgroundColor: Colors
                                      .white, // latar belakang putih atau bisa Colors.transparent
                                  foregroundColor:
                                      ColorStyle.button_red, // warna ikon
                                  minimumSize: Size(35, 35), // ukuran tombol
                                  padding: EdgeInsets
                                      .zero, // biar ikon pas di tengah
                                  elevation: 0, // tanpa bayangan
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: ColorStyle.button_red,
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(right: 13)),
                              Expanded(
                                child: buildTextField("Nama Obaat", namaObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField("Dosis", jumlahObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                  child: buildTextField("Satuan", satuanObat)),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField(
                                    "Harga Satuan", hargaSatuaan),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 20)),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  print('Minus button clicked');
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // sudut melengkung
                                    side: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 2), // border merah
                                  ),
                                  backgroundColor: Colors
                                      .white, // latar belakang putih atau bisa Colors.transparent
                                  foregroundColor:
                                      ColorStyle.button_red, // warna ikon
                                  minimumSize: Size(35, 35), // ukuran tombol
                                  padding: EdgeInsets
                                      .zero, // biar ikon pas di tengah
                                  elevation: 0, // tanpa bayangan
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: ColorStyle.button_red,
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(right: 13)),
                              Expanded(
                                child: buildTextField("Nama Obaat", namaObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField("Dosis", jumlahObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                  child: buildTextField("Satuan", satuanObat)),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField(
                                    "Harga Satuan", hargaSatuaan),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 20)),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  print('Minus button clicked');
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // sudut melengkung
                                    side: BorderSide(
                                        color: ColorStyle.tulisan_hitam_filter,
                                        width: 2), // border merah
                                  ),
                                  backgroundColor: Colors
                                      .white, // latar belakang putih atau bisa Colors.transparent
                                  foregroundColor: ColorStyle
                                      .tulisan_hitam_filter, // warna ikon
                                  minimumSize: Size(35, 35), // ukuran tombol
                                  padding: EdgeInsets
                                      .zero, // biar ikon pas di tengah
                                  elevation: 0, // tanpa bayangan
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: ColorStyle.tulisan_hitam_filter,
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(right: 13)),
                              Expanded(
                                child: buildTextField("Nama Obaat", namaObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField("Dosis", jumlahObat),
                              ),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                  child: buildTextField("Satuan", satuanObat)),
                              Padding(padding: EdgeInsets.only(right: 35)),
                              Expanded(
                                child: buildTextField(
                                    "Harga Satuan", hargaSatuaan),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 28)),
                          Divider(),
                          Padding(padding: EdgeInsets.only(bottom: 15)),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 5),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: ColorStyle.text_dalam_kolom,
                                        width: 1),
                                  ),
                                ),
                                child: const Text("Tambah Obat",
                                    style: TextStyle(
                                        color: ColorStyle.text_dalam_kolom,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(padding: EdgeInsets.only(right: 25)),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 5),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: ColorStyle.text_dalam_kolom,
                                        width: 1),
                                  ),
                                ),
                                child: const Text("Tambah Racikan",
                                    style: TextStyle(
                                        color: ColorStyle.text_dalam_kolom,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Total Harga",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    "Rp. 0,00",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 18)),
                          Divider(),
                          Padding(padding: EdgeInsets.only(bottom: 27)),
                          Text(
                            "Metode Pembayaran",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          _dropdownMetodePembayaran(),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  global.selectedIndex = 0;
                                  global.selectedScreen = 0;
                                });
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyHomePage()));
                              },
                              icon: Image.asset("images/print.png"),
                              // icon: const Icon(Icons.arrow_back, color: Colors.white),
                              label: const Text("Cetak Struk",
                                  style: TextStyle(
                                      color: ColorStyle.button_green)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: const BorderSide(
                                      color: ColorStyle.button_green, width: 1),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 5),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget inputField(String isi, TextEditingController edit) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Container(
            width: 200,
            height: 30,
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

   Widget _dropdownMetodePembayaran() {
    return Center(
      child: SizedBox(
        width: double.infinity, // Sesuaikan lebar agar tidak terlalu besar
        height: 28, // Tinggi dropdown agar sesuai dengan contoh gambar
        child: DropdownButtonFormField2<String>(
          isExpanded: false, // Jangan meluaskan dropdown ke full width
          value: _selectedMetode,
          hint: Text(
            "Pilih Pembayaran",
            style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
          ),
          items: metodePembayaranItems
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style:
                          TextStyle(fontSize: 12, color: ColorStyle.text_hint),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedMetode = value!;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorStyle.fill_form,
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            constraints: BoxConstraints(maxHeight: 30),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5), // Border radius halus
              borderSide: BorderSide(color: ColorStyle.button_grey),
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
            padding:
                EdgeInsets.symmetric(horizontal: 6), // Jarak dalam dropdown
          ),

          // **Atur Tampilan Dropdown yang Muncul**
          dropdownStyleData: DropdownStyleData(
            width: null, // Lebar dropdown harus sama dengan input
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey),
              color: ColorStyle.fill_form,
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
    );
  }

  Widget _dropdownGender() {
    return Center(
      child: SizedBox(
        width: 200, // Sesuaikan lebar agar tidak terlalu besar
        height: 30, // Tinggi dropdown agar sesuai dengan contoh gambar
        child: DropdownButtonFormField2<String>(
          isExpanded: false, // Jangan meluaskan dropdown ke full width
          value: _selectedStatus,
          hint: Text(
            "Pilih Gender",
            style: TextStyle(fontSize: 12, color: ColorStyle.text_hint),
          ),
          items: genderItems
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style:
                          TextStyle(fontSize: 12, color: ColorStyle.text_hint),
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
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            constraints: BoxConstraints(maxHeight: 30),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5), // Border radius halus
              borderSide: BorderSide(color: ColorStyle.button_grey),
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
            padding:
                EdgeInsets.symmetric(horizontal: 6), // Jarak dalam dropdown
          ),

          // **Atur Tampilan Dropdown yang Muncul**
          dropdownStyleData: DropdownStyleData(
            width: 200, // Lebar dropdown harus sama dengan input
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey),
              color: ColorStyle.fill_form,
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
    );
  }

  Widget buildTextField(String data, TextEditingController isi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: isi,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
