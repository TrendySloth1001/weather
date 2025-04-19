import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import 'custom_layer.dart';

class WeatherHeatmapLayer extends StatelessWidget {
  final List<WeatherModel> weatherPoints;
  final String dataType; // 'temperature', 'humidity', 'precipitation'

  const WeatherHeatmapLayer({
    super.key,
    required this.weatherPoints,
    required this.dataType,
  });

  @override
  Widget build(BuildContext context) {
    return CustomLayerWidget(
      painter: WeatherHeatmapPainter(
        weatherPoints: weatherPoints,
        dataType: dataType,
      ),
    );
  }
}

class WeatherHeatmapPainter extends CustomPainter {
  final List<WeatherModel> weatherPoints;
  final String dataType;

  WeatherHeatmapPainter({
    required this.weatherPoints,
    required this.dataType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (var point in weatherPoints) {
      double value = _getValue(point);
      Color color = _getColor(value);
      paint.color = color.withOpacity(0.3);

      canvas.drawCircle(
        Offset(point.latitude.toDouble(), point.longitude.toDouble()),
        30,
        paint,
      );
    }
  }

  double _getValue(WeatherModel point) {
    switch (dataType) {
      case 'temperature':
        return point.temperature;
      case 'humidity':
        return point.humidity;
      case 'precipitation':
        return point.precipitation;
      default:
        return 0;
    }
  }

  Color _getColor(double value) {
    if (dataType == 'temperature') {
      if (value < 0) return Colors.blue;
      if (value < 15) return Colors.green;
      if (value < 25) return Colors.yellow;
      return Colors.red;
    } else if (dataType == 'humidity') {
      return Color.lerp(Colors.yellow, Colors.blue, value / 100) ?? Colors.blue;
    } else if (dataType == 'precipitation') {
      return Color.lerp(Colors.transparent, Colors.blue, value / 100) ?? Colors.blue;
    }
    return Colors.blue;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
