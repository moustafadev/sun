import 'package:amplitude_flutter/amplitude.dart';

class AmplitudeService {
  static final AmplitudeService _singleton = AmplitudeService._internal();
  factory AmplitudeService() {
    return _singleton;
  }
  AmplitudeService._internal();
  static const String _apiKey = 'b3a6efe8a993db27aaa1d9e88f4381c2';

  final Amplitude _analytics = Amplitude.getInstance();

  Future<void> init() async {
    await _analytics.init(_apiKey);
    await _analytics.trackingSessionEvents(true);
  }

  Future<void> logPushScreen(String name) async {
    await _analytics.logEvent(name);
    return pushEvents();
  }

  Future<void> pushEvents() {
    return _analytics.uploadEvents();
  }
}
