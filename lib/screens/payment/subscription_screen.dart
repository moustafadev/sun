// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
// import 'package:flutter_inapp_purchase/modules.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:meditation/resources/images.dart';
// import 'package:meditation/resources/keys.dart';
// import 'package:meditation/resources/strings.dart';
// import 'package:meditation/screens/home/home_screen.dart';
// import 'package:meditation/screens/payment/inapp/in_app_preferences.dart';
// import 'package:meditation/screens/payment/inapp/in_app_purchases_impl_2.dart';
// import 'package:meditation/screens/payment/inapp/in_app_utils.dart';
// import 'package:meditation/screens/payment/models/products_provider.dart';
// import 'package:meditation/screens/payment/models/products_provider_impl.dart';
// import 'package:meditation/screens/payment/subscription_dialogs.dart';
// import 'package:meditation/screens/payment/subscription_special_offer_screen.dart';
// import 'package:meditation/screens/payment/widgets/payment_conditions_widget.dart';
// import 'package:meditation/screens/payment/widgets/subscription_price_widget.dart';
// import 'package:meditation/util/analytics/analytics_logs.dart';
// import 'package:meditation/repositories/local/preferences.dart';
// import 'package:meditation/util/submit_button.dart';
// import 'package:meditation/util/submit_small_button.dart';

// class SubscriptionScreen extends StatefulWidget {

//   SubscriptionScreen();

//   @override
//   _SubscriptionScreenState createState() => _SubscriptionScreenState();

// }

// class _SubscriptionScreenState extends State<SubscriptionScreen> {

//   final ProductsProvider _productsProvider = ProductsProviderImpl();
//   final Preferences _preferences = Preferences();
//   final AnalyticsLogs _analyticsLogs = AnalyticsLogs();

//   InAppPurchasesImpl2 _iap;
//   Timer _closeButtonTimer;
//   Future _progressDialog;

//   List<String> _features = [
//     Strings.subscriptionFeature2,
//     Strings.subscriptionFeature3,
//     Strings.subscriptionFeature4,
//     Strings.subscriptionFeature5
//   ];
//   String _localizedPrice = "";
//   String _price = "";
//   String _currency = "";
//   String _packId = "";
//   String _specialOfferPackId = "";
//   String _trialDays = "";
//   String _conditionsFormat = "";
//   double _pricePerYearSize = 18.0;
//   bool _freeContent = true;
//   bool _showCloseButton = false;
//   bool _showRestoreButton = false;

//   @override
//   void initState() {
//     super.initState();
//     _initInApp();
//     print("[SubscriptionScreen]: initState");
//   }
  
//   void _initInApp() async {
//     final subscriptionPackMetaData = await _productsProvider.getActiveSubscriptionPack();
//     if (subscriptionPackMetaData != null) {
//       setState(() {
//         _packId = subscriptionPackMetaData.id;
//         _specialOfferPackId = subscriptionPackMetaData.specialOfferId;
//         _trialDays = subscriptionPackMetaData.trialDaysCount.toString();
//         _freeContent = subscriptionPackMetaData.freeContent;
//         _conditionsFormat = subscriptionPackMetaData.priceFormat;
//         _pricePerYearSize = subscriptionPackMetaData.pricePerYearSize;
//       });
//       if (subscriptionPackMetaData.closeButtonDelay > 0) {
//         _startCloseButtonTimer(subscriptionPackMetaData.closeButtonDelay);
//       } else {
//         setState(() => _showCloseButton = true);
//       }
//     } else {
//       _showSubscriptionPackLoadingErrorMessage();
//     }
//     _iap = InAppPurchasesImpl2(
//       productsProvider: _productsProvider,
//       onPurchaseUpdate: (purchase) { _onPurchaseUpdate(purchase); },
//       onPurchaseError: (error) {
//         _closeProgressDialog();
//         var message = error.message ?? "Something went wrong";
//         if (!message.startsWith("Cancelled")) {
//           showSubscriptionErrorDialog(context, message: message);
//         } else if (_specialOfferPackId?.isNotEmpty ?? false) {
//           _navigateToSpecialOfferScreen();
//         }
//       },
//       onError: (error) {
//         _closeProgressDialog();
//         showSubscriptionErrorDialog(context,
//           message: error is PlatformException ? error.message : error.toString()
//         );
//       }
//     );
//     await _iap.initialize();
//     List<IAPItem> products = await _iap.loadProducts();
//     final subscriptionPackProduct = products.firstWhere((p) => p.productId == _packId);
//     if (subscriptionPackProduct != null) {
//       setState(() {
//         _localizedPrice = subscriptionPackProduct.localizedPrice;
//         _price = subscriptionPackProduct.price;
//         _currency = subscriptionPackProduct.currency;
//       });
//     } else {
//       _showSubscriptionPackLoadingErrorMessage();
//     }
//     final subscriptionPack = await _iap.isSubscriptionActive(_packId, Keys.subscriptionPackPass);
//     final isFirstSubscriptionCheck = await _preferences.isFirstSubscriptionCheck();
//     if (subscriptionPack && isFirstSubscriptionCheck) {
//       setState(() => _showRestoreButton = true);
//     }
//   }

