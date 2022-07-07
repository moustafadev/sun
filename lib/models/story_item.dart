class StoryItem {
  final String id;
  final String caption;
  final String imageUrl;
  final String description;

  StoryItem({
    this.id,
    this.caption,
    this.imageUrl,
    this.description,
  });

  String getCoverImageFullPath() {
    return imageUrl;
  }

  factory StoryItem.fromJson(Map<String, dynamic> data) {
    return StoryItem(
      id: data['id'],
      caption: data['caption'],
      description: data['description'],
      imageUrl: data['coverImage'],
    );
  }
}
