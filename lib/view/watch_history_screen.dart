import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:not_too_shabby/model/video_detail.dart';
import 'package:not_too_shabby/model/watch_history.dart';
import 'package:not_too_shabby/model/youtube_api_key.dart';
import 'package:not_too_shabby/service/storage_interactions.dart';

class WatchHistoryScreen extends StatefulWidget {
  final WatchHistory watchHistory;
  final List<VideoDetail> videoDetails;

  WatchHistoryScreen(
    this.watchHistory,
    this.videoDetails,
  );

  @override
  _WatchHistoryScreenState createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final List<String> watchHistoryKeys = _sortedWatchHistoryKeys();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Watch History',
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            child: Text(
              _numberOfVideosWatchedText(),
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: watchHistoryKeys.length,
              separatorBuilder: (
                BuildContext context,
                int index,
              ) {
                return Divider();
              },
              itemBuilder: (
                BuildContext context,
                int index,
              ) {
                final VideoWatchHistory videoWatchHistory = widget
                    .watchHistory.watchHistoryMap[watchHistoryKeys[index]];
                return _watchHistoryTile(videoWatchHistory);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _numberOfVideosWatchedText() {
    List<String> watchHistoryKeys =
        widget.watchHistory.watchHistoryMap.keys.toList();
    String variableText;

    if (watchHistoryKeys.length == 1) {
      variableText = 'video';
    } else {
      variableText = 'videos';
    }

    return '${watchHistoryKeys.length} of ${widget.videoDetails.length} Not Too Shabby $variableText watched';
  }

  List<String> _sortedWatchHistoryKeys() {
    List<String> watchHistoryKeys =
        widget.watchHistory.watchHistoryMap.keys.toList();

    watchHistoryKeys.sort((String key1, String key2) {
      DateTime date1 = DateTime.parse(widget
          .watchHistory.watchHistoryMap[key1].watchEvents.last.timeWatched);
      DateTime date2 = DateTime.parse(widget
          .watchHistory.watchHistoryMap[key2].watchEvents.last.timeWatched);

      return date2.compareTo(date1);
    });

    return watchHistoryKeys;
  }

  Widget _watchHistoryTile(VideoWatchHistory videoWatchHistory) {
    final double dimension = 75.0;

    return GestureDetector(
      child: ListTile(
        leading: SizedBox(
          width: dimension,
          height: dimension,
          child: Image.network(
            videoWatchHistory.videoDetail.defaultThumbnail.url,
          ),
        ),
        title: Text(
          videoWatchHistory.videoDetail.title,
        ),
        trailing: Text(
          '${videoWatchHistory.watchEvents.length}',
        ),
      ),
      onTap: () async {
        final YoutubeApiKey youtubeApiKey =
            await Storage.youtubeApiKey(context);

        FlutterYoutube.playYoutubeVideoById(
          apiKey: youtubeApiKey.value,
          videoId: videoWatchHistory.videoDetail.videoId,
          autoPlay: true,
          fullScreen: true,
        );

        setState(() {
          widget.watchHistory.addToWatchHistory(videoWatchHistory.videoDetail);
        });
      },
    );
  }
}
