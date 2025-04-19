import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied. Please allow access to continue.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied. Please enable them in settings.'
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5),
    );
  }

  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    try {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 7));
      
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$latitude&longitude=$longitude'
        '&current_weather=true'
        '&hourly=temperature_2m,precipitation_probability,relativehumidity_2m,windspeed_10m,weathercode'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset'
        '&timezone=auto'
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }

      final weatherData = jsonDecode(response.body);
      return WeatherModel.fromJson(weatherData);
      
    } catch (e) {
      print('Error fetching weather data: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<Map<String, dynamic>> searchLocation(String query) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1'),
      headers: {'User-Agent': 'WeatherApp/1.0'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
          'name': data[0]['display_name'].toString().split(',')[0],
        };
      }
      throw Exception('Location not found');
    } else {
      throw Exception('Failed to search location');
    }
  }

  Future<List<Map<String, dynamic>>> getLocationSuggestions(String query) async {
    if (query.length < 2) return [];

    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5'),
      headers: {'User-Agent': 'WeatherApp/1.0'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((result) {
        final nameParts = result['display_name'].toString().split(',');
        return {
          'name': nameParts[0],
          'country': nameParts.last.trim(),
          'latitude': double.parse(result['lat']),
          'longitude': double.parse(result['lon']),
          'display_name': result['display_name'],
        };
      }).toList();
    } else {
      throw Exception('Failed to get suggestions');
    }
  }

  Future<Map<String, dynamic>> getReverseGeocode(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json'),
      headers: {'User-Agent': 'WeatherApp/1.0'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'name': data['address']['city'] ?? 
               data['address']['town'] ?? 
               data['address']['village'] ?? 
               data['address']['suburb'] ??
               'Unknown location',
      };
    } else {
      throw Exception('Failed to get location name');
    }
  }
}
