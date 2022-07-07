import 'package:meditation/resources/strings.dart';

class UserExperienceItem {
  final String name;
  final String title;

  UserExperienceItem({this.name, this.title});
}

class UserExperienceProvider {

  static final String noExperience = "No experience";
  static final String meditatedACoupleOfTimes = "Meditated a couple of times";
  static final String sometimesMediate = "Sometimes I meditate";
  static final String meditateConstantly = "I meditate constantly";

  List<UserExperienceItem> _availableItems = [
    UserExperienceItem(
      name: noExperience,
      title: Strings.noExperience,
    ),
    UserExperienceItem(
      name: meditatedACoupleOfTimes,
      title: Strings.meditatedACoupleOfTimes,
    ),
    UserExperienceItem(
      name: sometimesMediate,
      title: Strings.sometimesMediate,
    ),
    UserExperienceItem(
      name: meditateConstantly,
      title: Strings.meditateConstantly,
    ),
  ];

  List<UserExperienceItem> getAllAvailable() {
    return _availableItems;
  }

  UserExperienceItem getItemByName(String name) {
    return _availableItems.firstWhere((e) => e.name == name);
  }
}