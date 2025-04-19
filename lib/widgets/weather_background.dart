import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class WeatherBackground extends StatelessWidget {
  final int weatherCode;
  final bool isNight;

  const WeatherBackground({
    super.key,
    required this.weatherCode,
    required this.isNight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getBackgroundColors(),
            ),
          ),
        ),
        // Weather effects overlay
        if (_shouldShowParticles) ParticleOverlay(weatherCode: weatherCode),
        // Celestial body (sun/moon)
        if (!_shouldShowParticles) CelestialBody(isNight: isNight),
      ],
    );
  }

  List<Color> _getBackgroundColors() {
    if (isNight) {
      return [
        const Color(0xFF1a1b26),
        const Color(0xFF2a2b3d),
      ];
    }

    switch (weatherCode) {
      case 0: // Clear sky
        return [
          const Color(0xFF4a90e2),
          const Color(0xFF87ceeb),
        ];
      case 1:
      case 2:
      case 3: // Partly cloudy
        return [
          const Color(0xFF6b92b5),
          const Color(0xFF9fb5c7),
        ];
      default:
        return [
          const Color(0xFF54717a),
          const Color(0xFF8b9ea5),
        ];
    }
  }

  bool get _shouldShowParticles {
    return weatherCode > 50; // Rain, snow, or other precipitation
  }
}

class ParticleOverlay extends StatefulWidget {
  final int weatherCode;

  const ParticleOverlay({super.key, required this.weatherCode});

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          speed: 0.1 + random.nextDouble() * 0.5,
          size: 2 + random.nextDouble() * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            weatherCode: widget.weatherCode,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double speed;
  final double size;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final int weatherCode;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.weatherCode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);

    for (var particle in particles) {
      particle.y = (particle.y + particle.speed * progress) % 1.0;
      final offset = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );
      
      if (weatherCode >= 70) { // Snow
        canvas.drawCircle(offset, particle.size, paint);
      } else { // Rain
        canvas.drawLine(
          offset,
          Offset(offset.dx, offset.dy + particle.size * 4),
          paint..strokeWidth = particle.size,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class CelestialBody extends StatelessWidget {
  final bool isNight;

  const CelestialBody({super.key, required this.isNight});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 40,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isNight ? Colors.grey[300] : Colors.yellow,
          boxShadow: [
            BoxShadow(
              color: (isNight ? Colors.grey[300] : Colors.yellow)!
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 10,
            ),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: const Duration(seconds: 4)),
    );
  }
}
