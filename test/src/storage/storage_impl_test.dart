import 'dart:io';

import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage.dart';
import 'package:soda_db/src/storage/storage_impl.dart';
import 'package:test/test.dart';

void main() {
  Storage storage;

  setUp(() {
    storage = StorageImpl();
  });

  group('Operate on closed storage', () {
    test('Get repository', () {
      StateError error;
      try {
        storage.getRepository('test_on_closed_storage');
      } on StateError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('Storage not opened'));
    });

    test('Close', () {
      var error;
      try {
        storage.close();
      } catch (e) {
        error = e;
      }
      expect(error, isNull);
    });
  });

  group('Register entity', () {
    test('EntityFactory is null', () {
      ArgumentError error;
      try {
        storage.registerEntity('test', null);
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('must not be null'));
    });

    test('Already regsitered', () {
      ArgumentError error;
      try {
        storage.registerEntity('test_already_registered', (map) => User());
        storage.registerEntity('test_already_registered', (map) => User());
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('already registered'));
    });
  });

  group('Open storage', () {
    tearDown(() async {
      await storage.close();
      File('test/tmp/').deleteSync(recursive: true);
    });

    test('Path ending without separator', () async {
      await storage.open('test/tmp');
      expect(File('test/tmp/soda.db').existsSync(), isTrue);
    });

    test('Path ending with separator', () async {
      await storage.open('test/tmp/');
      expect(File('test/tmp/soda.db').existsSync(), isTrue);
    });
  });

  group('Get repository', () {
    setUp(() async {
      await storage.open('test/tmp/');
    });

    tearDown(() async {
      await storage.close();
      File('test/tmp/').deleteSync(recursive: true);
    });

    test('Repository not regsitered', () {
      ArgumentError error;
      try {
        storage.getRepository('test_not_registered');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('No such repository'));
    });

    test('Wrong type', () {
      ArgumentError error;
      try {
        storage.registerEntity<Animal>('users', (map) => Animal());
        storage.getRepository<User>('users');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('registered as Repository<Animal>'));
    });

    test('Correct type', () {
      storage.registerEntity<Animal>('animals', (map) => Animal());
      var repo = storage.getRepository<Animal>('animals');
      expect(repo, isA<Repository<Animal>>());
    });
  });
}

class User with SodaEntity {
  String userName;

  @override
  Map<String, Object> toJson() {
    return {};
  }
}

class Animal with SodaEntity {
  String animalName;

  @override
  Map<String, Object> toJson() {
    return {};
  }
}
