import 'package:meditation/resources/strings.dart';

class UserPayPlanItem {
  final String name;
  final String title;

  UserPayPlanItem({this.name, this.title});
}

class UserPayPlanProvider {
  static final String oneMonth = "oneMonth";
  static final String threeDays = "threeDays";
  static final String forever = "forever";

  List<UserPayPlanItem> _availableItems = [
    UserPayPlanItem(
      name: oneMonth,
      title: Strings.oneMonth,
    ),
    UserPayPlanItem(
      name: threeDays,
      title: Strings.threeDays,
    ),
    UserPayPlanItem(
      name: forever,
      title: Strings.forever,
    ),
  ];

  List<UserPayPlanItem> getAllAvailable() {
    return _availableItems;
  }

  UserPayPlanItem getItemByName(String name) {
    return _availableItems.firstWhere((e) => e.name == name);
  }
}
