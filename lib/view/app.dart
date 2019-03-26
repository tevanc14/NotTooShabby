import 'package:flutter/material.dart';
import 'package:not_too_shabby/view/random_video_player.dart';

class NotTooShabbyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: RandomVideoPlayer(),
    );
  }
}
