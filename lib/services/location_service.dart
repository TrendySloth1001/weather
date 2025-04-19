import '../models/location_model.dart';
import 'database_helper.dart';

class LocationService {
  Future<List<SavedLocation>> getSavedLocations() async {
    try {
      return await DatabaseHelper.getSavedLocations();
    } catch (e) {
      print('Error getting saved locations: $e');
      return [];
    }
  }

  Future<void> saveLocation(SavedLocation location) async {
    try {
      if (await isLocationSaved(location)) {
        print('Location already saved: ${location.name}');
        return;
      }
      await DatabaseHelper.saveLocation(location);
    } catch (e) {
      print('Error saving location: $e');
      rethrow;
    }
  }

  Future<void> removeLocation(SavedLocation location) async {
    try {
      await DatabaseHelper.removeLocation(location);
    } catch (e) {
      print('Error removing location: $e');
      rethrow;
    }
  }

  Future<bool> isLocationSaved(SavedLocation location) async {
    try {
      return await DatabaseHelper.isLocationSaved(location);
    } catch (e) {
      print('Error checking location: $e');
      return false;
    }
  }
}
