abstract class LocalRepository<T, ID> {

  Future<List<T>> getAll();

  Future<T> get(ID id);

  Future add(ID id, T item);

  Future remove(ID id);

}
