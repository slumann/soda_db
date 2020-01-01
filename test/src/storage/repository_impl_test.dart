import 'dart:convert';

import 'package:mockito/mockito.dart';
import 'package:soda_db/src/database/database.dart';
import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/repository_impl.dart';
import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:soda_db/src/storage/type_adapter.dart';
import 'package:test/test.dart';

void main() {
  Database mockDB;
  Repository<TestEntity> repo;

  setUp(() {
    mockDB = MockDataBase();
    repo = RepositoryImpl('test', TestEntityAdapter(), mockDB);
  });

  test('Get existing entity', () async {
    when(mockDB.readEntity('test', 0))
        .thenAnswer((_) => Future.value('{"field":"test_data"}'));
    var entity = await repo.get(0);
    expect(entity.id, 0);
    expect(entity.field, 'test_data');
  });

  test('Get non existing entity', () async {
    when(mockDB.readEntity('test', 0)).thenAnswer((_) => Future.value(null));
    var result = await repo.get(0);
    expect(result, null);
  });

  test('GetAll empty group', () async {
    when(mockDB.readGroup('test')).thenAnswer((_) => Future.value({}));
    var result = await repo.getAll();
    expect(result, []);
  });

  test('GetAll non empty group', () async {
    when(mockDB.readGroup('test')).thenAnswer((_) => Future.value({
          0: '{"field":"test_data_one"}',
          1: '{"field":"test_data_two"}',
        }));
    var result = await repo.getAll();

    expect(result.length, 2);
    expect(result[0].field, 'test_data_one');
    expect(result[1].field, 'test_data_two');
  });

  test('Put entity', () async {
    var entity = TestEntity();
    when(mockDB.writeEntity('test', null, jsonEncode(entity)))
        .thenAnswer((_) => Future.value(0));
    await repo.put(entity);
    expect(entity.id, 0);
  });

  test('Remove entity success', () async {
    when(mockDB.deleteEntity('test', 1)).thenAnswer((_) => Future.value(true));
    var entity = TestEntity.withId(1);
    await repo.remove(entity);
    verify(mockDB.deleteEntity('test', 1));
    expect(entity.id, null);
  });

  test('Remove entity fail', () async {
    when(mockDB.deleteEntity('test', 1)).thenAnswer((_) => Future.value(false));
    var entity = TestEntity.withId(1);
    await repo.remove(entity);
    verify(mockDB.deleteEntity('test', 1));
    expect(entity.id, 1);
  });

  test('Clear repository', () async {
    await repo.clear();
    verify(mockDB.deleteGroup('test'));
  });
}

class MockDataBase extends Mock implements Database {}

class TestEntity with SodaEntity {
  var _fakeId;
  String field;

  TestEntity();

  TestEntity.withId(this._fakeId);

  TestEntity.fromJson(Map<String, dynamic> map) {
    field = map['field'];
  }

  @override
  int get id => _fakeId ?? super.id;

  void set id(int value) => _fakeId = value;

  Map<String, Object> toJson() {
    return {'field': field};
  }
}

class TestEntityAdapter extends TypeAdapter<TestEntity> {
  @override
  TestEntity deserialize(String data) {
    return TestEntity.fromJson(jsonDecode(data));
  }

  @override
  String serialize(TestEntity type) {
    return jsonEncode(type);
  }
}
