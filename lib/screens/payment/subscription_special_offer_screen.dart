// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
// import 'package:meditation/resources/images.dart';
// import 'package:meditation/resources/strings.dart';
// import 'package:meditation/screens/home/home_screen.dart';
// import 'package:meditation/screens/payment/inapp/in_app_preferences.dart';
// import 'package:meditation/screens/payment/inapp/in_app_purchases_impl_2.dart';
// import 'package:meditation/screens/payment/inapp/in_app_utils.dart';
// import 'package:meditation/screens/payment/models/products_provider.dart';
// import 'package:meditation/screens/payment/models/products_provider_impl.dart';
// import 'package:meditation/util/notifications/notifications_utils.dart';
// import 'package:meditation/screens/payment/subscription_dialogs.dart';
// import 'package:meditation/screens/payment/subscription_screen.dart';
// import 'package:meditation/screens/payment/widgets/payment_conditions_widget.dart';
// import 'package:meditation/screens/payment/widgets/subscription_price_widget.dart';
// import 'package:meditation/util/analytics/analytics_logs.dart';
// import 'package:meditation/repositories/local/preferences.dart';
// import 'package:meditation/util/submit_button.dart';

// class SubscriptionSpecialOfferScreen extends StatefulWidget {

//   final bool notificationSelect;

//   SubscriptionSpecialOfferScreen({this.notificationSelect = false});

//   @override
//   _SubscriptionSpecialOfferScreenState createState() => _SubscriptionSpecialOfferScreenState();

// }

// class _SubscriptionSpecialOfferScreenState extends State<SubscriptionSpecialOfferScreen> {

//   final ProductsProvider _productsProvider = ProductsProviderImpl();
//   final Preferences _preferences = Preferences();
//   final AnalyticsLogs _analyticsLogs = AnalyticsLogs();
//   final NotificationsUtils _notifications = NotificationsUtils();

//   InAppPurchasesImpl2 _iap;
//   Future _progressDialog;

//   String _localizedPrice = "";
//   String _price = "";
//   String _currency = "";
//   String _specialPackId = "";
//   String _priceFormat = "";
//   double _pricePerYearSize = 18.0;

//   @override
//   void initState() {
//     super.initState();
//     _initInApp();
//     print("[SubscriptionSpecialOfferScreen]: initState");
//   }

//   void _initInApp() async {
//     await _initMetaData();
//     _iap = InAppPurchasesImpl2(
//       productsProvider: _productsProvider,
//       onPurchaseUpdate: _onPurchaseUpdate,
//       onPurchaseError: _onPurchaseError,
//       onError: _onError
//     );
//     await _iap.initialize();
//     await _initProductData();
//   }

//   Future<void> _initMetaData() async {
//     final metaData = await _productsProvider.getActiveSubscriptionPack();
//     if (metaData != null) {
//       final isSpecialOfferShown = await _preferences.isSpecialOfferShown();
//       if (metaData.hasSpecialNotifications() && !isSpecialOfferShown) {
//         _notifications.scheduleSpecialOfferNotification(
//           metaData.specialOfferNotificationTitle,
//           metaData.specialOfferNotificationBody
//         );
//         _preferences.setSpecialOfferShown(true);
//       }
//       setState(() {
//         _specialPackId = metaData.specialOfferId;
//         _priceFormat = metaData.specialPriceFormat;
//         _pricePerYearSize = metaData.pricePerYearSize;
//       });
//     } else {
//       _showLoadingErrorMessage();
//     }
//   }

//   Future<void> _initProductData() async {
//     List<IAPItem> products = await _iap.loadProducts();
//     final product = products.firstWhere((p) => p.productId == _specialPackId, orElse: () => null);
//     if (product != null) {
//       _analyticsLogs.logSpecialOfferShown(
//         _specialPackId,
//         product.price,
//         product.currency
//       );
//       setState(() {
//         _localizedPrice = product.localizedPrice;
//         _price = product.price;
//         _currency = product.currency;
//       });
//     } else {
//       _showLoadingErrorMessage();
//     }
//   }

//   void _onPurchaseError(PurchaseResult error) {
//     _closeProgressDialog();
//     var message = error.message ?? "Something went wrong";
//     if (!message.startsWith("Cancelled")) {
//       showSubscriptionErrorDialog(context, message: message);
//     }
//   }

//   void _onError(dynamic error) {
//     _closeProgressDialog();
//     showSubscriptionErrorDialog(context,
//       message: error is PlatformException ? error.message : error.toString()
//     );
//   }

//   void _showLoadingErrorMessage() {
//     showSubscriptionErrorDialog(
//       context,
//       message: Strings.subscriptionPackLoadingError,
//       onOk: () => _navigateToSubscriptionScreen(),
//       onClose: () => _navigateToSubscriptionScreen()
//     );
//   }

