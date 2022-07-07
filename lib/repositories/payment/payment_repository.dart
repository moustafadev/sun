abstract class PaymentRepository {
  Stream<bool> getPaymentStatus();

  void changePaymentStatus(bool status);

  bool isLocked(bool isPaid, bool audioStatus);
}
