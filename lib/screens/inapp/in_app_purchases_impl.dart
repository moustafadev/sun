import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditation/screens/payment/inapp/in_app_purchases.dart';
import 'package:meditation/screens/payment/models/products_provider.dart';

class InAppPurchasesImpl extends InAppPurchases {
  final InAppPurchase iap = InAppPurchase.instance;

  final ProductsProvider productsProvider;

  final Function(PurchaseDetails) onPurchaseUpdate;
  final Function(IAPError) onIapError;
  final Function(String) onError;

  Map<String, ProductDetails> _products = {};
  Map<String, PurchaseDetails> _purchases = {};

  StreamSubscription<List<PurchaseDetails>> _subscription;

  InAppPurchasesImpl(
      {@required this.productsProvider,
      @required this.onPurchaseUpdate,
      @required this.onIapError,
      @required this.onError});

  @override
  void initialize() {
    final Stream<List<PurchaseDetails>> purchaseUpdates = iap.purchaseStream;
    _subscription = purchaseUpdates.listen((List<PurchaseDetails> purchases) {
      purchases.forEach((element) => onPurchaseUpdate(element));
    }, onError: (e) => onError != null ? onError(e.toString()) : {});
  }

  @override
  Future<List<ProductDetails>> loadProducts() async {
    final ids = await productsProvider.getIds();
    final ProductDetailsResponse response =
        await iap.queryProductDetails(ids.toSet());
    if (response.error != null) {
      onIapError(response.error);
    } else {
      _products.clear();
      response.productDetails
          .forEach((element) => _products[element.id] = element);
    }
    return _products.values.toList();
  }

  @override
  Future<List<PurchaseDetails>> loadPurchases() async {
    // final ProductDetailsResponse response = await iap.queryProductDetails(Set<String>());
    // if (response.error != null) {
    //   onIapError(response.error);
    // } else {
    //   _purchases.clear();
    //   for (ProductDetails purchase in response.productDetails) {
    //     _purchases[purchase.id] = purchase;
    //     onPurchaseUpdate(purchase);
    //     if (Platform.isIOS) {
    //       iap.completePurchase(purchase);
    //     }
    //   }
    // }
    return _purchases.values.toList();
  }

  @override
  Future<bool> makePurchase(String id) async {
    final ProductDetails productDetails = _products[id];
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    final metaData = await productsProvider.get(id);
    if (metaData.consumable) {
      return iap.buyConsumable(purchaseParam: purchaseParam);
    } else {
      return iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}
