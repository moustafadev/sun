import 'package:meditation/main.dart';
import 'package:meditation/resources/keys.dart';
import 'package:meditation/util/analytics/events.dart';

class EventsFirebase extends Events {

  @override
  void logSubscriptionPackBuyButtonPressed(String name, String price, String currency) {
    try {
      MyApp.analytics.logEvent(
        name: Keys.inAppBuyButtonPressedEventName,
        parameters: {
          Keys.inAppNameParam: name,
          Keys.inAppPriceParam: price,
          Keys.inAppCurrencyParam: currency
        }
      );
    } catch (error) {
      print("[AnalyticsLogs]: ${error.toString()}");
    }
  }

  @override
  void logSubscriptionPackCloseButtonPressed(String name, String price, String currency) {
    try {
      MyApp.analytics.logEvent(
        name: Keys.inAppCloseButtonPressedEventName,
        parameters: {
          Keys.inAppNameParam: name,
          Keys.inAppPriceParam: price,
          Keys.inAppCurrencyParam: currency
        }
      );
    } catch (error) {
      print("[AnalyticsLogs]: ${error.toString()}");
    }
  }

  @override
  void logSubscriptionPackSuccess(String name, String price, String currency) {
    try {
      MyApp.analytics.logEvent(
        name: Keys.inAppSuccessEventName,
        parameters: {
          Keys.inAppNameParam: name,
          Keys.inAppPriceParam: price,
          Keys.inAppCurrencyParam: currency
        }
      );
    } catch (error) {
      print("[AnalyticsLogs]: ${error.toString()}");
    }
  }

  @override
  void logSpecialOfferButtonContinue(String name, String price, String currency) {
    try {
      MyApp.analytics.logEvent(
        name: Keys.inAppSpecialOfferButtonContinueEventName,
        parameters: {
          Keys.inAppNameParam: name,
          Keys.inAppPriceParam: price,
          Keys.inAppCurrencyParam: currency
        }
      );
    } catch (error) {
      print("[AnalyticsLogs]: ${error.toString()}");
    }
  }

  @override
  void logSpecialOfferShown(String name, String price, String currency) {
    try {
      MyApp.analytics.logEvent(
        name: Keys.inAppSpecialOfferShownEventName,
        parameters: {
          Keys.inAppNameParam: name,
          Keys.inAppPriceParam: price,
          Keys.inAppCurrencyParam: currency
        }
      );
    } catch (error) {
      print("[AnalyticsLogs]: ${error.toString()}");
    }
  }

  @override
  void logSpecialOfferSuccess(String name, String price, String currency) {
    try {
      MyApp.analytics.logEvent(
        name: Keys.inAppSpecialOfferSuccessEventName,
        parameters: {
          Keys.inAppNameParam: name,
          Keys.inAppPriceParam: price,
          Keys.inAppCurrencyParam: currency
        }
      );
    } catch (error) {
      print("[AnalyticsLogs]: ${error.toString()}");
    }
  }

}