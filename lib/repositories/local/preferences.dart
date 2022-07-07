import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Future<bool> setList(String key, List<String> values) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.setStringList(key, values);
  }

  Future<List<String>> getList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getStringList(key) ?? [];
  }

  Future<bool> setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.setString(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return await prefs.setBool(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return await prefs.setDouble(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      return await prefs.setInt(key, value);
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<String> getString(String key, String defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getString(key) ?? defaultValue;
  }

  Future<bool> getBool(String key, bool defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<double> getDouble(String key, double defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getDouble(key) ?? defaultValue;
  }

  Future<int> getInt(String key, int defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt(key) ?? defaultValue;
  }
}
