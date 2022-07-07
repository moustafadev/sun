import 'dart:async';

import 'package:meditation/repositories/home_screen/home_screen_repository.dart';
import 'package:meditation/util/amplitude/amplitude_service.dart';

class HomeScreenNavigation extends HomeScreenRepository {
  // singleton
  static final HomeScreenNavigation _singleton =
      HomeScreenNavigation._internal();
  factory HomeScreenNavigation() {
    return _singleton;
  }
  HomeScreenNavigation._internal();
  // end singleton

  StreamController<int> _pageIndexController =
      StreamController<int>.broadcast();
  int homeScreenPageIndex = 0;

  @override
  Stream<int> getPageIndex() {
    return _pageIndexController.stream;
  }

  @override
  void changePageIndex(int index) {
    homeScreenPageIndex = index;
    _pageIndexController.add(index);
    AmplitudeService().logPushScreen(getHomeScreenName(index));
  }

  String getHomeScreenName(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'meditation';
      case 2:
        return 'sleep';
      case 3:
        return 'music';
      case 4:
        return 'profile';
      case 5:
        return 'background_sound';
      case 6:
        return 'favourites';
      default:
        return 'home';
    }
  }
}
