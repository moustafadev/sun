import 'package:meditation/repositories/local/preferences.dart';

extension UserPreferences on Preferences {

  static final String selectedGoals = 'selectedGoals';
  static final String selectedExperience = 'selectedExperience';

  Future<bool> setSelectedGoals(List<String> values) {
    return setList(selectedGoals, values);
  }

  Future<List<String>> getSelectedGoals() {
    return getList(selectedGoals);
  }

  Future<bool> setSelectedExperience(List<String> values) {
    return setList(selectedExperience, values);
  }

  Future<List<String>> getSelectedExperience() {
    return getList(selectedExperience);
  }
}