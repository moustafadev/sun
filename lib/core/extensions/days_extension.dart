import 'package:flutter_local_notifications/flutter_local_notifications.dart';

extension DaysExtension on Day {
  String asString() {
    switch (this.value) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  String short() {
    return this.asString().substring(0, 3);
  }
}
