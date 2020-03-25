import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:soda_db/src/database/meta_data.dart';

class Database {
  final File _file;
  final _pageSize = 512;
  final _ioQueue = DoubleLinkedQueue<_IORequest>();
  var _ioActive = false;
  RandomAccessFile _metaFile;
  RandomAccessFile _pageFile;
  MetaData _metaData;

  Database(this._file);

  Future<void> open() {
    return _addToQueue(() => _open());
  }

  Future<void> _open() async {
    if (_metaFile != null) {
      return;
    }

    _pageFile ??= await _file.open(mode: FileMode.append);
    await _pageFile.lock();
    _metaFile ??= await File('${_file.path}.meta').open(mode: FileMode.append);
    await _metaFile.lock();
    if (await _metaFile.length() == 0) {
      _metaData = MetaData();
      await _writeMeta();
    } else {
      await _readMeta();
    }
  }

  Future<void> _writeMeta() async {
    await _metaFile.setPosition(0);
    var data = _metaData.toString();
    await _metaFile.writeString(data);
    await _metaFile.truncate(data.length);
  }

  Future<void> _readMeta() async {
    await _metaFile.setPosition(0);
    var data = await _metaFile.read(await _metaFile.length());
    _metaData = MetaData.fromString(String.fromCharCodes(data));
  }

  Future<int> writeEntity(String groupId, int entityId, String data) {
    return _addToQueue(() => _writeEntity(groupId, entityId, data));
  }

  Future<int> _writeEntity(String groupId, int entityId, String data) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    var pageCount = (data.length / _pageSize).ceil();
    var pages = <int>[];

    if (entityId == null ||
        _metaData.groups[groupId] == null ||
        !_metaData.groups[groupId].containsKey(entityId.toString())) {
      _metaData.groups.putIfAbsent(groupId, () => {});
      pages = await _getFreePages(pageCount);
      entityId = _metaData.createId(groupId);
    } else {
      pages = _metaData.groups[groupId][entityId.toString()].pages;
      var diffCount = pageCount - pages.length;
      if (diffCount > 0) {
        pages.addAll(await _getFreePages(pageCount - pages.length));
      } else if (diffCount < 0) {
        var freePages = <int>[];
        for (var i = diffCount; i < 0; i++) {
          freePages.add(pages.removeLast());
        }
        _metaData.freePages.addAll(freePages);
      }
    }

    var offset = data.length % _pageSize;
    var lastPageSize = offset != 0 ? offset : _pageSize;
    for (var i = 0; i < pageCount; i++) {
      var pageSize = (i == pageCount - 1) ? lastPageSize : _pageSize;
      await _pageFile.setPosition(pages[i]);
      var start = i * _pageSize;
      var end = start + pageSize;
      await _pageFile.writeString(data.substring(start, end));
    }
    _metaData.groups[groupId][entityId.toString()] =
        MetaEntity(lastPageSize, pages);
    await _writeMeta();
    return entityId;
  }

  Future<List<int>> _getFreePages(int count) async {
    var pages = <int>[];
    while (_metaData.freePages.isNotEmpty && count > 0) {
      pages.add(_metaData.freePages.removeLast());
      count--;
    }
    if (count > 0) {
      var fileEnd = await _pageFile.length();
      var offset = 0;
      if (fileEnd % _pageSize == 0) {
        offset = fileEnd;
      } else {
        offset = fileEnd + _pageSize - (fileEnd % _pageSize);
      }
      for (var i = 0; i < count; i++) {
        pages.add(offset);
        offset += _pageSize;
      }
    }
    return pages;
  }

  Future<String> readEntity(String groupId, int entityId) {
    return _addToQueue(() => _readEntity(groupId, entityId));
  }

  Future<String> _readEntity(String groupId, int entityId) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    if (entityId == null ||
        _metaData.groups[groupId] == null ||
        !_metaData.groups[groupId].containsKey(entityId.toString())) {
      return null;
    }

    var entity = _metaData.groups[groupId][entityId.toString()];
    var pages = entity.pages;
    var buffer = StringBuffer();
    var byte;
    for (var i = 0; i < pages.length; i++) {
      var pageSize = i == (pages.length - 1) ? entity.lastPageSize : _pageSize;
      await _pageFile.setPosition(pages[i]);
      for (var i = 0; i < pageSize; i++) {
        byte = await _pageFile.readByte();
        buffer.write(String.fromCharCode(byte));
      }
    }
    return buffer.toString();
  }

  Future<Map<int, String>> readGroup(String groupId) {
    return _addToQueue(() => _readGroup(groupId));
  }

  Future<Map<int, String>> _readGroup(String groupId) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    var result = <int, String>{};
    if (_metaData.groups[groupId] != null) {
      for (var entry in _metaData.groups[groupId].entries) {
        var id = int.parse(entry.key);
        result[id] = await _readEntity(groupId, id);
      }
    }
    return result;
  }

  Future<bool> deleteEntity(String groupId, int entityId) {
    return _addToQueue(() => _deleteEntity(groupId, entityId));
  }

  Future<bool> _deleteEntity(String groupId, int entityId) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    if (_metaData.groups[groupId] != null &&
        _metaData.groups[groupId].containsKey(entityId.toString())) {
      _metaData.freePages
          .addAll(_metaData.groups[groupId][entityId.toString()].pages);
      _metaData.groups[groupId].remove(entityId.toString());
      await _writeMeta();
      return true;
    }
    return false;
  }

  Future<bool> deleteGroup(String groupId) {
    return _addToQueue(() => _deleteGroup(groupId));
  }

  Future<bool> _deleteGroup(String groupId) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    if (_metaData.groups[groupId] != null) {
      _metaData.groups[groupId].values.forEach(
          (metaEntity) => _metaData.freePages.addAll(metaEntity.pages));
      _metaData.groups[groupId] = null;
      await _writeMeta();
      return true;
    }
    return false;
  }

  List<int> getEntityIds(String groupId) {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    var result = <String>[];
    if (_metaData.groups[groupId] != null) {
      result.addAll(_metaData.groups[groupId].keys);
    }
    return result.map((s) => int.parse(s)).toList();
  }

  Future<void> close() {
    return _addToQueue(() => _close());
  }

  Future<void> _close() async {
    await _pageFile?.flush();
    await _pageFile?.unlock();
    await _pageFile?.close();
    await _metaFile?.flush();
    await _metaFile?.unlock();
    await _metaFile?.close();
    _pageFile = null;
    _metaFile = null;
  }

  Future<T> _addToQueue<T>(Function function) {
    var request = _IORequest<T>(function);
    _ioQueue.add(request);
    _processQueue();
    return request.result;
  }

  Future<void> _processQueue() async {
    if (_ioActive) return;
    _ioActive = true;

    while (_ioQueue.isNotEmpty) {
      var request = _ioQueue.removeFirst();
      try {
        request.finish(await request.action.call());
      } catch (e) {
        request.error(e);
      }
    }
    _ioActive = false;
  }
}

class _IORequest<T> {
  final Function action;
  final _completer = Completer<T>();

  _IORequest(this.action);

  Future<T> get result => _completer.future;

  void finish(T result) {
    _completer.complete(result);
  }

  void error(dynamic error) {
    _completer.completeError(error);
  }
}
