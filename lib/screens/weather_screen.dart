import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_timeline.dart';
import '../widgets/animated_weather_icon.dart';
import '../widgets/weather_background.dart';
import '../widgets/sun_moon_info.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';
import '../widgets/weather_data_charts.dart';
import '../widgets/weather_map.dart';
import '../widgets/weather_analytics.dart';
import '../widgets/search_field.dart';
import '../widgets/animated_night_sky.dart';
import '../widgets/weather_backgrounds/sunrise_background.dart';
import '../widgets/weather_backgrounds/sunset_background.dart';
import '../widgets/weather_backgrounds/daytime_background.dart';
import '../widgets/weather_effects/weather_particles.dart';
import '../widgets/hourly_weather_timeline.dart';
import '../widgets/loading_shimmer.dart';
import 'dart:ui';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  final _weatherService = WeatherService();
  final _locationService = LocationService();
  WeatherModel? _weather;
  String _cityName = '';
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  List<SavedLocation> _savedLocations = [];
  List<WeatherModel> _nearbyLocations = [];
  int _currentIndex = 0;
  bool _isCurrentLocationSaved = false;
  late TabController _tabController;

  bool get _isNight => _weather != null 
    ? _weather!.time.hour < 6 || _weather!.time.hour > 18
    : false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentLocation();
    _searchController.addListener(_onSearchChanged);
    _loadSavedLocations();
    _loadNearbyLocations();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    if (_searchController.text.length >= 2) {
      final suggestions = await _weatherService.getLocationSuggestions(_searchController.text);
      setState(() {
        _suggestions = suggestions;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      final location = await _weatherService.searchLocation(query);
      final weather = await _weatherService.getWeather(
        location['latitude'],
        location['longitude'],
      );
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _cityName = location['name'];
      });
      await _checkIfLocationSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _weatherService.getCurrentLocation();
      final weather = await _weatherService.getWeather(
        position.latitude,
        position.longitude,
      );
      final address = await _weatherService.getReverseGeocode(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _cityName = address['name'];
      });
      await _checkIfLocationSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _loadSavedLocations() async {
    final locations = await _locationService.getSavedLocations();
    setState(() {
      _savedLocations = locations;
    });
  }

  Future<void> _saveCurrentLocation() async {
    if (_weather != null) {
      final location = SavedLocation(
        name: _cityName,
        latitude: _weather!.latitude,
        longitude: _weather!.longitude,
        displayName: _cityName,
      );
      await _locationService.saveLocation(location);
      await _loadSavedLocations();
      await _checkIfLocationSaved();
    }
  }

  Future<void> _checkIfLocationSaved() async {
    if (_weather != null) {
      final location = SavedLocation(
        name: _cityName,
        latitude: _weather!.latitude,
        longitude: _weather!.longitude,
        displayName: _cityName,
      );
      _isCurrentLocationSaved = await _locationService.isLocationSaved(location);
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(WeatherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkIfLocationSaved();
  }

  Future<void> _toggleFavorite() async {
    if (_weather == null) return;

    final location = SavedLocation(
      name: _cityName,
      latitude: _weather!.latitude,
      longitude: _weather!.longitude,
      displayName: _cityName,
    );

    if (_isCurrentLocationSaved) {
      await _locationService.removeLocation(location);
    } else {
      await _locationService.saveLocation(location);
    }

    await _loadSavedLocations();
    await _checkIfLocationSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildWeatherBackground(),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMainContent(),
                _buildMapTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildWeatherBackground() {
    if (_weather == null) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base background based on time
        _buildBaseBackground(),
        
        // Weather effects overlay
        if (_weather != null)
          WeatherParticles(
            weatherCode: _weather!.weatherCode,
            isNight: _isNight,
          ),
      ],
    ).animate(
      target: _weather != null ? 1 : 0,
    ).fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildBaseBackground() {
    final hour = _weather!.time.hour;
    final isNight = hour < 6 || hour > 18;
    final isSunrise = hour >= 5 && hour < 8;
    final isSunset = hour >= 17 && hour < 20;

    if (isNight) {
      return const AnimatedNightSky(numberOfStars: 200);
    } else if (isSunrise) {
      return SunriseBackground(weather: _weather!);
    } else if (isSunset) {
      return SunsetBackground(weather: _weather!);
    } else {
      return DaytimeBackground(weather: _weather!);
    }
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.home), text: 'Home'),
          Tab(icon: Icon(Icons.map), text: 'Map'),
          Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_weather == null) {
      return const WeatherShimmer();
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildMainWeather().animate().fadeIn(
            duration: const Duration(milliseconds: 300),
          ),
          HourlyWeatherTimeline(
            hourlyWeather: _weather!.hourlyForecast,
            currentTime: _weather!.time,
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 24),
          _buildWeatherDetails().animate().fadeIn(
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 24),
          SunMoonInfo(weather: _weather!).animate().fadeIn(
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 24),
          WeatherDataCharts(weather: _weather!).animate().fadeIn(
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 24),
          WeatherTimeline(
            dailyWeather: _weather!.dailyForecast,
            title: 'Next 7 Days',
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 16),
        ].animate(
          interval: Duration(milliseconds: 50),
        ).slideY(
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    if (_weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return WeatherMap(
      weather: _weather!,
      nearbyLocations: _nearbyLocations,
    );
  }

  Widget _buildAnalyticsTab() {
    if (_weather == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return WeatherAnalytics(
      currentWeather: _weather!,
      historicalData: _weather!.historicalWeather.isNotEmpty 
        ? _weather!.historicalWeather
        : _weather!.dailyForecast, // Fallback to forecast data if no historical data
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _cityName.isEmpty ? 'Loading...' : _cityName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isCurrentLocationSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isCurrentLocationSaved ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.location_on, color: Colors.white),
                onPressed: _showLocationsDialog,
              ),
            ],
          ),
          WeatherSearchField(
            controller: _searchController,
            onSubmitted: _searchLocation,
            onDirectionsPressed: () {},
            suggestions: _suggestions,
            onSuggestionSelected: (suggestion) {
              _searchLocation(suggestion['name']);
              _searchController.clear();
              setState(() => _suggestions = []);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeather() {
    if (_weather == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedWeatherIcon(
            icon: _weather!.weatherIcon,
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            '${_weather!.temperature.round()}°',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate()
            .fadeIn(delay: const Duration(milliseconds: 300))
            .scale(),
          Text(
            _weather!.weatherCondition,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[400],
            ),
          ).animate()
            .fadeIn(delay: const Duration(milliseconds: 400))
            .slideY(begin: 50, duration: const Duration(milliseconds: 500)),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          WeatherCard(
            value: '${_weather!.temperature.round()}°C',
            icon: Icons.thermostat,
            color: Colors.orange,
          ),
          WeatherCard(
            value: '${_weather!.precipitation.round()}%',
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
          WeatherCard(
            value: '${_weather!.windspeed} km/h',
            icon: Icons.air,
            color: Colors.green,
          ),
          WeatherCard(
            value: '${_weather!.uvIndex.round()} mm',
            icon: Icons.wb_sunny,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    setState(() => _searchController.clear());
  }

  void _showLocationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Saved Locations'),
        content: SizedBox(
          width: double.maxFinite,
          child: _savedLocations.isEmpty
              ? const Center(
                  child: Text(
                    'No saved locations yet.\nTap the heart icon to save locations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _savedLocations.length,
                  itemBuilder: (context, index) {
                    final location = _savedLocations[index];
                    return ListTile(
                      title: Text(location.name),
                      subtitle: Text(location.displayName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _locationService.removeLocation(location);
                          await _loadSavedLocations();
                          if (mounted) Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        _searchLocation(location.name);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _loadNearbyLocations() async {
    if (_weather == null) return;

    final nearbyCoords = [
      (_weather!.latitude + 0.1, _weather!.longitude + 0.1),
      (_weather!.latitude - 0.1, _weather!.longitude - 0.1),
      (_weather!.latitude + 0.1, _weather!.longitude - 0.1),
      (_weather!.latitude - 0.1, _weather!.longitude + 0.1),
    ];

    final locations = await Future.wait(
      nearbyCoords.map((coord) => _weatherService.getWeather(coord.$1, coord.$2))
    );

    setState(() {
      _nearbyLocations = locations;
    });
  }
}