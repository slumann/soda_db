import 'package:meta/meta.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage_impl.dart';
import 'package:soda_db/src/storage/type_adapter.dart';

Storage _storage;

/// Singleton instance of Storage [Storage]. Can be overwritten in unit test.
Storage get storage => _storage ??= StorageImpl();

@visibleForTesting
set storage(Storage value) => _storage = value;

/// SodaDB access point. Provides facilities to open/close the storage,
/// register entity types and obtain [Repository]s.
/// Use the global singleton [storage] variable to access the Storage..
abstract class Storage {
  /// Opens the storage. Must be called before any [Repository]s are obtained
  /// from storage. Provide the [path] where the storage should be persisted.
  /// Storage is designed as singleton, so only one single storage can be
  /// opened at a time.
  Future<void> open(String path);

  /// Registers the given [TypeAdapter], so that SodaDB is able to de-/serialize
  /// [SodaEntity]s of the type supported by this adapter.
  void register(TypeAdapter adapter);

  /// Retrieves the [Repository] for the given [repository] name.
  /// If the repository does not yet exist, it is created.
  /// Once the repository is created for this name, the provided type [T]
  /// is associated with this repository.
  Repository<T> get<T extends SodaEntity>(String repository);

  /// Flushes all pending operations and closes the storage.
  Future<void> close();
}
