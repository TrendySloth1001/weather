import 'package:flutter/material.dart';

class WeatherEffectsService {
  static const maxParticles = 200;
  static const thunderInterval = Duration(seconds: 5);

  static bool shouldShowRain(int weatherCode) => 
      (weatherCode >= 51 && weatherCode <= 65) || 
      (weatherCode >= 80 && weatherCode <= 82);

  static bool shouldShowSnow(int weatherCode) => 
      weatherCode >= 71 && weatherCode <= 77;

  static bool shouldShowThunder(int weatherCode) => 
      weatherCode >= 95 && weatherCode <= 99;

  static bool shouldShowFog(int weatherCode) =>
      weatherCode >= 45 && weatherCode <= 48;

  static bool shouldShowHail(int weatherCode) =>
      weatherCode >= 85 && weatherCode <= 87;

  static Color getParticleColor(int weatherCode) {
    if (shouldShowSnow(weatherCode)) {
      return Colors.white.withOpacity(0.8);
    } else if (shouldShowRain(weatherCode)) {
      return Colors.blue.shade200.withOpacity(0.6);
    } else if (shouldShowHail(weatherCode)) {
      return Colors.white.withOpacity(0.9);
    } else if (shouldShowFog(weatherCode)) {
      return Colors.grey.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  static double getParticleSize(int weatherCode) {
    if (shouldShowSnow(weatherCode)) return 3.0;
    if (shouldShowRain(weatherCode)) return 1.5;
    if (shouldShowHail(weatherCode)) return 4.0;
    if (shouldShowFog(weatherCode)) return 50.0;
    return 2.0;
  }

  static double getParticleSpeed(int weatherCode) {
    if (shouldShowSnow(weatherCode)) return 2.0;
    if (shouldShowRain(weatherCode)) return 15.0;
    if (shouldShowHail(weatherCode)) return 20.0;
    if (shouldShowFog(weatherCode)) return 0.5;
    return 5.0;
  }

  static ParticleSystem getParticleSystem(int weatherCode) {
    if (shouldShowFog(weatherCode)) {
      return ParticleSystem.fog;
    } else if (shouldShowSnow(weatherCode)) {
      return ParticleSystem.snow;
    } else if (shouldShowHail(weatherCode)) {
      return ParticleSystem.hail;
    }
    return ParticleSystem.rain;
  }
}

enum ParticleSystem {
  rain,
  snow,
  hail,
  fog,
}
