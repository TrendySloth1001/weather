import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapTileService {
  static String getTileUrl(MapStyle style) {
    switch (style) {
      case MapStyle.standard:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.hybrid:
        return 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
      case MapStyle.terrain:
        return 'https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png';
      case MapStyle.weatherTemp:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  static Map<String, String> getHeaders(MapStyle style) {
    return {
      'User-Agent': 'WeatherApp/1.0',
    };
  }

  static TileLayer createTileLayer(MapStyle style, bool isDarkMode) {
    return TileLayer(
      urlTemplate: getTileUrl(style),
      userAgentPackageName: 'com.example.weather',
      tileProvider: NetworkTileProvider(),
      retinaMode: false,
      backgroundColor: Colors.grey[900],
      tileBuilder: (context, widget, tile) {
        // Apply different color filters based on map style
        if (style == MapStyle.weatherTemp) {
          return ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              1.5, 0, 0, 0, 0,
              0, 0.8, 0, 0, 0,
              0, 0, 0.8, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: widget,
          );
        }
        return widget;
      },
    );
  }
}

enum MapStyle {
  standard,
  satellite,
  hybrid,
  terrain,
  weatherTemp,
}
