import 'package:not_too_shabby/model/video_detail.dart';
import 'package:not_too_shabby/service/storage_interactions.dart';

class WatchHistory {
  Map<String, VideoWatchHistory> watchHistoryMap;

  WatchHistory() {
    watchHistoryMap = {};
  }

  WatchHistory.fromJson(Map<String, dynamic> json) {
    watchHistoryMap = Map();
    json.forEach((
      String key,
      dynamic value,
    ) {
      watchHistoryMap.putIfAbsent(
        key,
        () => VideoWatchHistory.fromJson(json[key]),
      );
    });
  }

  void addToWatchHistory(VideoDetail videoDetail) {
    if (watchHistoryMap.containsKey(videoDetail.videoId)) {
      _addWatchEvent(videoDetail);
    } else {
      _addVideoWatchHistory(videoDetail);
    }

    _writeWatchHistory();
  }

  void _addWatchEvent(VideoDetail videoDetail) {
    watchHistoryMap[videoDetail.videoId].addWatchEvent();
  }

  void _addVideoWatchHistory(VideoDetail videoDetail) {
    watchHistoryMap[videoDetail.videoId] = VideoWatchHistory(videoDetail);
  }

  void _writeWatchHistory() {
    Storage.writeWatchHistory(this);
  }
}

class VideoWatchHistory {
  VideoDetail videoDetail;
  List<WatchEvent> watchEvents;

  VideoWatchHistory(
    this.videoDetail,
  ) {
    watchEvents = List();
    addWatchEvent();
  }

  VideoWatchHistory.fromJson(Map<String, dynamic> json) {
    videoDetail = VideoDetail.fromLocalJson(json['videoDetail']);
    watchEvents = WatchEvent.listFromJson(json['watchEvents']);
  }

  Map<String, dynamic> toJson() {
    return {
      'videoDetail': videoDetail,
      'watchEvents': watchEvents,
    };
  }

  addWatchEvent() {
    String nowString = DateTime.now().toString();
    WatchEvent newWatchEvent = WatchEvent(nowString);
    watchEvents.add(newWatchEvent);
  }
}

class WatchEvent {
  String timeWatched;

  WatchEvent(
    this.timeWatched,
  );

  WatchEvent.fromJson(Map<String, dynamic> json) {
    timeWatched = json['timeWatched'];
  }

  static List<WatchEvent> listFromJson(List<dynamic> dynamicWatchEvents) {
    return dynamicWatchEvents
        .map((dynamicVideoId) => WatchEvent.fromJson(dynamicVideoId))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'timeWatched': timeWatched,
    };
  }
}
