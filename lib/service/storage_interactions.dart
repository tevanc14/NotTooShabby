import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:not_too_shabby/model/watch_history.dart';
import 'package:not_too_shabby/model/video_detail.dart';
import 'package:not_too_shabby/model/youtube_api_key.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

class Storage {
  static final String _assetsDirectoryName = 'assets';
  static final String _secretsFileName = 'secrets.json';

  static final String _videoDetailsFileName = 'videoDetails.json';
  static final String _cacheTimerFileName = 'videoIdCacheTimer.json';
  static final String _watchHistoryFileName = 'watchHistory.json';

  BuildContext _context;

  List<VideoDetail> videoIds;

  Storage(BuildContext context) {
    this._context = context;
  }

  static void loadVideoDetails() async {
    final File cacheTimerFile = await _cacheTimerFile;

    final bool cacheTimerFileIsEmpty =
        (await cacheTimerFile.readAsString()).isEmpty;

    if (cacheTimerFileIsEmpty) {
      _retrieveVideoDetails();
      return;
    }

    final bool shouldInvalidateCache =
        await _shouldInvalidateCache(cacheTimerFile);
    if (shouldInvalidateCache) {
      _retrieveVideoDetails();
      return;
    }
  }

  static Future<List<VideoDetail>> get localStorageVideoDetails async {
    final File data = await _videoDetailsFile;

    if (!data.existsSync()) {
      loadVideoDetails();
    }

    final List<dynamic> videoDetailsJson =
        json.decode(await data.readAsString());
    final List<VideoDetail> videoDetails =
        VideoDetail.listFromJson(videoDetailsJson);
    return videoDetails;
  }

  static Future<WatchHistory> readWatchHistory() async {
    final File watchHistoryFile = await _watchHistoryFile;
    final String watchHistoryFileContents = watchHistoryFile.readAsStringSync();

    if (watchHistoryFileContents.isEmpty) {
      return WatchHistory();
    } else {
      final Map<String, dynamic> watchHistoryJson =
          json.decode(watchHistoryFileContents);
      return WatchHistory.fromJson(watchHistoryJson);
    }
  }

  static Future<void> writeWatchHistory(WatchHistory watchHistory) async {
    final File watchHistoryFile = await _watchHistoryFile;
    watchHistoryFile.writeAsString(json.encode(watchHistory.watchHistoryMap));
  }

  Future<YoutubeApiKey> get youtubeApiKey async {
    final Map<String, dynamic> json = await _loadJsonAsset(_secretsFileName);
    return YoutubeApiKey.fromJson(json);
  }

  static Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _cacheTimerFile async {
    return _localFile(_cacheTimerFileName);
  }

  static Future<File> get _videoDetailsFile async {
    return _localFile(_videoDetailsFileName);
  }

  static Future<File> get _watchHistoryFile async {
    return _localFile(_watchHistoryFileName);
  }

  static Future<File> _localFile(String fileName) async {
    final String path = await _localPath;
    final File file = File('$path/$fileName');

    if (await file.exists()) {
      return file;
    } else {
      return await file.create();
    }
  }

  static Future<bool> _shouldInvalidateCache(File cacheTimerFile) async {
    final CacheTimer cacheTimer = await _localStorageCacheTimer(cacheTimerFile);
    final DateTime videoIdsLastRetrieved = DateTime.fromMillisecondsSinceEpoch(
        cacheTimer.videoDetailsLastRetrieved);
    return _isOlderThanADay(videoIdsLastRetrieved);
  }

  static Future<CacheTimer> _localStorageCacheTimer(File cacheTimerFile) async {
    final String cacheTimerFileContents = await cacheTimerFile.readAsString();
    final Map<String, dynamic> cacheTimerJson =
        json.decode(cacheTimerFileContents);
    return CacheTimer.fromJson(cacheTimerJson);
  }

  static bool _isOlderThanADay(DateTime date) {
    return date.isBefore(DateTime.now().subtract(Duration(days: 1)));
  }

  static void _retrieveVideoDetails() {
    print('fetching from GCS');
    http.get(_buildGCSUrl()).then((response) async {
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        final File videoIdsFile = await _videoDetailsFile;
        videoIdsFile.writeAsString(response.body);
        _makeCacheTimerFile();
      }
    });
  }

  static Future<void> _makeCacheTimerFile() async {
    final File cacheTimerFile = await _cacheTimerFile;
    Map<String, dynamic> cacheTimerJson = Map();
    cacheTimerJson.addAll(
        {"videoDetailsLastRetrieved": DateTime.now().millisecondsSinceEpoch});
    cacheTimerFile.writeAsString(json.encode(cacheTimerJson));
  }

  Future<Map<String, dynamic>> _loadJsonAsset(String filename) async {
    final String data = await DefaultAssetBundle.of(this._context)
        .loadString('$_assetsDirectoryName/$filename');
    return json.decode(data);
  }

  static String _buildGCSUrl() {
    final String pathSeparator = '/';
    final String baseUrl = 'https://storage.googleapis.com';
    final String bucketName = 'not-too-shabby';
    final String objectPath =
        ['videoDetails', 'videoDetails.json'].join(pathSeparator);
    return [baseUrl, bucketName, objectPath].join(pathSeparator);
  }
}

class CacheTimer {
  final int videoDetailsLastRetrieved;

  CacheTimer(
    this.videoDetailsLastRetrieved,
  );

  CacheTimer.fromJson(Map<String, dynamic> json)
      : videoDetailsLastRetrieved = json['videoDetailsLastRetrieved'];
}
