import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class HourlyWeatherTimeline extends StatefulWidget {
  final List<HourlyWeather> hourlyWeather;
  final DateTime currentTime;

  const HourlyWeatherTimeline({
    super.key,
    required this.hourlyWeather,
    required this.currentTime,
  });

  @override
  State<HourlyWeatherTimeline> createState() => _HourlyWeatherTimelineState();
}

class _HourlyWeatherTimelineState extends State<HourlyWeatherTimeline> {
  String _selectedGraphType = 'temperature';
  bool _showGraph = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentHour();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentHour() {
    if (!_scrollController.hasClients) return;
    final currentHourIndex = widget.hourlyWeather.indexWhere(
      (hour) => hour.time.hour == widget.currentTime.hour,
    );
    if (currentHourIndex != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      final cardWidth = math.min(screenWidth * 0.85, 300.0);
      final offset = currentHourIndex * cardWidth - (screenWidth - cardWidth) / 2;
      _scrollController.animateTo(
        math.max(0, offset),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showWeatherDetails(HourlyWeather weather) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.65,
        child: DetailedWeatherSheet(
          weather: weather,
          hourlyData: widget.hourlyWeather,
          currentTime: widget.currentTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Today\'s Forecast',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _showGraph ? Icons.view_list : Icons.show_chart,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _showGraph = !_showGraph),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: _buildHourlyList(),
                secondChild: _buildHourlyGraph(),
                crossFadeState: _showGraph
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 160,
          margin: const EdgeInsets.only(bottom: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = math.min(constraints.maxWidth * 0.85, 300.0);
              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  final currentIndex = widget.hourlyWeather.indexWhere(
                    (hour) => hour.time.hour == widget.currentTime.hour,
                  );
                  if (details.primaryVelocity! > 0 && currentIndex > 0) {
                    // Swipe right - show previous hour
                    _showWeatherDetails(widget.hourlyWeather[currentIndex - 1]);
                  } else if (details.primaryVelocity! < 0 &&
                      currentIndex < widget.hourlyWeather.length - 1) {
                    // Swipe left - show next hour
                    _showWeatherDetails(widget.hourlyWeather[currentIndex + 1]);
                  }
                },
                child: PageView.builder(
                  controller: PageController(
                    viewportFraction: cardWidth / constraints.maxWidth,
                    initialPage: widget.hourlyWeather.indexWhere(
                      (hour) => hour.time.hour == widget.currentTime.hour,
                    ),
                  ),
                  onPageChanged: (index) {
                    _showWeatherDetails(widget.hourlyWeather[index]);
                  },
                  itemCount: widget.hourlyWeather.length,
                  itemBuilder: (context, index) {
                    final hourData = widget.hourlyWeather[index];
                    final isCurrentHour = hourData.time.hour == widget.currentTime.hour;
                    return _HourlyWeatherCard(
                      weather: hourData,
                      isCurrentHour: isCurrentHour,
                      index: index,
                      width: cardWidth,
                      hourlyData: widget.hourlyWeather,
                      currentTime: widget.currentTime,
                    ).animate(
                      delay: Duration(milliseconds: 50 * index),
                    ).fadeIn(
                      duration: const Duration(milliseconds: 200),
                    ).slideX(
                      begin: 0.2,
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyGraph() {
    // Find current hour index
    final currentHourIndex = widget.hourlyWeather.indexWhere(
      (hour) => hour.time.hour == widget.currentTime.hour,
    );

    // Get relevant hours (-3 to +5 around current hour)
    final startIndex = math.max(0, currentHourIndex - 3);
    final endIndex = math.min(widget.hourlyWeather.length - 1, currentHourIndex + 5);
    final relevantHours = widget.hourlyWeather.sublist(startIndex, endIndex + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Temperature Trends',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGraphTypeSelector(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getInterval(),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white10,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= relevantHours.length) return const Text('');
                              final hour = relevantHours[value.toInt()];
                              final isCurrentHour = hour.time.hour == widget.currentTime.hour;
                              return Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  DateFormat('HH:mm').format(hour.time),
                                  style: TextStyle(
                                    color: isCurrentHour ? Colors.blue : Colors.white60,
                                    fontSize: 11,
                                    fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _getYAxisLabel(),
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _getInterval(),
                            reservedSize: 35,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _formatAxisValue(value),
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: relevantHours.asMap().entries.map((e) {
                            final value = switch (_selectedGraphType) {
                              'temperature' => e.value.temperature,
                              'precipitation' => e.value.precipitation,
                              'humidity' => e.value.humidity,
                              _ => 0.0,
                            };
                            return FlSpot(e.key.toDouble(), value);
                          }).toList(),
                          isCurved: true,
                          color: _getGraphColor(),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              final isCurrentHour = relevantHours[index].time.hour == widget.currentTime.hour;
                              return FlDotCirclePainter(
                                radius: isCurrentHour ? 6 : 4,
                                color: _getGraphColor(),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _getGraphColor().withOpacity(0.1),
                          ),
                        ),
                      ],
                      minY: _getMinY(relevantHours),
                      maxY: _getMaxY(relevantHours),
                      lineTouchData: _getLineTouchData(relevantHours),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getMinY(List<HourlyWeather> hours) {
    if (hours.isEmpty) return 0;
    switch (_selectedGraphType) {
      case 'temperature':
        return hours.map((h) => h.temperature).reduce(min) - 5;
      case 'precipitation':
      case 'humidity':
        return 0;
      default:
        return 0;
    }
  }

  double _getMaxY(List<HourlyWeather> hours) {
    if (hours.isEmpty) return 100;
    switch (_selectedGraphType) {
      case 'temperature':
        return hours.map((h) => h.temperature).reduce(max) + 5;
      case 'precipitation':
      case 'humidity':
        return 100;
      default:
        return 100;
    }
  }

  LineTouchData _getLineTouchData(List<HourlyWeather> hours) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.black87,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final hour = hours[spot.x.toInt()];
            return LineTooltipItem(
              '${DateFormat('HH:mm').format(hour.time)}\n${_formatTooltipValue(spot.y)}',
              const TextStyle(color: Colors.white70, fontSize: 12),
              children: [
                TextSpan(
                  text: '\n${_getTooltipDescription(spot.y)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildGraphTypeSelector() {
    return Row(
      children: [
        _GraphTypeChip(
          label: 'Temperature',
          icon: Icons.thermostat,
          isSelected: _selectedGraphType == 'temperature',
          onTap: () => setState(() => _selectedGraphType = 'temperature'),
        ),
        _GraphTypeChip(
          label: 'Precipitation',
          icon: Icons.water_drop,
          isSelected: _selectedGraphType == 'precipitation',
          onTap: () => setState(() => _selectedGraphType = 'precipitation'),
        ),
        _GraphTypeChip(
          label: 'Humidity',
          icon: Icons.water_outlined,
          isSelected: _selectedGraphType == 'humidity',
          onTap: () => setState(() => _selectedGraphType = 'humidity'),
        ),
      ],
    ).animate().fadeIn();
  }

  String _formatTooltipValue(double value) {
    switch (_selectedGraphType) {
      case 'temperature':
        return '${value.round()}°';
      case 'precipitation':
      case 'humidity':
        return '${value.round()}%';
      default:
        return value.toString();
    }
  }

  double _getInterval() {
    switch (_selectedGraphType) {
      case 'temperature':
        return 5;
      case 'precipitation':
      case 'humidity':
        return 20;
      default:
        return 10;
    }
  }

  String _getYAxisLabel() {
    switch (_selectedGraphType) {
      case 'temperature':
        return 'Temperature (°C)';
      case 'precipitation':
        return 'Precipitation (%)';
      case 'humidity':
        return 'Humidity (%)';
      default:
        return '';
    }
  }

  String _formatAxisValue(double value) {
    switch (_selectedGraphType) {
      case 'temperature':
        return '${value.round()}°';
      case 'precipitation':
      case 'humidity':
        return '${value.round()}%';
      default:
        return value.toString();
    }
  }

  String _getTooltipDescription(double value) {
    switch (_selectedGraphType) {
      case 'temperature':
        if (value > 30) return 'Very Hot';
        if (value > 25) return 'Hot';
        if (value > 20) return 'Warm';
        if (value > 15) return 'Mild';
        if (value > 10) return 'Cool';
        return 'Cold';
      case 'precipitation':
        if (value > 70) return 'Heavy Rain';
        if (value > 40) return 'Moderate Rain';
        if (value > 20) return 'Light Rain';
        return 'Dry';
      case 'humidity':
        if (value > 70) return 'Very Humid';
        if (value > 50) return 'Moderate';
        if (value > 30) return 'Comfortable';
        return 'Dry';
      default:
        return '';
    }
  }

  Color _getGraphColor() {
    switch (_selectedGraphType) {
      case 'temperature':
        return Colors.orange;
      case 'precipitation':
        return Colors.blue;
      case 'humidity':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}

class DetailedWeatherSheet extends StatelessWidget {
  final HourlyWeather weather;
  final List<HourlyWeather> hourlyData;
  final DateTime currentTime;

  const DetailedWeatherSheet({
    super.key,
    required this.weather,
    required this.hourlyData,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final hourIndex = hourlyData.indexOf(weather);
    final previousHour = hourIndex > 0 ? hourlyData[hourIndex - 1] : null;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 1000) {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        }
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d - HH:mm').format(weather.time),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTrendGraph(),
                        if (previousHour != null) _buildComparison(previousHour),
                        _buildDetailedStats(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      curve: Curves.easeOutExpo,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildDragHandle() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTrendGraph() {
    // Get the current hour index and the surrounding hours
    final hourIndex = hourlyData.indexOf(weather);
    final prevHour = hourIndex > 0 ? hourlyData[hourIndex - 1] : null;
    final nextHour = hourIndex < hourlyData.length - 1 ? hourlyData[hourIndex + 1] : null;

    // Create a list of 3 hours (previous, current, next)
    final displayHours = [
      if (prevHour != null) prevHour,
      weather,
      if (nextHour != null) nextHour,
    ];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= displayHours.length) return const Text('');
                  final hour = displayHours[value.toInt()];
                  final isCurrentHour = hour.time == weather.time;
                  return Text(
                    DateFormat('HH:mm').format(hour.time),
                    style: TextStyle(
                      color: isCurrentHour ? Colors.blue : Colors.white60,
                      fontSize: 12,
                      fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.round()}°',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  );
                },
                interval: 5,
                reservedSize: 40,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: displayHours.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.temperature);
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isCurrentHour = displayHours[index].time == weather.time;
                  return FlDotCirclePainter(
                    radius: isCurrentHour ? 6 : 4,
                    color: Colors.orange,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.1),
              ),
            ),
          ],
          minY: displayHours.map((e) => e.temperature).reduce(min) - 2,
          maxY: displayHours.map((e) => e.temperature).reduce(max) + 2,
        ),
      ),
    );
  }

  Widget _buildComparison(HourlyWeather previousHour) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hour Comparison',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 25) / 2; // Account for divider
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: itemWidth, child: _buildTimeColumn(previousHour, 'Previous Hour')),
                  const SizedBox(width: 16),
                  Container(
                    width: 1,
                    height: 120,
                    color: Colors.white12,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: itemWidth, child: _buildTimeColumn(weather, 'Current Hour')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(HourlyWeather weather, String label) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('HH:mm').format(weather.time),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildComparisonWithTrend(
          Icons.thermostat,
          '${weather.temperature.round()}°',
          weather.temperature,
          this.weather.temperature,
          Colors.orange,
          size: 24,
        ),
        const SizedBox(height: 8),
        _buildComparisonWithTrend(
          Icons.water_drop,
          '${weather.precipitation.round()}%',
          weather.precipitation,
          this.weather.precipitation,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildComparisonWithTrend(
          Icons.water,
          '${weather.humidity.round()}%',
          weather.humidity,
          this.weather.humidity,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildComparisonWithTrend(
    IconData icon,
    String value,
    double currentValue,
    double comparisonValue,
    Color color, {
    double size = 20,
  }) {
    final difference = currentValue - comparisonValue;
    final showTrend = value != '${weather.temperature}°' &&
        value != '${weather.precipitation}%' &&
        value != '${weather.humidity}%';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      constraints: const BoxConstraints(maxHeight: 80),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: size),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.75,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (showTrend) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  difference > 0
                      ? Icons.arrow_upward
                      : difference < 0
                          ? Icons.arrow_downward
                          : Icons.remove,
                  color: difference > 0
                      ? Colors.green
                      : difference < 0
                          ? Colors.red
                          : Colors.grey,
                  size: 12,
                ),
                Text(
                  difference.abs() < 0.1
                      ? 'No change'
                      : '${difference.abs().toStringAsFixed(1)}',
                  style: TextStyle(
                    color: difference > 0
                        ? Colors.green
                        : difference < 0
                            ? Colors.red
                            : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Weather Details',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _DetailItem(
              icon: Icons.thermostat,
              label: 'Temperature',
              value: '${weather.temperature.round()}°C',
              color: Colors.orange,
            ),
            _DetailItem(
              icon: Icons.water_drop,
              label: 'Precipitation',
              value: '${weather.precipitation.round()}%',
              color: Colors.blue,
            ),
            _DetailItem(
              icon: Icons.air,
              label: 'Wind Speed',
              value: '${weather.windSpeed.round()} km/h',
              color: Colors.green,
            ),
            _DetailItem(
              icon: Icons.water,
              label: 'Humidity',
              value: '${weather.humidity.round()}%',
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced from 12
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row( // Changed from Column to Row
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20), // Reduced size from default
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.white70, fontSize: 11), // Reduced from 12
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 14, // Reduced from 16
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(delay: Duration(milliseconds: 100));
  }
}

class _GraphTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GraphTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.blue.withOpacity(0.1),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.blue : Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HourlyWeatherCard extends StatelessWidget {
  final HourlyWeather weather;
  final bool isCurrentHour;
  final int index;
  final double width;
  final List<HourlyWeather> hourlyData;
  final DateTime currentTime;

  const _HourlyWeatherCard({
    required this.weather,
    required this.isCurrentHour,
    required this.index,
    required this.width,
    required this.hourlyData,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          enableDrag: true,
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.65,
            child: DetailedWeatherSheet(
              weather: weather,
              hourlyData: hourlyData,
              currentTime: currentTime,
            ),
          ),
        );
      },
      onLongPress: () => HapticFeedback.heavyImpact(),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: isCurrentHour
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentHour
                ? Colors.blue.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTimeAndTemp(),
            ),
            Expanded(
              flex: 3,
              child: _buildWeatherInfo(),
            ),
          ],
        ),
      ),
    ).animate(
      delay: Duration(milliseconds: 50 * index),
    ).fadeIn(duration: const Duration(milliseconds: 200))
     .slideX(duration: const Duration(milliseconds: 200));
  }

  Widget _buildTimeAndTemp() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(weather.time),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
              color: isCurrentHour ? Colors.blue : Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${weather.temperature.round()}°',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCurrentHour ? Colors.blue : Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _getWeatherIcon(weather.weatherCode),
                color: isCurrentHour ? Colors.blue : Colors.white70,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDetailRow(
            Icons.water_drop,
            'Rain',
            '${weather.precipitation.round()}%',
          ),
          _buildDetailRow(
            Icons.air,
            'Wind',
            '${weather.windSpeed.round()} km/h',
          ),
          _buildDetailRow(
            Icons.water,
            'Humidity',
            '${weather.humidity.round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(int code) {
    if (code <= 3) return Icons.wb_sunny;
    if (code <= 48) return Icons.cloud;
    if (code <= 65) return Icons.grain;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 82) return Icons.water_drop;
    return Icons.thunderstorm;
  }
}

class DailyAverage {
  final DateTime date;
  final double avgTemp;
  final double avgPrecip;
  final double avgHumidity;

  DailyAverage({
    required this.date,
    required this.avgTemp,
    required this.avgPrecip,
    required this.avgHumidity,
  });
}
