import 'package:soda_db/soda_db.dart';
import 'package:test/test.dart';

void main() {
  Repository<User> repo;

  setUp(() {
    Storage.open();
    Storage.registerEntity<User>('users', (map) => User.fromMap(map));
    repo = Storage.getRepository<User>('users');
  });

  test('Put entity', () {
    var john = User('John');
    repo.put(john);
    var users = repo.entities;

    expect(users.length, 1);
    expect(users.first.name, john.name);
  });

  test('Put entity sets id', () {
    repo.put(User('John'));
    var users = repo.entities;

    expect(users.first.name, 'John');
    expect(users.first.id, 0);
  });

  test('Put entities increments ids', () {
    repo.put(User('John'));
    repo.put(User('Jack'));
    var users = repo.entities;

    expect(users[0].id, 0);
    expect(users[1].id, 1);
  });

  test('PutAll entities', () {
    repo.putAll([User('John'), User('Jack'), User('Jill')]);
    var users = repo.entities;

    expect(users.length, 3);
  });

  test('Remove entity', () {
    var john = User('John');
    repo.put(john);
    expect(repo.entities.length, 1);
    repo.remove(john);
    expect(repo.entities.length, 0);
  });

  test('RemoveAll entities', () {
    var john = User('John');
    var jack = User('Jack');
    var jill = User('Jill');
    repo.putAll([john, jack, jill]);
    expect(repo.entities.length, 3);

    repo.removeAll([john, jill]);
    expect(repo.entities.length, 1);
    expect(repo.entities[0], jack);
  });

  test('Clear repo', () {
    repo.putAll([User('John'), User('Jack'), User('Jill')]);
    expect(repo.entities.length, 3);

    repo.clear();
    expect(repo.entities.isEmpty, true);
  });

  test('Get all creates copy of entities', () {
    var john = User('John');
    repo.putAll([john, User('Jack'), User('Jill')]);
    var oldList = repo.entities;
    expect(oldList.length, 3);

    repo.remove(john);
    expect(oldList.length, 3);
    expect(oldList.contains(john), true);

    var newList = repo.entities;
    expect(newList.length, 2);
    expect(newList.contains(john), false);
  });

  test('No duplicate ids', () {
    var john = User('John');
    repo.put(john);
    expect(john.id, 0);

    var jack = User('Jack');
    repo.remove(john);
    repo.put(jack);
    expect(jack.id, 1);
  });
}

class User extends Entity {
  String name;

  User(this.name);

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(map['name']);
  }
}
