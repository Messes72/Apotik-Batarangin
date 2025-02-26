import 'package:apotek/Gudang/Penerimaan/penerimaanBarang.dart';
import 'package:apotek/Gudang/Produk/produk.dart';
import 'package:apotek/Gudang/Stock/stokopname.dart';
import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/login.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onMenuPressed;

  const Sidebar(
      {super.key, required this.isExpanded, required this.onMenuPressed});
  @override
  State<Sidebar> createState() => _SideBarPage();
}

class _SideBarPage extends State<Sidebar> {
  int kepilih = 0;
  bool isExpanded = false;
  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  late final List<Widget> screenApp;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    screenApp = [
      produk(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
      stokopname(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
      PenerimaanBarang(isExpanded: isExpanded, toggleSidebar: toggleSidebar)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isExpanded,
            backgroundColor: ColorStyle.primary,
            leading: isExpanded
                ? Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 1
                      )
                    )
                  ),
                    child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Image.asset('images/logo_apotik.png', height: 60),
                          Text(
                            "Apotik Bantarangin\nGeneral Hospital",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    
                  )
                : Container(decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 1
                  )
                )
                                  ),child: Image.asset('images/logo_apotik.png', height: 60)),
            trailing: isExpanded ?  Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white,
                        width: 1
                      )
                    )
                  ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        Text("Keluar", style: TextStyle(color: Colors.white),)
                      ],
                    ),
                  ),
                ),
              ),
            ): Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white,
                        width: 1
                      )
                    )
                  ),
                    child: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            destinations: [
              NavigationRailDestination(
                  icon: Icon(
                    Icons.inventory,
                    color: Colors.white,
                  ),
                  selectedIcon: Icon(
                    Icons.inventory,
                    color: Colors.white,
                  ),
                  label: Text("Produk", style: TextStyle(color: Colors.white),)),
              NavigationRailDestination(
                  icon: Icon(
                    Icons.list_alt,
                    color: Colors.white,
                  ),
                  selectedIcon: Icon(
                    Icons.list_alt,
                    color: Colors.white,
                  ),
                  label: Text("Stock Opname", style: TextStyle(color: Colors.white))),
              NavigationRailDestination(
                  icon: Icon(
                    Icons.inbox_outlined,
                    color: Colors.white,
                  ),
                  selectedIcon: Icon(
                    Icons.inbox_outlined,
                    color: Colors.white,
                  ),
                  label: Text("Penerimaan Barang",style: TextStyle(color: Colors.white))),
            ],
            selectedIndex: kepilih,
            onDestinationSelected: (index) {
              setState(() {
                kepilih = index;
              });
            },
          ),
          Expanded(child: screenApp[kepilih])
        ],
      ),
    );
  }
}
