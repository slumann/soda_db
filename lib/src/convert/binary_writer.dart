import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:soda_db/src/convert/data_type.dart';

class BinaryWriter {
  final StringBuffer _buffer;

  BinaryWriter({int dataVersion = 1}) : _buffer = StringBuffer() {
    _writeString(dataVersion.toString());
  }

  @override
  String toString() {
    return _buffer.toString();
  }

  void write(Object object) {
    if (object is int) {
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

  void _writeInt(int i) {
    _buffer.write(DataType.int);
    _buffer.write(encodeLength(i.toString().length));
    _buffer.write(i);
  }

  void _writeDouble(double d) {
    _buffer.write(DataType.double);
    _buffer.write(encodeLength(d.toString().length));
    _buffer.write(d);
  }

  void _writeBool(bool b) {
    _buffer.write(DataType.bool);
    _buffer.write(b ? 1 : 0);
  }

  void _writeList(List list) {
    _buffer.write(DataType.list);
    _buffer.write(encodeLength(list.length));
    list.forEach((value) => write(value));
  }

  void _writeSet(Set set) {
    _buffer.write(DataType.set);
    _buffer.write(encodeLength(set.length));
    for (var value in set) {
      write(value);
    }
  }

  void _writeMap(Map map) {
    _buffer.write(DataType.map);
    _buffer.write(encodeLength(map.length));
    for (var entry in map.entries) {
      write(entry.key);
      write(entry.value);
    }
  }

  void _writeString(String string) {
    _buffer.write(DataType.string);
    _buffer.write(encodeLength(string.length));
    _buffer.write(string);
  }

  @visibleForTesting
  String encodeLength(int length) {
    if (length > 0xffffffff) {
      throw ArgumentError('Max supported data length is '
          '${0xffffffff.toString()}');
    }

    var bytes = ByteData(4);
    bytes.setUint32(0, length);
    return String.fromCharCodes(bytes.buffer.asUint8List());
  }
}