//   void _navigateToSpecialOfferScreen() async {
//     await _iap?.dispose();
//     _iap = null;
//     Navigator.pushReplacement(
//       context,
//       CupertinoPageRoute(builder: (context) => SubscriptionSpecialOfferScreen())
//     );
//   }

//   void _startCloseButtonTimer(int delay) {
//     _closeButtonTimer = Timer(Duration(seconds: delay), () {
//       setState(() => _showCloseButton = true);
//     });
//   }

//   void _showSubscriptionPackLoadingErrorMessage() {
//     showSubscriptionErrorDialog(
//       context,
//       message: Strings.subscriptionPackLoadingError,
//       onOk: () => _navigateToHomeScreen(),
//       onClose: () => _navigateToHomeScreen()
//     );
//   }

//   void _navigateToHomeScreen() {
//     Navigator.of(context).pushReplacement(CupertinoPageRoute(
//       builder: (context) => HomeScreen(checkSubscription: false)
//     ));
//   }

//   void _onPurchaseUpdate(PurchasedItem purchase) async {
//     _closeProgressDialog();
//     if (purchase?.isSuccessful(_packId) ?? false) {
//       _analyticsLogs.logSubscriptionPackSuccess(_packId, _price, _currency);
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
//     Navigator.pop(context, true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _onCloseClick();
//         return true;
//       },
//       child: Scaffold(
//         body: Container(
//           foregroundDecoration: BoxDecoration(),
//           height: MediaQuery.of(context).size.height,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(Images.mainBackground),
//               fit: BoxFit.cover
//             )
//           ),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   _buildHeaderWidget(),
//                   _buildContentWidget(),
//                   PaymentConditionsWidget(),
//                   SizedBox(height: 40.0),
//                   SubmitSmallButton(
//                     title: Strings.subscriptionRestore,
//                     onTap: _onRestoreClick,
//                     enabled: _showRestoreButton
//                   ),
//                   SizedBox(height: 40.0)
//                 ]
//               )
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
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _showCloseButton ? InkWell(
//               onTap: _onCloseClick,
//               child: SvgPicture.asset(
//                 Images.closeIconSvg,
//                 color: Colors.white60,
//                 width: 18.0,
//                 height: 18.0
//               ),
//             ) : Container(),
//             if (_showCloseButton) SizedBox(width: 20.0),
//             Text(
//               Strings.subscriptionScreenHeader,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.w200,
//                 fontFamily: "roboto"
//               )
//             )
//           ]
//         )
//       )
//     );
//   }

//   Widget _buildContentWidget() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20.0),
//       decoration: BoxDecoration(
//         color: Colors.black38,
//         borderRadius: BorderRadius.all(Radius.circular(20.0))
//       ),
//       child: Column(
//         children: [
//           SizedBox(height: 20.0),
//           _buildFeaturesListWidget(),
//           SizedBox(height: 20.0),
//           SubmitButton(
//             title: Strings.subscriptionContinue,
//             onTap: _onContinueClick,
//             enabled: _localizedPrice?.isNotEmpty == true
//           ),
//           SubscriptionPriceWidget(
//             format: _conditionsFormat,
//             price: _localizedPrice,
//             pricePerYearSize: _pricePerYearSize,
//             days: _trialDays
//           )
//         ]
//       ),
//     );
//   }

//   void _onCloseClick() {
//     _analyticsLogs.logSubscriptionPackCloseButtonPressed(_packId, _price, _currency);
//     if (_freeContent) {
//       Navigator.pop(context);
//     } else {
//       exit(0);
//     }
//   }

//   Widget _buildFeaturesListWidget() {
//     return ListView.separated(
//       separatorBuilder: (context, index) => SizedBox(height: 5.0),
//       itemBuilder: (context, index) => _buildFeatureItemWidget(_features[index]),
//       itemCount: _features.length,
//       shrinkWrap: true,
//       physics: BouncingScrollPhysics()
//     );
//   }

//   Widget _buildFeatureItemWidget(String item) {
//     return Container(
//       alignment: Alignment.topLeft,
//       margin: const EdgeInsets.symmetric(horizontal: 20.0),
//       padding: const EdgeInsets.all(10.0),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           SvgPicture.asset(
//             Images.checkIconSvg,
//             color: Color(0xffFACAD8),
//             height: 24.0,
//             width: 24.0
//           ),
//           SizedBox(width: 20.0),
//           Expanded(
//             child: Text(
//               item,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.w200,
//                 fontFamily: "roboto"
//               )
//             )
//           )
//         ]
//       )
//     );
//   }

//   Future _onContinueClick() async {
//     if (_packId != null && _packId.isNotEmpty) {
//       _analyticsLogs.logSubscriptionPackBuyButtonPressed(_packId, _price, _currency);
//       if (_progressDialog == null) {
//         _progressDialog = showProgressDialog(context);
//       }
//       final purchase = await _iap.makePurchase(_packId);
//       print(purchase);
//     }
//   }

//   Future _onRestoreClick() async {
//     await _onSubscriptionSuccess();
//   }

//   @override
//   void dispose() {
//     _closeButtonTimer?.cancel();
//     _iap?.dispose();
//     super.dispose();
//     print("[SubscriptionScreen]: dispose");
//   }

// }
