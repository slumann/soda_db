import 'package:soda_db/src/storage/soda_entity.dart';
import 'package:test/test.dart';

void main() {
  SodaEntity a1;
  SodaEntity a2;
  SodaEntity b;
  EntityC c;

  setUp(() {
    a1 = EntityA();
    a2 = EntityA();
    b = EntityB();
    c = EntityC();
  });

  test('Identical objects', () {
    a1.id = 0;
    expect(a1 == a1, true);
  });

  test('Same type, other ID', () {
    a1.id = 0;
    a2.id = 1;
    expect(a1 == a2, false);
  });

  test('Same type, same ID', () {
    a1.id = 0;
    a2.id = 0;
    expect(a1 == a2, true);
  });

  test('Other type, same ID', () {
    a1.id = 0;
    b.id = 0;
    expect(a1 == b, false);
  });

  test('Other type, other ID', () {
    a1.id = 0;
    b.id = 1;
    expect(a1 == b, false);
  });

  test('Foreign type, same ID', () {
    a1.id = 0;
    c.id = 0;
    expect(a1 == c, false);
  });
}

class EntityA with SodaEntity {}

class EntityB with SodaEntity {}

class EntityC {
  int id;
}
