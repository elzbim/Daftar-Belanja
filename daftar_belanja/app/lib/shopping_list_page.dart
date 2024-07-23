import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'local_notification_service.dart';

class ShoppingListPage extends StatefulWidget {
  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _localNotificationService.init();
  }

  Future<void> _fetchItems() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem(String name, int quantity, int price) async {
    await _dbHelper.insertItem({'name': name, 'quantity': quantity, 'price': price});
    _fetchItems();
    _localNotificationService.showNotification(
      'Item Added',
      'Successfully added item: $name',
    );
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    _fetchItems();
    _localNotificationService.showNotification(
      'Item Deleted',
      'Successfully deleted item with ID: $id',
    );
  }

  Future<void> _updateItem(int id, String name, int quantity, int price) async {
    await _dbHelper.updateItem({'id': id, 'name': name, 'quantity': quantity, 'price': price});
    _fetchItems();
    _localNotificationService.showNotification(
      'Item Updated',
      'Successfully updated item: $name',
    );
  }

  int get _totalPrice {
    int total = 0;
    for (var item in _items) {
      int price = item['price'] is int
          ? item['price']
          : int.tryParse(item['price'].toString()) ?? 0;
      int quantity = item['quantity'] is int
          ? item['quantity']
          : int.tryParse(item['quantity'].toString()) ?? 0;
      total += price * quantity;
    }
    return total;
  }

  void _showAddItemDialog(BuildContext context, {Map<String, dynamic>? item}) {
    final TextEditingController nameController = TextEditingController(text: item?['name']);
    final TextEditingController quantityController = TextEditingController(text: item?['quantity']?.toString());
    final TextEditingController priceController = TextEditingController(text: item?['price']?.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Tambah Item' : 'Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Item'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Kuantitas'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final String name = nameController.text;
                final int quantity = int.tryParse(quantityController.text) ?? 0;
                final int price = int.tryParse(priceController.text) ?? 0;
                if (name.isNotEmpty && quantity > 0 && price > 0) {
                  if (item == null) {
                    _addItem(name, quantity, price);
                  } else {
                    _updateItem(item['id'], name, quantity, price);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(item == null ? 'Tambah' : 'Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Belanja'),
      ),
      body: 
      
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rp${item['price']} x ${item['quantity']} = Rp${item['price'] * item['quantity']}'),
                    onTap: () => _showAddItemDialog(context, item: item),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(item['id']),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Total Harga:  ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp$_totalPrice',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
