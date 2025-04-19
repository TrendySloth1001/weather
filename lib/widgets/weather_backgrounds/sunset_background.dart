import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import 'dart:ui' as ui;

class SunsetBackground extends StatefulWidget {
  final WeatherModel weather;

  const SunsetBackground({super.key, required this.weather});

  @override
  State<SunsetBackground> createState() => _SunsetBackgroundState();
}

class _SunsetBackgroundState extends State<SunsetBackground> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(minutes: 1),
      vsync: this,
    )..repeat();
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
          painter: SunsetPainter(
            animation: _controller,
            weatherCode: widget.weather.weatherCode,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class SunsetPainter extends CustomPainter {
  final Animation<double> animation;
  final int weatherCode;

  SunsetPainter({required this.animation, required this.weatherCode});

  @override
  void paint(Canvas canvas, Size size) {
    // Create sunset gradient with reduced opacity
    final gradient = ui.Gradient.linear(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      [
        Colors.deepOrange.shade400.withOpacity(0.7),
        Colors.orange.shade300.withOpacity(0.6),
        Colors.amber.shade200.withOpacity(0.5),
        Colors.blue.shade200.withOpacity(0.4),
      ],
      [0.0, 0.3, 0.6, 1.0],
    );

    // Add dark overlay for better contrast
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.2);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = gradient,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      overlayPaint,
    );

    // Draw setting sun
    final sunPaint = Paint()
      ..color = Colors.orange.shade500
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    final sunCenter = Offset(
      size.width * 0.5,
      size.height * (0.4 + animation.value * 0.2),
    );

    canvas.drawCircle(sunCenter, 80, sunPaint);

    // Draw sun rays
    _drawSunRays(canvas, sunCenter, size);
  }

  void _drawSunRays(Canvas canvas, Offset center, Size size) {
    final rayPaint = Paint()
      ..color = Colors.orange.shade300.withOpacity(0.3)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 + animation.value * 360) * 3.14159 / 180;
      final startPoint = Offset(
        center.dx + cos(angle) * 100,
        center.dy + sin(angle) * 100,
      );
      final endPoint = Offset(
        center.dx + cos(angle) * 150,
        center.dy + sin(angle) * 150,
      );
      canvas.drawLine(startPoint, endPoint, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
