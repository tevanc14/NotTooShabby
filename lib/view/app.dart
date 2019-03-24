import 'package:flutter/material.dart';
import 'package:not_too_shabby/service/storage_interactions.dart';
import 'package:not_too_shabby/view/random_video_player.dart';

class NotTooShabbyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Storage.loadVideoDetails();

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: RandomVideoPlayer(),
    );
  }
}
