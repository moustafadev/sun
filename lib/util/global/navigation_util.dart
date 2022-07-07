import 'package:flutter/material.dart';
import 'package:meditation/util/amplitude/amplitude_service.dart';

class NavigationUtil {
  static final NavigationUtil _singleton = NavigationUtil._internal();

  factory NavigationUtil() {
    return _singleton;
  }

  NavigationUtil._internal();

  Future<T> push<T>(BuildContext context, Route<dynamic> route) async {
    await AmplitudeService().logPushScreen(route.settings.name);
    return Navigator.maybeOf(context).push(route);
  }

  Future<T> pushReplacement<T>(
      BuildContext context, Route<dynamic> route) async {
    await AmplitudeService().logPushScreen(route.settings.name);
    return Navigator.maybeOf(context).pushReplacement(route);
  }

  void pop(BuildContext context) async {
    return Navigator.maybeOf(context).pop();
  }
}
