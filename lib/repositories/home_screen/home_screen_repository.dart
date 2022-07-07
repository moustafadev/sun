abstract class HomeScreenRepository{
  
  Stream<int> getPageIndex();

  void changePageIndex(int index);
}