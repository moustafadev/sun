import 'dart:math';
import 'dart:ui' as ui;

import 'clock_text.dart';
import 'package:flutter/material.dart';

class ClockDialPainter extends CustomPainter {
  final clockText;

  final hourTickMarkLength = 10.0;
  final minuteTickMarkLength = 5.0;

  final hourTickMarkWidth = 3.0;
  final minuteTickMarkWidth = 1.5;

  final Paint tickPaint;
  final ui.TextStyle textStyle;

  final double tickLength = 6.0;
  final double tickLongLength = 12.0;
  final double tickWidth = 2.0;
  final double tickLongWidth = 3.0;

  final arabicNumeralList = [
    '12',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11'
  ];

  ClockDialPainter({
    this.clockText = ClockText.roman
  }) :
      tickPaint = Paint(),
      textStyle = ui.TextStyle(
        color: Colors.white,
        fontSize: 20.0
      ) {
    tickPaint.color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final numberRadius = radius - 30.0;

    for (var i = 0; i < 12; i++) {
      double numberAngle = i * 30.0;
      canvas.save();
      canvas.translate(radius, radius);
      double numberX = sin(getRadians(numberAngle)) * numberRadius;
      double numberY = cos(getRadians(numberAngle)) * numberRadius;
      canvas.translate(numberX, -numberY);

      //String hourText = arabicNumeralList[i];
      //final paragraphStyle = ui.ParagraphStyle(
      //  textAlign: TextAlign.center
      //);
      //final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      //  ..pushStyle(textStyle)
      //  ..addText(hourText);
      //final constraints = ui.ParagraphConstraints(width: 50);
      //final paragraph = paragraphBuilder.build();
      //paragraph.layout(constraints);
      //final offset = Offset(-paragraph.width / 2, -paragraph.height / 2);
      //canvas.drawParagraph(paragraph, offset);

      canvas.restore();
    }

    var tickMarkLength;
    final tickAngle = 2 * pi / 60;
    canvas.save();

    // drawing
    canvas.translate(radius, radius);

    for (var i = 0; i < 60; i++) {
      //make the length and stroke of the tick marker longer and thicker depending
      if (i % 5 == 0) {
        tickMarkLength = tickLongLength;
        tickPaint.strokeWidth = tickLongWidth;
      } else {
        tickMarkLength = tickLength;
        tickPaint.strokeWidth = tickWidth;
      }
      canvas.drawLine(
        Offset(0.0, -radius),
        Offset(0.0, -radius + tickMarkLength),
        tickPaint
      );

      canvas.rotate(tickAngle);
    }

    for (var i = 0; i < 12; ++i) {

    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  static double getRadians(double angle) {
    return angle * pi / 180;
  }

}
