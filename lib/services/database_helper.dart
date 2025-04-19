import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_model.dart';

class DatabaseHelper {
  static const String _locationsBox = 'saved_locations';
  static Box<Map>? _box;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<Map>(_locationsBox);
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<List<SavedLocation>> getSavedLocations() async {
    if (_box == null) await init();
    try {
      final locations = _box!.values.map((data) {
        final map = Map<String, dynamic>.from(data);
        return SavedLocation.fromJson(map);
      }).toList();
      
      // Sort by name
      locations.sort((a, b) => a.name.compareTo(b.name));
      return locations;
    } catch (e) {
      print('Error getting saved locations: $e');
      return [];
    }
  }

  static Future<void> saveLocation(SavedLocation location) async {
    if (_box == null) await init();
    try {
      // Create unique key using coordinates with precision
      final key = _createLocationKey(location.latitude, location.longitude);
      await _box!.put(key, location.toJson());
      print('Location saved: ${location.name} at $key');
    } catch (e) {
      print('Error saving location: $e');
      rethrow;
    }
  }

  static Future<void> removeLocation(SavedLocation location) async {
    if (_box == null) await init();
    try {
      final key = _createLocationKey(location.latitude, location.longitude);
      await _box!.delete(key);
      print('Location removed: ${location.name} at $key');
    } catch (e) {
      print('Error removing location: $e');
      rethrow;
    }
  }

  static Future<bool> isLocationSaved(SavedLocation location) async {
    if (_box == null) await init();
    try {
      final key = _createLocationKey(location.latitude, location.longitude);
      return _box!.containsKey(key);
    } catch (e) {
      print('Error checking location: $e');
      return false;
    }
  }

  static String _createLocationKey(double latitude, double longitude) {
    // Round to 4 decimal places for consistent keys
    return '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
  }

  static Future<void> clearAllLocations() async {
    if (_box == null) await init();
    await _box!.clear();
  }
}
