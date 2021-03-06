import 'package:soda_db/src/convert/binary_reader.dart';
import 'package:soda_db/src/convert/binary_writer.dart';

class MetaData {
  int _dbVersion = 1;
  Map<String, int> _ids;
  List<int> freePages;
  Map<String, Map<String, MetaEntity>> groups;

  MetaData()
      : _ids = {},
        freePages = [],
        groups = {};

  int get dbVersion => _dbVersion;

  int createId(String group) {
    if (!_ids.containsKey(group)) {
      _ids[group] = 0;
    } else {
      _ids[group]++;
    }
    return _ids[group];
  }

  @override
  String toString() {
    var writer = BinaryWriter()
      ..write(_dbVersion)
      ..write(_ids)
      ..write(freePages)
      ..write(groups);
    return writer.toString();
  }

  MetaData.fromString(String data) {
    var reader = BinaryReader(data);
    _dbVersion = reader.readNext();
    _ids = Map.from(reader.readNext());
    freePages = List.from(reader.readNext());
    groups = {};
    var groupMap = reader.readNext();
    for (var entry in groupMap.entries) {
      if (entry.value != null) {
        groups[entry.key] = Map.from(entry.value)
            .map((k, v) => MapEntry(k, MetaEntity.fromString(v)));
      }
    }
  }
}

class MetaEntity {
  int lastPageSize;
  List<int> pages;

  MetaEntity(this.lastPageSize, this.pages);

  @override
  String toString() {
    var writer = BinaryWriter()..write(lastPageSize)..write(pages);
    return writer.toString();
  }

  MetaEntity.fromString(String data) {
    var reader = BinaryReader(data);
    lastPageSize = reader.readNext();
    pages = List.from(reader.readNext());
  }
}
