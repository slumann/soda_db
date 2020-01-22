import 'dart:typed_data';

import 'package:soda_db/src/convert/data_type.dart';

class BinaryReader {
  final String _data;
  int _pos;
  int _dataVersion;

  BinaryReader(this._data) : _pos = 0 {
    _dataVersion = read();
  }

  int get dataVersion => _dataVersion;

  dynamic read() {
    var type = _readBytes(1);
    if (type == DataType.int) {
      var bytes = _readBytes(8);
      var data = ByteData(8);
      for (var i = 0; i < 8; i++) {
        data.setInt8(i, bytes.codeUnitAt(i));
      }
      return data.getInt64(0);
    } else if (type == DataType.double) {
      var bytes = _readBytes(8);
      var data = ByteData(8);
      for (var i = 0; i < 8; i++) {
        data.setInt8(i, bytes.codeUnitAt(i));
      }
      return data.getFloat64(0);
    } else if (type == DataType.bool) {
      return _readBytes(1) == '1';
    } else if (type == DataType.string) {
      var length = _decodeLength(_readBytes(4));
      return _readBytes(length);
    } else if (type == DataType.list) {
      var length = _decodeLength(_readBytes(4));
      var list = [];
      for (var i = 0; i < length; i++) {
        list.add(read());
      }
      return list;
    } else if (type == DataType.map) {
      var length = _decodeLength(_readBytes(4));
      var map = {};
      for (var i = 0; i < length; i++) {
        map[read()] = read();
      }
      return map;
    } else if (type == DataType.set) {
      var length = _decodeLength(_readBytes(4));
      var set = <dynamic>{};
      for (var i = 0; i < length; i++) {
        set.add(read());
      }
      return set;
    }
  }

  String _readBytes(int length) => _data.substring(_pos, _pos += length);

  int _decodeLength(String encoded) {
    var bytes = ByteData(4);
    for (var i = 0; i < 4; i++) {
      bytes.setUint8(i, encoded.codeUnitAt(i));
    }
    return bytes.getUint32(0);
  }
}

void main() {
  var bOut = ByteData(8)..setFloat64(0, 2.0);
  var enc = String.fromCharCodes(bOut.buffer.asUint8List());
  print(enc);

  var bIn = ByteData(8);
  for (var i = 0; i < 8; i++) {
    bIn.setInt8(i, enc.codeUnitAt(i));
  }
  print(bIn.getFloat64(0));
}
