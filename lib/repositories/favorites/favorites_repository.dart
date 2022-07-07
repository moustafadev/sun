import 'package:meditation/models/audio.dart';
import 'package:meditation/repositories/local/local_repository_impl.dart';

class FavoritesRepository extends LocalHiveRepository<AudioItem> {
  Future<List<AudioItem>> _favourites;
  Future<List<AudioItem>> get favourites =>
      _favourites == null ? getAll() : _favourites;

  FavoritesRepository()
      : super(
            name: "favorites_audio",
            modelToJsonConverter: (AudioItem item) => item.toMap(),
            jsonToModelConverter: (Map<dynamic, dynamic> item) =>
                AudioItem.fromMap(item.cast<String, dynamic>()));
}
