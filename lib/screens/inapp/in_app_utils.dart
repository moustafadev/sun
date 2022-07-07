import 'dart:io';

import 'package:flutter_inapp_purchase/modules.dart';

extension PurchasedItemUtils on PurchasedItem {
  bool isSuccessfulState() {
    if (Platform.isIOS) {
      return transactionStateIOS == TransactionState.purchased ||
          transactionStateIOS == TransactionState.restored;
    } else {
      return purchaseStateAndroid == PurchaseState.purchased;
    }
  }

  bool isSuccessful(String id) {
    if (productId == id) {
      return isSuccessfulState();
    } else {
      return false;
    }
  }
}
