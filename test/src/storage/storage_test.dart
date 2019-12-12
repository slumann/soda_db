import 'dart:io';

import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/storage.dart';
import 'package:test/test.dart';

void main() {
  group('Operate on closed storage', () {
    test('Get repository', () {
      StateError error;
      try {
        Storage.getRepository('test_on_closed_storage');
      } on StateError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('Storage not opened'));
    });

    test('Close', () {
      var error;
      try {
        Storage.close();
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
        Storage.registerEntity('test', null);
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('must not be null'));
    });

    test('Already regsitered', () {
      ArgumentError error;
      try {
        Storage.registerEntity('test_already_registered', (map) => User());
        Storage.registerEntity('test_already_registered', (map) => User());
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('already registered'));
    });
  });

  group('Open storage', () {
    tearDown(() async {
      await Storage.close();
      File('test/tmp/').deleteSync(recursive: true);
    });

    test('Path ending without separator', () async {
      await Storage.open('test/tmp');
      expect(File('test/tmp/soda.db').existsSync(), isTrue);
    });

    test('Path ending with separator', () async {
      await Storage.open('test/tmp/');
      expect(File('test/tmp/soda.db').existsSync(), isTrue);
    });
  });

  group('Get repository', () {
    setUp(() async {
      await Storage.open('test/tmp/');
    });

    tearDown(() async {
      await Storage.close();
      File('test/tmp/').deleteSync(recursive: true);
    });

    test('Repository not regsitered', () {
      ArgumentError error;
      try {
        Storage.getRepository('test_not_registered');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('No such repository'));
    });

    test('Wrong type', () {
      ArgumentError error;
      try {
        Storage.registerEntity<Animal>('users', (map) => Animal());
        Storage.getRepository<User>('users');
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message, contains('registered as Repository<Animal>'));
    });

    test('Correct type', () {
      Storage.registerEntity<Animal>('animals', (map) => Animal());
      var repo = Storage.getRepository<Animal>('animals');
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
