import 'package:meta/meta.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage_impl.dart';

Storage _storage;

Storage get storage => _storage ??= StorageImpl();

@visibleForTesting
void set storage(Storage value) => _storage = value;

typedef EntityFactory<T> = T Function(Map<String, dynamic>);

abstract class Storage {
  Future<void> open(String path);

  void registerEntity<T extends SodaEntity>(
      String repoName, EntityFactory<T> factory);

  Repository<T> getRepository<T extends SodaEntity>(String name);

  Future<void> close();
}
