import 'package:meditation/resources/strings.dart';

class UserGoalItem {
  final String name;
  final String title;

  UserGoalItem({this.name, this.title});
}

class UserGoalsProvider {
  static final String fallAsleep = "fallAsleep";
  static final String getRidOfStress = "getRidOfStress";
  static final String beMoreEffective = "beMoreEffective";
  static final String beFullOfEnergy = "beFullOfEnergy";

  List<UserGoalItem> _availableItems = [
    UserGoalItem(
      name: fallAsleep,
      title: Strings.fallAsleep,
    ),
    UserGoalItem(
      name: getRidOfStress,
      title: Strings.getRidOfStress,
    ),
    UserGoalItem(
      name: beMoreEffective,
      title: Strings.beMoreEffective,
    ),
    UserGoalItem(
      name: beFullOfEnergy,
      title: Strings.beFullOfEnergy,
    ),
  ];

  List<UserGoalItem> getAllAvailable() {
    return _availableItems;
  }

  UserGoalItem getItemByName(String name) {
    return _availableItems.firstWhere((e) => e.name == name);
  }
}
