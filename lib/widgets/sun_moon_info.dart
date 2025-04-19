import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class SunMoonInfo extends StatelessWidget {
  final WeatherModel weather;

  const SunMoonInfo({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSunInfo(),
                const Divider(height: 32),
                _buildMoonInfo(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildSunInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _InfoItem(
          icon: Icons.wb_sunny,
          title: 'Sunrise',
          value: DateFormat('HH:mm').format(weather.sunrise),
          color: Colors.orange,
        ),
        _InfoItem(
          icon: Icons.nightlight,
          title: 'Sunset',
          value: DateFormat('HH:mm').format(weather.sunset),
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildMoonInfo() {
    return _InfoItem(
      icon: Icons.brightness_2,
      title: 'Moon Phase',
      value: weather.moonPhaseDescription,
      color: Colors.blue,
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24)
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: const Duration(seconds: 2)),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
