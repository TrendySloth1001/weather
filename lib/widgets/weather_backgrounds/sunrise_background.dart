import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

class SunriseBackground extends StatelessWidget {
  final WeatherModel weather;

  const SunriseBackground({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepOrange.withOpacity(0.7),
            Colors.amber.withOpacity(0.5),
            Colors.blue.withOpacity(0.3),
          ],
        ),
      ),
      child: const CustomPaint(
        painter: SunrisePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class SunrisePainter extends CustomPainter {
  const SunrisePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient sky with reduced opacity
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.deepPurple.shade900.withOpacity(0.7),
        Colors.deepOrange.shade400.withOpacity(0.6),
        Colors.amber.shade300.withOpacity(0.5),
        Colors.blue.shade300.withOpacity(0.4),
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    // Add dark overlay for better contrast
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.25);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = skyGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      ),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      overlayPaint,
    );

    // Draw rising sun
    final sunPaint = Paint()
      ..color = Colors.orange
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final sunCenter = Offset(
      size.width * 0.5,
      size.height * 0.6,
    );

    // Draw sun glow
    canvas.drawCircle(sunCenter, 100, sunPaint);

    // Draw sun core
    sunPaint
      ..maskFilter = null
      ..color = Colors.orange.shade500;
    canvas.drawCircle(sunCenter, 70, sunPaint);

    // Draw light rays
    _drawLightRays(canvas, sunCenter, size);
  }

  void _drawLightRays(Canvas canvas, Offset center, Size size) {
    final rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.2)
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final angle = i * 45 * 3.14159 / 180;
      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(angle) * size.width * 0.8,
          center.dy + sin(angle) * size.height * 0.8,
        ),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
