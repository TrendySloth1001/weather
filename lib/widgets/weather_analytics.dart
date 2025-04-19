import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class WeatherAnalytics extends StatefulWidget {
  final WeatherModel currentWeather;
  final List<DailyWeather> historicalData;

  const WeatherAnalytics({
    super.key,
    required this.currentWeather,
    required this.historicalData,
  });

  @override
  State<WeatherAnalytics> createState() => _WeatherAnalyticsState();
}

class _WeatherAnalyticsState extends State<WeatherAnalytics>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildTabSelector(),
          _buildTabView(),
          _buildStatsSummary(),
          _buildPatternPrediction(),
        ].animate(interval: const Duration(milliseconds: 100))
         .fadeIn()
         .slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.2),
                Colors.purple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              _buildWeatherScore(),
              const SizedBox(height: 16),
              _buildTrendIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherScore() {
    final score = _calculateWeatherScore();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Score',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  score.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _getScoreIcon(score),
                  color: _getScoreColor(score),
                  size: 28,
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: 80,
          height: 80,
          child: _buildScoreGauge(score),
        ),
      ],
    );
  }

  Widget _buildTrendIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTrendItem(
          'Temperature Trend',
          _calculateTemperatureTrend(),
          Colors.orange,
        ),
        _buildTrendItem(
          'Precipitation Risk',
          _calculatePrecipitationTrend(),
          Colors.blue,
        ),
        _buildTrendItem(
          'Comfort Level',
          _calculateComfortIndex(),
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // Match card margins
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the tabs
        children: [
          _buildTabItem('Temperature', Icons.thermostat, 0),
          _buildTabItem('Precipitation', Icons.water_drop, 1),
          _buildTabItem('Wind', Icons.air, 2),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildTabItem(String label, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded( // Make tabs fill space evenly
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4), // Add spacing between tabs
        child: GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: isSelected ? LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.1),
                ],
              ) : null,
              border: isSelected ? Border.all(
                color: Colors.blue.withOpacity(0.3),
              ) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 20, // Reduced size
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey,
                    fontSize: 11, // Reduced size
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

  Widget _buildTabView() {
    return SizedBox(
      height: 350,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: [
            _buildTemperatureAnalysis(),
            _buildPrecipitationAnalysis(),
            _buildWindAnalysis(),
          ][_selectedIndex],
        ),
      ),
    );
  }

  Widget _buildTemperatureAnalysis() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                ),
              ),
              titlesData: _getTitlesData(),
              borderData: FlBorderData(show: false),
              lineBarsData: [_getTemperatureLine()],
              minY: _getMinTemperature() - 5,
              maxY: _getMaxTemperature() + 5,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.round()}°',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildPrecipitationAnalysis() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                ),
              ),
              titlesData: _getTitlesData(),
              borderData: FlBorderData(show: false),
              barGroups: _getPrecipitationBars(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()}%',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildWindAnalysis() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Expanded(
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(-0.3),
                  alignment: Alignment.center,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.circle,
                      ticksTextStyle: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                      getTitle: (index, angle) => RadarChartTitle(
                        text: _getWindDirectionTitle(index),
                        angle: angle,
                      ),
                      dataSets: [_getWindDataSet()],
                      radarBackgroundColor: Colors.blue.withAlpha(40),
                      borderData: FlBorderData(show: false),
                      radarBorderData: const BorderSide(color: Colors.white24),
                      tickBorderData: const BorderSide(color: Colors.white12),
                      gridBorderData: const BorderSide(color: Colors.white10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildWindStats(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  String _getWindDirectionTitle(int index) {
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return index >= 0 && index < directions.length ? directions[index] : '';
  }

  Widget _buildWindStats() {
    final avgSpeed = _calculateAverageWind();
    final maxSpeed = widget.historicalData
        .map((e) => e.maxTemp)
        .reduce((a, b) => math.max(a, b));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildWindStatCard(
          'Average',
          '$avgSpeed km/h',
          Icons.speed,
          Colors.blue,
        ),
        _buildWindStatCard(
          'Max Speed',
          '$maxSpeed km/h',
          Icons.trending_up,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildWindStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: color.withAlpha(200))),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final tempData = _calculateTemperatureStats();
    final rainData = _calculateRainStats();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Statistics',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  'Temperature',
                  Icons.thermostat,
                  [
                    StatItem('Average', '${tempData.average.toStringAsFixed(1)}°'),
                    StatItem('Max', '${tempData.max.toStringAsFixed(1)}°'),
                    StatItem('Min', '${tempData.min.toStringAsFixed(1)}°'),
                    StatItem('Variance', '±${tempData.variance.toStringAsFixed(1)}°'),
                  ],
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedStatCard(
                  'Precipitation',
                  Icons.water_drop,
                  [
                    StatItem('Chance', '${rainData.probability.toStringAsFixed(0)}%'),
                    StatItem('Intensity', '${rainData.intensity.toStringAsFixed(1)} mm'),
                    StatItem('Duration', '${rainData.duration.toStringAsFixed(0)} hrs'),
                    StatItem('Trend', rainData.trend),
                  ],
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard(String title, IconData icon, List<StatItem> stats, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...stats.map((stat) => _buildStatItem(stat, color)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildStatItem(StatItem stat, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stat.label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          Text(
            stat.value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  WeatherStats _calculateTemperatureStats() {
    final temps = widget.historicalData.map((e) => (e.maxTemp + e.minTemp) / 2).toList();
    final max = temps.reduce(math.max);
    final min = temps.reduce(math.min);
    final avg = temps.reduce((a, b) => a + b) / temps.length;
    final variance = temps.map((t) => math.pow(t - avg, 2)).reduce((a, b) => a + b) / temps.length;
    
    return WeatherStats(
      average: avg,
      max: max,
      min: min,
      variance: math.sqrt(variance),
    );
  }

  RainStats _calculateRainStats() {
    final precipData = widget.historicalData.map((e) => e.precipitation).toList();
    final probability = precipData.where((p) => p > 0).length / precipData.length * 100;
    final intensity = precipData.reduce((a, b) => a + b) / precipData.length;
    final rainyHours = precipData.where((p) => p > 0).length;
    final trend = _getRainTrend(precipData);

    return RainStats(
      probability: probability,
      intensity: intensity,
      duration: rainyHours.toDouble(),
      trend: trend,
    );
  }

  String _getRainTrend(List<double> precipData) {
    if (precipData.isEmpty) return 'N/A';
    
    final firstHalf = precipData.sublist(0, precipData.length ~/ 2);
    final secondHalf = precipData.sublist(precipData.length ~/ 2);
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    final diff = secondAvg - firstAvg;
    if (diff > 5) return '↑ Rising';
    if (diff < -5) return '↓ Falling';
    return '→ Stable';
  }

  Widget _buildPatternPrediction() {
    final patterns = _analyzeWeatherPatterns();
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Weather Pattern Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: patterns.map((pattern) => 
                _buildPatternCard(pattern)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(WeatherPattern pattern) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(left: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(pattern.icon, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pattern.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: pattern.confidence,
            backgroundColor: Colors.purple.withAlpha(30),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          const SizedBox(height: 12),
          Text(
            pattern.description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    ).animate()
     .slideX(begin: 0.2, duration: const Duration(milliseconds: 200))
     .fadeIn();
  }

  List<WeatherPattern> _analyzeWeatherPatterns() {
    return [
      _analyzeTemperaturePattern(),
      _analyzePrecipitationPattern(),
      _analyzeWindPattern(),
      _analyzeComfortPattern(),
    ];
  }

  WeatherPattern _analyzeTemperaturePattern() {
    final trend = _calculateTemperatureTrend();
    final confidence = _calculatePatternConfidence(trend);
    final description = _getPatternDescription(trend);
    
    return WeatherPattern(
      'Temperature Pattern',
      description,
      Icons.thermostat,
      confidence,
    );
  }

  WeatherPattern _analyzePrecipitationPattern() {
    final precipTrend = _calculatePrecipitationTrend();
    final confidence = _calculatePatternConfidence(precipTrend);
    final description = precipTrend > 0.5
        ? 'High chance of precipitation'
        : 'Low chance of precipitation';

    return WeatherPattern(
      'Precipitation Pattern',
      description,
      Icons.water_drop,
      confidence,
    );
  }

  WeatherPattern _analyzeWindPattern() {
    final windSpeed = widget.currentWeather.windspeed;
    final confidence = _normalizeValue(windSpeed, 0, 100);
    final description = windSpeed > 20
        ? 'Strong winds expected'
        : windSpeed > 10
            ? 'Moderate winds'
            : 'Light winds';

    return WeatherPattern(
      'Wind Pattern',
      description,
      Icons.air,
      confidence,
    );
  }

  WeatherPattern _analyzeComfortPattern() {
    final comfortIndex = _calculateComfortIndex();
    final confidence = _normalizeValue(comfortIndex, 0, 100);
    final description = comfortIndex > 0.7
        ? 'Very comfortable'
        : comfortIndex > 0.4
            ? 'Moderate comfort'
            : 'Uncomfortable conditions';

    return WeatherPattern(
      'Comfort Pattern',
      description,
      Icons.thermostat,
      confidence,
    );
  }

  double _calculatePatternConfidence(double trend) {
    final variations = widget.historicalData.map((data) {
      return (data.maxTemp - data.minTemp).abs();
    }).toList();
    
    final avgVariation = variations.reduce((a, b) => a + b) / variations.length;
    return 1 - (avgVariation / 20).clamp(0, 1);
  }

  String _getPatternDescription(double trend) {
    if (trend > 2) return 'Rapidly Rising';
    if (trend > 0.5) return 'Gradually Rising';
    if (trend < -2) return 'Rapidly Falling';
    if (trend < -0.5) return 'Gradually Falling';
    return 'Stable';
  }

  double _calculateWeatherScore() {
    final tempScore = _normalizeValue(
      widget.currentWeather.temperature,
      -10,
      35,
    );
    final precipScore = 1 - (widget.currentWeather.precipitation / 100);
    final uvScore = 1 - _normalizeValue(widget.currentWeather.uvIndex, 0, 11);

    return (tempScore * 0.4 + precipScore * 0.3 + uvScore * 0.3) * 10;
  }

  double _normalizeValue(double value, double min, double max) {
    return (value - min) / (max - min);
  }

  double _calculateAverageWind() {
    return widget.currentWeather.windspeed;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 8) return Icons.sentiment_very_satisfied;
    if (score >= 6) return Icons.sentiment_satisfied;
    if (score >= 4) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lime;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildScoreGauge(double score) {
    return CustomPaint(
      painter: ScoreGaugePainter(
        score: score,
        color: _getScoreColor(score),
      ),
      child: Center(
        child: Text(
          '${(score * 10).round()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  double _calculateTemperatureTrend() {
    final temps = widget.historicalData.map((e) => (e.maxTemp + e.minTemp) / 2).toList();
    return _calculateTrendValue(temps);
  }

  double _calculatePrecipitationTrend() {
    return widget.currentWeather.precipitation / 100;
  }

  double _calculateComfortIndex() {
    final temp = widget.currentWeather.temperature;
    final humidity = widget.currentWeather.humidity;
    final heatIndex = 0.5 * (temp + 61.0 + ((temp - 68.0) * 1.2) + (humidity * 0.094));
    return _normalizeValue(heatIndex, 0, 100);
  }

  double _calculateTrendValue(List<double> values) {
    if (values.length < 2) return 0;
    final diffs = List.generate(values.length - 1, (i) => values[i + 1] - values[i]);
    return diffs.reduce((a, b) => a + b) / diffs.length;
  }

  Widget _buildTrendItem(String label, double value, Color color) {
    final isPositive = value >= 0;
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 16,
            ),
            Text(
              value.abs().toStringAsFixed(1),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  RadarDataSet _getWindDataSet() {
    return RadarDataSet(
      fillColor: Colors.blue.withOpacity(0.2),
      borderColor: Colors.blue,
      entryRadius: 3,
      dataEntries: _getWindDirectionData(),
    );
  }

  List<RadarEntry> _getWindDirectionData() {
    final List<RadarEntry> entries = [];
    final windData = _calculateWindDirectionData();
    
    for (int i = 0; i < 8; i++) {
      entries.add(RadarEntry(value: windData[i]));
    }

    return entries;
  }

  List<double> _calculateWindDirectionData() {
    List<double> directionCounts = List.filled(8, 0.0);
    
    for (var day in widget.historicalData) {
      final windSpeed = widget.currentWeather.windspeed;
      final normalizedSpeed = _normalizeValue(windSpeed, 0, 100);
      final directionIndex = day.date.day % 8;
      directionCounts[directionIndex] += normalizedSpeed;
    }

    final maxCount = directionCounts.reduce(math.max);
    return directionCounts.map((count) => 
      count > 0 ? (count / maxCount) * 10.0 : 0.0
    ).toList();
  }

  double _getMinTemperature() {
    return widget.historicalData
        .map((e) => e.minTemp)
        .reduce(math.min);
  }

  double _getMaxTemperature() {
    return widget.historicalData
        .map((e) => e.maxTemp)
        .reduce(math.max);
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= widget.historicalData.length) {
              return const Text('');
            }
            return Text(
              DateFormat('d MMM').format(widget.historicalData[value.toInt()].date),
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(0),
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineChartBarData _getTemperatureLine() {
    return LineChartBarData(
      spots: widget.historicalData.asMap().entries.map((e) {
        return FlSpot(
          e.key.toDouble(),
          (e.value.maxTemp + e.value.minTemp) / 2,
        );
      }).toList(),
      isCurved: true,
      color: Colors.orange,
      barWidth: 2,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.orange.withOpacity(0.1),
      ),
    );
  }

  List<BarChartGroupData> _getPrecipitationBars() {
    return widget.historicalData.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.maxTemp - e.value.minTemp,
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}

class ScoreGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  ScoreGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - paint.strokeWidth / 2;

    paint.color = Colors.grey.withAlpha(30);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi,
      false,
      paint,
    );

    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi * score,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WeatherPattern {
  final String name;
  final String description;
  final IconData icon;
  final double confidence;

  WeatherPattern(this.name, this.description, this.icon, this.confidence);
}

class WeatherStats {
  final double average;
  final double max;
  final double min;
  final double variance;

  WeatherStats({
    required this.average,
    required this.max,
    required this.min,
    required this.variance,
  });
}

class RainStats {
  final double probability;
  final double intensity;
  final double duration;
  final String trend;

  RainStats({
    required this.probability,
    required this.intensity,
    required this.duration,
    required this.trend,
  });
}

class StatItem {
  final String label;
  final String value;

  StatItem(this.label, this.value);
}
