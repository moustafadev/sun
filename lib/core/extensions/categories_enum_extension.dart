extension CategoriesEnumExtensions on PageType {
  String asString() {
    return this.toString().replaceAll('PageType.', '');
  }

  String asProductionString() {
    switch (this) {
      case PageType.guided:
        return 'Guided Meditation';
      case PageType.sleep:
        return 'Sleep';
      case PageType.music:
        return 'Music';
      default:
        return 'Guided Meditation';
    }
  }

  static PageType getTypeFromString(String page){
    switch (page) {
      case 'guided':
        return PageType.guided;
      case 'music':
        return PageType.music;
      case 'sleep':
        return PageType.sleep;
      default:
        return PageType.guided;
    }
  }
}

enum PageType {
  guided,
  sleep,
  music,
}
