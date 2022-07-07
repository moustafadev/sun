import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation/core/extensions/categories_enum_extension.dart';
import 'package:meditation/models/audio.dart';
import 'package:meditation/models/category.dart';
import 'package:meditation/models/config.dart';
import 'package:meditation/models/story_item.dart';
import 'package:meditation/models/story_category.dart';
import 'package:meditation/repositories/content/content_repository.dart';

class ContentRepositoryFirebase extends ContentRepository {
  FirebaseFirestore _firestore;

  Config _configCache;
  List<AudioItem> _bestOfTheWeekCache;
  List<AudioItem> _popularCache;
  List<AudioItem> _backgroundSoundsCache;
  List<StoryCategory> _storyCategoriesCache;
  List<CategoryItem> _categoriesCache;
  Map<String, List<AudioItem>> _categoryAudiosCache;
  Map<String, List<CategoryItem>> _categoriesByTypeCache;

  Stream<Config> _config;
  Stream<List<AudioItem>> _popular;
  Stream<List<AudioItem>> _bestOfTheWeek;
  Stream<List<CategoryItem>> _categories;
  Stream<List<StoryCategory>> _storyCategories;
  Stream<List<AudioItem>> _backgroundSounds;
  Map<String, Stream<List<AudioItem>>> _categoryAudios;
  Map<String, Stream<List<CategoryItem>>> _categoriesByType;

  Config get configCache => _configCache;
  List<AudioItem> get bestOfTheWeekCache => _bestOfTheWeekCache;
  List<AudioItem> get popularCache => _popularCache;
  List<CategoryItem> get categoriesCache => _categoriesCache;
  List<AudioItem> get backgroundSoundsCache => _backgroundSoundsCache;
  List<StoryCategory> get storyCategoriesCache => _storyCategoriesCache;
  Map<String, List<AudioItem>> get categoryAudiosCache => _categoryAudiosCache ?? {};
  Map<String, List<CategoryItem>> get categoriesByTypeCache => _categoriesByTypeCache ?? {};

  Stream<List<AudioItem>> get popular => _popular == null ? loadPopularAudio() : _popular;
  Stream<List<AudioItem>> get bestOfTheWeek => _bestOfTheWeek == null ? loadBestOfWeek() : _bestOfTheWeek;
  Stream<List<CategoryItem>> get categories => _categories == null ? loadCategories() : _categories;
  Stream<List<StoryCategory>> get storyCategories => _storyCategories == null ? loadStoriesCategory() : _storyCategories;
  Stream<List<AudioItem>> get backgroundSounds => _backgroundSounds == null ? loadBackgroundAudios() : _backgroundSounds;
  Stream<Config> get config => _config == null ? loadConfig() : _config;

  Stream<List<AudioItem>> categoryAudios(String categoryId) {
    if (_categoryAudios == null) {
      _categoryAudios = {};
    }
    _categoryAudios[categoryId] = !_categoryAudios.containsKey(categoryId) ? loadCategoryAudios(categoryId) : _categoryAudios[categoryId];
    return _categoryAudios[categoryId];
  }

  Stream<List<CategoryItem>> categoriesByType(PageType type) {
    if (_categoriesByType == null) {
      _categoriesByType = {};
    }
    _categoriesByType[type.asString()] =
        !_categoriesByType.containsKey(type.asString()) ? loadCategoriesByType(type) : _categoriesByType[type.asString()];
    return _categoriesByType[type.asString()];
  }

  ContentRepositoryFirebase() {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<List<CategoryItem>> loadCategories() {
    _categories = FirebaseFirestore.instance
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "categories")
        .snapshots()
        .asyncMap((document) {
      _categoriesCache = _mapDocumentToCategories(document, isAllCategories: true);
      return _categoriesCache;
    });

    return _categories;
  }

  List<CategoryItem> _mapDocumentToCategories(QuerySnapshot snapshot, {bool isAllCategories = false}) {
    List<CategoryItem> categories = [];
    for (var doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      categories.add(
        CategoryItem(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          image: data['coverImageUrl'] ?? '',
          type: CategoriesEnumExtensions.getTypeFromString(data['type']),
        ),
      );
    }
    if (isAllCategories) {
      _categoriesCache = categories;
    }
    return categories;
  }

  List<StoryItem> _getStoryItems(List<dynamic> data) {
    List<StoryItem> storyItems = [];
    for (var item in data) {
      storyItems.add(
        StoryItem(
          caption: item['caption'],
          description: item['description'],
          imageUrl: item['coverImageUrl'] ?? '',
        ),
      );
    }

    return storyItems;
  }

  List<StoryCategory> _mapDocumentToStoryCategories(QuerySnapshot data) {
    List<StoryCategory> categories = [];
    try {
      for (var doc in data.docs) {
        final Map<String, dynamic> data = doc.data();
        categories.add(
          StoryCategory(
            id: doc.id,
            category: data['category'],
            name: data['name'],
            storyItems: _getStoryItems(data['storyItems']),
            imageUrl: data['coverImageUrl'] ?? '',
            isPaid: data['isPaid'],
          ),
        );
      }
    } catch (e) {
      print(e);
    }

    return categories;
  }

