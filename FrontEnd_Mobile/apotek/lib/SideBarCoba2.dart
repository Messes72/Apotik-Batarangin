import 'dart:math';

import 'package:apotek/Gudang/Pembelian/pembeliaanBarang.dart';
import 'package:apotek/Gudang/Produk/inputproduk.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/login.dart';
import 'package:flutter/material.dart';
import 'package:apotek/Gudang/Penerimaan/penerimaanBarang.dart';
import 'package:apotek/Gudang/Produk/produk.dart';
import 'package:apotek/Gudang/Stock/stokopname.dart';
import 'package:apotek/global.dart' as global;

class Sidebarcoba2 extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onMenuPressed;

  const Sidebarcoba2({
    super.key,
    required this.isExpanded,
    required this.onMenuPressed,
  });

  @override
  State<Sidebarcoba2> createState() => _SideBarPage();
}

class _SideBarPage extends State<Sidebarcoba2> {
  bool isExpanded = false;
  // int selectedIndex = 0;
  int hoveredIndex = -1;
  late final List<Widget> screenApp;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
    screenApp = [
      PageProduk(isExpanded: isExpanded, toggleSidebar: toggleSidebar), // 0
      stokopname(isExpanded: isExpanded, toggleSidebar: toggleSidebar), // 1
      PenerimaanBarang(
          isExpanded: isExpanded, toggleSidebar: toggleSidebar), //2
      Inputproduk(isExpanded: isExpanded, toggleSidebar: toggleSidebar), //3
      Pembeliaanbarang(isExpanded: isExpanded, toggleSidebar: toggleSidebar) //4
    ];
  }

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isExpanded ? 250 : 60,
          decoration: BoxDecoration(
            color: ColorStyle.primary,
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black26,
            //     blurRadius: 5,
            //     offset: Offset(2, 0),
            //   ),
            // ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(top: 22)),
              GestureDetector(
                onTap: toggleSidebar,
                child: Row(
                  children: [
                    // Image.asset('images/logo_apotik.png', height: 50),
                    Container(
                      height: 50,
                      width: 55,
                      child: Image.asset(
                        "images/logo_apotik.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                    if (isExpanded)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Apotek Bantarangin\n General Hospital",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(color: Colors.white, thickness: 2),
              SizedBox(
                height: 40,
              ),
              buildMenuItem("images/produk.png", "Product", 0),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              buildMenuItem("images/stockOpname.png", "Stock Opname", 1),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              buildMenuItem("images/pembelian.png", "Pembeliaan Barang", 4),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              buildMenuItem("images/penerimaan.png", "Penerimaan Barang", 2),
              Spacer(),
              Divider(color: Colors.white, thickness: 2),
              buildMenuItem2(Icons.logout, "Keluar", 3),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: screenApp[global.selectedIndex],
          ),
        ),
      ],
    );
  }

  Widget buildMenuItem(String logo, String title, int index) {
    // IconData icon
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = -1),
      child: InkWell(
        onTap: () {
          if (index == 3) {
            setState(() {
              global.selectedIndex = 0; // Reset ke halaman Product
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          } else {
            // Untuk menu lainnya
            setState(() {
              global.selectedIndex = index;
              global.selectedScreen = index;
              // if (index == 3) {
              //   index = 0;
              // }
            });
            isExpanded = false;
            widget.onMenuPressed;
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          color: global.selectedScreen == index
              ? ColorStyle.hover
              : hoveredIndex == index
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 6),
                child: Container(
                  height: 24,
                  width: 24,
                  child: Image.asset(
                    logo,
                    fit: BoxFit.fill,
                  ),
                ),
                // Icon(icon, color: Colors.white, size: 24),
              ),
              if (isExpanded)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem2(IconData icon, String title, int index) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = -1),
      child: InkWell(
        onTap: () {
          if (index == 3) {
            setState(() {
              global.selectedIndex = 0; // Reset ke halaman Product
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          } else {
            // Untuk menu lainnya
            setState(() {
              global.selectedIndex = index;
              global.selectedScreen = index;
              // if (index == 3) {
              //   index = 0;
              // }
            });
            isExpanded = false;
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          color: global.selectedScreen == index
              ? ColorStyle.hover
              : hoveredIndex == index
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 6),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              if (isExpanded)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
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
