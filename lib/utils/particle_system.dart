import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/weather_effects_service.dart';

class CompactParticleSystem {
  final int maxParticles;
  final Float32List positions;
  final Float32List velocities;
  final Float32List sizes;

  CompactParticleSystem(this.maxParticles)
      : positions = Float32List(maxParticles * 2),
        velocities = Float32List(maxParticles * 2),
        sizes = Float32List(maxParticles);

  void initialize(int weatherCode) {
    final random = math.Random();
    final baseSpeed = WeatherEffectsService.getParticleSpeed(weatherCode);
    final baseSize = WeatherEffectsService.getParticleSize(weatherCode);

    for (int i = 0; i < maxParticles; i++) {
      // Position (x, y)
      positions[i * 2] = random.nextDouble();     // x
      positions[i * 2 + 1] = random.nextDouble(); // y

      // Velocity (vx, vy)
      velocities[i * 2] = (random.nextDouble() - 0.5) * 0.1;     // vx
      velocities[i * 2 + 1] = baseSpeed * (0.5 + random.nextDouble()); // vy

      // Size
      sizes[i] = baseSize * (0.8 + random.nextDouble() * 0.4);
    }
  }

  void update(double deltaTime) {
    for (int i = 0; i < maxParticles; i++) {
      // Update position
      positions[i * 2] += velocities[i * 2] * deltaTime;
      positions[i * 2 + 1] += velocities[i * 2 + 1] * deltaTime;

      // Wrap around screen
      positions[i * 2] = positions[i * 2].remainder(1.0);
      positions[i * 2 + 1] = positions[i * 2 + 1].remainder(1.0);
    }
  }
}
