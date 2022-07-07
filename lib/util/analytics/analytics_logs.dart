import 'package:meditation/util/analytics/events.dart';
import 'package:meditation/util/analytics/events_facebook.dart';
import 'package:meditation/util/analytics/events_firebase.dart';

class AnalyticsLogs extends Events {

  final List<Events> eventsLoggers = [
    EventsFirebase(),
    EventsFacebook()
  ];

  @override
  void logSubscriptionPackBuyButtonPressed(String name, String price, String currency) {
    eventsLoggers.forEach((element) => element.logSubscriptionPackBuyButtonPressed(name, price, currency));
  }

  @override
  void logSubscriptionPackCloseButtonPressed(String name, String price, String currency) {
    eventsLoggers.forEach((element) => element.logSubscriptionPackCloseButtonPressed(name, price, currency));
  }

  @override
  void logSubscriptionPackSuccess(String name, String price, String currency) {
    eventsLoggers.forEach((element) => element.logSubscriptionPackSuccess(name, price, currency));
  }

  @override
  void logSpecialOfferButtonContinue(String name, String price, String currency) {
    eventsLoggers.forEach((element) => element.logSpecialOfferButtonContinue(name, price, currency));
  }

  @override
  void logSpecialOfferShown(String name, String price, String currency) {
    eventsLoggers.forEach((element) => element.logSpecialOfferShown(name, price, currency));
  }

  @override
  void logSpecialOfferSuccess(String name, String price, String currency) {
    eventsLoggers.forEach((element) => element.logSpecialOfferSuccess(name, price, currency));
  }

}
