import 'package:meditation/screens/payment/models/product_meta_data.dart';

abstract class ProductsProvider {

  Future<List<ProductMetaData>> initialize();

  Future<List<String>> getAvailableSubscriptionIds();

  Future<List<String>> getIds();

  Future<MeditationPackSubscriptionMetaData> getActiveSubscriptionPack();

  Future<ProductMetaData> get(String id);

}
