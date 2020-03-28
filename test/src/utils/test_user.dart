import 'package:soda_db/soda_db.dart';
import 'package:soda_db/src/convert/binary_reader.dart';
import 'package:soda_db/src/convert/binary_writer.dart';

class User with SodaEntity {
  String firstName;
  String lastName;
  DateTime birthday;
  String eMail;

  User();

  User.withData(this.firstName, this.lastName, this.birthday, this.eMail);
}

class UserAdapter extends TypeAdapter<User> {
  @override
  User deserialize(String data) {
    var reader = BinaryReader(data);
    var user = User();
    user.firstName = reader.readNext();
    user.lastName = reader.readNext();
    user.birthday = DateTime.fromMillisecondsSinceEpoch(reader.readNext());
    user.eMail = reader.readNext();
    return user;
  }

  @override
  String serialize(User entity) {
    var writer = BinaryWriter()
      ..write(entity.firstName)
      ..write(entity.lastName)
      ..write(entity.birthday.millisecondsSinceEpoch)
      ..write(entity.eMail);
    return writer.toString();
  }
}
