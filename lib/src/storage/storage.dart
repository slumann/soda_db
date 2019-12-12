import 'dart:io';

import 'package:soda_db/src/database/database.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/repository_impl.dart';
import 'package:soda_db/src/storage/soda_entity.dart';

typedef EntityFactory<T> = T Function(Map<String, dynamic>);

abstract class Storage {
  static Map<String, dynamic> _repositories = {};
  static Database _db;

  static Future<void> open(String path) async {
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

  static void registerEntity<T extends SodaEntity>(
      String repoName, EntityFactory<T> factory) {
    if (factory == null) {
      throw ArgumentError('EntityFactory must not be null!');
    }

    if (_repositories.containsKey(repoName)) {
      throw ArgumentError('Repository $repoName already registered!');
    }

    _repositories[repoName] = RepositoryImpl<T>(repoName, factory, _db);
  }

  static Repository<T> getRepository<T extends SodaEntity>(String name) {
    if (_db == null) {
      throw StateError('Storage not opened! Call Storage.open() first.');
    }

    var repo = _repositories[name];
    if (repo == null) {
      throw ArgumentError('No such repository "$name". '
          'Did you forgot to call registerEntity()?');
    }

    if (repo is! Repository<T>) {
      var repoType = repo.runtimeType.toString();
      repoType =
          repoType.substring(repoType.indexOf('<') + 1, repoType.indexOf('>'));
      throw ArgumentError(
          'Repository "$name" is registered as Repository<$repoType>, '
          'not Repository<$T>.');
    }
    return _repositories[name];
  }

  static Future<void> close() async {
    await _db?.close();
  }
}
