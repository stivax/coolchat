import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimationStart extends StatelessWidget {
  const AnimationStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor: themeProvider.currentTheme.primaryColorDark,
        body: Center(
          child: Image(
            image: const AssetImage('assets/animation/animation_start.gif'),
            width: 200,
            height: 200,
            color: themeProvider.currentTheme.shadowColor,
          ),
        ),
      );
    });
  }
}
