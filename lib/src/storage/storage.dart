import 'package:meta/meta.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage_impl.dart';

Storage _storage;

/// Singleton instance of Storage [Storage]. Can be overwritten in unit test.
Storage get storage => _storage ??= StorageImpl();

@visibleForTesting
void set storage(Storage value) => _storage = value;

/// Factory for [SodaEntity]s. A factory must be able to re-created a type
/// from a Map<String, dynamic>. Each entity type must be registered using
/// [storage.register].
typedef EntityFactory<T extends SodaEntity> = T Function(Map<String, dynamic>);

/// SodaDB access point. Provides facilities to open/close the storage,
/// register entity types and obtain [Repository]s.
/// Use the global singleton [storage] variable to access the Storage..
abstract class Storage {
  /// Opens the storage. Must be called before any [Repository]s are obtained
  /// from storage. Provide the [path] where the storage should be persisted.
  /// Storage is designed as singleton, so only one single storage can be
  /// opened at a time.
  Future<void> open(String path);

  /// Any [SodaEntity] that is to be stored must be registered first.
  /// The [repository] name must be unique and must never be changed once a type
  /// is registered. However, the same type might be registered more than one
  /// time, if necessary.<br>
  /// An [EntityFactory] must be provided in order to re-create entities of
  /// a specific type.<br>
  /// Entities might be registered before the storage is opened.
  void register<T extends SodaEntity>(
      String repository, EntityFactory<T> factory);

  /// Retrieves the [Repository] for the given [repository] name from storage.
  Repository<T> get<T extends SodaEntity>(String repository);

  /// Flushes all pending operations and than closes the storage.
  Future<void> close();
}
