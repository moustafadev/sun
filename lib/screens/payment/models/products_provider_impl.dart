import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:meditation/screens/payment/models/product_meta_data.dart';
import 'package:meditation/screens/payment/models/products_provider.dart';

class ProductsProviderImpl extends ProductsProvider {
  static final String defaultSubsPriceFormat =
      "Try \$days days free, then \$pricePerYear.\nCancel anytime.";
  static final String defaultSubsSpecialPriceFormat =
      "\$pricePerYear.\nCancel anytime.";
  static final String defaultSubsPack = "meditation_pack";
  static final String defaultSubsSpecialPack = "meditation_special_pack";

  static final String subsCloseButtonDelay = "subscription_close_button_delay";

  static final String subsPriceFormat = "subscription_price_format";
  static final String subsPricePerYearSize = "subscription_price_per_year_size";

  static final String subsPackName = "subscription_pack_name";
  static final String subsPackTrialDays = "subscription_pack_trial_days";
  static final String subsPackFreeContent = "subscription_pack_free_content";

  static final String subsSpecialPriceFormat =
      "subscription_special_price_format";
  static final String subsSpecialOfferPackName =
      "subscription_special_offer_pack_name";

  static final String subsSpecialOfferNotificationTitle =
      "subscription_special_offer_notification_title";
  static final String subsSpecialOfferNotificationBody =
      "subscription_special_offer_notification_body";

  static List<ProductMetaData> _products;

  @override
  Future<List<ProductMetaData>> initialize() async {
    final RemoteConfig remoteConfig = await _initRemoteConfig();
    final subscription = await _fetchActiveSubscription(remoteConfig);
    return [subscription];
  }

  Future<RemoteConfig> _initRemoteConfig() async {
    final RemoteConfig remoteConfig = RemoteConfig.instance;
    await remoteConfig.setDefaults({
      subsPackName: defaultSubsPack,
      subsPackTrialDays: "3",
      subsPackFreeContent: "true",
      subsCloseButtonDelay: 0,
      subsPriceFormat: defaultSubsPriceFormat,
      subsSpecialPriceFormat: defaultSubsSpecialPriceFormat,
      subsPricePerYearSize: 18.0,
      subsSpecialOfferPackName: defaultSubsSpecialPack,
      subsSpecialOfferNotificationTitle: "",
      subsSpecialOfferNotificationBody: ""
    });
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(minutes: 1),
        minimumFetchInterval: Duration(minutes: 1),
      ),
    );
    return remoteConfig;
  }

  Future<ProductMetaData> _fetchActiveSubscription(
      RemoteConfig remoteConfig) async {
    final packId = remoteConfig.getString(subsPackName);
    final packTrialDays = remoteConfig.getString(subsPackTrialDays);
    final packFreeContent = remoteConfig.getString(subsPackFreeContent);
    final closeButtonDelay = remoteConfig.getString(subsCloseButtonDelay);
    final priceFormat = remoteConfig.getString(subsPriceFormat);
    final specialPriceFormat = remoteConfig.getString(subsSpecialPriceFormat);
    final pricePerYearSize = remoteConfig.getString(subsPricePerYearSize);
    final specialOfferPackId = remoteConfig.getString(subsSpecialOfferPackName);
    final specialOfferNotificationTitle =
        remoteConfig.getString(subsSpecialOfferNotificationTitle);
    final specialOfferNotificationBody =
        remoteConfig.getString(subsSpecialOfferNotificationBody);
    return MeditationPackSubscriptionMetaData(
        id: packId,
        trialDaysCount: int.tryParse(packTrialDays) ?? 3,
        freeContent: packFreeContent == "true",
        closeButtonDelay: int.tryParse(closeButtonDelay) ?? 0,
        priceFormat: priceFormat?.replaceAll('\\n', '\n'),
        pricePerYearSize: double.tryParse(pricePerYearSize) ?? 18.0,
        specialPriceFormat: specialPriceFormat?.replaceAll('\\n', '\n'),
        specialOfferId: specialOfferPackId,
        specialOfferNotificationTitle: specialOfferNotificationTitle,
        specialOfferNotificationBody: specialOfferNotificationBody);
  }

  @override
  Future<List<String>> getIds() async {
    if (_products == null || _products.isEmpty) {
      _products = await initialize();
    }
    return _products.expand<String>((e) {
      if (e is MeditationPackSubscriptionMetaData &&
          (e.specialOfferId?.isNotEmpty ?? false)) {
        return [e.id, e.specialOfferId];
      } else {
        return [e.id];
      }
    }).toList();
  }

  @override
  Future<ProductMetaData> get(String id) async {
    if (_products == null || _products.isEmpty) {
      _products = await initialize();
    }
    return _products.firstWhere((element) {
      if (element is MeditationPackSubscriptionMetaData) {
        return element.id == id || element.specialOfferId == id;
      } else {
        return element.id == id;
      }
    });
  }

  @override
  Future<MeditationPackSubscriptionMetaData> getActiveSubscriptionPack() async {
    if (_products == null || _products.isEmpty) {
      _products = await initialize();
    }
    return _products.firstWhere(
        (element) => element is MeditationPackSubscriptionMetaData,
        orElse: () => _getDefaultSubscriptionPack());
  }

  MeditationPackSubscriptionMetaData _getDefaultSubscriptionPack() {
    return MeditationPackSubscriptionMetaData(
        id: defaultSubsPack,
        trialDaysCount: 3,
        freeContent: true,
        closeButtonDelay: 0,
        priceFormat: defaultSubsPriceFormat,
        specialPriceFormat: defaultSubsSpecialPriceFormat,
        pricePerYearSize: 18.0,
        specialOfferId: defaultSubsSpecialPack,
        specialOfferNotificationBody: "",
        specialOfferNotificationTitle: "");
  }

  @override
  Future<List<String>> getAvailableSubscriptionIds() {
    return Future.value([
      "meditation_pack_25",
      "meditation_pack_49_7_",
      "meditation_pack_50",
      "meditation_pack_99_3_",
      "meditation_pack_99_7",
      "meditation_pack_1"
    ]);
  }
}
