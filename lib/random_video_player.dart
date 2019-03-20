import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';

import 'package:not_too_shabby/info.dart';
import 'package:not_too_shabby/storage_interactions.dart';

class RandomVideoPlayer extends StatefulWidget {
  RandomVideoPlayer({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _RandomVideoPlayerState createState() => _RandomVideoPlayerState();
}

class _RandomVideoPlayerState extends State<RandomVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    Storage storage = Storage(context);
    final double _buttonSize = 250.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.info,
            ),
            onPressed: () {
              _toInfoScreen();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: _buttonSize,
              width: _buttonSize,
              child: FloatingActionButton(
                onPressed: () {
                  _randomVideo(storage);
                },
                tooltip: 'Play random video',
                child: Icon(
                  Icons.play_arrow,
                  size: _buttonSize / 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _randomVideo(Storage storage) async {
    final List<VideoId> videoIds = await storage.localStorageVideoIds;
    final String randomVideoId =
        videoIds[Random().nextInt(videoIds.length)].value;
    final String youtubeApiKey = await storage.youtubeApiKey;

    FlutterYoutube.playYoutubeVideoById(
      apiKey: youtubeApiKey,
      videoId: randomVideoId,
      autoPlay: true,
      fullScreen: true,
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
}
