import 'package:soda_db/src/convert/binary_writer.dart';
import 'package:soda_db/src/convert/data_type.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  BinaryWriter writer;

  String resultWithoutVersion() {
    return writer.toString().substring(6);
  }

  setUp(() {
    writer = BinaryWriter();
  });

  group('Encode data length', () {
    test(('Encode 0x0'), () {
      expect(writer.encodeLength(0x0), equals('\x00\x00\x00\x00'));
    });

    test(('Encode 0xff'), () {
      expect(writer.encodeLength(0xff), equals('\x00\x00\x00\xff'));
    });

    test(('Encode 0xffff'), () {
      expect(writer.encodeLength(0xffff), equals('\x00\x00\xff\xff'));
    });

    test(('Encode 0xffffff'), () {
      expect(writer.encodeLength(0xffffff), equals('\x00\xff\xff\xff'));
    });

    test(('Encode 0xffffffff'), () {
      expect(writer.encodeLength(0xffffffff), equals('\xff\xff\xff\xff'));
    });

    test('Invalid length', () {
      ArgumentError error;
      try {
        writer.encodeLength(0x1ffffffff);
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error.message,
          equals('Max supported data length is ${0xffffffff.toString()}'));
    });
  });

  group('Write data version', () {
    test('Write default value', () {
      var expected = '${DataType.string}'
          '\x00\x00\x00\x011';
      expect(writer.toString(), equals(expected));
    });

    test('Write custom value', () {
      writer = BinaryWriter(dataVersion: 2);
      var expected = '${DataType.string}'
          '\x00\x00\x00\x012';
      expect(writer.toString(), equals(expected));
    });
  });

  group('Write int', () {
    test('Negative', () {
      var expected = '${DataType.int}'
          '\xff\xff\xff\xff\xff\xff\xff\xff';
      writer.write(-1);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Zero', () {
      var expected = '${DataType.int}'
          '\x00\x00\x00\x00\x00\x00\x00\x00';
      writer.write(0);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Positive', () {
      var expected = '${DataType.int}'
          '\x00\x00\x00\x00\x00\x00\x00\xff';
      writer.write(255);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write double', () {
    test('Negative', () {
      var expected = '${DataType.double}'
          '¿à\x00\x00\x00\x00\x00\x00';
      writer.write(-0.50);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Zero', () {
      var expected = '${DataType.double}'
          '\x00\x00\x00\x00\x00\x00\x00\x00';
      writer.write(0.000);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Positive', () {
      var expected = '${DataType.double}'
          '@\x00\x00\x00\x00\x00\x00\x00';
      writer.write(2.0);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write bool', () {
    test('true', () {
      var expected = '${DataType.bool}1';
      writer.write(true);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('false', () {
      var expected = '${DataType.bool}0';
      writer.write(false);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write string', () {
    test('Empty', () {
      var input = '';
      var expected = '${DataType.string}'
          '\x00\x00\x00\x00'
          '$input';
      writer.write('');
      expect(resultWithoutVersion(), equals(expected));
    });

    test('4 bytes', () {
      var input = 'test';
      var expected = '${DataType.string}'
          '\x00\x00\x00\x04'
          '$input';
      writer.write(input);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('256 bytes', () {
      var input = createRandomString(256);
      var expected = '${DataType.string}'
          '\x00\x00\x01\x00'
          '$input';
      writer.write(input);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write list', () {
    test('Empty', () {
      var list = <String>[];
      var expected = '${DataType.list}'
          '\x00\x00\x00\x00';
      writer.write(list);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Non empty', () {
      var list = ['one', 'two', 'three'];
      var expected = '${DataType.list}'
          '\x00\x00\x00\x03'
          '${DataType.string}\x00\x00\x00\x03one'
          '${DataType.string}\x00\x00\x00\x03two'
          '${DataType.string}\x00\x00\x00\x05three';
      writer.write(list);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Nested', () {
      var listOne = ['one'];
      var listTwo = [listOne];
      var expected = '${DataType.list}'
          '\x00\x00\x00\x01'
          '${DataType.list}'
          '\x00\x00\x00\x01'
          '${DataType.string}\x00\x00\x00\x03one';
      writer.write(listTwo);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write map', () {
    test('Empty', () {
      var map = <String, String>{};
      var expected = '${DataType.map}'
          '\x00\x00\x00\x00';
      writer.write(map);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Non empty', () {
      var map = {
        'k1': 'v1',
        'k2': 'v2',
      };
      var expected = '${DataType.map}'
          '\x00\x00\x00\x02'
          '${DataType.string}\x00\x00\x00\x02k1'
          '${DataType.string}\x00\x00\x00\x02v1'
          '${DataType.string}\x00\x00\x00\x02k2'
          '${DataType.string}\x00\x00\x00\x02v2';
      writer.write(map);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Nested', () {
      var mapOne = {'k1': 'v1'};
      var mapTwo = {'k2': mapOne};
      var expected = '${DataType.map}'
          '\x00\x00\x00\x01'
          '${DataType.string}\x00\x00\x00\x02k2'
          '${DataType.map}'
          '\x00\x00\x00\x01'
          '${DataType.string}\x00\x00\x00\x02k1'
          '${DataType.string}\x00\x00\x00\x02v1';
      writer.write(mapTwo);
      expect(resultWithoutVersion(), equals(expected));
    });
  });

  group('Write set', () {
    test('Empty', () {
      var set = <String>{};
      var expected = '${DataType.set}'
          '\x00\x00\x00\x00';
      writer.write(set);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('Non empty', () {
      var set = {'one', 'two'};
      var expected = '${DataType.set}'
          '\x00\x00\x00\x02'
          '${DataType.string}\x00\x00\x00\x03one'
          '${DataType.string}\x00\x00\x00\x03two';
      writer.write(set);
      expect(resultWithoutVersion(), equals(expected));
    });

    test('No duplicates', () {
      var set = {'one', 'two', 'one'};
      var expected = '${DataType.set}'
          '\x00\x00\x00\x02'
          '${DataType.string}\x00\x00\x00\x03one'
          '${DataType.string}\x00\x00\x00\x03two';
      writer.write(set);
      expect(resultWithoutVersion(), equals(expected));
    });
  });
}
