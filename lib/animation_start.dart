// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coolchat/theme_provider.dart';

class AnimationStart extends StatelessWidget {
  final int size;
  AnimationStart({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.currentTheme.primaryColorDark,
          body: AnimationMain(
            size: size,
          ),
        );
      }),
    );
  }
}

class AnimationMain extends StatelessWidget {
  final int size;
  const AnimationMain({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child:
        Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Image(
        image: const AssetImage('assets/animation/animation_start.gif'),
        width: 200,
        height: 200,
        color: themeProvider.currentTheme.shadowColor,
      );
    }));
  }
}

class AnimationRefresh extends StatefulWidget {
  final double size;
  const AnimationRefresh({Key? key, required this.size}) : super(key: key);

  @override
  _AnimationRefreshState createState() => _AnimationRefreshState();
}

class _AnimationRefreshState extends State<AnimationRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return ScaleTransition(
        scale: _controller,
        child: Image.asset(
          'assets/images/refresh.png',
          color: themeProvider.currentTheme.primaryColor,
          width: widget.size,
          height: widget.size,
        ),
      );
    });
  }
}
