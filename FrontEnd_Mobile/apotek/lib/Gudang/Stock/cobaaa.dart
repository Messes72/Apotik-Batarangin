import 'package:flutter/material.dart';

class StockOpnameModel {
  String name;
  int quantity;
  String status;

  StockOpnameModel({required this.name, required this.quantity, required this.status});
}

class StokOpnamePage extends StatefulWidget {
  @override
  _StokOpnamePageState createState() => _StokOpnamePageState();
}

class _StokOpnamePageState extends State<StokOpnamePage> {
  List<StockOpnameModel> _data = [
    StockOpnameModel(name: 'Product A', quantity: 50, status: 'Berhasil'),
    StockOpnameModel(name: 'Product B', quantity: 20, status: 'Gagal'),
    StockOpnameModel(name: 'Product C', quantity: 30, status: 'Berhasil'),
  ];

  void _editStock(StockOpnameModel item) {
    TextEditingController nameController = TextEditingController(text: item.name);
    TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
    String selectedStatus = item.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: selectedStatus,
                items: ['Berhasil', 'Gagal'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item.name = nameController.text;
                  item.quantity = int.tryParse(quantityController.text) ?? item.quantity;
                  item.status = selectedStatus;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stock Opname")),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _data.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.name)),
                DataCell(Text(item.quantity.toString())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == 'Berhasil' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataCell(IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editStock(item),
                ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
