import 'dart:io';

import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage.dart';
import 'package:soda_db/src/storage/storage_impl.dart';
import 'package:soda_db/src/storage/type_adapter.dart';
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

    test('No TypeAdapter registered', () {
      ArgumentError error;
      try {
        storage.get<User>('test_not_registered');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('No TypeAdapter registered'));
    });

    test('Correct type', () {
      storage.register(AnimalAdapter());
      var repo = storage.get<Animal>('animals');
      expect(repo, isA<Repository<Animal>>());
    });

    test('Wrong type', () {
      ArgumentError error;
      try {
        storage.register(UserAdapter());
        storage.register(AnimalAdapter());
        storage.get<User>('users');
        storage.get<Animal>('users');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('"users" is of type Repository<User>'));
    });

    test('Repository is cached', () {
      storage.register(UserAdapter());
      var firstGet = storage.get<User>('users');
      var secondGet = storage.get<User>('users');
      expect(firstGet, same(secondGet));
    });

    test('Repository cache cleared on close', () async {
      storage.register(UserAdapter());
      var firstGet = storage.get<User>('users');
      await storage.close();
      await storage.open('$testDir');
      var secondGet = storage.get<User>('users');
      expect(firstGet, isNot(same(secondGet)));
    });
  });
}

class User with SodaEntity {}

class Animal with SodaEntity {}

class UserAdapter extends TypeAdapter<User> {
  @override
  User deserialize(String data) {
    return null;
  }

  @override
  String serialize(User type) {
    return null;
  }
}

class AnimalAdapter extends TypeAdapter<Animal> {
  @override
  Animal deserialize(String data) {
    return null;
  }

  @override
  String serialize(Animal type) {
    return null;
  }
}
