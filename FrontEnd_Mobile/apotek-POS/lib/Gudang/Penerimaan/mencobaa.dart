import 'package:apotek/Theme/ColorStyle.dart';
import 'package:flutter/material.dart';


class Mencobaa extends StatefulWidget {
  const Mencobaa({Key? key}) : super(key: key);

  @override
  _MencobaaState createState() => _MencobaaState();
}

class _MencobaaState extends State<Mencobaa>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _selectedColor = Color(0xff1a73e8);
  final _unselectedColor = Color(0xff5f6368);
  final _tabs = [
    Tab(text: 'Tab1'),
    Tab(text: 'Tab2'),
    Tab(text: 'Tab3'),
  ];

  final _iconTabs = [
    Tab(icon: Icon(Icons.home)),
    Tab(icon: Icon(Icons.search)),
    Tab(icon: Icon(Icons.settings)),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _selectedColor,
        title: Text("Custom Tab Bars"),
      ),
      body: ListView(
        children: [
          ///Default Tabbar with full width tabbar indicator
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            labelColor: _selectedColor,
            indicatorColor: _selectedColor,
            unselectedLabelColor: _unselectedColor,
          ),
      
          ///Default Tabbar with indicator width of the label
         Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding:  EdgeInsets.zero,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: ColorStyle.primary, // Warna teks saat aktif
                    unselectedLabelColor:
                        Colors.black, // Warna teks saat tidak aktif
                    indicatorColor:
                        ColorStyle.primary, // Warna garis bawah tab aktif
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    isScrollable: true,
                    labelPadding: const EdgeInsets.only(left: 0, right: 16),
                    // dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: "Penerimaan"),
                      Tab(text: "Statistik"),
                      Tab(text: "Riwayat"),
                    ],
                  ),
                ),
              ),
            ),
         
      
          /// Custom Tabbar with solid selected bg and transparent tabbar bg
          Container(
            height: kToolbarHeight - 8.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: _selectedColor),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: _tabs,
            ),
          ),
      
          /// Custom Tabbar with solid selected bg and transparent tabbar bg
          Container(
            height: kToolbarHeight + 8.0,
            padding:
                const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),
                  color: Colors.white),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              tabs: _tabs,
            ),
          ),
      
          /// Custom Tabbar with transparent selected bg and solid selected text
          TabBar(
            controller: _tabController,
            tabs: _iconTabs,
            unselectedLabelColor: Colors.black,
            labelColor: _selectedColor,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(80.0),
              color: _selectedColor.withOpacity(0.2),
            ),
          ),
      
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            unselectedLabelColor: Colors.black,
            labelColor: _selectedColor,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(80.0),
              color: _selectedColor.withOpacity(0.2),
            ),
          ),
        ]
            .map((item) => Column(
                  /// Added a divider after each item to let the tabbars have room to breathe
                  children: [
                    item,
                    Divider(
                      color: Colors.transparent,
                    )
                  ],
                ))
            .toList(),
      ),
    );
  }
}
