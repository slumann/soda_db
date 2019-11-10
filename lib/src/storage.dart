import 'package:dost/dost.dart';
import 'package:dost/src/repository_impl.dart';

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

    _repositories.putIfAbsent(repoName, () => RepositoryImpl<T>(builder));
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
