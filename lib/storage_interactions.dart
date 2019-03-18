import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

class Storage {
  final String _assetsDirectoryName = 'assets';
  final String _videoIdFileName = 'videoIds.json';
  final String _cacheTimerFileName = 'videoIdCacheTimer.json';
  final String _secretsFileName = 'secrets.json';

  BuildContext _context;

  Storage(BuildContext context) {
    this._context = context;
  }

  void loadVideoIds() async {
    final File cacheTimerFile = await _cacheTimerFile;
    final bool cacheTimerFileExists = await cacheTimerFile.exists();
    final bool shouldInvalidateCache =
        await _shouldInvalidateCache(cacheTimerFile);
    if (!cacheTimerFileExists || shouldInvalidateCache) {
      _retrieveVideoIds();
    }
  }

  Future<List<VideoId>> get localStorageVideoIds async {
    // TODO: Save this data to avoid loading it every time?
    final File data = await _videoIdsFile;
    final List<dynamic> videoIdsJson = json.decode(await data.readAsString());
    final List<VideoId> videoIds = VideoId.listFromJson(videoIdsJson);
    return videoIds;
  }

  Future<String> get youtubeApiKey async {
    final Map<String, dynamic> json = await _loadJsonAsset(_secretsFileName);
    return YoutubeApiKey.fromJson(json).value;
  }

  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _cacheTimerFile async {
    return _localFile(_cacheTimerFileName);
  }

  Future<File> get _videoIdsFile async {
    return _localFile(_videoIdFileName);
  }

  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<bool> _shouldInvalidateCache(File cacheTimerFile) async {
    final CacheTimer cacheTimer = await _localStorageCacheTimer(cacheTimerFile);
    final DateTime videoIdsLastRetrieved =
        DateTime.fromMillisecondsSinceEpoch(cacheTimer.videoIdsLastRetrieved);
    return _isOlderThanADay(videoIdsLastRetrieved);
  }

  Future<CacheTimer> _localStorageCacheTimer(File cacheTimerFile) async {
    final String cacheTimerFileContents = await cacheTimerFile.readAsString();
    final Map<String, dynamic> cacheTimerJson =
        json.decode(cacheTimerFileContents);
    return CacheTimer.fromJson(cacheTimerJson);
  }

  bool _isOlderThanADay(DateTime date) {
    return date.isBefore(DateTime.now().subtract(Duration(days: 1)));
  }

  void _retrieveVideoIds() {
    http.get(_buildGCSUrl()).then((response) async {
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        final File videoIdsFile = await _videoIdsFile;
        videoIdsFile.writeAsString(response.body);
        _makeCacheTimerFile();
      }
    });
  }

  Future _makeCacheTimerFile() async {
    final File cacheTimerFile = await _cacheTimerFile;
    Map<String, dynamic> cacheTimerJson = Map();
    cacheTimerJson.addAll(
        {"videoIdsLastRetrieved": DateTime.now().millisecondsSinceEpoch});
    cacheTimerFile.writeAsString(json.encode(cacheTimerJson));
  }

  Future<Map<String, dynamic>> _loadJsonAsset(String filename) async {
    final String data = await DefaultAssetBundle.of(this._context)
        .loadString('$_assetsDirectoryName/$filename');
    return json.decode(data);
  }

  String _buildGCSUrl() {
    final String pathSeparator = '/';
    final String baseUrl = 'https://storage.googleapis.com';
    final String bucketName = 'not-too-shabby';
    final String objectPath = ['videoIds', 'videoIds.json'].join(pathSeparator);
    return [baseUrl, bucketName, objectPath].join(pathSeparator);
  }
}

class VideoId {
  final String value;

  VideoId({
    this.value,
  });

  VideoId.fromJson(dynamic arrayMember) : value = arrayMember;

  static List<VideoId> listFromJson(List<dynamic> dynamicVideoIds) {
    return dynamicVideoIds
        .map((dynamicVideoId) => VideoId.fromJson(dynamicVideoId))
        .toList();
  }
}

class YoutubeApiKey {
  final String value;

  YoutubeApiKey({
    this.value,
  });

  YoutubeApiKey.fromJson(Map<String, dynamic> json)
      : value = json['youtubeApiKey'];
}

class CacheTimer {
  final int videoIdsLastRetrieved;

  CacheTimer({
    this.videoIdsLastRetrieved,
  });

  CacheTimer.fromJson(Map<String, dynamic> json)
      : videoIdsLastRetrieved = json['videoIdsLastRetrieved'];
}
