import 'dart:math';

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

  RandomVideoPlayer();

  @override
  _RandomVideoPlayerState createState() => _RandomVideoPlayerState();
}

class _RandomVideoPlayerState extends State<RandomVideoPlayer> {
  WatchHistory watchHistory;
  List<VideoDetail> videoDetails;

  @override
  void initState() {
    _initializeWatchHistory();
    _initializeLocalVideoDetails();
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
            tooltip: 'Watch History',
          ),
          IconButton(
            icon: Icon(
              Icons.info,
            ),
            onPressed: () {
              _toInfoScreen();
            },
            tooltip: 'App Info',
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
    final Storage storage = Storage(context);

    final snackBar = SnackBar(
      content: Text(
        'Unable to connect to internet to retrieve videos',
      ),
      action: SnackBarAction(
        label: 'Try again',
        onPressed: () {
          setState(() {
            _initializeWatchHistory();
          });
        },
      ),
    );

    final Function disabledButtonFunction = () {
      Scaffold.of(context).showSnackBar(snackBar);
    };

    final Function enabledButtonFunction = () {
      _randomVideo(storage);
    };

    if (videoDetails == null || videoDetails.length <= 0) {
      return _randomVideoButtonBuilder(disabledButtonFunction);
    } else {
      return _randomVideoButtonBuilder(enabledButtonFunction);
    }
  }

  Widget _randomVideoButtonBuilder(Function callback) {
    final double buttonSize = 250.0;

    return SizedBox(
      height: buttonSize,
      width: buttonSize,
      child: FloatingActionButton(
        onPressed: () {
          callback();
        },
        tooltip: 'Play random video',
        child: Icon(
          Icons.play_arrow,
          size: buttonSize / 2,
        ),
      ),
    );
  }

  void _randomVideo(Storage storage) async {
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

  void _toWatchHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WatchHistoryScreen(watchHistory),
      ),
    );
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

  void _initializeLocalVideoDetails() {
    Storage.localStorageVideoDetails
        .then((List<VideoDetail> localStorageVideoDetails) {
      videoDetails = localStorageVideoDetails;
    });
  }
}
