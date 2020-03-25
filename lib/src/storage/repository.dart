import 'package:soda_db/src/storage/soda_entity.dart';

/// Repository for a specific [SodaEntity] type. Provides CRUD operations
/// for objects of the given type [T].
abstract class Repository<T extends SodaEntity> {
  /// Gets the entity with [id]. null if the entity does not exist.
  Future<T> get(int id);

  /// Gets all entities of this repository.
  Future<List<T>> getAll();

  /// Saves the given [entity] to the repository if it does not exist.
  /// The entity's ID will be auto generated.<br>
  /// Updates the given [entity] in the repository if it already exists
  /// (if [entity] already has an ID set).
  Future<void> put(T entity);

  /// Removes the given [entity] from the repository. Returns true if the
  /// entity was removed successful, false if the entity could not be removed
  /// or does not exist in the repository.
  Future<bool> remove(T entity);

  /// Removes all entities from the repository.
  Future<void> clear();

  /// Gets all entity IDs of this repository.
  List<int> getEntityIds();
}
