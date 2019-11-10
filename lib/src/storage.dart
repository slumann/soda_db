typedef EntityBuilder<T> = T Function(Map<String, dynamic>);

abstract class Storage {
  static Map<String, dynamic> _repositories;
  static String _fileName;
  static String _password;

  static void open({String fileName, String password}) {
    _fileName = fileName;
    _password = password;
    _repositories = {};
  }

  static void registerEntity<T extends Entity>(
      String repoName, EntityBuilder<T> builder) {
    if (_repositories == null) {
      throw 'Storage not initialized. Call Storage.open() first.';
    }

    if (builder == null) {
      throw 'EntityBuilder must not be null';
    }

    _repositories.putIfAbsent(repoName, () => _Repository<T>(builder));
  }

  static Repository<T> getRepository<T extends Entity>(String name) {
    if (_repositories == null) {
      throw 'Storage not initialized. Call Storage.open() first.';
    }

    var repo = _repositories[name];
    if (repo == null) {
      throw 'No such repository "$name". Call registerEntity() first.';
    }

    if (repo is! Repository<T>) {
      var repoType = repo.runtimeType.toString();
      repoType =
          repoType.substring(repoType.indexOf('<') + 1, repoType.indexOf('>'));
      throw 'Repository "$name" is registered as Repository<$repoType>, not Repository<$T>.';
    }
    return _repositories[name];
  }

  static void close() => _repositories = null;
}

abstract class Repository<T extends Entity> {
  List<T> get entities;

  void put(T entity);

  void putAll(Iterable<T> entities);

  void remove(T entity);

  void removeAll(Iterable<T> entities);

  void clear();
}

class _Repository<T extends Entity> extends Repository<T> {
  final List<T> _entities;
  final EntityBuilder<T> _builder;
  int _nextId;

  _Repository(this._builder) : _entities = [] {
    _nextId = 0;
  }

  List<T> get entities {
    var copies = [];
    _entities.forEach((entity) {
      var copy = _builder(entity.toMap());
      copy._id = entity.id;
      copies.add(copy);
    });
    return List.from(copies);
  }

  void put(T entity) {
    var i = _entities.indexOf(entity);
    if (i >= 0) {
      _entities.replaceRange(i, i + 1, [entity]);
    } else {
      entity._id = _nextId++;
      _entities.add(entity);
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

abstract class Entity {
  int _id;

  int get id => _id;

  Map<String, Object> toMap();

  @override
  bool operator ==(other) => id == other.id;
}
