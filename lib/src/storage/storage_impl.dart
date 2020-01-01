import 'dart:io';

import 'package:soda_db/src/database/database.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/repository_impl.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage.dart';
import 'package:soda_db/src/storage/type_adapter.dart';

class StorageImpl extends Storage {
  final _typeAdapters = <Type, TypeAdapter>{};
  final _repositories = <String, Repository>{};
  Database _db;

  @override
  Future<void> open(String path) async {
    if (!path.endsWith('/')) {
      path += '/';
    }
    var file = File('${path}soda.db');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    _db ??= Database(file);
    await _db.open();
  }

  @override
  void register(TypeAdapter<SodaEntity> adapter) {
    if (!_typeAdapters.containsKey(adapter.type)) {
      _typeAdapters[adapter.type] = adapter;
    }
  }

  @override
  Repository<T> get<T extends SodaEntity>(String repository) {
    if (_db == null) {
      throw StateError('Storage not opened! Call Storage.open() first.');
    }

    if (!_typeAdapters.containsKey(T)) {
      throw ArgumentError('No TypeAdapter registered for type $T');
    }

    var repo = _repositories.putIfAbsent(
        repository, () => RepositoryImpl<T>(repository, _typeAdapters[T], _db));

    if (repo is! Repository<T>) {
      var repoType = repo.runtimeType.toString();
      repoType =
          repoType.substring(repoType.indexOf('<') + 1, repoType.indexOf('>'));
      throw ArgumentError(
          'Repository "$repository" is of type Repository<$repoType>, '
          'not Repository<$T>.');
    }
    return repo;
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _repositories.clear();
  }
}
