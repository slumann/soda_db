import 'dart:convert';

import 'package:soda_db/src/meta_data.dart';
import 'package:test/test.dart';

void main() {
  final jsonData =
      '{"dbVersion":1,"nextId":2,"freePages":[512,1024],"repositories":'
      '{"users":{"0":[1400,1800],"1":[2000]},'
      '"animals":{"0":[2000],"1":[2400,2600]}}}';

  test('Serialize meta', () {
    var meta = MetaData();
    meta.createNextId;
    meta.createNextId;
    meta.freePages.addAll([512, 1024]);
    meta.repositories['users'] = {
      '0': [1400, 1800],
      '1': [2000]
    };
    meta.repositories['animals'] = {
      '0': [2000],
      '1': [2400, 2600]
    };

    expect(json.encode(meta), jsonData);
  });

  test('Deserialize meta', () {
    var meta = MetaData.fromMap(json.decode(jsonData));
    expect(meta.dbVersion, 1);
    expect(meta.createNextId, 2);
    expect(meta.freePages.length, 2);
    expect(meta.freePages.contains(512), true);
    expect(meta.freePages.contains(1024), true);

    expect(meta.repositories.containsKey('users'), true);
    expect(meta.repositories['users'].length, 2);
    expect(meta.repositories['users']['0'][0], 1400);
    expect(meta.repositories['users']['0'][1], 1800);

    expect(meta.repositories.containsKey('animals'), true);
    expect(meta.repositories['animals'].length, 2);
    expect(meta.repositories['animals']['0'][0], 2000);
    expect(meta.repositories['animals']['1'][0], 2400);
    expect(meta.repositories['animals']['1'][1], 2600);
  });

  test('Get next ID', () {
    var meta = MetaData();
    expect(meta.createNextId, 0);
    expect(meta.createNextId, 1);
  });
}
