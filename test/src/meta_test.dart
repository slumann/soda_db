import 'dart:convert';

import 'package:soda_db/src/meta_data.dart';
import 'package:test/test.dart';

void main() {
  final jsonData =
      '{"dbVersion":1,"nextId":2,"freePages":[512,1024],"dataPages":'
      '{"1":[1400,1800],"2":[2000],"3":[2400,2600],"4":[3000,3200]}}';

  test('Serialize meta', () {
    var meta = MetaData();
    meta.nextId;
    meta.nextId;
    meta.freePages.addAll([512, 1024]);
    meta.dataPages['1'] = [1400, 1800];
    meta.dataPages['2'] = [2000];
    meta.dataPages['3'] = [2400, 2600];
    meta.dataPages['4'] = [3000, 3200];

    expect(json.encode(meta), jsonData);
  });

  test('Deserialize meta', () {
    var meta = MetaData.fromMap(json.decode(jsonData));
    expect(meta.dbVersion, 1);
    expect(meta.nextId, 2);
    expect(meta.freePages.length, 2);
    expect(meta.freePages.contains(512), true);
    expect(meta.freePages.contains(1024), true);

    expect(meta.dataPages.containsKey('1'), true);
    expect(meta.dataPages['1'].length, 2);
    expect(meta.dataPages['1'].contains(1400), true);
    expect(meta.dataPages['1'].contains(1800), true);

    expect(meta.dataPages.containsKey('2'), true);
    expect(meta.dataPages['2'].length, 1);
    expect(meta.dataPages['2'].contains(2000), true);

    expect(meta.dataPages.containsKey('3'), true);
    expect(meta.dataPages['3'].length, 2);
    expect(meta.dataPages['3'].contains(2400), true);
    expect(meta.dataPages['3'].contains(2600), true);

    expect(meta.dataPages.containsKey('4'), true);
    expect(meta.dataPages['4'].length, 2);
    expect(meta.dataPages['4'].contains(3000), true);
    expect(meta.dataPages['4'].contains(3200), true);
  });

  test('Get next ID', () {
    var meta = MetaData();
    expect(meta.nextId, 0);
    expect(meta.nextId, 1);
  });
}
