import 'package:dost/dost.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    Storage.open();
  });

  tearDown(() {
    Storage.close();
  });

  test('Storage not opened on registerEntity()', () {
    String exception;
    try {
      Storage.close();
      Storage.registerEntity('test', null);
    } catch (e) {
      exception = e;
    }
    expect(exception, 'Storage not initialized. Call Storage.open() first.');
  });

  test('Storage not opened on getRepository()', () {
    String exception;
    try {
      Storage.close();
      Storage.getRepository('test');
    } catch (e) {
      exception = e;
    }
    expect(exception, 'Storage not initialized. Call Storage.open() first.');
  });

  test('No EntityBuilder provided', () {
    String exception;
    try {
      Storage.registerEntity('test', null);
    } catch (e) {
      exception = e;
    }
    expect(exception, 'EntityBuilder must not be null');
  });

  test('No such repository', () {
    String exception;
    try {
      Storage.getRepository('test');
    } catch (e) {
      exception = e;
    }
    expect(
        exception, 'No such repository "test". Call registerEntity() first.');
  });

  test('Wrong repository type', () {
    String exception;
    try {
      Storage.registerEntity<User>('test', (map) => User());
      Storage.getRepository<Animal>('test');
    } catch (e) {
      exception = e;
    }
    expect(exception,
        'Repository "test" is registered as Repository<User>, not Repository<Animal>.');
  });
}

class User extends Entity {
  String userName;

  @override
  Map<String, Object> toMap() {
    return {};
  }
}

class Animal extends Entity {
  String animalName;

  @override
  Map<String, Object> toMap() {
    return {};
  }
}
