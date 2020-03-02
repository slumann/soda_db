import 'package:soda_db/src/convert/binary_writer.dart';
import 'package:soda_db/src/database/meta_data.dart';
import 'package:test/test.dart';

void main() {
  var expected = BinaryWriter()
    ..write(1)
    ..write({'users': 1})
    ..write([512, 1024])
    ..write({
      'users': {
        '0': MetaEntity(128, [1400, 1800]),
        '1': MetaEntity(128, [2000])
      },
      'animals': {
        '0': MetaEntity(256, [2000]),
        '1': MetaEntity(256, [2400, 2600])
      }
    });

  test('Serialze MetaEntity', () {
    var expectedEntity = BinaryWriter();
    expectedEntity..write(512)..write([0, 1024]);

    var entity = MetaEntity(512, [0, 1024]);
    expect(entity.toString(), equals(expectedEntity.toString()));
  });

  test('Serialize meta', () {
    var meta = MetaData();
    meta.createId('users');
    meta.createId('users');
    meta.freePages.addAll([512, 1024]);
    meta.groups['users'] = {
      '0': MetaEntity(128, [1400, 1800]),
      '1': MetaEntity(128, [2000])
    };
    meta.groups['animals'] = {
      '0': MetaEntity(256, [2000]),
      '1': MetaEntity(256, [2400, 2600])
    };

    expect(meta.toString(), equals(expected.toString()));
  });

  test('Deserialize meta', () {
    var meta = MetaData.fromString(expected.toString());
    expect(meta.dbVersion, 1);
    expect(meta.createId('users'), 2);
    expect(meta.createId('animals'), 0);
    expect(meta.freePages.length, 2);
    expect(meta.freePages.contains(512), true);
    expect(meta.freePages.contains(1024), true);

    expect(meta.groups.containsKey('users'), true);
    expect(meta.groups['users'].length, 2);
    expect(meta.groups['users']['0'].pages, [1400, 1800]);
    expect(meta.groups['users']['0'].lastPageSize, 128);
    expect(meta.groups['users']['1'].pages, [2000]);
    expect(meta.groups['users']['1'].lastPageSize, 128);

    expect(meta.groups.containsKey('animals'), true);
    expect(meta.groups['animals'].length, 2);
    expect(meta.groups['animals']['0'].pages, [2000]);
    expect(meta.groups['animals']['0'].lastPageSize, 256);
    expect(meta.groups['animals']['1'].pages, [2400, 2600]);
    expect(meta.groups['animals']['1'].lastPageSize, 256);
  });

  test('Get next ID', () {
    var meta = MetaData();
    expect(meta.createId('users'), 0);
    expect(meta.createId('users'), 1);
    expect(meta.createId('animals'), 0);
  });
}
