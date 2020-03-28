import 'package:mockito/mockito.dart';
import 'package:soda_db/src/query/query.dart';
import 'package:soda_db/src/storage/storage.dart';
import 'package:test/test.dart';

import '../utils/mock_repository.dart';
import '../utils/test_user.dart';

void main() async {
  String userRepo = 'users';

  setUp(() {
    var repo = UserRepository();
    repo.put(User.withData(
        'Aaron', 'Aaronson', DateTime(1981, 1, 1), 'a.aaronson@aol.com'));
    repo.put(User.withData(
        'Ben', 'Benson', DateTime(1982, 2, 2), 'b.benson@bol.com'));
    repo.put(User.withData(
        'Charlie', 'Charlson', DateTime(1983, 3, 3), 'c.charlsonn@col.com'));
    repo.put(User.withData(
        'Dean', 'Deanson', DateTime(1984, 4, 4), 'd.deanson@dol.com'));
    repo.put(User.withData(
        'Emil', 'Emilson', DateTime(1985, 5, 5), 'e.emilson@eol.com'));

    storage = MockStorage();
    when(storage.get(userRepo)).thenReturn(repo);
  });

  group('from selector', () {
    test('selectAll', () async {
      var users = await from(userRepo).selectAll();
      expect(users.length, equals(5));
    });

    test('selectFirst', () async {
      User user = await from(userRepo).selectFirst();
      expect(user.firstName, equals('Aaron'));
    });

    test('selectLast', () async {
      User user = await from(userRepo).selectLast();
      expect(user.firstName, equals('Emil'));
    });

    test('select -1', () async {
      var users = await from<User>(userRepo).select(limit: -1);
      expect(users.length, equals(0));
    });

    test('select 0', () async {
      var users = await from<User>(userRepo).select(limit: 0);
      expect(users.length, equals(0));
    });

    test('select 2', () async {
      var users = await from<User>(userRepo).select(limit: 2);
      expect(users.length, equals(2));
      expect(users[0].firstName, equals('Aaron'));
      expect(users[1].firstName, equals('Ben'));
    });

    test('select all + 1', () async {
      var users = await from<User>(userRepo).select(limit: 6);
      expect(users.length, equals(5));
    });
  });
}

class MockStorage extends Mock implements Storage {}
