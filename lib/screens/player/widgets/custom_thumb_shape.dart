import 'package:flutter/material.dart';

class CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const CustomThumbShape({
    this.thumbRadius = 6.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    double textScaleFactor,
    Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = sliderTheme.thumbColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 15, circlePaint);
    canvas.drawCircle(center, 5, fillPaint);
  }
}
