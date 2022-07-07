import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

abstract class InAppPurchases {

  void initialize();

  Future<List<ProductDetails>> loadProducts();

  Future<List<PurchaseDetails>> loadPurchases();

  Future<bool> makePurchase(String id);

  void dispose();

}
