import 'package:flutter/widgets.dart';

class AudioItem {
  final String id;
  final String file;
  final String coverImage;
  final String description;
  final String name;
  final String categoryName;
  final bool isPaid;
  final bool isPopular;
  final bool isBestOfTheWeek;

  AudioItem({
    @required this.id,
    @required this.file,
    @required this.coverImage,
    @required this.description,
    @required this.name,
    @required this.categoryName,
    @required this.isPaid,
    @required this.isPopular,
    @required this.isBestOfTheWeek,
  });

  String getCoverImageFullPath() {
    return coverImage;
  }

  String getFileUrl() {
    return file;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          file == other.file &&
          coverImage == other.coverImage &&
          description == other.description &&
          name == other.name &&
          isPaid == other.isPaid &&
          categoryName == other.categoryName;

  @override
  int get hashCode =>
      id.hashCode ^
      file.hashCode ^
      coverImage.hashCode ^
      description.hashCode ^
      name.hashCode ^
      isPaid.hashCode ^
      categoryName.hashCode;

  @override
  String toString() {
    return 'AudioItem{'
        'id: $id, '
        'file: $file, '
        'coverImage: $coverImage, '
        'description: $description, '
        'name: $name, '
        'isPaid: $isPaid, '
        'categoryName: $categoryName}';
  }

  factory AudioItem.fromMap(Map<String, dynamic> item) {
    return AudioItem(
      id: item['id'],
      file: item['audioFile'],
      coverImage: item['audioCoverImage'],
      description: item['audioDescription'],
      name: item['audioName'],
      categoryName: item['categoryName'],
      isPaid: item['isPaid'] ?? false,
      isBestOfTheWeek: item['isBestOfTheWeek'],
      isPopular: item['isPopular'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audioFile': file,
      'audioCoverImage': coverImage,
      'audioDescription': description,
      'audioName': name,
      'isPaid': isPaid,
      'categoryName': categoryName,
      'isPopular': isPopular,
      'isBestOfTheWeek': isBestOfTheWeek,
    };
  }

  factory AudioItem.fromPlaylistAudio(Map<String, dynamic> data) {
    return AudioItem(
      id: data['uniqueKey'],
      file: data['audioFileUrl'],
      coverImage: data['coverImageUrl'],
      description: '-',
      name: data['audioTitle'],
      categoryName: '-',
      isPaid: false,
      isBestOfTheWeek: false,
      isPopular: false,
    );
  }
}
