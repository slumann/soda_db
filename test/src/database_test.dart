import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:soda_db/soda_db.dart';
import 'package:soda_db/src/meta_data.dart';
import 'package:test/test.dart';

void main() async {
  final filePath = 'test/tmp/test.db';
  final file = File(filePath);
  Database db;

  MetaData readMetaFile() {
    var data = File('${filePath}_meta').readAsStringSync();
    return MetaData.fromMap(json.decode(data));
  }

  void writeMetaFile(MetaData metaData) {
    var metaFile = File('${filePath}_meta');
    metaFile.writeAsStringSync(json.encode(metaData));
  }

  String createRandomString(int size) {
    var buffer = StringBuffer();
    var min = 97;
    var max = 122;
    var rnd = Random();
    for (var i = 0; i < size; i++) {
      buffer.writeCharCode(min + rnd.nextInt(max - min));
    }
    return buffer.toString();
  }

  setUp(() async {
    var tmpDir = File('test/tmp/');
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
    file.createSync(recursive: true);
    db = Database(file);
  });

  tearDown(() async {
    db.close();
    File('test/tmp/').deleteSync(recursive: true);
  });

  group('MetaData tests', () {
    test('Write on initialization', () async {
      await db.open();
      var metaData = readMetaFile();
      expect(metaData.dbVersion, 1);
      expect(metaData.createNextId, 0);
      expect(metaData.freePages, []);
      expect(metaData.groups, {});
    });

    test('Read existing MetaData', () async {
      var metaData = MetaData();
      metaData.createNextId;
      metaData.freePages = [512, 1024];
      writeMetaFile(metaData);

      await db.open();
      metaData = readMetaFile();

      expect(metaData.createNextId, 1);
      expect(metaData.freePages, [512, 1024]);
    });

    test('Write entries', () async {
      await db.open();
      await db.writeEntity('test 1', null, 'some test data');
      await db.writeEntity('test 2', null, 'some more test data');
      var metaData = readMetaFile();

      expect(metaData.groups.containsKey('test 1'), true);
      var groupTest1 = metaData.groups['test 1'];
      expect(groupTest1.containsKey('0'), true);
      expect(groupTest1['0'].pages, [0]);
      expect(metaData.groups.containsKey('test 2'), true);
      var groupTest2 = metaData.groups['test 2'];
      expect(groupTest2.containsKey('1'), true);
      expect(groupTest2['1'].pages, [512]);
    });

    test('Delete entry', () async {
      await db.open();
      var id = await db.writeEntity('test', null, 'some test data');
      await db.writeEntity('test', null, 'some more test data');
      await db.deleteEntity('test', id);
      var metaData = readMetaFile();

      expect(metaData.groups['test'][id.toString()], null);
      expect(metaData.freePages.contains(0), true);
    });

    test('Reuse free pages', () async {
      var metaData = MetaData();
      metaData.freePages = [512, 1024];
      writeMetaFile(metaData);

      await db.open();
      await db.writeEntity('test', null, 'some test data');
      metaData = readMetaFile();

      expect(metaData.freePages, [512]);
    });
  });

  group('Database not opened', () {
    test('on write', () async {
      StateError error;
      try {
        await db.writeEntity('test', null, 'data');
      } on StateError catch (e) {
        error = e;
      }
      expect(error.message, 'Database not opened');
    });

    test('on read', () async {
      StateError error;
      try {
        await db.readEntity('test', 1);
      } on StateError catch (e) {
        error = e;
      }
      expect(error.message, 'Database not opened');
    });

    test('on readAll', () async {
      StateError error;
      try {
        await db.readGroup('test');
      } on StateError catch (e) {
        error = e;
      }
      expect(error.message, 'Database not opened');
    });

    test('on delete', () async {
      StateError error;
      try {
        await db.deleteEntity('test', 1);
      } on StateError catch (e) {
        error = e;
      }
      expect(error.message, 'Database not opened');
    });
  });

  group('Functional tests', () {
    setUp(() async {
      await db.open();
    });

    test('Write new entry creates id', () async {
      var idFirst = await db.writeEntity('test', null, 'some test data');
      var idSecond = await db.writeEntity('test', null, 'some more test data');

      expect(idFirst, 0);
      expect(idSecond, 1);
    });

    test('Write entry smaller than one page', () async {
      var data = createRandomString(128);
      var id = await db.writeEntity('test', null, data);
      var entry = await db.readEntity('test', id);

      expect(entry, data);
    });

    test('Write entry exactly one page', () async {
      var data = createRandomString(512);
      var id = await db.writeEntity('test', null, data);
      var entry = await db.readEntity('test', id);

      expect(entry, data);
    });

    test('Write entry larger than one page', () async {
      var data = createRandomString(2300);
      var id = await db.writeEntity('test', null, data);
      var entry = await db.readEntity('test', id);

      expect(entry, data);
    });

    test('Update entry within one page', () async {
      var data = createRandomString(128);
      var id = await db.writeEntity('test', null, data);
      data = data.substring(0, 64);
      await db.writeEntity('test', id, data);
      var entry = await db.readEntity('test', id);

      expect(entry, data);
    });

    test('Update entry increments used pages', () async {
      var data = createRandomString(512);
      var id = await db.writeEntity('test', null, data);
      data += 'someadditionaltext';
      await db.writeEntity('test', id, data);
      var entry = await db.readEntity('test', id);

      expect(entry, data);
    });

    test('Update entry decrements used pages', () async {
      var data = createRandomString(1024);
      var id = await db.writeEntity('test', null, data);
      data = data.substring(0, 300);
      await db.writeEntity('test', id, data);
      var entry = await db.readEntity('test', id);

      expect(entry, data);
    });

    test('Read null id', () async {
      expect(null, await db.readEntity('test', null));
    });

    test('Read non existing repository', () async {
      expect(null, await db.readEntity('test', 0));
    });

    test('Read non existing id', () async {
      await db.writeEntity('test', null, 'some tet data');
      expect(null, await db.readEntity('test', 1));
    });

    test('ReadAll non existing repository', () async {
      expect({}, await db.readGroup('test'));
    });

    test('ReadAll empty repository', () async {
      var id = await db.writeEntity('test', null, 'some test data');
      await db.deleteEntity('test', id);
      expect({}, await db.readGroup('test'));
    });

    test('ReadAll non empty repository', () async {
      var idFirst = await db.writeEntity('test', null, 'some test data');
      var idSecond = await db.writeEntity('test', null, 'some more test data');

      var repo = await db.readGroup('test');

      expect(repo.length, 2);
      expect(repo[idFirst], 'some test data');
      expect(repo[idSecond], 'some more test data');
    });

    test('Delete entry', () async {
      var id = await db.writeEntity('test', null, 'some test data');
      expect(true, await db.deleteEntity('test', id));
    });

    test('Delete non existing entry', () async {
      await db.writeEntity('test', null, 'some test data');
      expect(false, await db.deleteEntity('test', 1));
    });

    test('Delete from non existing repository', () async {
      expect(false, await db.deleteEntity('test', 0));
    });
  });

  group('Concurrent access', () {
    setUp(() async {
      await db.open();
    });

    test('Parallel access', () {
      // This should not throw any FileSystemExceptions
      db.writeEntity('test', null, 'some test data');
      db.readEntity('test', 0);
      db.writeEntity('test', null, 'some test data');
      db.readEntity('test', 1);
      db.deleteEntity('test', 0);
      db.readGroup('test');
    });

    test('Sequential I/O', () async {
      db.writeEntity('test', null, 'some test data');
      db.writeEntity('test', null, 'some more test data');
      var entry = db.readEntity('test', 0);
      await db.deleteEntity('test', 0);
      var allEntries = db.readGroup('test');

      expect(await entry, 'some test data');
      expect(await allEntries, {1: 'some more test data'});
    });
  });
}
