import 'dart:math';

import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:not_too_shabby/model/video_detail.dart';
import 'package:not_too_shabby/model/watch_history.dart';
import 'package:not_too_shabby/model/youtube_api_key.dart';
import 'package:not_too_shabby/service/storage_interactions.dart';

class VideoPlayer {
  WatchHistory watchHistory;
  List<VideoDetail> videoDetails;
  Storage storage;

  YoutubeApiKey youtubeApiKey;

  VideoPlayer(
    this.watchHistory,
    this.videoDetails,
    this.storage,
  ) {
    storage.youtubeApiKey.then((result) {
      youtubeApiKey = result;
    });
  }

  void randomVideo() async {
    final int randomIndex = Random().nextInt(videoDetails.length);
    final VideoDetail randomVideoDetails = videoDetails[randomIndex];
    final YoutubeApiKey youtubeApiKey = await storage.youtubeApiKey;

    FlutterYoutube.playYoutubeVideoById(
      apiKey: youtubeApiKey.value,
      videoId: randomVideoDetails.videoId,
      autoPlay: true,
      fullScreen: true,
    );

    watchHistory.addToWatchHistory(randomVideoDetails);
  }
}
