import 'package:soda_db/src/convert/binary_reader.dart';
import 'package:soda_db/src/convert/binary_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  BinaryWriter writer;
  BinaryReader reader;

  setUp(() {
    writer = BinaryWriter();
  });

  test('Read data version', () {
    reader = BinaryReader(writer.toString());
    expect(reader.dataVersion, equals(1));
  });

  group('Read int', () {
    test('Negative', () {
      writer.write(-12);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(-12));
    });

    test('Zero', () {
      writer.write(0);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(0));
    });

    test('Positive', () {
      writer.write(23);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(23));
    });
  });

  group('Read double', () {
    test('Negative', () {
      writer.write(-12.00);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(-12.0));
    });

    test('Zero', () {
      writer.write(0.000);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(0.0));
    });

    test('Positive', () {
      writer.write(23.1);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(23.1));
    });
  });

  group('Read bool', () {
    test('true', () {
      writer.write(true);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(true));
    });

    test('false', () {
      writer.write(false);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(false));
    });
  });

  group('Read string', () {
    test('Empty', () {
      writer.write('');
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), isEmpty);
    });

    test('Non empty', () {
      var input = createRandomString(128);
      writer.write(input);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(input));
    });
  });

  group('Read list', () {
    test('Empty', () {
      writer.write([]);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals([]));
    });

    test('Non empty', () {
      writer.write(['one', 'two', 'three']);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(['one', 'two', 'three']));
    });

    test('Nested', () {
      writer.write([
        ['1.1', '1.2'],
        ['2.1', '2.2']
      ]);
      reader = BinaryReader(writer.toString());
      expect(
          reader.readNext(),
          equals([
            ['1.1', '1.2'],
            ['2.1', '2.2']
          ]));
    });
  });

  group('Read map', () {
    test('Empty', () {
      writer.write({});
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals({}));
    });

    test('Non empty', () {
      writer.write({
        'k1': 'v1',
        'k2': 'v2',
      });
      reader = BinaryReader(writer.toString());
      expect(
          reader.readNext(),
          equals({
            'k1': 'v1',
            'k2': 'v2',
          }));
    });

    test('Nested', () {
      var mapOne = {'k1': 'v1'};
      var mapTwo = {'k2': mapOne};
      writer.write(mapTwo);
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(mapTwo));
    });
  });

  group('Read set', () {
    test('Empty', () {
      writer.write(<String>{});
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals(<String>{}));
    });

    test('Non empty', () {
      writer.write({'one', 'two'});
      reader = BinaryReader(writer.toString());
      expect(reader.readNext(), equals({'one', 'two'}));
    });
  });
}
