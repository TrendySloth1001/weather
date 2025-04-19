import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'map_overlays/weather_heatmap.dart';
import 'map_overlays/custom_layer.dart';
import 'map_search_field.dart';

class WeatherMap extends StatefulWidget {
  final WeatherModel weather;
  final List<WeatherModel> nearbyLocations;

  const WeatherMap({
    super.key,
    required this.weather,
    required this.nearbyLocations,
  });

  @override
  State<WeatherMap> createState() => _WeatherMapState();
}

class _WeatherMapState extends State<WeatherMap> {
  late final MapController _mapController;
  Timer? _updateTimer;
  bool _isDisposed = false;
  double _currentZoom = 10;
  bool _showSatellite = false;
  bool _showHeatmap = false;
  bool _showWindDirection = false;
  bool _show3D = false;
  MapStyle _currentStyle = MapStyle.standard;
  final String _selectedDataType = 'temperature';
  final List<LatLng> _routePoints = [];
  List<WeatherModel> _searchedLocations = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Optimize updates by using a timer instead of continuous animation
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isDisposed) {
        setState(() {
          // Update map state periodically
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _updateTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  String get _mapUrl {
    switch (_currentStyle) {
      case MapStyle.satellite:
        return 'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
      case MapStyle.terrain:
        return 'https://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}';
      case MapStyle.dark:
        return 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png';
      default:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  List<String> get _subdomains {
    switch (_currentStyle) {
      case MapStyle.satellite:
      case MapStyle.terrain:
        return ['mt0', 'mt1', 'mt2', 'mt3'];
      case MapStyle.dark:
        return ['a', 'b', 'c'];
      default:
        return ['a', 'b', 'c'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return RepaintBoundary(
      child: Stack(
        children: [
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_show3D ? -0.3 : 0.0),
            alignment: Alignment.center,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(widget.weather.latitude, widget.weather.longitude),
                initialZoom: _currentZoom,
                onPositionChanged: (pos, _) {
                  if (pos.zoom != null) {
                    setState(() => _currentZoom = pos.zoom!);
                  }
                },
                enableScrollWheel: true,
                rotation: _show3D ? 0.0 : 0.0,
                interactionOptions: InteractionOptions(
                  enableScrollWheel: false,
                  enableMultiFingerGestureRace: false,
                  flags: InteractiveFlag.drag | 
                        InteractiveFlag.pinchZoom | 
                        InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: _mapUrl,
                  userAgentPackageName: 'com.example.weather',
                  subdomains: _subdomains,
                  tileProvider: _currentStyle == MapStyle.satellite || 
                              _currentStyle == MapStyle.terrain
                      ? GoogleTileProvider()
                      : NetworkTileProvider(),
                  tileBuilder: _buildThemedTile,
                ),
                if (_showHeatmap)
                  WeatherHeatmapLayer(
                    weatherPoints: [widget.weather, ...widget.nearbyLocations],
                    dataType: _selectedDataType,
                  ),
                _buildWindDirectionLayer(),
                if (_routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                MarkerLayer(markers: _buildAllMarkers()),
              ],
            ),
          ),
          _buildSearchField(),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapControlButton(
                  icon: _show3D ? Icons.view_in_ar : Icons.view_in_ar_outlined,
                  onPressed: () => setState(() => _show3D = !_show3D),
                  isActive: _show3D,
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMapControlButton(
                        icon: Icons.add,
                        onPressed: _zoomIn,
                      ),
                      const Divider(height: 1),
                      _buildMapControlButton(
                        icon: Icons.remove,
                        onPressed: _zoomOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: () => _mapController.move(
                    LatLng(widget.weather.latitude, widget.weather.longitude),
                    _currentZoom,
                  ),
                ),
              ],
            ),
          ),
          _buildMapStyleControls(),
        ],
      ),
    );
  }

  void _onLocationSearched(LatLng location) async {
    try {
      final weather = await WeatherService().getWeather(
        location.latitude,
        location.longitude,
      );
      setState(() {
        _searchedLocations = [..._searchedLocations, weather];
      });
      _mapController.move(location, _currentZoom);
    } catch (e) {
      print('Error fetching weather for searched location: $e');
    }
  }

  Widget _buildWindDirectionLayer() {
    if (!_showWindDirection) return const SizedBox.shrink();
    return CustomLayerWidget(
      painter: WindDirectionPainter(
        weatherPoints: [widget.weather, ...widget.nearbyLocations],
      ),
    );
  }

  Widget _buildThemedTile(BuildContext context, Widget tileWidget, TileImage tileImage) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.8, 0, 0, 0, 0,
        0, 0.8, 0, 0, 0,
        0, 0, 0.8, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: tileWidget,
    );
  }

  void _zoomIn() {
    final newZoom = (_currentZoom + 1).clamp(4.0, 18.0);
    _mapController.move(
      _mapController.camera.center,
      newZoom,
    );
    setState(() => _currentZoom = newZoom);
  }

  void _zoomOut() {
    final newZoom = (_currentZoom - 1).clamp(4.0, 18.0);
    _mapController.move(
      _mapController.camera.center,
      newZoom,
    );
    setState(() => _currentZoom = newZoom);
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey[700],
            size: 20,
          ),
        ),
      ),
    );
  }

  void _searchOnMap(String query) async {
    // Implement location search
  }

  void _startRouteMode() {
    // Implement route planning mode
  }

  List<Marker> _buildAllMarkers() {
    return [
      _buildLocationMarker(widget.weather, isCurrentLocation: true),
      ..._searchedLocations.map((location) => 
        _buildLocationMarker(location, isSearchResult: true)
      ),
      ...widget.nearbyLocations.map((location) => 
        _buildLocationMarker(location)
      ),
    ];
  }

  Marker _buildLocationMarker(WeatherModel weather, {
    bool isCurrentLocation = false,
    bool isSearchResult = false,
  }) {
    return Marker(
      point: LatLng(weather.latitude, weather.longitude),
      width: 110,
      height: 110,
      child: WeatherMarker(
        weather: weather,
        isCurrentLocation: isCurrentLocation,
        isSearchResult: isSearchResult,
      ).animate().scale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
      ),
    );
  }

  Positioned _buildSearchField() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: MapSearchField(
        onLocationSelected: _onLocationSearched,
        onHeatmapToggle: () => setState(() => _showHeatmap = !_showHeatmap),
        onDirectionsPressed: _startRouteMode,
        showHeatmap: _showHeatmap,
      ),
    );
  }

  Widget _buildMapStyleControls() {
    return Positioned(
      left: 16,
      bottom: 16 + MediaQuery.of(context).padding.bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStyleButton(
                  icon: Icons.map,
                  label: 'Standard',
                  isSelected: _currentStyle == MapStyle.standard,
                  onTap: () => setState(() => _currentStyle = MapStyle.standard),
                ),
                const Divider(height: 1),
                _buildStyleButton(
                  icon: Icons.satellite,
                  label: 'Satellite',
                  isSelected: _currentStyle == MapStyle.satellite,
                  onTap: () => setState(() => _currentStyle = MapStyle.satellite),
                ),
                const Divider(height: 1),
                _buildStyleButton(
                  icon: Icons.map_outlined,
                  label: 'Hybrid',
                  isSelected: _currentStyle == MapStyle.hybrid,
                  onTap: () => setState(() => _currentStyle = MapStyle.hybrid),
                ),
                const Divider(height: 1),
                _buildStyleButton(
                  icon: Icons.terrain,
                  label: 'Terrain',
                  isSelected: _currentStyle == MapStyle.terrain,
                  onTap: () => setState(() => _currentStyle = MapStyle.terrain),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildStyleButton(
              icon: _show3D ? Icons.view_in_ar : Icons.view_in_ar_outlined,
              label: '3D View',
              isSelected: _show3D,
              onTap: () => setState(() => _show3D = !_show3D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherMarker extends StatelessWidget {
  final WeatherModel weather;
  final bool isCurrentLocation;
  final bool isSearchResult;

  const WeatherMarker({
    super.key,
    required this.weather,
    this.isCurrentLocation = false,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = isCurrentLocation 
        ? Colors.blue 
        : isSearchResult 
            ? Colors.green 
            : Colors.white;

    return SizedBox(
      width: 110,
      height: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: markerColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weather.weatherIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  '${weather.temperature.round()}°',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: markerColor == Colors.white ? Colors.black87 : Colors.white,
                  ),
                ),
                Text(
                  '${weather.humidity.round()}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: markerColor == Colors.white ? Colors.black54 : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            Icons.location_pin,
            size: 24,
            color: markerColor,
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _MapButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? Colors.blue : Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class WindDirectionPainter extends CustomPainter {
  final List<WeatherModel> weatherPoints;

  WindDirectionPainter({required this.weatherPoints});

  @override
  void paint(Canvas canvas, Size size) {
    // Implement wind direction arrows
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GoogleTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = options.urlTemplate?.replaceAll(
      '{s}',
      options.subdomains[coordinates.x % options.subdomains.length],
    ).replaceAll('{z}', '${coordinates.z}')
     .replaceAll('{x}', '${coordinates.x}')
     .replaceAll('{y}', '${coordinates.y}');

    if (url == null) {
      throw Exception('TileLayer urlTemplate is null');
    }

    return NetworkImage(
      url,
      headers: {'User-Agent': 'Mozilla/5.0'},
    );
  }
}

enum MapStyle {
  standard,
  satellite,
  terrain,
  dark,
  hybrid,
  weatherTemp,
  weatherClouds,
  weatherPrecipitation,
  weatherWind,
  weatherPressure,
}
