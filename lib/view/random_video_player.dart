import 'dart:math';

import 'package:flutter/material.dart';
import 'package:not_too_shabby/model/watch_history.dart';
import 'package:not_too_shabby/model/video_detail.dart';
import 'package:not_too_shabby/model/youtube_api_key.dart';
import 'package:not_too_shabby/service/storage_interactions.dart';
import 'package:not_too_shabby/service/video_interactions.dart';
import 'package:not_too_shabby/view/info.dart';
import 'package:not_too_shabby/view/watch_history_screen.dart';

class RandomVideoPlayer extends StatefulWidget {
  final String title = 'NOT TOO SHABBY';

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
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
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
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: _layoutPlayer(),
          ),
        ],
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
          );
        } else if (snapshot.hasError) {
          return _RandomVideoButton(
            callback: errorButtonFunction,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> _randomVideo() async {
    final int randomIndex = Random().nextInt(videoDetails.length);
    final VideoDetail randomVideoDetail = videoDetails[randomIndex];
    final YoutubeApiKey youtubeApiKey = await Storage.youtubeApiKey(context);

    Video.play(
      watchHistory,
      randomVideoDetail,
      youtubeApiKey,
    );
  }

  void _toWatchHistoryScreen() {
    if (watchHistory != null && videoDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => WatchHistoryScreen(
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
        builder: (BuildContext context) => Info(),
      ),
    );
  }

  void _initializeWatchHistory() {
    Storage.readWatchHistory().then((WatchHistory readWatchHistory) {
      watchHistory = readWatchHistory;
    });
  }

  bool _widerThanTall() {
    final MediaQueryData queryData = MediaQuery.of(context);
    return queryData.size.width > queryData.size.height;
  }

  Widget _layoutPlayer() {
    final List<Widget> children = <Widget>[
      _randomVideoButton(context),
      _WrittenTitle(),
    ];
    if (_widerThanTall()) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }
  }
}

class _RandomVideoButton extends StatelessWidget {
  final Function callback;

  const _RandomVideoButton({
    @required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.5;

    return SizedBox(
      height: buttonSize,
      width: buttonSize,
      child: InkWell(
        onTap: callback,
        child: Image.asset(
          'assets/play_button.png',
        ),
      ),
    );
  }
}

class _WrittenTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.5;

    return SizedBox(
      width: width,
      height: width * 0.8,
      child: Image.asset(
        'assets/written_title.png',
      ),
    );
  }
}