//   void _onPurchaseUpdate(PurchasedItem purchase) async {
//     _closeProgressDialog();
//     if (purchase?.isSuccessful(_specialPackId) ?? false) {
//       _analyticsLogs.logSpecialOfferSuccess(_specialPackId, _price, _currency);
//       await _onSubscriptionSuccess();
//     }
//   }

//   void _closeProgressDialog() {
//     if (_progressDialog != null) {
//       _progressDialog = null;
//       Navigator.of(context).pop();
//     }
//   }

//   Future<void> _onSubscriptionSuccess() async {
//     await _preferences.setHasSubscription(true);
//     await _preferences.setFirstSubscriptionCheck(false);
//     await _notifications.cancelSpecialOfferNotification();
//     _navigateToHomeScreen();
//   }

//   void _navigateToHomeScreen() {
//     Navigator.of(context).pushReplacement(CupertinoPageRoute(
//       builder: (context) => HomeScreen(checkSubscription: false)
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         foregroundDecoration: BoxDecoration(),
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(Images.mainBackground),
//             fit: BoxFit.cover
//           )
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 _buildHeaderWidget(),
//                 _buildFeaturesWidget(),
//                 _buildGiftWidget(),
//                 SizedBox(height: 20.0),
//                 SubmitButton(
//                   title: Strings.subscriptionContinue,
//                   onTap: _onContinueClick,
//                   enabled: _localizedPrice?.isNotEmpty == true
//                 ),
//                 SubscriptionPriceWidget(
//                   format: _priceFormat,
//                   price: _localizedPrice,
//                   pricePerYearSize: _pricePerYearSize
//                 ),
//                 _buildSecuredWithITunes(),
//                 PaymentConditionsWidget(),
//                 SizedBox(height: 40.0)
//               ]
//             )
//           )
//         )
//       )
//     );
//   }

//   Widget _buildHeaderWidget() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20.0),
//       child: SizedBox(
//         height: 60.0,
//         child: TextButton(
//           onPressed: () => widget.notificationSelect
//             ? _navigateToHomeScreen()
//             : _navigateToSubscriptionScreen(),
//           child: Row(
//             children: <Widget>[
//               Icon(
//                 Icons.arrow_back_ios,
//                 size: 30.0,
//                 color: Colors.white
//               ),
//               Text(
//                 Strings.back,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.w400,
//                   fontFamily: "roboto"
//                 )
//               )
//             ]
//           )
//         )
//       )
//     );
//   }

//   void _navigateToSubscriptionScreen() async {
//     await _iap?.dispose();
//     _iap = null;
//     Navigator.pushReplacement(
//       context,
//       CupertinoPageRoute(builder: (context) => SubscriptionScreen())
//     );
//   }

//   Widget _buildFeaturesWidget() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//       child: RichText(
//         textAlign: TextAlign.center,
//         text: TextSpan(
//           children: [
//             TextSpan(
//               text: Strings.subscriptionSpecialOfferDescription1,
//               style: TextStyle(
//                 fontSize: 26.0,
//                 fontWeight: FontWeight.w600
//               )
//             ),
//             TextSpan(
//               text: "\n\n",
//             ),
//             TextSpan(
//               text: Strings.subscriptionSpecialOfferDescription2
//             )
//           ],
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16.0,
//             fontWeight: FontWeight.w200,
//             fontFamily: "roboto"
//           )
//         )
//       )
//     );
//   }

//   Widget _buildGiftWidget() {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Image.asset(
//         Images.giftIcon,
//         height: 150.0,
//         fit: BoxFit.fill
//       )
//     );
//   }
  
//   Widget _buildSecuredWithITunes() {
//     return Platform.isIOS ? Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.verified_user,
//             color: Colors.white
//           ),
//           SizedBox(width: 10.0),
//           Text(
//             Strings.subscriptionSecuredWithITunes,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16.0,
//               fontWeight: FontWeight.w200,
//               fontFamily: "roboto"
//             )
//           )
//         ]
//       ),
//     ) : Container();
//   }

//   Future _onContinueClick() async {
//     if (_specialPackId?.isNotEmpty ?? false) {
//       _analyticsLogs.logSpecialOfferButtonContinue(_specialPackId, _price, _currency);
//       if (_progressDialog == null) {
//         _progressDialog = showProgressDialog(context);
//       }
//       final purchase = await _iap.makePurchase(_specialPackId);
//       print(purchase);
//     }
//   }

//   @override
//   void dispose() {
//     _iap?.dispose();
//     super.dispose();
//     print("[SubscriptionSpecialOfferScreen]: dispose");
//   }

// }
