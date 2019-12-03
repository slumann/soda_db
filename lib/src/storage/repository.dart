import 'package:soda_db/src/storage/soda_entity.dart';

abstract class Repository<T extends SodaEntity> {
  Future<T> get(int id);

  Future<List<T>> getAll();

  Future<void> put(T entity);

  Future<bool> remove(T entity);

  Future<void> clear();
}
