import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:latlong2/latlong.dart';
import '../services/weather_service.dart';

class MapSearchField extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final bool showHeatmap;
  final VoidCallback onHeatmapToggle;
  final VoidCallback onDirectionsPressed;

  const MapSearchField({
    super.key,
    required this.onLocationSelected,
    required this.showHeatmap,
    required this.onHeatmapToggle,
    required this.onDirectionsPressed,
  });

  @override
  _MapSearchFieldState createState() => _MapSearchFieldState();
}

class _MapSearchFieldState extends State<MapSearchField> {
  final _weatherService = WeatherService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final suggestions = await _weatherService.getLocationSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  void _handleLocationSelected(Map<String, dynamic> suggestion) {
    widget.onLocationSelected(LatLng(
      suggestion['latitude'],
      suggestion['longitude'],
    ));
    _searchController.text = suggestion['name'];
    setState(() => _suggestions = []);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.6)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.search,
                        color: Colors.blue.withOpacity(0.8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search places...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 16,
                            ),
                            suffixIcon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _suggestions = []);
                          },
                          color: Colors.grey,
                        ),
                      const SizedBox(width: 8),
                      VerticalDivider(
                        color: isDark
                            ? Colors.white24
                            : Colors.black26,
                      ),
                      IconButton(
                        icon: Icon(
                          widget.showHeatmap ? Icons.layers : Icons.layers_outlined,
                          color: widget.showHeatmap ? Colors.blue : Colors.grey,
                        ),
                        onPressed: widget.onHeatmapToggle,
                      ),
                    ],
                  ),
                  if (_suggestions.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            title: Text(
                              suggestion['name'],
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              suggestion['country'],
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                            ),
                            onTap: () => _handleLocationSelected(suggestion),
                          ).animate().fadeIn().slideY(
                            begin: 0.1,
                            duration: Duration(milliseconds: 100 * index),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
