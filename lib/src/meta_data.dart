class MetaData {
  int dbVersion = 1;
  int _nextId = 0;
  List<int> freePages;
  Map<String, List<int>> dataPages;

  MetaData()
      : freePages = [],
        dataPages = {};

  int get nextId => _nextId++;

  MetaData.fromMap(Map<String, dynamic> map) {
    dbVersion = map['dbVersion'];
    _nextId = map['nextId'];
    freePages = List<int>.from(map['freePages']) ?? [];
    dataPages = {};
    var entries = map['dataPages'] ?? {};
    entries.forEach((key, value) {
      dataPages.putIfAbsent(key, () => []);
      var pages = List<int>.from(value) ?? [];
      dataPages[key] = pages;
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'dbVersion': dbVersion,
      'nextId': _nextId,
      'freePages': freePages,
      'dataPages': dataPages,
    };
  }
}
