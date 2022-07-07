import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart' as apps;

class AppsflyerService {
  static final AppsflyerService _singleton = AppsflyerService._internal();
  factory AppsflyerService() {
    return _singleton;
  }
  AppsflyerService._internal();

  static final Map _appsFlyerOptions = {
    "afDevKey": 'TC6qBpZjR4JGCJJwLRDZv',
    "afAppId": Platform.isAndroid ? 'sun.live' : '1561970579',
    "isDebug": false,
    "disableAdvertisingIdentifier": true,
  };
  apps.AppsflyerSdk sdk = apps.AppsflyerSdk(_appsFlyerOptions);

  Future<void> initSdk() async {
    await sdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    sdk.onDeepLinking((p0) async {
      await reEngage();
    });
  }

  Future<void> achievementUnlocked(String name) async {
    await sdk.logEvent('af_achievement_unlocked', {
      'af_level': name,
    });
  }

  Future<void> initiatedCheckout() async {
    await sdk.logEvent('af_initiated_checkout', {});
  }

  Future<void> purchase(double revenue, String currency, String city) async {
    await sdk.logEvent('af_purchase', {
      'af_revenue': revenue,
      'af_currency': currency,
      'af_city': city,
    });
  }

  Future<void> openedFromPushNotification() async {
    await sdk.logEvent('af_opened_from_push_notification', {});
  }

  Future<void> reEngage() async {
    await sdk.logEvent('af_re_engage', {});
  }

  Future<void> preonboardingComplete(int index) async {
    await sdk.logEvent('preonboarding${index}_complete', {});
  }
}
