import 'package:flutter/foundation.dart';

class Config {
  final bool showSubscribeScreen;
  final int delay;

  Config({
    @required this.showSubscribeScreen,
    @required this.delay,
  });

  factory Config.fromJson(Map<String, dynamic> data) {
    return Config(
      delay: data['delaySeconds'],
      showSubscribeScreen: data['showSubscribeScreen'],
    );
  }
}
