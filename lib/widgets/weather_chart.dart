import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';

class WeatherChart extends StatelessWidget {
  final List<HourlyWeather> hourlyData;
  final String title;

  const WeatherChart({
    super.key,
    required this.hourlyData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(_createChartData()),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createChartData() {
    return LineChartData(
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: _getGridLine,
      ),
      titlesData: _getTitlesData(),
      lineBarsData: [_getLineData()],
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineTouchData: _getLineTouchData(),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white10),
      ),
    );
  }

  static FlLine _getGridLine(double value) {
    return FlLine(
      color: Colors.white10,
      strokeWidth: 1,
      dashArray: [5, 5], // Dotted lines for better readability
    );
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= hourlyData.length) return const Text('');
            return Text(
              '${hourlyData[value.toInt()].time.hour}:00',
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
    );
  }

  LineChartBarData _getLineData() {
    return LineChartBarData(
      spots: hourlyData.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value.temperature);
      }).toList(),
      isCurved: true,
      color: Colors.blue,
      dotData: const FlDotData(show: false),
    );
  }

  double _getMinY() {
    return hourlyData.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxY() {
    return hourlyData.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
  }

  LineTouchData _getLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.blueAccent,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final hour = hourlyData[spot.x.toInt()].time.hour;
            final temperature = spot.y;
            return LineTooltipItem(
              '$hour:00\n${temperature.toStringAsFixed(1)}°C',
              const TextStyle(color: Colors.white),
            );
          }).toList();
        },
      ),
    );
  }
}
