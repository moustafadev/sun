import 'package:flutter/widgets.dart';
import 'package:meditation/core/extensions/categories_enum_extension.dart';

class CategoryItem {
  final String id;
  final String name;
  final String description;
  final String image;
  final PageType type;

  CategoryItem({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.image,
    @required this.type,
  });

  String getImageFullPath() {
    return image;
  }
}
