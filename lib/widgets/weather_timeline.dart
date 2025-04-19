import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class WeatherTimeline extends StatelessWidget {
  final List<DailyWeather> dailyWeather;
  final String title;

  const WeatherTimeline({
    super.key,
    required this.dailyWeather,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 16),
                ...List.generate(dailyWeather.length, (index) {
                  final day = dailyWeather[index];
                  final isToday = index == 0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        _buildDayIcon(day, isToday, index),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDayInfo(day, isToday, index),
                        ),
                        _buildTemperature(day, index),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayIcon(DailyWeather day, bool isToday, int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isToday ? [
            Colors.blue.withOpacity(0.8),
            Colors.blue.withOpacity(0.6),
          ] : [
            Colors.blue.withOpacity(0.3),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Text(
          day.weatherIcon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn()
      .scale(delay: Duration(milliseconds: 100 * index));
  }

  Widget _buildDayInfo(DailyWeather day, bool isToday, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isToday ? 'Today' : DateFormat('EEEE').format(day.date),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('MMM d').format(day.date),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn()
      .slideX();
  }

  Widget _buildTemperature(DailyWeather day, int index) {
    return Row(
      children: [
        Text(
          '${day.maxTemp.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${day.minTemp.round()}°',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 18,
          ),
        ),
      ],
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn()
      .slideX();
  }
}
