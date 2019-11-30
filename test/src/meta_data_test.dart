import 'dart:convert';

import 'package:soda_db/src/meta_data.dart';
import 'package:test/test.dart';

void main() {
  final jsonData =
      '{"dbVersion":1,"ids":{"users":1},"freePages":[512,1024],"groups":'
      '{"users":{"0":{"lps":128,"pgs":[1400,1800]},"1":{"lps":128,"pgs":[2000]}},'
      '"animals":{"0":{"lps":256,"pgs":[2000]},"1":{"lps":256,"pgs":[2400,2600]}}}}';

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

    expect(json.encode(meta), jsonData);
  });

  test('Deserialize meta', () {
    var meta = MetaData.fromMap(json.decode(jsonData));
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
