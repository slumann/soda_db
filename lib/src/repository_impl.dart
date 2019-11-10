import 'package:dost/dost.dart';

class RepositoryImpl<T extends Entity> extends Repository<T> {
  final List<T> _entities;
  final EntityBuilder<T> _builder;

  RepositoryImpl(this._builder) : _entities = [];

  List<T> get entities {
    var copy = [];
    _entities.forEach((entity) => copy.add(_builder(entity.toMap())));
    return List.from(copy);
  }

  void put(T entity) {
    var i = _entities.indexOf(entity);
    if (i >= 0) {
      _entities.replaceRange(i, i + 1, [entity]);
    } else {
      entity.id = _createId();
      _entities.add(entity);
    }
  }

  int _createId() {
    if (_entities.isEmpty) {
      return 0;
    } else {
      return _entities.last.id + 1;
    }
  }

  void putAll(Iterable<T> entities) {
    entities.forEach(put);
  }

  void remove(T entity) {
    var i = _entities.indexOf(entity);
    if (i >= 0) _entities.removeAt(i);
  }

  void removeAll(Iterable<T> entities) {
    entities.forEach(remove);
  }

  void clear() {
    _entities.clear();
  }
}
