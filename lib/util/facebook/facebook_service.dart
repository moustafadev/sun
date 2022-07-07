// import 'package:flutter_facebook_sdk/flutter_facebook_sdk.dart';

import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookService {
  static final FacebookService _singleton = FacebookService._internal();
  factory FacebookService() {
    return _singleton;
  }
  FacebookService._internal();

  Future<void> setAdvertiserTracking() async {
    await FacebookAppEvents().setAdvertiserTracking(enabled: true);
  }

  Future<void> logInitiateCheckout() async {
    await FacebookAppEvents().logEvent(name: 'purchase_attempt');
  }

  Future<void> logAchievementUnlocked(String name) async {
    await FacebookAppEvents().logEvent(name: 'achievement_unlocked', parameters: {'name': name});
  }
}
