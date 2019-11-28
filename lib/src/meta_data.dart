class MetaData {
  int _dbVersion = 1;
  int _nextId = 0;
  List<int> freePages;
  Map<String, Map<String, MetaEntity>> groups;

  MetaData()
      : freePages = [],
        groups = {};

  int get dbVersion => _dbVersion;

  int get createNextId => _nextId++;

  MetaData.fromMap(Map<String, dynamic> map) {
    _dbVersion = map['dbVersion'];
    _nextId = map['nextId'];
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
      'nextId': _nextId,
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
