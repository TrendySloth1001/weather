import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class WeatherCard extends StatelessWidget {

  final String value;
  final IconData icon;
  final Color color;

  const WeatherCard({
    super.key,
        required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 25, color: color)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: const Duration(seconds: 2), color: color.withOpacity(0.3)),
              const SizedBox(height: 8),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().scale(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
    );
  }
}
