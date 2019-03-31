import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:not_too_shabby/model/watch_history.dart';

import 'package:not_too_shabby/model/video_detail.dart';
import 'package:not_too_shabby/model/youtube_api_key.dart';
import 'package:not_too_shabby/service/storage_interactions.dart';
import 'package:not_too_shabby/view/info.dart';
import 'package:not_too_shabby/view/watch_history_screen.dart';

class RandomVideoPlayer extends StatefulWidget {
  final String title = 'Not Too Shabby';

  @override
  _RandomVideoPlayerState createState() => _RandomVideoPlayerState();
}

class _RandomVideoPlayerState extends State<RandomVideoPlayer> {
  WatchHistory watchHistory;
  List<VideoDetail> videoDetails;

  @override
  void initState() {
    _initializeWatchHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.history,
            ),
            onPressed: () {
              _toWatchHistoryScreen();
            },
            tooltip: 'Watch history',
          ),
          IconButton(
            icon: Icon(
              Icons.info,
            ),
            onPressed: () {
              _toInfoScreen();
            },
            tooltip: 'App info',
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _randomVideoButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _randomVideoButton(BuildContext context) {
    final Function successButtonFunction = () {
      _randomVideo();
    };

    final Function errorButtonFunction = () {
      setState(() {});
    };

    return FutureBuilder<List<VideoDetail>>(
      future: Storage.localStorageVideoDetails,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<VideoDetail>> snapshot,
      ) {
        if (snapshot.hasData) {
          videoDetails = snapshot.data;

          return _RandomVideoButton(
            callback: successButtonFunction,
            iconData: Icons.play_arrow,
          );
        } else if (snapshot.hasError) {
          return _RandomVideoButton(
            callback: errorButtonFunction,
            iconData: Icons.refresh,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  void _randomVideo() async {
    final int randomIndex = Random().nextInt(videoDetails.length);
    final VideoDetail randomVideoDetails = videoDetails[randomIndex];
    final YoutubeApiKey youtubeApiKey = await Storage.youtubeApiKey(context);

    FlutterYoutube.playYoutubeVideoById(
      apiKey: youtubeApiKey.value,
      videoId: randomVideoDetails.videoId,
      autoPlay: true,
      fullScreen: true,
    );

    watchHistory.addToWatchHistory(randomVideoDetails);

    FirebaseAnalytics().logEvent(
      name: 'random_video_play',
      parameters: {'videoId': randomVideoDetails.videoId},
    );
  }

  void _toWatchHistoryScreen() {
    if (watchHistory != null && videoDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WatchHistoryScreen(
                watchHistory,
                videoDetails,
              ),
        ),
      );
    }
  }

  void _toInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Info(),
      ),
    );
  }

  void _initializeWatchHistory() {
    Storage.readWatchHistory().then((WatchHistory readWatchHistory) {
      watchHistory = readWatchHistory;
    });
  }
}

class _RandomVideoButton extends StatelessWidget {
  final Function callback;
  final IconData iconData;

  final double buttonSize = 250.0;

  const _RandomVideoButton({
    @required this.callback,
    @required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonSize,
      width: buttonSize,
      child: FloatingActionButton(
        onPressed: () {
          callback();
        },
        tooltip: 'Play random video',
        child: _RandomVideoButtonIcon(
          iconData: iconData,
          buttonSize: buttonSize,
        ),
      ),
    );
  }
}

class _RandomVideoButtonIcon extends StatelessWidget {
  final IconData iconData;
  final double buttonSize;

  _RandomVideoButtonIcon({
    @required this.iconData,
    @required this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData,
      size: buttonSize / 1.5,
    );
  }
}
