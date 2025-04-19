import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedWeatherIcon extends StatelessWidget {
  final String icon;
  final double size;

  const AnimatedWeatherIcon({
    super.key,
    required this.icon,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      icon,
      style: TextStyle(fontSize: size),
    )
    .animate()
    .fade(duration: const Duration(milliseconds: 500))
    .scale(
      begin: const Offset(0.5, 0.5),
      end: const Offset(1, 1),
      duration: const Duration(milliseconds: 500),
    );
  }
}
