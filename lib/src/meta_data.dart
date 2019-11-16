class MetaData {
  int dbVersion = 1;
  List<int> freePages;
  Map<String, List<int>> dataPages;

  MetaData()
      : freePages = [],
        dataPages = {};

  MetaData.fromMap(Map<String, dynamic> map) {
    dbVersion = map['dbVersion'];
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
      'freePages': freePages,
      'dataPages': dataPages,
    };
  }
}
