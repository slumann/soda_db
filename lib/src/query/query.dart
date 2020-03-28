import 'package:meta/meta.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage.dart';

FromSelector<T> from<T extends SodaEntity>(String repository) {
  return FromSelector._(storage.get(repository));
}

class FromSelector<T extends SodaEntity> extends _Selector<T> {
  Repository<T> _repository;

  FromSelector._(this._repository);

  @override
  Future<List<T>> select({int limit}) async {
    List<int> ids = getSortedIds();
    var entities = <T>[];
    for (var i = 0; i < limit && i < ids.length; i++) {
      entities.add(await _repository.get(ids[i]));
    }
    return entities;
  }

  @override
  Future<List<T>> selectAll() async {
    var entities = await _repository.getAll();
    entities.sort((a, b) => a.id - b.id);
    return entities;
  }

  @override
  Future<T> selectFirst() {
    return _repository.get(getSortedIds().first);
  }

  @override
  Future<T> selectLast() {
    return _repository.get(getSortedIds().last);
  }

  List<int> getSortedIds() {
    var ids = _repository.getEntityIds();
    ids.sort((a, b) => a - b);
    return ids;
  }
}

abstract class _Selector<T extends SodaEntity> {
  Future<List<T>> selectAll();

  Future<List<T>> select({@required int limit});

  Future<T> selectFirst();

  Future<T> selectLast();
}
