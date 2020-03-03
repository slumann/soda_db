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

  MetaData.fromMap(Map<String, dynamic> map) {
    _dbVersion = map['dbVersion'];
    _ids = {};
    var idsMap = map['ids'] ?? {};
    idsMap.forEach((group, id) => _ids[group] = id);
    freePages = List<int>.from(map['freePages']) ?? [];
    groups = {};
    var groupMaps = map['groups'] ?? {};
    groupMaps.forEach((groupId, groupMap) {
      groups.putIfAbsent(groupId, () => {});
      groupMap?.forEach((entityId, entityMap) {
        groups[groupId][entityId] = MetaEntity.fromMap(entityMap);
      });
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'dbVersion': _dbVersion,
      'ids': _ids,
      'freePages': freePages,
      'groups': groups,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'lps': lastPageSize,
      'pgs': pages,
    };
  }

  MetaEntity.fromMap(Map<String, dynamic> map) {
    lastPageSize = map['lps'];
    pages = List<int>.from(map['pgs']) ?? [];
  }

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