  @override
  Stream<List<AudioItem>> loadCategoryAudios(String categoryId) {
    final categoryReference = _getCategoryReference(categoryId);
    List<AudioItem> audios;
    _categoryAudios[categoryId] = _firestore
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "audios")
        .where("category", isEqualTo: categoryReference)
        .snapshots()
        .asyncMap((document) {
      audios = _mapDocumentToAudios(document);
      return audios;
    });
    if (_categoryAudiosCache == null) _categoryAudiosCache = {};
    _categoryAudiosCache[categoryId] = audios;
    return _categoryAudios[categoryId];
  }

  List<AudioItem> _mapDocumentToAudios(QuerySnapshot snapshot) {
    List<AudioItem> audios = [];
    for (var audio in snapshot.docs) {
      final Map<String, dynamic> data = audio.data();
      final audioFile = data['fileUrl'];
      final audioCoverImage = data['coverImageUrl'];
      final id = data['id'];
      final description = data['description'];
      final name = data['name'];
      final isPaid = data['isPaid'];
      final category = _getCategoryData(data['category'], _categoriesCache);
      final isBestOfTheWeek = data['isBestOfTheWeek'];
      final isPopular = data['isPopular'];
      audios.add(
        AudioItem(
          id: id,
          categoryName: category.name,
          name: name,
          coverImage: audioCoverImage,
          description: description,
          file: audioFile,
          isPaid: isPaid,
          isBestOfTheWeek: isBestOfTheWeek,
          isPopular: isPopular,
        ),
      );
    }
    return audios;
  }

  @override
  Stream<List<AudioItem>> loadPopularAudio() {
    _popular = _firestore
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "audios")
        .where('isPopular', isEqualTo: true)
        .orderBy("_fl_meta_.createdDate", descending: true)
        .limit(15)
        .snapshots()
        .asyncMap((document) {
      _popularCache = _mapDocumentToAudios(document);
      return _popularCache;
    });
    return _popular;
  }

  @override
  Stream<List<AudioItem>> loadBestOfWeek() {
    _bestOfTheWeek = _firestore
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "audios")
        .where("isBestOfTheWeek", isEqualTo: true)
        .snapshots()
        .asyncMap((document) {
      _bestOfTheWeekCache = _mapDocumentToAudios(document);
      return _bestOfTheWeekCache;
    });
    return _bestOfTheWeek;
  }

  DocumentReference _getCategoryReference(String categoryId) {
    return _firestore.collection('fl_content').doc(categoryId);
  }

  CategoryItem _getCategoryData(DocumentReference reference, List<CategoryItem> categories) {
    for (var item in categories) {
      if (item.id == reference.id) return item;
    }
    return categories[0];
  }

  @override
  Stream<List<CategoryItem>> loadCategoriesByType(PageType categoriesType) {
    List<CategoryItem> categories;

    _categoriesByType[categoriesType.asString()] = FirebaseFirestore.instance
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "categories")
        .where('type', isEqualTo: categoriesType.asString())
        .where('name', isNotEqualTo: 'Background music')
        .orderBy('name')
        .snapshots()
        .asyncMap((document) {
      categories = _mapDocumentToCategories(document);
      return categories;
    });
    if (_categoriesByTypeCache == null) _categoriesByTypeCache = {};
    _categoriesByTypeCache[categoriesType.asString()] = categories;
    return _categoriesByType[categoriesType.asString()];
  }

  @override
  Stream<List<StoryCategory>> loadStoriesCategory() {
    _storyCategories = FirebaseFirestore.instance
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "featuredStories")
        .orderBy('name')
        .snapshots()
        .asyncMap((document) {
      _storyCategoriesCache = _mapDocumentToStoryCategories(document);
      return _storyCategoriesCache;
    });
    return _storyCategories;
  }

  @override
  Stream<List<AudioItem>> loadBackgroundAudios() {
    final categoryId = _categoriesCache.where((element) => element.name == 'Background music').toList()[0].id;
    final categoryReference = _getCategoryReference(categoryId);
    _backgroundSounds = _firestore
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "audios")
        .where("category", isEqualTo: categoryReference)
        .snapshots()
        .asyncMap((document) {
      _backgroundSoundsCache = _mapDocumentToAudios(document);
      return _backgroundSoundsCache;
    });
    return _backgroundSounds;
  }

  @override
  Stream<Config> loadConfig() {
    _config = _firestore
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "config")
        .snapshots()
        .asyncMap((document) {
      _configCache = Config.fromJson(document.docs[0].data());
      return _configCache;
    });

    _firestore
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "config")
        .snapshots()
        .listen((document) {
      _configCache = Config.fromJson(document.docs[0].data());
    });
    return _config;
  }
}
