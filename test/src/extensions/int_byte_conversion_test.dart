import 'package:soda_db/src/extensions/int_byte_conversion.dart';
import 'package:test/test.dart';

void main() {
  group('ints to bytes', () {
    test('0 to bytes', () {
      var result = 0.toBytes();
      expect(result, equals('\x00\x00\x00\x00'));
    });

    test('255 to bytes', () {
      var result = 255.toBytes();
      expect(result, equals('\x00\x00\x00\xff'));
    });

    test('256 to bytes', () {
      var result = 256.toBytes();
      expect(result, equals('\x00\x00\x01\x00'));
    });

    test('0xffffffff to bytes', () {
      var result = 0xffffffff.toBytes();
      expect(result, equals('\xff\xff\xff\xff'));
    });
  });

  group('bytes to ints', () {
    test('String to short', () {
      ArgumentError error;
      try {
        '\x00\x00'.toInt();
      } on ArgumentError catch (e) {
        error = e;
      }
      expect(error.message, equals('Expected String of length 4.'));
    });

    test('bytes to 0', () {
      var result = '\x00\x00\x00\x00'.toInt();
      expect(result, equals(0));
    });

    test('bytes to 255', () {
      var result = '\x00\x00\x00\xff'.toInt();
      expect(result, equals(255));
    });

    test('bytes to 256', () {
      var result = '\x00\x00\x01\x00'.toInt();
      expect(result, equals(256));
    });

    test('bytes to 0xffffffffffffffff', () {
      var result = '\xff\xff\xff\xff'.toInt();
      expect(result, equals(0xffffffff));
    });
  });
}
