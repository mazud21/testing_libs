import 'dart:math';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'app_database.db';
  static const int _databaseVersion = 1;

  static const String tableLocation = 'location';
  static const String columnIdLocation = 'id_location';
  static const String columnLatLong = 'latlong';
  static const String columnSpeed = 'speed';
  static const String columnStatus = 'status';
  static const String columnDurasiDiam = 'durasi_diam';
  static const String columnDistanceKm = 'distance_km';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableLocation (
        $columnIdLocation INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnLatLong TEXT NOT NULL,
        $columnSpeed TEXT NOT NULL,
        $columnStatus TEXT,
        $columnDurasiDiam TEXT,
        $columnDistanceKm REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db
          .execute('ALTER TABLE $tableLocation ADD COLUMN $columnSpeed TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE $tableLocation ADD COLUMN $columnDistanceKm REAL');
    }
    if (oldVersion < 4) {
      await db
          .execute('ALTER TABLE $tableLocation ADD COLUMN $columnStatus TEXT');
    }
    if (oldVersion < 5) {
      await db.execute(
          'ALTER TABLE $tableLocation ADD COLUMN $columnDurasiDiam TEXT');
    }
  }

  Future<int> insertLocation(Map<String, dynamic> row) async {
    final db = await database;

    // Hitung jarak dari lokasi sebelumnya (jika ada)
    final List<Map<String, dynamic>> previous = await db.query(
      tableLocation,
      orderBy: '$columnIdLocation DESC',
      limit: 1,
    );

    double? jarakKm;

    if (previous.isNotEmpty) {
      final lastLatLong = previous.first[columnLatLong];
      final lastCoords = _parseLatLong(lastLatLong);
      final currentCoords = _parseLatLong(row[columnLatLong]);

      if (lastCoords != null && currentCoords != null) {
        jarakKm = _calculateDistanceKm(
          lastCoords[0],
          lastCoords[1],
          currentCoords[0],
          currentCoords[1],
        );
        row[columnDistanceKm] = jarakKm;
      }
    }

    return await db.insert(tableLocation, row);
  }

  Future<List<Map<String, dynamic>>> queryAllLocation() async {
    final db = await database;
    return await db.query(
      tableLocation,
      orderBy: '$columnIdLocation DESC',
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableLocation,
      where: '$columnIdLocation = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalDistanceKm() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT SUM($columnDistanceKm) as total FROM $tableLocation');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  List<double>? _parseLatLong(String latlong) {
    try {
      final parts = latlong.split(',');
      if (parts.length == 2) {
        final lat = double.parse(parts[0].trim());
        final lon = double.parse(parts[1].trim());
        return [lat, lon];
      }
    } catch (_) {}
    return null;
  }

  /// Haversine Formula (km)
  double _calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of Earth in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
