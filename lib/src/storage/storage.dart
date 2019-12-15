import 'package:meta/meta.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage_impl.dart';

Storage _storage;

Storage get storage => _storage ??= StorageImpl();

@visibleForTesting
void set storage(Storage value) => _storage = value;

typedef EntityFactory<T extends SodaEntity> = T Function(Map<String, dynamic>);

abstract class Storage {
  Future<void> open(String path);

  void register<T extends SodaEntity>(
      String repository, EntityFactory<T> factory);

  Repository<T> get<T extends SodaEntity>(String repository);

  Future<void> close();
}
