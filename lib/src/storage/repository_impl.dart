import 'package:soda_db/src/database/database.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/type_adapter.dart';

class RepositoryImpl<T extends SodaEntity> implements Repository<T> {
  final String _groupId;
  final TypeAdapter<T> _adapter;
  final Database _db;

  RepositoryImpl(this._groupId, this._adapter, this._db);

  @override
  Future<T> get(int id) async {
    var data = await _db.readEntity(_groupId, id);
    if (data == null) {
      return null;
    } else {
      var entity = _adapter.deserialize(data);
      entity.id = id;
      return entity;
    }
  }

  @override
  Future<List<T>> getAll() async {
    var entities = <T>[];
    var group = await _db.readGroup(_groupId);
    for (var data in group.entries) {
      var entity = _adapter.deserialize(data.value);
      entity.id = data.key;
      entities.add(entity);
    }
    return entities;
  }

  @override
  Future<void> put(T entity) async {
    var id =
        await _db.writeEntity(_groupId, entity.id, _adapter.serialize(entity));
    entity.id = id;
  }

  @override
  Future<bool> remove(T entity) async {
    var success = await _db.deleteEntity(_groupId, entity.id);
    if (success) {
      entity.id = null;
    }
    return success;
  }

  @override
  Future<void> clear() async {
    await _db.deleteGroup(_groupId);
  }
}
