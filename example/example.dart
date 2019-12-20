import 'package:soda_db/soda_db.dart';

void main() async {
  // Register type 'User' in repository named 'users'.
  // Provide a builder method to re-create User instances from JSON maps.
  storage.register<User>('users', (map) => User.fromMap(map));

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

class User with SodaEntity {
  String firstName;
  String lastName;

  User(this.firstName, this.lastName);

  // Provide a builder method to re-create your entities
  // from JSON maps.
  User.fromMap(Map<String, dynamic> map) {
    firstName = map['firstName'];
    lastName = map['name'];
  }

  // Provide toJson method to serialize your entities
  // as JSON maps.
  @override
  Map<String, Object> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}