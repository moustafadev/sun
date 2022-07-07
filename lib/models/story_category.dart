import 'package:meditation/models/story_item.dart';

class StoryCategory {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final List<StoryItem> storyItems;
  final bool isPaid;

  StoryCategory({
    this.id,
    this.name,
    this.category,
    this.imageUrl,
    this.storyItems,
    this.isPaid,
  });

  String getCoverImageFullPath() {
    return imageUrl;
  }
}
