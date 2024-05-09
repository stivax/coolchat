import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? filePath;

  const AudioPlayerWidget({super.key, required this.filePath});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  FlutterSoundPlayer? _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player!.openPlayer();
  }

  Future<void> _togglePlaying() async {
    if (_isPlaying) {
      await _player!.stopPlayer();
    } else {
      await _player!.startPlayer(
        fromURI: widget.filePath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _player!.closePlayer();
    _player = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return GestureDetector(
        child: Icon(
          _isPlaying ? Icons.stop : Icons.play_arrow,
          color: themeProvider.currentTheme.shadowColor,
        ),
        onTap: () => _togglePlaying(),
      );
    });
  }
}
