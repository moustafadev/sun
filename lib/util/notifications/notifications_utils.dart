import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meditation/util/appsflyer/appsflyer_service.dart';

enum NotificationsFrequency {
  everyDay,
  weekday,
  weekend,
}

class NotificationsUtils {
  final int specialOfferNotification = 12;
  final int reminderNotificationId = 10;
  static const List<Day> weekdays = [
    Day.monday,
    Day.tuesday,
    Day.wednesday,
    Day.thursday,
    Day.friday
  ];
  static const List<Day> weekend = [Day.saturday, Day.sunday];

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> initialize() async {
    if (flutterLocalNotificationsPlugin == null) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var settingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var settingsIOS = IOSInitializationSettings(defaultPresentAlert: false);
      var settings =
          InitializationSettings(android: settingsAndroid, iOS: settingsIOS);
      await flutterLocalNotificationsPlugin.initialize(
        settings,
        onSelectNotification: (payload) async {
          await AppsflyerService().openedFromPushNotification();
        },
      );
    }
  }

  Future<bool> isSpecialOfferNotificationAppLaunch() async {
    await initialize();
    final details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    return details.didNotificationLaunchApp &&
        details.payload == "special_offer_notification";
  }

  Future<void> scheduleSpecialOfferNotification(
      String title, String body) async {
    await initialize();
    var android = AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails(presentAlert: false);
    var platform = NotificationDetails(android: android, iOS: iOS);
    final now = DateTime.now();
    final dateTime = now.add(Duration(days: 1));
    //final dateTime = now.add(Duration(minutes: 1));
    await flutterLocalNotificationsPlugin.schedule(
        specialOfferNotification, title, body, dateTime, platform,
        payload: "special_offer_notification");
  }

  Future<void> cancelSpecialOfferNotification() async {
    await initialize();
    await flutterLocalNotificationsPlugin.cancel(specialOfferNotification);
  }

  Future<void> setReminder(Time time, NotificationsFrequency frequency) async {
    var android = AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails(presentAlert: false);
    var platform = NotificationDetails(android: android, iOS: iOS);
    switch (frequency) {
      case NotificationsFrequency.everyDay:
        for (var i = 0; i < 7; i++) {
          await flutterLocalNotificationsPlugin.cancel(i);
        }
        flutterLocalNotificationsPlugin.showDailyAtTime(
          reminderNotificationId,
          'Meditation',
          'Don`t forget to listen today!',
          time,
          platform,
        );
        break;
      case NotificationsFrequency.weekday:
        for (var i = 0; i < weekend.length; i++) {
          await flutterLocalNotificationsPlugin.cancel(i + 5);
        }
        await flutterLocalNotificationsPlugin.cancel(reminderNotificationId);

        for (var i = 0; i < weekdays.length; i++) {
          flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
            i,
            'Meditation',
            'Don`t forget to listen today!',
            weekdays[i],
            time,
            platform,
          );
        }

        break;
      case NotificationsFrequency.weekend:
        for (var i = 0; i < weekdays.length; i++) {
          await flutterLocalNotificationsPlugin.cancel(i);
        }
        await flutterLocalNotificationsPlugin.cancel(reminderNotificationId);

        for (var i = 0; i < weekend.length; i++) {
          flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
            i + 5,
            'Meditation',
            'Don`t forget to listen today!',
            weekend[i],
            time,
            platform,
          );
        }

        break;
      default:
    }
  }

  Future<void> cancelReminder() async {
    for (var i = 0; i < 7; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }
    await flutterLocalNotificationsPlugin.cancel(reminderNotificationId);
  }
}
