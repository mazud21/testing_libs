import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'database_helper.dart';
import 'edit.dart';

class SqlitePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ItemLocationListScreen(),
    );
  }
}

class ItemLocationListScreen extends StatefulWidget {
  @override
  _ItemLocationListScreenState createState() => _ItemLocationListScreenState();
}

class _ItemLocationListScreenState extends State<ItemLocationListScreen> {
  List<Map<String, dynamic>> _itemsLocation = [];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer t) => _loadItemLocations());
  }

  // Load all items from the database
  _loadItemLocations() async {
    final items = await DatabaseHelper.instance.queryAllLocation();
    setState(() {
      _itemsLocation = items;
    });
  }

  // Add a new item
  _addItemLocation() async {
    debugPrint("getLocation: ${await getLocation()}");
    await DatabaseHelper.instance.insertLocation({
      'latlong': '${await getLocation()}',
    });
    _loadItemLocations();  // Reload items from DB
  }

  // Delete an item
  _deleteItemLocation(int id) async {
    await DatabaseHelper.instance.delete(id);
    _loadItemLocations();  // Reload items from DB
  }

  // Navigate to the Edit screen
  _editItemLocation(int id, String currentName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(
          itemId: id,
          currentName: currentName,
        ),
      ),
    ).then((_) {
      // Reload the items after returning from the edit screen
      _loadItemLocations();
    });
  }

  getLocation() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    debugPrint("CHECK_LOCATION: ${position.latitude}, ${position.longitude}");

    String a = "${position.latitude}, ${position.longitude}";
    return a.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite Example')),
      body: ListView.builder(
        itemCount: _itemsLocation.length,
        itemBuilder: (context, index) {
          var item = _itemsLocation[index];
          return ListTile(
            title: Row(
              children: [
                Text(item['id_location'].toString()),
                Text(item['latlong']),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editItemLocation(item['id_location'], item['latlong']),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteItemLocation(item['id_location']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItemLocation,
        child: Icon(Icons.add),
      ),
    );
  }
}
