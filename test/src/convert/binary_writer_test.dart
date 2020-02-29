import 'package:soda_db/src/convert/binary_writer.dart';
import 'package:soda_db/src/convert/data_type.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  BinaryWriter writer;

  String resultWithoutVersion() {
    return writer.toString().substring(2);
  }

  String intsAsChars(List<int> ints) {
    return String.fromCharCodes(ints);
  }

  setUp(() {
    writer = BinaryWriter();
  });

  group('Write data version', () {
    test('Write default value', () {
      var expected = intsAsChars([DataType.int | 0x00, 0x01]);
      expect(writer.toString(), equals(expected));
    });

    test('Write custom value', () {
      writer = BinaryWriter(dataVersion: 2);
      var expected = intsAsChars([DataType.int | 0x00, 0x02]);
      expect(writer.toString(), equals(expected));
    });
  });

  test('Write null value', () {
    writer.write(null);
    expect(resultWithoutVersion(), intsAsChars([DataType.nil]));
  });

  group('Write int', () {
    test('Zero', () {
      var expected = intsAsChars([DataType.int | 0x00, 0]);
      writer.write(0x00);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('One byte', () {
      var expected = intsAsChars([DataType.int | 0x00, 255]);
      writer.write(0xff);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Two bytes', () {
      var expected = intsAsChars([DataType.int | 0x01, 255, 255]);
      writer.write(0xffff);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Three bytes', () {
      var expected = intsAsChars([DataType.int | 0x02, 255, 255, 255]);
      writer.write(0xffffff);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Four bytes', () {
      var expected = intsAsChars([DataType.int | 0x03, 255, 255, 255, 255]);
      writer.write(0xffffffff);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Five bytes', () {
      var expected =
          intsAsChars([DataType.int | 0x04, 255, 255, 255, 255, 255]);
      writer.write(0xffffffffff);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Six bytes', () {
      var expected =
          intsAsChars([DataType.int | 0x05, 255, 255, 255, 255, 255, 255]);
      writer.write(0xffffffffffff);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Seven bytes', () {
      var expected =
          intsAsChars([DataType.int | 0x06, 255, 255, 255, 255, 255, 255, 255]);
      writer.write(0xffffffffffffff);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Eight bytes', () {
      var expected = intsAsChars(
          [DataType.int | 0x07, 255, 255, 255, 255, 255, 255, 255, 255]);
      writer.write(0xffffffffffffffff);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write double', () {
    test('Zero', () {
      var expected = intsAsChars([DataType.double | 0x00, 0]);
      writer.write(0.0);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Negative', () {
      var expected = intsAsChars([
        DataType.double | 0x07,
        0xbf,
        0xf0,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00
      ]);
      writer.write(-1.0);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Positive', () {
      var expected = intsAsChars([
        DataType.double | 0x07,
        0x3f,
        0xf0,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00
      ]);
      writer.write(1.0);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write bool', () {
    test('true', () {
      var expected = intsAsChars([DataType.bool | 0x00, 0x01]);
      writer.write(true);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('false', () {
      var expected = intsAsChars([DataType.bool | 0x00, 0x00]);
      writer.write(false);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write string', () {
    test('Empty', () {
      var expected = intsAsChars([DataType.string | 0x00, 0x00]);
      writer.write('');
      expect(resultWithoutVersion(), equals(expected));
    });

    test('4 bytes', () {
      var input = 'test';
      var expected = intsAsChars([DataType.string | 0x00, 0x04]) + input;
      writer.write(input);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('256 bytes', () {
      var input = createRandomString(256);
      var expected = intsAsChars([DataType.string | 0x01, 0x01, 0x00]) + input;
      writer.write(input);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write list', () {
    test('Empty', () {
      var list = <String>[];
      var expected = intsAsChars([DataType.list | 0x00, 0x00]);
      writer.write(list);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Non empty', () {
      var list = ['one', 'two', 'three'];
      var expected = intsAsChars([DataType.list | 0x00, 0x03]) +
          intsAsChars([DataType.string | 0x00, 0x03]) +
          'one' +
          intsAsChars([DataType.string | 0x00, 0x03]) +
          'two' +
          intsAsChars([DataType.string | 0x00, 0x05]) +
          "three";
      writer.write(list);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Nested', () {
      var listOne = ['one'];
      var listTwo = [listOne];
      var expected = intsAsChars([DataType.list | 0x00, 0x01]) +
          intsAsChars([DataType.list | 0x00, 0x01]) +
          intsAsChars([DataType.string | 0x00, 0x03]) +
          'one';
      writer.write(listTwo);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write map', () {
    test('Empty', () {
      var map = <String, String>{};
      var expected = intsAsChars([DataType.map | 0x00, 0x00]);
      writer.write(map);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Non empty', () {
      var map = {
        'k1': 'v1',
        'k2': 'v2',
      };
      var expected = intsAsChars([DataType.map | 0x00, 0x02]) +
          intsAsChars([DataType.string | 0x00, 0x02]) +
          'k1' +
          intsAsChars([DataType.string | 0x00, 0x02]) +
          'v1' +
          intsAsChars([DataType.string | 0x00, 0x02]) +
          'k2' +
          intsAsChars([DataType.string | 0x00, 0x02]) +
          'v2';
      writer.write(map);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Nested', () {
      var mapOne = {'k1': 'v1'};
      var mapTwo = {'k2': mapOne};
      var expected = intsAsChars([DataType.map | 0x00, 0x01]) +
          intsAsChars([DataType.string | 0x00, 0x02]) +
          'k2' +
          intsAsChars([DataType.map | 0x00, 0x01]) +
          intsAsChars([DataType.string | 0x00, 0x02]) +
          'k1' +
          intsAsChars([DataType.string | 0x00, 0x02]) +
          'v1';
      writer.write(mapTwo);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write set', () {
    test('Empty', () {
      var set = <String>{};
      var expected = intsAsChars([DataType.set | 0x00, 0x00]);
      writer.write(set);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Non empty', () {
      var set = {'one', 'two'};
      var expected = intsAsChars([DataType.set | 0x00, 0x02]) +
          intsAsChars([DataType.string | 0x00, 0x03]) +
          'one' +
          intsAsChars([DataType.string | 0x00, 0x03]) +
          'two';
      writer.write(set);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('No duplicates', () {
      var set = {'one', 'two', 'one'};
      var expected = intsAsChars([DataType.set | 0x00, 0x02]) +
          intsAsChars([DataType.string | 0x00, 0x03]) +
          'one' +
          intsAsChars([DataType.string | 0x00, 0x03]) +
          'two';
      writer.write(set);
      expect(resultWithoutVersion(), equals(expected));
    });
  });
}
