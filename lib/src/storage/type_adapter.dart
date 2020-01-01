import 'package:soda_db/src/storage/soda_entity.dart';

/// Adapter to serialize and deserialize [SodaEntity]s of the given type [T];
abstract class TypeAdapter<T extends SodaEntity> {
  /// Gets the [Type] that is associated with this adapter.
  Type get type => T;

  /// Returns the string representation of [type].
  /// Must contain all fields that should be persisted by SodaDB.
  String serialize(T type);

  /// Deserializes [data] and returns a [SodaEntity] of type [T].
  T deserialize(String data);
}
