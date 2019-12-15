import 'dart:io';

import 'package:soda_db/src/database/database.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/repository_impl.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage.dart';

class StorageImpl extends Storage {
  Map<String, dynamic> _repositories = {};
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
  void register<T extends SodaEntity>(
      String repository, EntityFactory<T> factory) {
    if (factory == null) {
      throw ArgumentError('EntityFactory must not be null!');
    }

    if (_repositories.containsKey(repository)) {
      throw ArgumentError('Repository $repository already registered!');
    }

    _repositories[repository] = RepositoryImpl<T>(repository, factory, _db);
  }

  @override
  Repository<T> get<T extends SodaEntity>(String repository) {
    if (_db == null) {
      throw StateError('Storage not opened! Call Storage.open() first.');
    }

    var repo = _repositories[repository];
    if (repo == null) {
      throw ArgumentError('No such repository "$repository". '
          'Did you forgot to call registerEntity()?');
    }

    if (repo is! Repository<T>) {
      var repoType = repo.runtimeType.toString();
      repoType =
          repoType.substring(repoType.indexOf('<') + 1, repoType.indexOf('>'));
      throw ArgumentError(
          'Repository "$repository" is registered as Repository<$repoType>, '
          'not Repository<$T>.');
    }
    return _repositories[repository];
  }

  @override
  Future<void> close() async {
    await _db?.close();
  }
}
