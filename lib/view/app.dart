import 'package:flutter/material.dart';
import 'package:not_too_shabby/view/random_video_player.dart';

class NotTooShabbyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImages(context);
    final Color background = Color(0xFF181818);

    return MaterialApp(
      theme: ThemeData(
        accentColor: Color(0xFFF9D938),
        primaryColor: Colors.black,
        brightness: Brightness.dark,
        fontFamily: 'RobotoCondensed',
        backgroundColor: background,
        canvasColor: background,
      ),
      home: RandomVideoPlayer(),
    );
  }

  void precacheImages(BuildContext context) {
    final List<String> imagePaths = [
      'assets/background.png',
      'assets/written_title.png',
      'assets/play_button.png'
    ];

    imagePaths.forEach((String imagePath) {
      precacheImage(
        AssetImage(
          imagePath,
        ),
        context,
      );
    });
  }
}
