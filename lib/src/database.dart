import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:soda_db/src/meta_data.dart';

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
    _metaFile ??= await File('${_file.path}_meta').open(mode: FileMode.append);
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
    var data = jsonEncode(_metaData);
    await _metaFile.writeString(data);
    await _metaFile.truncate(data.length);
  }

  Future<void> _readMeta() async {
    await _metaFile.setPosition(0);
    var data = await _metaFile.read(await _metaFile.length());
    _metaData = MetaData.fromMap(jsonDecode(String.fromCharCodes(data)));
  }

  Future<int> write(String repo, int id, String data) {
    return _addToQueue(() => _write(repo, id, data));
  }

  Future<int> _write(String repo, int id, String data) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    data = _padToPageSize(data);
    var pageCount = (data.length / _pageSize).ceil();
    var pages = [];

    if (id == null ||
        _metaData.groups[repo] == null ||
        !_metaData.groups[repo].containsKey(id.toString())) {
      _metaData.groups.putIfAbsent(repo, () => {});
      pages = await _getFreePages(pageCount);
      id = _metaData.createNextId;
    } else {
      pages = _metaData.groups[repo][id.toString()].pages;
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

    for (var i = 0; i < pageCount; i++) {
      await _pageFile.setPosition(pages[i]);
      await _pageFile
          .writeString(data.substring(i * _pageSize, ((i + 1) * _pageSize)));
    }
    _metaData.groups[repo][id.toString()] = MetaEntity(0, pages);
    await _writeMeta();
    return id;
  }

  String _padToPageSize(String input) {
    return input.padRight(
        (input.length / _pageSize).ceil() * _pageSize, '\x00');
  }

  Future<List<int>> _getFreePages(int count) async {
    var pages = <int>[];
    while (_metaData.freePages.isNotEmpty && count > 0) {
      pages.add(_metaData.freePages.removeLast());
      count--;
    }
    if (count > 0) {
      var fileEnd = await _pageFile.length();
      for (var i = 0; i < count; i++) {
        pages.add(fileEnd);
        fileEnd += _pageSize;
      }
    }
    return pages;
  }

  Future<String> read(String repo, int id) {
    return _addToQueue(() => _read(repo, id));
  }

  Future<String> _read(String repo, int id) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    if (id == null ||
        _metaData.groups[repo] == null ||
        !_metaData.groups[repo].containsKey(id.toString())) {
      return null;
    }

    var pages = _metaData.groups[repo][id.toString()].pages;
    var buffer = StringBuffer();
    var byte;
    for (var page in pages) {
      await _pageFile.setPosition(page);
      byte = await _pageFile.readByte();
      for (var i = 0; i < _pageSize && byte != 0; i++) {
        buffer.write(String.fromCharCode(byte));
        byte = await _pageFile.readByte();
      }
    }
    return buffer.toString();
  }

  Future<Map<int, String>> readAll(String repo) {
    return _addToQueue(() => _readAll(repo));
  }

  Future<Map<int, String>> _readAll(String repo) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    var result = <int, String>{};
    if (_metaData.groups[repo] != null) {
      for (var entry in _metaData.groups[repo].entries) {
        var id = int.parse(entry.key);
        result[id] = await _read(repo, id);
      }
    }
    return result;
  }

  Future<bool> delete(String repo, int id) {
    return _addToQueue(() => _delete(repo, id));
  }

  Future<bool> _delete(String repo, int id) async {
    if (_metaFile == null) {
      throw StateError('Database not opened');
    }

    if (_metaData.groups[repo] != null &&
        _metaData.groups[repo].containsKey(id.toString())) {
      _metaData.freePages.addAll(_metaData.groups[repo][id.toString()].pages);
      _metaData.groups[repo].remove(id.toString());
      await _writeMeta();
      return true;
    }
    return false;
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
