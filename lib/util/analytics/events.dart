abstract class Events {

  void logSubscriptionPackBuyButtonPressed(String name, String price, String currency);

  void logSubscriptionPackCloseButtonPressed(String name, String price, String currency);

  void logSubscriptionPackSuccess(String name, String price, String currency);

  void logSpecialOfferShown(String name, String price, String currency);

  void logSpecialOfferButtonContinue(String name, String price, String currency);

  void logSpecialOfferSuccess(String name, String price, String currency);

}
