import 'dart:typed_data';

import 'package:soda_db/src/convert/data_type.dart';

class BinaryWriter {
  final StringBuffer _buffer;
  final ByteData _data;

  BinaryWriter({int dataVersion = 1})
      : _buffer = StringBuffer(),
        _data = ByteData(8) {
    _writeInt(dataVersion);
  }

  @override
  String toString() {
    return _buffer.toString();
  }

  void write(Object object) {
    if (object == null) {
      _writeNull();
    } else if (object is int) {
      _writeInt(object);
    } else if (object is double) {
      _writeDouble(object);
    } else if (object is bool) {
      _writeBool(object);
    } else if (object is List) {
      _writeList(object);
    } else if (object is Set) {
      _writeSet(object);
    } else if (object is Map) {
      _writeMap(object);
    } else {
      _writeString(object.toString());
    }
  }

  void _writeNull() {
    _buffer.writeCharCode(DataType.nil);
  }

  void _writeInt(int i) {
    _writeTypeInfo(DataType.int, i);
  }

  void _writeDouble(double d) {
    _writeTypeInfo(DataType.double, d);
  }

  void _writeTypeInfo(int type, num n) {
    if (n is double) {
      _data.setFloat64(0, n);
    } else {
      _data.setInt64(0, n);
    }
    var varNum = _toVarNum(_data);
    var typeInfo = type | varNum.length - 1;
    _buffer.writeCharCode(typeInfo);
    varNum.forEach(_buffer.writeCharCode);
  }

  Uint8List _toVarNum(ByteData data) {
    var bytes = data.buffer.asUint8List();
    var idx = bytes.indexWhere((i) => i != 0);
    idx = idx == -1 ? 7 : idx;
    return bytes.sublist(idx);
  }

  void _writeBool(bool b) {
    _writeTypeInfo(DataType.bool, b ? 1 : 0);
  }

  void _writeList(List list) {
    _writeTypeInfo(DataType.list, list.length);
    list.forEach((value) => write(value));
  }

  void _writeSet(Set set) {
    _writeTypeInfo(DataType.set, set.length);
    for (var value in set) {
      write(value);
    }
  }

  void _writeMap(Map map) {
    _writeTypeInfo(DataType.map, map.length);
    for (var entry in map.entries) {
      write(entry.key);
      write(entry.value);
    }
  }

  void _writeString(String string) {
    _writeTypeInfo(DataType.string, string.length);
    _buffer.write(string);
  }
}
