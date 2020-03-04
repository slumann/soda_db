![build](https://github.com/slumann/soda_db/workflows/Dart%20CI/badge.svg?branch=master)

SodaDB is a lightweight and simple to use object-oriented storage for Dart and Flutter applications,
with type-safe access on entities.

Written in pure Dart with no third party dependencies.

## Usage

### Define entity classes and type adapters
Define your entity classes using SodaDB's SodaEntity mixin. Provide TypeAdapters for the necessary 
de-/serializer methods, which might be written by hand or generated by frameworks like 
json_serializable. 

```dart
class User with SodaEntity {
  String firstName;
  String lastName;

  User(this.firstName, this.lastName);

  User.fromMap(Map<String, dynamic> map) {
    firstName = map['firstName'];
    lastName = map['name'];
  }

  Map<String, Object> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class UserAdapter extends TypeAdapter<User> {
  // Provide a serialized version of your entity.
  // A convenient way would be to use JSON.
  @override
  String serialize(User entity) {
    return jsonEncode(entity);
  }

  // Deserialize your entity from the String
  // generated by serialize(User entity).
  @override
  User deserialize(String data) {
    return User.fromMap(jsonDecode(data));
  }
}
```

### Use storage and repositories
Storage is designed as singleton and can be accessed by the global 'storage' variable.
Repositories are used to organize entity types.

```dart
void main() async {
  // Register adapter for type 'User'.
  storage.register(UserAdapter());

  // Open/create storage in path './example'.
  await storage.open('./example');

  // Create a user instance.
  var john = User('John', 'McClaine');

  // Obtain repository 'users' from storage.
  // Provide type information to the get method or explicitly
  // type the users variable to help the compiler determine the correct type.
  var users = storage.get<User>('users');

  // Save user john to repository.
  await users.put(john);

  // Auto created ID for new entities.
  print(john.id); // prints '0'

  // Update existing entity.
  john.lastName = 'McClane';
  await users.put(john);

  // Read existing entities.
  var user = await users.get(0);

  // Remove user from repository.
  await users.remove(user);

  // Close storage before the application finishes
  // to ensure all operations get finished.
  await storage.close();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/slumann/soda_db/issues
