import 'dart:io';

import 'package:coolchat/servises/file_controller.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:coolchat/widget/content_view_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoPath;
  bool fileSend;

  VideoPlayerPage({super.key, required this.videoPath, required this.fileSend});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  File? videoFile;
  Future<void>? _initialize;

  @override
  void initState() {
    super.initState();
    _initialize = _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoPath = await FileController.getFilePathInCache(widget.videoPath);
    await Future.delayed(Duration(seconds: 2));
    _controller = VideoPlayerController.file(File(videoPath!))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _seekRelative(int seconds) {
    final position = _controller!.value.position;
    final newPosition = position + Duration(seconds: seconds);
    _controller!.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    String videoName =
        widget.videoPath.substring(widget.videoPath.lastIndexOf('/') + 1);
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor: themeProvider.currentTheme.primaryColorDark,
        drawerScrimColor: themeProvider.currentTheme.primaryColorDark,
        appBar: ContentViewAppBar(
            titleText: videoName,
            fileSend: widget.fileSend,
            imageUrl: widget.videoPath,
            themeProvider: themeProvider),
        body: Center(
          child: FutureBuilder<void>(
            future: _initialize,
            builder: (context, snapshot) {
              if (_controller != null && _controller!.value.isInitialized) {
                return AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller!),
                      Container(
                        color: themeProvider.currentTheme.shadowColor
                            .withOpacity(0.5),
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.replay_5,
                                  color:
                                      themeProvider.currentTheme.primaryColor),
                              onPressed: () {
                                _seekRelative(-5);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                _controller!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: themeProvider.currentTheme.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller!.value.isPlaying
                                      ? _controller!.pause()
                                      : _controller!.play();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.forward_5,
                                  color:
                                      themeProvider.currentTheme.primaryColor),
                              onPressed: () {
                                _seekRelative(5);
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        /*floatingActionButton: FutureBuilder<void>(
          future: _initialize,
          builder: (context, snapshot) {
            return FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            );
          },
        ),*/
      );
    });
  }
}
