import 'dart:async';

import 'package:flutter/widgets.dart';

class PlayerCountdownTimer {

  final int startTimeSeconds;
  final int durationsMinutes;

  int _countdown;
  Timer _timer;

  factory PlayerCountdownTimer.def() {
    return PlayerCountdownTimer(startTimeSeconds: 0, durationsMinutes: 0);
  }

  PlayerCountdownTimer({
    @required this.startTimeSeconds,
    @required this.durationsMinutes
  });

  PlayerCountdownTimer copy() {
    return PlayerCountdownTimer(
      startTimeSeconds: startTimeSeconds,
      durationsMinutes: durationsMinutes
    );
  }

  void start({
    @required Function(int) onTick,
    Function onComplete
  }) {
    final now = DateTime.now();
    final nowSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final durationSeconds = durationsMinutes * 60;
    _countdown = durationSeconds - (nowSeconds - startTimeSeconds);
    if (_timer != null) {
      _timer.cancel();
    }
    if (_countdown > 0) {
      onTick(_countdown);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _timerHandler(onTick, onComplete, timer);
      });
    }
  }
  
  void _timerHandler(Function(int) onTick, Function onComplete, Timer timer) {
    --_countdown;
    if (_countdown == 0) {
      timer.cancel();
      if (onComplete != null) onComplete();
    } else {
      onTick(_countdown);
    }
  }

  void cancel() {
    if (_timer != null) {
      _timer.cancel();
    }
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) || other is PlayerCountdownTimer &&
      runtimeType == other.runtimeType &&
      startTimeSeconds == other.startTimeSeconds &&
      durationsMinutes == other.durationsMinutes;

  @override
  int get hashCode => startTimeSeconds.hashCode ^ durationsMinutes.hashCode;

  @override
  String toString() {
    return 'TimerSetup{'
      'startTimeSeconds: $startTimeSeconds, '
      'durationsMinutes: $durationsMinutes}';
  }

}
