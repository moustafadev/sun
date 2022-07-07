import 'dart:async';

import 'package:meditation/repositories/payment/payment_repository.dart';

class PaymentStatus extends PaymentRepository {
  // singleton
  static final PaymentStatus _singleton = PaymentStatus._internal();
  factory PaymentStatus() {
    return _singleton;
  }
  PaymentStatus._internal();
  // end singleton

  bool paymentStatus = false;
  StreamController<bool> _paymentController = StreamController<bool>.broadcast();

  @override
  void changePaymentStatus(bool status) {
    paymentStatus = status;
    _paymentController.add(status);
  }

  @override
  Stream<bool> getPaymentStatus() {
    return _paymentController.stream;
  }

  @override
  bool isLocked(bool isPaid, bool audioPaidStatus) {
    return !isPaid && audioPaidStatus;
  }
}
