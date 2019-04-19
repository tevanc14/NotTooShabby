import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class Info extends StatelessWidget {
  final double _padding = 16.0;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle aboutTextStyle = textTheme.body2;
    final TextStyle linkTextStyle = aboutTextStyle.copyWith(
      color: Colors.lightBlue,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _padding,
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              _header(
                'About',
                textTheme,
              ),
              _bodyText(
                _aboutText(
                  aboutTextStyle,
                  linkTextStyle,
                ),
              ),
              _header(
                'Watch History',
                textTheme,
              ),
              _bodyText(
                _watchHistoryText(
                  aboutTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(
    String text,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _padding,
      ),
      child: Text(
        text,
        style: textTheme.display1,
      ),
    );
  }

  Widget _bodyText(
    Widget bodyText,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: _padding,
      ),
      child: bodyText,
    );
  }

  Widget _aboutText(
    TextStyle aboutTextStyle,
    TextStyle linkTextStyle,
  ) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'This application plays a random ',
            style: aboutTextStyle,
          ),
          _LinkTextSpan(
            style: linkTextStyle,
            text: 'Not Too Shabby',
            url: 'https://www.youtube.com/playlist?'
                'list=PLRmITxmMBnX-a_FuL36egMUk2b6OcxnDa',
          ),
          TextSpan(
            text: ' video created by the ',
            style: aboutTextStyle,
          ),
          _LinkTextSpan(
            style: linkTextStyle,
            text: 'kisscactus',
            url: 'https://www.youtube.com/user/kisscactus',
          ),
          TextSpan(
            text: ' channel on YouTube. Simply press the play button '
                'and a random video will be selected and played and '
                'recorded in your watch history.',
            style: aboutTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _watchHistoryText(
    TextStyle aboutTextStyle,
  ) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'The watch history button in the app bar will take you to '
                'a page that contains all the videos you have watched on this '
                'device. It also will let you know how many videos you have '
                'watched out of all the Not Too Shabby videos available.',
            style: aboutTextStyle,
          )
        ],
      ),
    );
  }
}

class _LinkTextSpan extends TextSpan {
  _LinkTextSpan({
    TextStyle style,
    String url,
    String text,
  }) : super(
          style: style,
          text: text ?? url,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch(url);
            },
        );
}
