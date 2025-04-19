import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CustomLayerWidget extends StatelessWidget {
  final CustomPainter painter;

  const CustomLayerWidget({
    super.key,
    required this.painter,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: painter,
      size: Size.infinite,
    );
  }
}
