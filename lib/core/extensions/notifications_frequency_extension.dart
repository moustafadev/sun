import 'package:meditation/util/notifications/notifications_utils.dart';
import 'package:meditation/resources/strings.dart';

extension NotificationFrequencyExtension on NotificationsFrequency {
  String asString() {
    return this.toString().replaceAll('NotificationsFrequency.', '');
  }

  String notificationView() {
    switch (this) {
      case NotificationsFrequency.everyDay:
        return Strings.everyDay;
      case NotificationsFrequency.weekday:
        return Strings.onWeekdays;
      case NotificationsFrequency.weekend:
        return Strings.onWeekend;
      default:
        return Strings.everyDay;
    }
  }
}
