import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

class DaytimeBackground extends StatefulWidget {
  final WeatherModel weather;

  const DaytimeBackground({super.key, required this.weather});

  @override
  State<DaytimeBackground> createState() => _DaytimeBackgroundState();
}

class _DaytimeBackgroundState extends State<DaytimeBackground> 
    with SingleTickerProviderStateMixin {
  late AnimationController _sunController;

  @override
  void initState() {
    super.initState();
    _sunController = AnimationController(
      duration: const Duration(minutes: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _sunController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sunController,
      builder: (context, child) {
        return CustomPaint(
          painter: DaytimePainter(
            animation: _sunController,
            weatherCode: widget.weather.weatherCode,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class DaytimePainter extends CustomPainter {
  final Animation<double> animation;
  final int weatherCode;

  DaytimePainter({required this.animation, required this.weatherCode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw sky gradient background first with reduced opacity
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A90E2).withOpacity(0.7), // Reduced opacity
          const Color(0xFF87CEEB).withOpacity(0.6), // Reduced opacity
          const Color(0xFFC5E3F7).withOpacity(0.5), // Reduced opacity
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Add a dark overlay for better contrast
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.2);
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      skyPaint,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      overlayPaint,
    );

    // Draw sun with glow
    final sunPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final sunCenter = Offset(
      size.width * (0.3 + animation.value * 0.4),
      size.height * 0.3,
    );

    // Draw sun glow
    canvas.drawCircle(sunCenter, 60, sunPaint);
    
    // Draw sun core
    sunPaint
      ..maskFilter = null
      ..color = Colors.yellow.shade500;
    canvas.drawCircle(sunCenter, 40, sunPaint);

    // Draw clouds if weather code indicates clouds
    if (weatherCode >= 1 && weatherCode <= 3) {
      _drawClouds(canvas, size);
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.9) // Made clouds more visible
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final positions = [
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.15),
    ];

    for (var position in positions) {
      _drawCloudShape(canvas, position, size.width * 0.2, cloudPaint);
    }
  }

  void _drawCloudShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..addOval(Rect.fromCenter(
        center: center,
        width: size,
        height: size * 0.6,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset(center.dx - size * 0.2, center.dy),
        width: size * 0.7,
        height: size * 0.4,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset(center.dx + size * 0.2, center.dy),
        width: size * 0.7,
        height: size * 0.4,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
