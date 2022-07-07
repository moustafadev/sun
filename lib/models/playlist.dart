import 'package:meditation/models/audio.dart';

class Playlist {
  String id;
  String name;
  String description;
  String imageUrl;
  List<AudioItem> audios;

  Playlist({
    this.id,
    this.audios,
    this.description,
    this.imageUrl,
    this.name,
  });

  factory Playlist.fromJson(Map<String, dynamic> data, List<AudioItem> audios,
      String id, String coverImage) {
    return Playlist(
      id: id,
      name: data['name'],
      description: data['description'],
      imageUrl: coverImage,
      audios: audios,
    );
  }

  String getCoverImageFullPath() {
    return imageUrl;
  }
}
