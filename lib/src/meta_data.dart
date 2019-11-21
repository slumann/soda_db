class MetaData {
  int _dbVersion = 1;
  int _pageSize;
  int _nextId = 0;
  List<int> freePages;
  Map<String, Map<String, List<int>>> repositories;

  MetaData(this._pageSize)
      : freePages = [],
        repositories = {};

  int get dbVersion => _dbVersion;

  int get pageSize => _pageSize;

  int get nextId => _nextId++;

  MetaData.fromMap(Map<String, dynamic> map) {
    _dbVersion = map['dbVersion'];
    _pageSize = map['pageSize'];
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
      'dbVersion': _dbVersion,
      'pageSize': _pageSize,
      'nextId': _nextId,
      'freePages': freePages,
      'repositories': repositories,
    };
  }
}
