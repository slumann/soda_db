class MetaData {
  int dbVersion = 1;
  int _nextId = 0;
  List<int> freePages;
  Map<String, Map<String, List<int>>> repositories;

  MetaData()
      : freePages = [],
        repositories = {};

  int get nextId => _nextId++;

  MetaData.fromMap(Map<String, dynamic> map) {
    dbVersion = map['dbVersion'];
    _nextId = map['nextId'];
    freePages = List<int>.from(map['freePages']) ?? [];
    repositories = {};
    var repos = map['repositories'] ?? {};
    repos.forEach((repoName, entityMap) {
      repositories.putIfAbsent(repoName, () => {});
      repos[repoName].forEach((entityName, pageList) {
        var pages = List<int>.from(pageList) ?? [];
        repositories[repoName][entityName] = pages;
      });
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'dbVersion': dbVersion,
      'nextId': _nextId,
      'freePages': freePages,
      'repositories': repositories,
    };
  }
}
