import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:not_too_shabby/info.dart';

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
            onPressed: _toInfoScreen,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _randomVideo,
              tooltip: 'Play random video',
              child: Icon(
                Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _randomVideo() async {
    // TODO: Serialize this properly
    // TODO: Probably pull this from cloud storage, cache for a day or something
    final String data =
        await DefaultAssetBundle.of(context).loadString('assets/videos.json');
    final jsonResult = json.decode(data);

    final random = new Random();
    final randomVideoObject = jsonResult[random.nextInt(jsonResult.length)];
    final randomVideoId = randomVideoObject['snippet']['resourceId']['videoId'];
    final String youtubeApiKey = await _youtubeApiKey();

    FlutterYoutube.playYoutubeVideoById(
      apiKey: youtubeApiKey,
      videoId: randomVideoId,
      autoPlay: true,
      fullScreen: true,
    );
  }

  Future<String> _youtubeApiKey() async {
    final Map<String, dynamic> json = await _loadJson('secrets.json');
    return YoutubeApiKey.fromJson(json).value;
  }

  Future<Map<String, dynamic>> _loadJson(String filename) async {
    final String data =
        await DefaultAssetBundle.of(context).loadString('assets/$filename');
    return json.decode(data);
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

class YoutubeApiKey {
  final String value;

  YoutubeApiKey({
    this.value,
  });

  YoutubeApiKey.fromJson(Map<String, dynamic> json)
      : value = json['youtubeApiKey'];
}
