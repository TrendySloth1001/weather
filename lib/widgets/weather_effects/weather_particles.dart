import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../services/weather_effects_service.dart';
import '../../utils/particle_system.dart';

class WeatherParticles extends StatefulWidget {
  final int weatherCode;
  final bool isNight;

  const WeatherParticles({
    super.key,
    required this.weatherCode,
    required this.isNight,
  });

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CompactParticleSystem _particleSystem;
  bool _showLightning = false;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _particleSystem = CompactParticleSystem(WeatherEffectsService.maxParticles);
    _particleSystem.initialize(widget.weatherCode);
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    if (WeatherEffectsService.shouldShowThunder(widget.weatherCode)) {
      _setupThunder();
    }
  }

  void _setupThunder() {
    Future.doWhile(() async {
      await Future.delayed(WeatherEffectsService.thunderInterval);
      if (!mounted) return false;
      setState(() => _showLightning = true);
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      setState(() => _showLightning = false);
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final now = DateTime.now();
            final deltaTime = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
            _lastUpdateTime = now;
            
            _particleSystem.update(deltaTime);
            
            return CustomPaint(
              painter: OptimizedParticlePainter(
                particleSystem: _particleSystem,
                weatherCode: widget.weatherCode,
              ),
              size: Size.infinite,
            );
          },
        ),
        if (_showLightning)
          Container(
            color: Colors.white.withOpacity(0.3),
          ).animate().fadeOut(duration: const Duration(milliseconds: 100)),
      ],
    );
  }
}

class OptimizedParticlePainter extends CustomPainter {
  final CompactParticleSystem particleSystem;
  final int weatherCode;

  OptimizedParticlePainter({
    required this.particleSystem,
    required this.weatherCode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WeatherEffectsService.getParticleColor(weatherCode);

    for (int i = 0; i < particleSystem.maxParticles; i++) {
      final x = particleSystem.positions[i * 2] * size.width;
      final y = particleSystem.positions[i * 2 + 1] * size.height;
      final particleSize = particleSystem.sizes[i];

      if (WeatherEffectsService.shouldShowSnow(weatherCode) ||
          WeatherEffectsService.shouldShowHail(weatherCode)) {
        canvas.drawCircle(Offset(x, y), particleSize, paint);
      } else {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + particleSize * 10),
          paint..strokeWidth = particleSize,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
