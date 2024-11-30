import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'app_database.db';
  static const int _databaseVersion = 1;

  static const String table = 'items';
  static const String columnId = 'id';
  static const String columnName = 'name';

  static const String tableLocation = 'location';
  static const String columnIdLocation = 'id_location';
  static const String columnLatLong = 'latlong';

  // Private constructor
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Lazy initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open or create the database
  Future<Database> _initDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    var path = join(dir.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the tables when the database is first created
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableLocation (
        $columnIdLocation INTEGER PRIMARY KEY,
        $columnLatLong TEXT NOT NULL
      )
    ''');
  }

  // Insert an item
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row);
  }

  Future<int> insertLocation(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableLocation, row);
  }

  // Query all items
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await database;
    return await db.query(
      table,
      orderBy: 'id_location DESC', // Replace with your column name
    );
  }

  // Query all items
  Future<List<Map<String, dynamic>>> queryAllLocation() async {
    Database db = await database;
    return await db.query(tableLocation);
  }

  // Query a specific item by ID
  Future<Map<String, dynamic>?> queryById(int id) async {
    Database db = await database;
    var result = await db.query(table, where: '$columnId = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // Update an item
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete an item
  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(tableLocation, where: '$columnIdLocation = ?', whereArgs: [id]);
  }
}
