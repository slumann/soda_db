import 'package:soda_db/src/storage/repository.dart';

import 'test_user.dart';

class UserRepository extends Repository<User> {
  int _idCounter = 0;
  List<User> _data = [];

  @override
  Future<void> clear() {
    _data.clear();
    return Future.value();
  }

  @override
  Future<User> get(int id) {
    return Future.value(_data.where((u) => u.id == id).first);
  }

  @override
  Future<List<User>> getAll() {
    return Future.value(_data);
  }

  @override
  Future<void> put(User entity) {
    entity.id = _idCounter++;
    _data.add(entity);
    return Future.value();
  }

  @override
  Future<bool> remove(User entity) {
    var i = _data.indexWhere((u) => u.id == entity.id);
    if (i >= 0) {
      _data.removeAt(i);
    }
    return Future.value(i >= 0);
  }

  @override
  List<int> getEntityIds() {
    return _data.map((u) => u.id).toList();
  }
}
