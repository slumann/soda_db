import 'dart:io';

import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage.dart';
import 'package:soda_db/src/storage/storage_impl.dart';
import 'package:test/test.dart';

const testDir = 'test/tmp/storage_impl_test';

void main() {
  Storage storage;

  setUp(() {
    storage = StorageImpl();
  });

  group('Operate on closed storage', () {
    test('Get repository', () {
      StateError error;
      try {
        storage.get('test_on_closed_storage');
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
        storage.register('test', null);
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('must not be null'));
    });

    test('Already regsitered', () {
      ArgumentError error;
      try {
        storage.register('test_already_registered', (map) => User());
        storage.register('test_already_registered', (map) => User());
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
      File('$testDir/').deleteSync(recursive: true);
    });

    test('Path ending without separator', () async {
      await storage.open('$testDir');
      expect(File('$testDir/soda.db').existsSync(), isTrue);
    });

    test('Path ending with separator', () async {
      await storage.open('$testDir/');
      expect(File('$testDir/soda.db').existsSync(), isTrue);
    });
  });

  group('Get repository', () {
    setUp(() async {
      await storage.open('$testDir/');
    });

    tearDown(() async {
      await storage.close();
      File('$testDir/').deleteSync(recursive: true);
    });

    test('Repository not regsitered', () {
      ArgumentError error;
      try {
        storage.get('test_not_registered');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('No such repository'));
    });

    test('Wrong type', () {
      ArgumentError error;
      try {
        storage.register<Animal>('users', (map) => Animal());
        storage.get<User>('users');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('registered as Repository<Animal>'));
    });

    test('Correct type', () {
      storage.register<Animal>('animals', (map) => Animal());
      var repo = storage.get<Animal>('animals');
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
