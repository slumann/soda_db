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
      groupMaps[groupId].forEach((entityId, entityMap) {
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
}
