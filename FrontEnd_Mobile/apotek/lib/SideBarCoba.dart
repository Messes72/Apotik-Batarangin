import 'package:apotek/Gudang/Penerimaan/penerimaanBarang.dart';
import 'package:apotek/Gudang/Produk/produk.dart';
import 'package:apotek/Gudang/Stock/stokopname.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/login.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';

class Sidebarcoba extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onMenuPressed;

  const Sidebarcoba({
    super.key,
    required this.isExpanded,
    required this.onMenuPressed,
  });

  @override
  State<Sidebarcoba> createState() => _SideBarPage();
}

class _SideBarPage extends State<Sidebarcoba> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  int kepilih = 0;
  bool isExpanded = false;

  late final List<Widget> screenApp;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded; // Inisialisasi dari widget
    screenApp = [
      produk(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
      stokopname(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
      PenerimaanBarang(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
    ];

    sideMenu.addListener((index) {
      setState(() {
        kepilih = index; // Perbarui indeks halaman
      });
    });
  }

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: ColorStyle.primary),
            child: Column(
              children: [
                Expanded(
                  child: SideMenu(
                    controller: sideMenu,
                    style: SideMenuStyle(
                      backgroundColor: ColorStyle.primary,
                      selectedColor: ColorStyle.hover,
                      selectedTitleTextStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      selectedIconColor: Colors.white,
                      unselectedTitleTextStyle: TextStyle(color: Colors.white),
                      unselectedIconColor: Colors.white,
                      itemBorderRadius: BorderRadius.circular(10),
                      displayMode: isExpanded
                          ? SideMenuDisplayMode.open
                          : SideMenuDisplayMode.compact,
                    ),
                    title: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset('images/logo_apotik.png', height: 50),
                            if (isExpanded)
                              Text(
                                "Apotik Bantarangin\nGeneral Hospital",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                          ],
                        ),
                        Divider(color: Colors.white),
                        SizedBox(height: 40),
                      ],
                    ),
                    items: [
                      SideMenuItem(
                        title: 'Product',
                        icon: Icon(Icons.inventory_2_rounded),
                        onTap: (index, _) {
                          setState(() {
                            kepilih = index;
                            isExpanded = false;
                          });
                        },
                      ),
                      SideMenuItem(
                        title: 'Stock Opname',
                        icon: Icon(Icons.assignment_return),
                        onTap: (index, _) {
                          setState(() {
                            kepilih = index;
                            isExpanded = false;
                          });
                        },
                      ),
                      SideMenuItem(
                        title: 'Penerimaan Barang',
                        icon: Icon(Icons.archive),
                        onTap: (index, _) {
                          setState(() {
                            kepilih = index;
                            isExpanded = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Tombol Logout tetap di bawah
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                top:
                                    BorderSide(color: Colors.white, width: 1))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Pastikan ini ada
                          children: [
                            Divider(
                                color: Colors.white,
                                thickness: 1), // Tambahkan thickness
                            Row(
                              children: [
                                Icon(Icons.exit_to_app,
                                    color: Colors.white, size: 30),
                                if (isExpanded)
                                  SizedBox(
                                      width: 5), // Jarak antara ikon dan teks
                                if (isExpanded)
                                  Text(
                                    "Keluar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: screenApp[kepilih]), // Halaman yang aktif
        ],
      ),
    );
  }
}
