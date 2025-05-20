import 'package:apotek/Gudang/Produk/Kategori.dart';
import 'package:apotek/SideBar.dart';
import 'package:apotek/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Login2());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Apotek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // textSelectionTheme: TextSelectionThemeData(
        //   cursorColor: Colors.black,
        //   // selectionColor: Colors.grey.shade300, // warna highlight saat seleksi
        //   selectionHandleColor: Colors.black, // titik pegangan seleksi
        // ),
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isExpanded = false;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Sidebarapotek(isExpanded: isExpanded, onMenuPressed: toggleSidebar),
      body: Sidebarcoba2(isExpanded: isExpanded, onMenuPressed: toggleSidebar),
      // body: Coba2(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
      // body: Produkcoba2(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
      // body: Kategori(isExpanded: isExpanded, toggleSidebar: toggleSidebar),
      // body: FilterScreen(),
    );
  }
}
