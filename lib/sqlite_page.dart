import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Tambahkan ini

import 'database_helper.dart';

class SqlitePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ItemLocationListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ItemLocationListScreen extends StatefulWidget {
  @override
  _ItemLocationListScreenState createState() => _ItemLocationListScreenState();
}

class _ItemLocationListScreenState extends State<ItemLocationListScreen> {
  List<Map<String, dynamic>> _itemsLocation = [];
  double _totalKm = 0.0;
  Timer? _timer;
  DateTime? _startStopTime;
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadTrackingState(); // Muat status tracking saat aplikasi dibuka
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();

    _loadItemLocations();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLocationTimer() {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _addItemLocation();
    });
  }

  void _stopLocationTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _toggleTracking() {
    setState(() {
      isTracking = !isTracking;
    });

    _saveTrackingState(isTracking); // Simpan status

    if (isTracking) {
      _startLocationTimer();
      FlutterBackgroundService().startService();
    } else {
      _stopLocationTimer();
      FlutterBackgroundService().invoke("stopService");
    }
  }

  Future<void> _saveTrackingState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTracking', value);
  }

  Future<void> _loadTrackingState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getBool('isTracking') ?? false;

    setState(() {
      isTracking = savedState;
    });

    if (isTracking) {
      _startLocationTimer();
      FlutterBackgroundService().startService();
    }
  }

  Future<void> _loadItemLocations() async {
    final items = await DatabaseHelper.instance.queryAllLocation();
    final km = await DatabaseHelper.instance.getTotalDistanceKm();

    setState(() {
      _itemsLocation = items;
      _totalKm = km;
    });
  }

  Future<void> _addItemLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      );

      final latlong = "${position.latitude}, ${position.longitude}";
      final speedKmph = (position.speed * 3.6).toStringAsFixed(2);
      final speed = double.tryParse(speedKmph) ?? 0.0;
      final isMoving = speed > 0.5;

      String? durasiDiam;
      String status = isMoving ? "Bergerak" : "Diam";

      if (!isMoving) {
        _startStopTime ??= DateTime.now();
      } else {
        if (_startStopTime != null) {
          final duration = DateTime.now().difference(_startStopTime!);
          durasiDiam = _formatDuration(duration);
          _startStopTime = null;
        }
      }

      await DatabaseHelper.instance.insertLocation({
        'latlong': latlong,
        'speed': speedKmph,
        'status': status,
        'durasi_diam': durasiDiam,
      });

      _loadItemLocations();
    } catch (e) {
      debugPrint("ERROR_GETTING_LOCATION: $e");
    }
  }

  Future<void> _deleteItemLocation(int id) async {
    await DatabaseHelper.instance.delete(id);
    _loadItemLocations();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location & Speed Logger'),
        actions: [
          IconButton(
            icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
            tooltip: isTracking ? 'Berhenti Tracking' : 'Mulai Tracking',
            onPressed: _toggleTracking,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "🧭 Total Distance: ${_totalKm.toStringAsFixed(2)} km",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _itemsLocation.isEmpty
                ? Center(child: Text('No location data yet.'))
                : ListView.builder(
                    itemCount: _itemsLocation.length,
                    itemBuilder: (context, index) {
                      var item = _itemsLocation[index];
                      return ListTile(
                        title: Text(
                            "${item['id_location']}.📍 ${item['latlong']}"),
                        subtitle: Text(
                          "🚗 Speed: ${item['speed']} km/h"
                          "\n📏 Dist: ${(item['distance_km'] ?? 0.0).toStringAsFixed(4)} km"
                          "\n📡 Status: ${item['status'] ?? '-'}"
                          "\n⏱️ Diam: ${item['durasi_diam'] ?? '-'}",
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              _deleteItemLocation(item['id_location']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
