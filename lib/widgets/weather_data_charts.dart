import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class WeatherDataCharts extends StatefulWidget {
  final WeatherModel weather;

  const WeatherDataCharts({super.key, required this.weather});

  @override
  State<WeatherDataCharts> createState() => _WeatherDataChartsState();
}

class _WeatherDataChartsState extends State<WeatherDataCharts> {
  int _selectedChartIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
                _buildChartSelector(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildSelectedChart(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSelector() {
    return Row(
      children: [
        _ChartButton(
          title: 'Temperature',
          isSelected: _selectedChartIndex == 0,
          onTap: () => setState(() => _selectedChartIndex = 0),
        ),
        _ChartButton(
          title: 'Precipitation',
          isSelected: _selectedChartIndex == 1,
          onTap: () => setState(() => _selectedChartIndex = 1),
        ),
        _ChartButton(
          title: 'Humidity',
          isSelected: _selectedChartIndex == 2,
          onTap: () => setState(() => _selectedChartIndex = 2),
        ),
      ],
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChartIndex) {
      case 0:
        return _buildTemperatureChart();
      case 1:
        return _buildPrecipitationChart();
      case 2:
        return _buildHumidityChart();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTemperatureChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: _getTitlesData(),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: widget.weather.hourlyForecast.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.temperature);
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: _getLineTouchData(),
      ),
    );
  }

  Widget _buildPrecipitationChart() {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: _getTitlesData(),
        borderData: FlBorderData(show: false),
        barGroups: widget.weather.hourlyForecast.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.precipitation,
                color: Colors.blue,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHumidityChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: _getTitlesData(),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: widget.weather.hourlyForecast.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.humidity);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: _getLineTouchData(),
      ),
    );
  }

  FlTitlesData _getTitlesData() {    return FlTitlesData(
      bottomTitles: AxisTitles(
        axisNameWidget: const Text(
          'Time',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          interval: 2,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= widget.weather.hourlyForecast.length) {
              return const Text('');
            }
            return Transform.rotate(
              angle: -0.5,
              child: Text(
                DateFormat('HH:mm').format(
                  widget.weather.hourlyForecast[value.toInt()].time,
                ),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            );
          },
          reservedSize: 36,
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          _getYAxisTitle(),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          interval: _getYAxisInterval(),
          reservedSize: 45,
          getTitlesWidget: (value, meta) {
            return Text(
              _formatYAxisValue(value),
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _getYAxisTitle() {
    switch (_selectedChartIndex) {
      case 0:
        return 'Temperature (°C)';
      case 1:
        return 'Precipitation (%)';
      case 2:
        return 'Humidity (%)';
      default:
        return '';
    }
  }

  double _getYAxisInterval() {
    switch (_selectedChartIndex) {
      case 0:
        return 5;
      case 1:
      case 2:
        return 20;
      default:
        return 10;
    }
  }

  String _formatYAxisValue(double value) {
    switch (_selectedChartIndex) {
      case 0:
        return '${value.round()}°';
      case 1:
      case 2:
        return '${value.round()}%';
      default:
        return value.toString();
    }
  }

  LineTouchData _getLineTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.black87,
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final time = DateFormat('HH:mm').format(
              widget.weather.hourlyForecast[spot.x.toInt()].time,
            );
            return LineTooltipItem(
              '$time\n${_formatYAxisValue(spot.y)}',
              const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: '\n${_getTooltipDescription(spot.y)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
      touchSpotThreshold: 10,
    );
  }

  String _getTooltipDescription(double value) {
    switch (_selectedChartIndex) {
      case 0:
        if (value > 25) return 'Hot';
        if (value > 15) return 'Warm';
        if (value > 5) return 'Cool';
        return 'Cold';
      case 1:
        if (value > 70) return 'Heavy Rain';
        if (value > 30) return 'Moderate Rain';
        if (value > 10) return 'Light Rain';
        return 'Dry';
      case 2:
        if (value > 70) return 'Very Humid';
        if (value > 50) return 'Moderate';
        return 'Dry';
      default:
        return '';
    }
  }
}

class _ChartButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue.withOpacity(0.8) : Colors.transparent,
                width: 2,
              ),
            ),
            gradient: isSelected ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.withOpacity(0.2),
                Colors.blue.withOpacity(0.1),
              ],
            ) : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
