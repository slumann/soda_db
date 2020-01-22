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
    var type = _readBytes(1);
    switch (type) {
      case DataType.int:
        return _readInt();
      case DataType.double:
        return _readDouble();
      case DataType.bool:
        return _readBool();
      case DataType.list:
        return _readList();
      case DataType.set:
        return _readSet();
      case DataType.map:
        return _readMap();
      case DataType.string:
      default:
        return _readString();
    }
  }

  int _readInt() {
    return _readNum().getInt64(0);
  }

  double _readDouble() {
    return _readNum().getFloat64(0);
  }

  ByteData _readNum() {
    var bytes = _readBytes(8);
    var data = ByteData(8);
    for (var i = 0; i < 8; i++) {
      data.setInt8(i, bytes.codeUnitAt(i));
    }
    return data;
  }

  bool _readBool() {
    return _readBytes(1) == '1';
  }

  List _readList() {
    var length = _readLength();
    var list = [];
    for (var i = 0; i < length; i++) {
      list.add(readNext());
    }
    return list;
  }

  Set _readSet() {
    var length = _readLength();
    var set = <dynamic>{};
    for (var i = 0; i < length; i++) {
      set.add(readNext());
    }
    return set;
  }

  Map _readMap() {
    var length = _readLength();
    var map = {};
    for (var i = 0; i < length; i++) {
      map[readNext()] = readNext();
    }
    return map;
  }

  String _readString() {
    return _readBytes(_readLength());
  }

  String _readBytes(int length) => _data.substring(_pos, _pos += length);

  int _readLength() {
    var bytes = _readBytes(4);
    var data = ByteData(4);
    for (var i = 0; i < 4; i++) {
      data.setUint8(i, bytes.codeUnitAt(i));
    }
    return data.getUint32(0);
  }
}
