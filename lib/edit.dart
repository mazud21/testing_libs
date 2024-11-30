import 'package:flutter/material.dart';

import 'database_helper.dart';

class EditItemScreen extends StatefulWidget {
  final int itemId;
  final String currentName;

  EditItemScreen({required this.itemId, required this.currentName});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
  }

  // Handle updating the item
  _updateItem() async {
    String newName = _nameController.text;
    if (newName.isNotEmpty) {
      await DatabaseHelper.instance.update({
        'id': widget.itemId,
        'name': newName,
      });
      Navigator.pop(context);  // Go back to the previous screen
    } else {
      // Show an alert if the name is empty
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Name cannot be empty!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateItem,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
