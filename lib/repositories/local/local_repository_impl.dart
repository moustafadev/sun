import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meditation/repositories/local/local_repository.dart';

class LocalHiveRepository<T> extends LocalRepository<T, String> {

  final String name;
  final Map<dynamic, dynamic> Function(T) modelToJsonConverter;
  final T Function(Map<dynamic, dynamic>) jsonToModelConverter;

  LocalHiveRepository({
    @required this.name,
    @required this.modelToJsonConverter,
    @required this.jsonToModelConverter
  });

  Box<Map<dynamic, dynamic>> box;

  Future _initBox() async {
    if (Hive.isBoxOpen(name)) {
      box = Hive.box(name);
    } else {
      box = await Hive.openBox(name);
    }
  }
  
  @override
  Future add(String id, T item) async {
    await _initBox();
    return box.put(id, modelToJsonConverter(item));
  }

  @override
  Future<T> get(String id) async {
    await _initBox();
    final item = box.get(id);
    if (item != null) {
      return jsonToModelConverter(item);
    } else {
      return null;
    }
  }

  @override
  Future<List<T>> getAll() async {
    await _initBox();
    return box.values.map((e) => jsonToModelConverter(e)).toList();
  }

  @override
  Future remove(String id) async {
    await _initBox();
    return box.delete(id);
  }

}
