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
