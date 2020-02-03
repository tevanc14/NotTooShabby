import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:not_too_shabby/model/video_detail.dart';
import 'package:not_too_shabby/model/watch_history.dart';
import 'package:not_too_shabby/model/youtube_api_key.dart';

class Video {
  static void play(
    WatchHistory watchHistory,
    VideoDetail videoDetail,
    YoutubeApiKey youtubeApiKey,
  ) {
    _launchVideo(videoDetail, youtubeApiKey);
    _addToWatchHistory(
      watchHistory,
      videoDetail,
    );
    _logWatchEvent(videoDetail);
  }

  static void _launchVideo(
    VideoDetail videoDetail,
    YoutubeApiKey youtubeApiKey,
  ) {
    FlutterYoutube.playYoutubeVideoById(
      apiKey: youtubeApiKey.value,
      videoId: videoDetail.videoId,
      autoPlay: true,
      fullScreen: true,
    );
  }

  static void _addToWatchHistory(
    WatchHistory watchHistory,
    VideoDetail videoDetail,
  ) {
    watchHistory.addToWatchHistory(videoDetail);
  }

  static void _logWatchEvent(VideoDetail videoDetail) {
    FirebaseAnalytics().logEvent(
      name: 'random_video_play',
      parameters: <String, String>{
        'videoId': videoDetail.videoId,
      },
    );
  }
}
