import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedNightSky extends StatefulWidget {
  final Color backgroundColor;
  final int numberOfStars;

  const AnimatedNightSky({
    super.key,
    this.backgroundColor = const Color(0xFF1a1b26),
    this.numberOfStars = 100,
  });

  @override
  State<AnimatedNightSky> createState() => _AnimatedNightSkyState();
}

class _AnimatedNightSkyState extends State<AnimatedNightSky> 
    with TickerProviderStateMixin {
  late List<Star> stars;
  late List<Cloud> clouds;
  late AnimationController _moonController;
  late AnimationController _cloudController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateStarsAndClouds();
  }

  void _initializeAnimations() {
    _moonController = AnimationController(
      duration: const Duration(minutes: 2),
      vsync: this,
    )..repeat();

    _cloudController = AnimationController(
      duration: const Duration(minutes: 15), // Much slower cloud movement
      vsync: this,
    )..repeat();

    _starController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _generateStarsAndClouds() {
    final random = math.Random();
    stars = List.generate(widget.numberOfStars, (index) {
      return Star(
        x: random.nextDouble() * 1.2 - 0.1,
        y: random.nextDouble() * 1.2 - 0.1,
        size: random.nextDouble() * 2 + 1,
        blinkDelay: random.nextDouble() * 3,
      );
    });

    clouds = List.generate(5, (index) {
      return Cloud(
        x: random.nextDouble() * 1.2 - 0.1,
        y: random.nextDouble() * 0.3,
        width: random.nextDouble() * 100 + 50,
        speed: random.nextDouble() * 0.02 + 0.01, // Very slow speed range
      );
    });
  }

  @override
  void dispose() {
    _moonController.dispose();
    _cloudController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.backgroundColor,
            widget.backgroundColor.withBlue(
              ((widget.backgroundColor.blue * 1.2).clamp(0, 255)).toInt(),
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Stars
          CustomPaint(
            painter: StarsPainter(
              stars: stars,
              animation: _starController,
            ),
            size: Size.infinite,
          ),
          // Moon
          AnimatedBuilder(
            animation: _moonController,
            builder: (context, child) {
              return CustomPaint(
                painter: MoonPainter(animation: _moonController),
                size: Size.infinite,
              );
            },
          ),
          // Clouds
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, child) {
              return CustomPaint(
                painter: CloudsPainter(
                  clouds: clouds,
                  animation: _cloudController,
                ),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double blinkDelay;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.blinkDelay,
  });
}

class Cloud {
  double x;
  final double y;
  final double width;
  final double speed;

  Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.speed,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final Animation<double> animation;

  StarsPainter({required this.stars, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      final opacity = (math.sin(animation.value * math.pi * 2 + star.blinkDelay) + 1) / 2;
      paint.color = Colors.white.withOpacity(0.3 + opacity * 0.7);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}

class MoonPainter extends CustomPainter {
  final Animation<double> animation;

  MoonPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30); // Increased blur

    final moonCenter = Offset(
      size.width * 0.8,
      size.height * 0.2,
    );

    canvas.drawCircle(moonCenter, 45, paint); // Increased moon size from 30 to 45

    // Moon details - adjusted for larger size
    paint.maskFilter = null;
    paint.color = Colors.white70;
    canvas.drawCircle(
      Offset(moonCenter.dx - 15, moonCenter.dy - 15),
      12, // Increased from 8
      paint,
    );
    canvas.drawCircle(
      Offset(moonCenter.dx + 8, moonCenter.dy + 8),
      18, // Increased from 12
      paint,
    );
  }

  @override
  bool shouldRepaint(MoonPainter oldDelegate) => true;
}

class CloudsPainter extends CustomPainter {
  final List<Cloud> clouds;
  final Animation<double> animation;

  CloudsPainter({required this.clouds, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (var cloud in clouds) {
      // Calculate cloud position based on animation value
      final moveDistance = size.width * cloud.speed * animation.value;
      double xPos = (cloud.x * size.width + moveDistance) % size.width;
      
      // If cloud moves off screen, wrap it around
      if (xPos > size.width) {
        cloud.x = -0.2; // Reset to just before screen start
      }

      final path = Path();
      final centerY = cloud.y * size.height;

      // Draw cloud shapes
      _drawCloudShape(path, xPos, centerY, cloud.width);
      canvas.drawPath(path, paint);
    }
  }

  void _drawCloudShape(Path path, double x, double y, double width) {
    path.addOval(Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: width * 0.6,
    ));

    path.addOval(Rect.fromCenter(
      center: Offset(x - width * 0.2, y),
      width: width * 0.7,
      height: width * 0.4,
    ));

    path.addOval(Rect.fromCenter(
      center: Offset(x + width * 0.2, y),
      width: width * 0.7,
      height: width * 0.4,
    ));
  }

  @override
  bool shouldRepaint(CloudsPainter oldDelegate) => true;
}
