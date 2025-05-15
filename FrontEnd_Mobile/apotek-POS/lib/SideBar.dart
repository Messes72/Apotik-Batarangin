import 'dart:async';

import 'package:apotek/Apotik/Riwayat/RiwayatTransaksi.dart';
import 'package:apotek/Apotik/Transaksi/inputTransaksi.dart';
import 'package:apotek/Apotik/Transaksi/transaksi.dart';
import 'package:apotek/Gudang/Pembelian/pembeliaanBarang.dart';
import 'package:apotek/Gudang/Stock/detailStockOpname.dart';
import 'package:apotek/Gudang/Stock/editStockOpname.dart';
import 'package:apotek/Gudang/Stock/inputStockOpname.dart';
import 'package:apotek/NavbarTop.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/login.dart';
import 'package:flutter/material.dart';
import 'package:apotek/Gudang/Penerimaan/penerimaanBarang.dart';
import 'package:apotek/Gudang/Produk/produk.dart';
import 'package:apotek/Gudang/Stock/stockOpname.dart';
import 'package:apotek/global.dart' as global;
import 'package:google_fonts/google_fonts.dart';

class Sidebarcoba2 extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onMenuPressed;

  const Sidebarcoba2({
    super.key,
    required this.isExpanded,
    required this.onMenuPressed,
  });

  @override
  State<Sidebarcoba2> createState() => _Sidebarcoba2();
}

class _Sidebarcoba2 extends State<Sidebarcoba2> {
  bool isExpanded = false;
  // int selectedIndex = 0;
  int hoveredIndex = -1;
  void changePage(int indexx) {
    setState(() {
      global.selectedIndex = indexx;
    });
  }

  List<Widget> screenApp = [];
  Timer? timerChange;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    // timerChange = Timer.periodic(
    //   Duration(seconds: 1),
    //   (timer) {
    //     setState(() {
    //       pageIndex = global.selectedIndex;
    //     });
    //   },
    // );
    pageIndex = global.selectedIndex;
    isExpanded = widget.isExpanded;
    screenApp = [
      TransaksiPage(isExpanded: isExpanded, toggleSidebar: toggleSidebar), //0
      KustomerApotek(isExpanded: isExpanded, toggleSidebar: toggleSidebar), //1
      inputTransaksi(isExpanded: isExpanded, toggleSidebar: toggleSidebar) //2
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
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600,
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
              //  buildMenuItem("images/dashboard.png", "Dashboard", 5),
              //   Padding(padding: EdgeInsets.only(bottom: 8)),
              buildMenuItem("images/transaksi.png", "Transaksi", 0),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              buildMenuItem("images/kustomer.png", "Riwayat Transaksi", 1),
              Spacer(),
              Divider(color: Colors.white, thickness: 2),
              buildMenuItem2(Icons.logout, "Keluar", 3),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Column(
              children: [
                NavbarTop(
                    title: pageIndex == 0
                        ? "TRANSAKSI"
                        : pageIndex == 1
                            ? "RIWAYAT TRANSAKSI"
                            : pageIndex == 2
                                ? "PENERIMAAN BARANG"
                                : "TIDAK ADA",
                    onMenuPressed: () {
                      setState(() {
                        if (isExpanded) {
                          isExpanded = false;
                        } else {
                          isExpanded = true;
                        }
                      });
                    },
                    isExpanded: isExpanded,
                    animationTrigger: () {},
                    animation: isExpanded ? true : false),
                Expanded(child: screenApp[pageIndex]),
              ],
            ),
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
              pageIndex = index;
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
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
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
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
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
