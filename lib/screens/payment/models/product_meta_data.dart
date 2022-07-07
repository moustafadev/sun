import 'package:flutter/widgets.dart';

class ProductMetaData {

  final String id;
  final bool consumable;

  ProductMetaData({
    @required this.id,
    @required this.consumable
  });

}

class MeditationPackSubscriptionMetaData extends ProductMetaData {

  final int trialDaysCount;
  final bool freeContent;
  final int closeButtonDelay;
  final String priceFormat;
  final double pricePerYearSize;
  final String specialPriceFormat;
  final String specialOfferId;
  final String specialOfferNotificationTitle;
  final String specialOfferNotificationBody;

  MeditationPackSubscriptionMetaData({
    @required this.trialDaysCount,
    @required this.freeContent,
    @required this.closeButtonDelay,
    @required this.priceFormat,
    @required this.pricePerYearSize,
    @required this.specialPriceFormat,
    @required this.specialOfferId,
    @required this.specialOfferNotificationTitle,
    @required this.specialOfferNotificationBody,
    String id
  }) : super(id: id, consumable: false);

  bool hasSpecialNotifications() {
    return (specialOfferNotificationBody?.isNotEmpty ?? false)
      && (specialOfferNotificationTitle?.isNotEmpty ?? false);
  }

}
