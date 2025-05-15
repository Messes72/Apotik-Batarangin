import 'package:flutter/material.dart';

class Percobaan extends StatelessWidget {
  const Percobaan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Popup Filter"),
          actions: [
            FilterButton(), // Tombol Filter dengan Icon & Teks
          ],
        ),
        body: const Center(child: Text("Daftar Produk")),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50), // Menyesuaikan posisi popup
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton.icon(
          onPressed: null, // Biarkan null agar hanya menu popup yang aktif
          icon: const Icon(Icons.filter_list, color: Colors.white),
          label: const Text("Filter", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Warna tombol hijau
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      onSelected: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Filter dipilih: $value")),
        );
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: "Kategori",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kategori Obat", style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: const Text("Obat Panas"),
                value: false,
                onChanged: (bool? value) {},
              ),
              CheckboxListTile(
                title: const Text("Obat Flu"),
                value: false,
                onChanged: (bool? value) {},
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: "Jumlah Stock",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Jumlah Stock", style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: const Text("> 5"),
                value: false,
                onChanged: (bool? value) {},
              ),
              CheckboxListTile(
                title: const Text("> 10"),
                value: false,
                onChanged: (bool? value) {},
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: "Harga",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Batas Harga", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Rp. Minimal",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Rp. Maksimal",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
