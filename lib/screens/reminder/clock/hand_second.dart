import 'dart:math';

import 'package:flutter/material.dart';

class SecondHandPainter extends CustomPainter {

  final Paint secondHandPaint;
  final Paint secondHandPointsPaint;

  int seconds;

  SecondHandPainter({this.seconds})
      : secondHandPaint = new Paint(),
        secondHandPointsPaint = new Paint() {
    secondHandPaint.color = Color(0xff233d9b);
    secondHandPaint.style = PaintingStyle.stroke;
    secondHandPaint.strokeWidth = 2.0;
    secondHandPaint.strokeCap = StrokeCap.round;

    secondHandPointsPaint.color = Color(0xff233d9b);
    secondHandPointsPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    canvas.save();

    canvas.translate(radius, radius);

    canvas.rotate(2 * pi * this.seconds / 60);

    Path path1 = Path();
    Path path2 = Path();
    path1.moveTo(0.0, -radius + 20.0);
    path1.lineTo(0.0, 0.0);

    path2.addOval(Rect.fromCircle(radius: 3.0, center: Offset(0.0, 0.0)));

    canvas.drawPath(path1, secondHandPaint);
    canvas.drawPath(path2, secondHandPointsPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SecondHandPainter oldDelegate) {
    return this.seconds != oldDelegate.seconds;
  }
}
