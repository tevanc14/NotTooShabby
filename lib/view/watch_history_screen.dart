import 'package:firebase_analytics/firebase_analytics.dart';
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
  final int _displayBatchSize = 10;
  final ScrollController _scrollController = ScrollController();

  List<String> _watchHistoryKeys;
  List<String> _displayWatchHistoryKeys;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _watchHistoryKeys = _sortedWatchHistoryKeys();
    _displayWatchHistoryKeys =
        _watchHistoryKeys.take(_displayBatchSize).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Watch History',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.assessment,
            ),
            onPressed: _watchStatsDialog,
            tooltip: 'Watch stats',
          )
        ],
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
          _watchHistoryTileList(),
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

  Widget _watchHistoryTileList() {
    bool isLoading = false;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoading &&
            _displayWatchHistoryKeys.length < _watchHistoryKeys.length) {
          isLoading = !isLoading;
          setState(
            () {
              _displayWatchHistoryKeys.addAll(_watchHistoryKeys
                  .skip(_displayWatchHistoryKeys.length)
                  .take(_displayBatchSize));
            },
          );
        }
      }
    });

    return Expanded(
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _displayWatchHistoryKeys.length,
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
              .watchHistory.watchHistoryMap[_displayWatchHistoryKeys[index]];
          return _watchHistoryTile(videoWatchHistory);
        },
      ),
    );
  }

  Widget _watchHistoryTile(VideoWatchHistory videoWatchHistory) {
    final double dimension = 75.0;

    return GestureDetector(
      child: ListTile(
        leading: SizedBox(
          width: dimension,
          height: dimension,
          child: FadeInImage.assetNetwork(
            image: videoWatchHistory.videoDetail.defaultThumbnail.url,
            placeholder: 'assets/grey_box.png',
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

        FirebaseAnalytics().logEvent(
          name: 'watch_history_video_play',
          parameters: {'videoId': videoWatchHistory.videoDetail.videoId},
        );
      },
    );
  }

  void _watchStatsDialog() {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                16.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Watch Stats',
                  style: textTheme.display1,
                ),
                Column(
                  children: <Widget>[
                    _WatchStatsHeading(
                      text: 'Most watched',
                    ),
                    _mostWatchedTile(),
                  ],
                ),
                Column(
                  children: <Widget>[
                    _WatchStatsHeading(
                      text: 'Total watches',
                    ),
                    Text(
                      _totalWatchCount().toString(),
                      style: textTheme.title,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        'CLOSE',
                      ),
                      textColor: themeData.accentColor,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mostWatchedTile() {
    if (widget.watchHistory.watchHistoryMap.length == 0) {
      return Text(
        'No videos watched',
      );
    } else {
      return _watchHistoryTile(
        _mostWatched(),
      );
    }
  }

  VideoWatchHistory _mostWatched() {
    VideoWatchHistory mostWatched;
    widget.watchHistory.watchHistoryMap.forEach((
      String videoId,
      VideoWatchHistory videoWatchHistory,
    ) {
      if (mostWatched == null) {
        mostWatched = videoWatchHistory;
      } else if (videoWatchHistory.watchEvents.length >
          mostWatched.watchEvents.length) {
        mostWatched = videoWatchHistory;
      }
    });

    return mostWatched;
  }

  int _totalWatchCount() {
    int totalWatchCount = 0;
    widget.watchHistory.watchHistoryMap.forEach((
      String videoId,
      VideoWatchHistory videoWatchHistory,
    ) {
      totalWatchCount += videoWatchHistory.watchEvents.length;
    });
    return totalWatchCount;
  }
}

class _WatchStatsHeading extends StatelessWidget {
  final String text;

  const _WatchStatsHeading({
    @required this.text,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        bottom: 16.0,
      ),
      child: Text(
        text,
        style: textTheme.title,
      ),
    );
  }
}
