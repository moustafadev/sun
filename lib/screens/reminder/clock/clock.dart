import 'dart:async';
import 'clock_dial_painter.dart';
import 'clock_hands.dart';
import 'clock_text.dart';
import 'package:flutter/material.dart';

typedef TimeProducer = DateTime Function();

class Clock extends StatefulWidget {

  final Color circleColor;
  final Color shadowColor;

  final ClockText clockText;

  final TimeProducer getCurrentTime;
  final Duration updateDuration;

  Clock({
    this.circleColor = const Color(0xfffe1ecf7),
    this.shadowColor = const Color(0xffd9e2ed),
    this.clockText = ClockText.arabic,
    this.getCurrentTime = getSystemTime,
    this.updateDuration = const Duration(seconds: 1)
  });

  static DateTime getSystemTime() {
    return new DateTime.now();
  }

  @override
  State<StatefulWidget> createState() {
    return _Clock();
  }
}

class _Clock extends State<Clock> {

  Timer _timer;
  DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    this._timer = Timer.periodic(widget.updateDuration, setTime);
  }

  void setTime(Timer timer) {
    setState(() {
      dateTime = new DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: buildClockCircle(context),
    );
  }

  Widget buildClockCircle(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(25),
          width: double.infinity,
          child: CustomPaint(
            painter: ClockDialPainter(clockText: widget.clockText)
          )
        ),
        ClockHands(dateTime: dateTime)
      ]
    );
  }
}
