import 'package:meditation/core/extensions/categories_enum_extension.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/models/category.dart';
import 'package:meditation/models/config.dart';
import 'package:meditation/models/story_category.dart';

abstract class ContentRepository {
  Stream<List<CategoryItem>> loadCategories();

  Stream<List<AudioItem>> loadBestOfWeek();

  Stream<List<AudioItem>> loadPopularAudio();

  Stream<List<StoryCategory>> loadStoriesCategory();

  Stream<List<AudioItem>> loadBackgroundAudios();

  Stream<List<AudioItem>> loadCategoryAudios(String categoryId);

  Stream<List<CategoryItem>> loadCategoriesByType(PageType categoriesType);

  Stream<Config> loadConfig();
}
