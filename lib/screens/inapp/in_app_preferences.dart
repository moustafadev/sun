import 'package:meditation/repositories/local/preferences.dart';

extension InAppPreferences on Preferences {

  static final String _firstSubscriptionCheck = 'firstSubscriptionCheck';
  static final String _specialOfferShown = 'specialOfferShown';
  static final String _hasSubscription = 'hasSubscription';

  Future<bool> isFirstSubscriptionCheck() => getBool(_firstSubscriptionCheck, true);

  Future<bool> setFirstSubscriptionCheck(bool set) => setBool(_firstSubscriptionCheck, set);

  Future<bool> isSpecialOfferShown() => getBool(_specialOfferShown, false);

  Future<bool> setSpecialOfferShown(bool shown) => setBool(_specialOfferShown, shown);

  Future<bool> hasSubscription() => getBool(_hasSubscription, false);

  Future<bool> setHasSubscription(bool has) => setBool(_hasSubscription, has);

}