import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart';
import 'package:meditation/screens/inapp/in_app_utils.dart';
import 'package:meditation/screens/payment/models/product_meta_data.dart';
import 'package:meditation/screens/payment/models/products_provider.dart';

class InAppPurchasesImpl2 {
  final FlutterInappPurchase iap = FlutterInappPurchase.instance;

  final ProductsProvider productsProvider;

  final Function(PurchasedItem) onPurchaseUpdate;
  final Function(PurchaseResult) onPurchaseError;
  final Function(dynamic) onError;

  StreamSubscription<ConnectionResult> _connectionUpdatedSubscription;
  StreamSubscription<PurchasedItem> _purchaseUpdatedSubscription;
  StreamSubscription<PurchaseResult> _purchaseErrorSubscription;

  List<IAPItem> _products = [];
  List<PurchasedItem> _purchases = [];

  InAppPurchasesImpl2(
      {@required this.productsProvider,
      @required this.onPurchaseUpdate,
      @required this.onPurchaseError,
      @required this.onError});

  Future initialize() async {
    try {
      final connectionResult = await iap.initialize();
      print("[InAppPurchases]: connectionResult = $connectionResult");
      _connectionUpdatedSubscription = FlutterInappPurchase.connectionUpdated
          .listen((ConnectionResult result) {
        print('[InAppPurchases]: connected = $result');
      });
      _purchaseUpdatedSubscription =
          FlutterInappPurchase.purchaseUpdated.listen((PurchasedItem purchase) {
        print('[InAppPurchases]: purchaseUpdated - $purchase');
        if (onPurchaseUpdate != null) onPurchaseUpdate(purchase);
        if (purchase.isSuccessfulState()) iap.finishTransaction(purchase);
      });
      _purchaseErrorSubscription =
          FlutterInappPurchase.purchaseError.listen((PurchaseResult error) {
        print('[InAppPurchases]: purchaseError - $error');
        if (onPurchaseError != null) onPurchaseError(error);
      });
    } catch (error) {
      print("[InAppPurchases]: error - ${error.toString()}");
      if (onError != null) onError(error);
    }
  }

  Future<List<IAPItem>> loadProducts() async {
    try {
      final ids = await productsProvider.getIds();
      List<IAPItem> items = await iap.getProducts(ids);
      _products.clear();
      _products.addAll(items);
    } catch (error) {
      print("[InAppPurchases]: ${error.toString()}");
      if (onError != null) onError(error);
    }
    return _products;
  }

  Future<List<PurchasedItem>> loadPurchases() async {
    try {
      List<PurchasedItem> items = await iap.getAvailablePurchases();
      _purchases.clear();
      _purchases.addAll(items);
    } catch (error) {
      print("[InAppPurchases]: ${error.toString()}");
      if (onError != null) onError(error);
    }
    return _purchases;
  }

  Future<bool> isAnySubscriptionActive(
      List<String> productIds, String pass) async {
    try {
      final available = await iap.getAvailablePurchases();
      if (available.isNotEmpty && productIds.isNotEmpty) {
        available.sort((p1, p2) {
          return p1.transactionDate.millisecondsSinceEpoch -
              p2.transactionDate.millisecondsSinceEpoch;
        });
        Response response = await iap.validateReceiptIos(receiptBody: {
          'receipt-data': available.last.transactionReceipt,
          'password': pass
        });
        Map<String, dynamic> body = jsonDecode(response.body);
        List<dynamic> latestReceiptInfo = body["latest_receipt_info"];
        final now = DateTime.now();
        return latestReceiptInfo.any((element) {
          if (element is Map) {
            final subscription = productIds.contains(element["product_id"]);
            if (subscription) {
              final expiresMillis = int.parse(element["expires_date_ms"]);
              final expiresDate =
                  DateTime.fromMillisecondsSinceEpoch(expiresMillis).toLocal();
              return expiresDate.isAfter(now);
            }
          }
          return false;
        });
      }
    } catch (error) {
      print("[InAppPurchases]: ${error.toString()}");
      if (onError != null) onError(error);
    }
    return false;
  }

  Future<bool> isSubscriptionActive(String productId, String pass) async {
    if (productId?.isNotEmpty ?? false) {
      return isAnySubscriptionActive([productId], pass);
    }
    return false;
  }

  Future<dynamic> makePurchase(String id) async {
    try {
      if (Platform.isIOS) {
        await iap.clearTransactionIOS();
      }
      final metaData = await productsProvider.get(id);
      if (metaData is MeditationPackSubscriptionMetaData) {
        return iap.requestSubscription(id);
      } else {
        return iap.requestPurchase(id);
      }
    } catch (error) {
      print("[InAppPurchases]: ${error.toString()}");
      if (onError != null) onError(error);
    }
  }

  Future<dynamic> dispose() async {
    if (_connectionUpdatedSubscription != null) {
      await _connectionUpdatedSubscription.cancel();
      _connectionUpdatedSubscription = null;
    }
    if (_purchaseUpdatedSubscription != null) {
      await _purchaseUpdatedSubscription.cancel();
      _purchaseUpdatedSubscription = null;
    }
    if (_purchaseErrorSubscription != null) {
      await _purchaseErrorSubscription.cancel();
      _purchaseErrorSubscription = null;
    }
    return await iap.finalize();
  }
}
