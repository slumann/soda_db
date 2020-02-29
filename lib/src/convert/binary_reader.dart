import 'dart:typed_data';

import 'package:soda_db/src/convert/data_type.dart';

class BinaryReader {
  final String _data;
  int _pos;
  int _dataVersion;

  BinaryReader(this._data) : _pos = 0 {
    _dataVersion = readNext();
  }

  int get dataVersion => _dataVersion;

  dynamic readNext() {
    var typeInfo = _readBytes(1).codeUnitAt(0);
    var type = typeInfo & 0xf8;
    var byteCount = (typeInfo & 0x07) + 1;
    switch (type) {
      case DataType.nil:
        return null;
      case DataType.int:
        return _readInt(byteCount);
      case DataType.double:
        return _readDouble(byteCount);
      case DataType.bool:
        return _readBool();
      case DataType.list:
        return _readList(byteCount);
      case DataType.set:
        return _readSet(byteCount);
      case DataType.map:
        return _readMap(byteCount);
      case DataType.string:
      default:
        return _readString(byteCount);
    }
  }

  int _readInt(int byteCount) {
    return _readNum(byteCount).getInt64(0);
  }

  double _readDouble(int byteCount) {
    return _readNum(byteCount).getFloat64(0);
  }

  ByteData _readNum(int byteCount) {
    var bytes = _readBytes(byteCount);
    var data = ByteData(8);
    for (var i = 8 - byteCount; i < 8; i++) {
      data.setInt8(i, bytes.codeUnitAt(i - (8 - byteCount)));
    }
    return data;
  }

  bool _readBool() {
    return _readBytes(1).codeUnitAt(0) == 1;
  }

  List _readList(int byteCount) {
    var length = _readInt(byteCount);
    var list = [];
    for (var i = 0; i < length; i++) {
      list.add(readNext());
    }
    return list;
  }

  Set _readSet(int byteCount) {
    var length = _readInt(byteCount);
    var set = <dynamic>{};
    for (var i = 0; i < length; i++) {
      set.add(readNext());
    }
    return set;
  }

  Map _readMap(int byteCount) {
    var length = _readInt(byteCount);
    var map = {};
    for (var i = 0; i < length; i++) {
      map[readNext()] = readNext();
    }
    return map;
  }

  String _readString(int byteCount) {
    return _readBytes(_readInt(byteCount));
  }

  String _readBytes(int length) => _data.substring(_pos, _pos += length);
}
