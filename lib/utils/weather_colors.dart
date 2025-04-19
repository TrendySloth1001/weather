import 'package:flutter/material.dart';

class WeatherColors {
  static Color getWeatherColor(int weatherCode) {
    switch (weatherCode) {
      case 0: // Clear sky
        return Colors.blue[400]!;
      case 1:
      case 2:
      case 3: // Partly cloudy
        return Colors.blueGrey[300]!;
      case 45:
      case 48: // Foggy
        return Colors.grey[400]!;
      case 51:
      case 53:
      case 55: // Light rain
        return Colors.lightBlue[300]!;
      case 61:
      case 63:
      case 65: // Rain
        return Colors.blue[700]!;
      case 71:
      case 73:
      case 75: // Snow
        return Colors.lightBlue[100]!;
      case 95: // Thunderstorm
        return Colors.deepPurple[700]!;
      default:
        return Colors.blue[300]!;
    }
  }

  static LinearGradient getWeatherGradient(int weatherCode, bool isNight) {
    final baseColor = getWeatherColor(weatherCode);
    
    if (isNight) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black,
          Colors.blue[900]!,
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor,
        baseColor.withOpacity(0.7),
      ],
    );
  }
}
