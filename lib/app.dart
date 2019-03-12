import 'package:flutter/material.dart';

import 'package:not_too_shabby/random_video_player.dart';
import 'package:not_too_shabby/storage_interactions.dart';

class NotTooShabbyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Storage storage = Storage(context);
    storage.loadVideoIds();

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: RandomVideoPlayer(
        title: 'Not Too Shabby',
      ),
    );
  }
}
