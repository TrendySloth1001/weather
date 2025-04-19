class WeatherModel {
  final double temperature;
  final double windspeed;
  final double humidity;
  final double precipitation;
  final int weatherCode;
  final double uvIndex;
  final DateTime time;
  final DateTime sunrise;
  final DateTime sunset;
  final double latitude;
  final double longitude;
  final double feelsLike;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;
  final List<DailyWeather> historicalWeather;
  final int moonPhase;

  WeatherModel({
    required this.temperature,
    required this.windspeed,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.uvIndex,
    required this.time,
    required this.sunrise,
    required this.sunset,
    required this.latitude,
    required this.longitude,
    required this.feelsLike,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.historicalWeather,
    this.moonPhase = 0,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    try {
      final currentData = json['current_weather'] ?? {};
      final hourlyData = json['hourly'] ?? {};
      final dailyData = json['daily'] ?? {};
      
      return WeatherModel(
        temperature: (currentData['temperature'] as num?)?.toDouble() ?? 0.0,
        windspeed: (currentData['windspeed'] as num?)?.toDouble() ?? 0.0,
        humidity: (currentData['relativehumidity_2m'] as num?)?.toDouble() ?? 0.0,
        precipitation: (currentData['precipitation_probability'] as num?)?.toDouble() ?? 0.0,
        weatherCode: currentData['weathercode'] as int? ?? 0,
        uvIndex: (currentData['uv_index'] as num?)?.toDouble() ?? 0.0,
        time: DateTime.parse(currentData['time'] ?? DateTime.now().toIso8601String()),
        sunrise: DateTime.parse(dailyData['sunrise']?[0] ?? DateTime.now().toIso8601String()),
        sunset: DateTime.parse(dailyData['sunset']?[0] ?? DateTime.now().toIso8601String()),
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        feelsLike: (currentData['feels_like'] as num?)?.toDouble() ?? 0.0,
        hourlyForecast: _parseHourlyData(hourlyData),
        dailyForecast: _parseDailyData(dailyData),
        historicalWeather: _parseDailyData(json['historical_weather'] ?? {}),
        moonPhase: dailyData['moon_phase']?[0] as int? ?? 0,
      );
    } catch (e) {
      print('Error parsing weather data: $e');
      throw Exception('Failed to parse weather data: $e');
    }
  }

  static List<HourlyWeather> _parseHourlyData(Map<String, dynamic> hourly) {
    final times = hourly['time'] as List? ?? [];
    final temps = hourly['temperature_2m'] as List? ?? [];
    final precip = hourly['precipitation_probability'] as List? ?? [];
    final humidity = hourly['relativehumidity_2m'] as List? ?? [];
    final windspeed = hourly['windspeed_10m'] as List? ?? [];
    final weathercode = hourly['weathercode'] as List? ?? [];

    return List.generate(
      times.length,
      (i) => HourlyWeather(
        time: DateTime.parse(times[i].toString()),
        temperature: (temps.length > i ? temps[i] as num : 0).toDouble(),
        precipitation: (precip.length > i ? precip[i] as num : 0).toDouble(),
        humidity: (humidity.length > i ? humidity[i] as num : 0).toDouble(),
        windSpeed: (windspeed.length > i ? windspeed[i] as num : 0).toDouble(),
        weatherCode: weathercode.length > i ? weathercode[i] as int : 0,
      ),
    );
  }

  static List<DailyWeather> _parseDailyData(Map<String, dynamic> daily) {
    final times = daily['time'] as List? ?? [];
    final maxTemps = daily['temperature_2m_max'] as List? ?? [];
    final minTemps = daily['temperature_2m_min'] as List? ?? [];
    final precipProb = daily['precipitation_probability_max'] as List? ?? [];
    final weatherCodes = daily['weathercode'] as List? ?? [];

    return List.generate(
      times.length,
      (i) => DailyWeather(
        date: DateTime.parse(times[i].toString()),
        maxTemp: (maxTemps.length > i ? maxTemps[i] as num : 0).toDouble(),
        minTemp: (minTemps.length > i ? minTemps[i] as num : 0).toDouble(),
        precipitation: (precipProb.length > i ? precipProb[i] as num : 0).toDouble(),
        weatherCode: weatherCodes.length > i ? weatherCodes[i] as int : 0,
      ),
    );
  }

  String get weatherIcon {
    if (weatherCode <= 3) return '☀️';
    if (weatherCode <= 48) return '☁️';
    if (weatherCode <= 65) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌧️';
    return '⛈️';
  }

  String get weatherCondition {
    if (weatherCode <= 3) return 'Clear';
    if (weatherCode <= 48) return 'Cloudy';
    if (weatherCode <= 65) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 82) return 'Showers';
    return 'Thunderstorm';
  }

  String get moonPhaseDescription {
    switch (moonPhase) {
      case 0:
        return 'New Moon';
      case 1:
        return 'Waxing Crescent';
      case 2:
        return 'First Quarter';
      case 3:
        return 'Waxing Gibbous';
      case 4:
        return 'Full Moon';
      case 5:
        return 'Waning Gibbous';
      case 6:
        return 'Last Quarter';
      case 7:
        return 'Waning Crescent';
      default:
        return 'Unknown';
    }
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double precipitation;
  final double humidity;
  final double windSpeed;
  final int weatherCode;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitation,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });
}

class DailyWeather {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double precipitation;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitation,
    this.weatherCode = 0,
  });

  String get weatherIcon {
    if (weatherCode <= 3) return '☀️';
    if (weatherCode <= 48) return '☁️';
    if (weatherCode <= 65) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌧️';
    return '⛈️';
  }
}
