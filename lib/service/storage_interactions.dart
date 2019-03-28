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
  static final String _cacheTimerFileName = 'videoDetailsCacheTimer.json';
  static final String _watchHistoryFileName = 'watchHistory.json';

  static Future<bool> _shouldLoadVideoDetails() async {
    final File cacheTimerFile = await _cacheTimerFile;

    final bool cacheTimerFileIsEmpty =
        cacheTimerFile.readAsStringSync().isEmpty;
    if (cacheTimerFileIsEmpty) {
      return true;
    }

    final bool shouldInvalidateCache =
        await _shouldInvalidateCache(cacheTimerFile);
    if (shouldInvalidateCache) {
      return true;
    }

    return false;
  }

  static Future<List<VideoDetail>> get localStorageVideoDetails async {
    File videoDetailsFile = await _videoDetailsFile;
    String videoDetailsFileContent = videoDetailsFile.readAsStringSync();

    if (await _shouldLoadVideoDetails()) {
      videoDetailsFileContent = await _retrieveVideoDetails();
    }

    final List<dynamic> videoDetailsJson = json.decode(videoDetailsFileContent);
    final List<VideoDetail> videoDetails =
        VideoDetail.listFromYoutubeJson(videoDetailsJson);
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

  static Future<YoutubeApiKey> youtubeApiKey(BuildContext context) async {
    final Map<String, dynamic> json =
        await _loadJsonAsset(_secretsFileName, context);
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

    if (file.existsSync()) {
      return file;
    } else {
      return await file.create();
    }
  }

  static Future<bool> _shouldInvalidateCache(File cacheTimerFile) async {
    final CacheTimer cacheTimer = await _localStorageCacheTimer(cacheTimerFile);
    final DateTime videoDetailsLastRetrieved =
        DateTime.fromMillisecondsSinceEpoch(
            cacheTimer.videoDetailsLastRetrieved);
    return _isOlderThanADay(videoDetailsLastRetrieved);
  }

  static Future<CacheTimer> _localStorageCacheTimer(File cacheTimerFile) async {
    final String cacheTimerFileContents = await cacheTimerFile.readAsString();
    final Map<String, dynamic> cacheTimerJson =
        json.decode(cacheTimerFileContents);
    return CacheTimer.fromJson(cacheTimerJson);
  }

  static bool _isOlderThanADay(DateTime date) {
    return date.isBefore(
      DateTime.now().subtract(
        Duration(
          days: 1,
        ),
      ),
    );
  }

  static Future<String> _retrieveVideoDetails() async {
    http.Response response = await http.get(_buildGCSUrl());
    final int statusCode = response.statusCode;
    if (statusCode == 200) {
      final File videoDetailsFile = await _videoDetailsFile;
      videoDetailsFile.writeAsString(response.body);
      _makeCacheTimerFile();
      return response.body;
    }
  }

  static Future<String> gcsBody() async {
    http.Response response = await http.get(_buildGCSUrl());
    return response.body;
  }

  static Future<void> _makeCacheTimerFile() async {
    final File cacheTimerFile = await _cacheTimerFile;
    Map<String, dynamic> cacheTimerJson = Map();
    cacheTimerJson.addAll(
        {"videoDetailsLastRetrieved": DateTime.now().millisecondsSinceEpoch});
    cacheTimerFile.writeAsString(json.encode(cacheTimerJson));
  }

  static Future<Map<String, dynamic>> _loadJsonAsset(
    String filename,
    BuildContext context,
  ) async {
    final String data = await DefaultAssetBundle.of(context)
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
