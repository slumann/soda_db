import 'dart:typed_data';

extension IntToByteConversion on int {
  String toBytes() {
    var bytes = Uint8List(4);
    bytes[0] = this >> 24;
    bytes[1] = this >> 16;
    bytes[2] = this >> 8;
    bytes[3] = this;
    return String.fromCharCodes(bytes);
  }
}

extension ByteToIntConversion on String {
  int toInt() {
    if (this.length != 4) {
      throw ArgumentError('Expected String of length 4.');
    }

    return this.codeUnitAt(0) << 24 ^
        this.codeUnitAt(1) << 16 ^
        this.codeUnitAt(2) << 8 ^
        this.codeUnitAt(3);
  }
}
