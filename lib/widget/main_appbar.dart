// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:coolchat/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beep/flutter_beep.dart';

import '../menu.dart';
import '../theme_provider.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  String? roomName;
  MyAppBar({
    Key? key,
    this.roomName,
  }) : super(key: key);
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AppBar(
          toolbarHeight: 56,
          backgroundColor: themeProvider.currentTheme.primaryColorDark,
          title: Center(
            child: GestureDetector(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AboutChatDialog();
                  },
                );
              },
              child: SizedBox(
                height: 35,
                child: Image.asset(
                  'assets/images/logo.png',
                  color: themeProvider.currentTheme.primaryColor,
                ),
              ),
            ),
          ),
          leading: MainDropdownMenu(screenName: roomName),
          actions: [
            IconButton(
                onPressed: () => {
                      FlutterBeep.playSysSound(1004),
                      HapticFeedback.lightImpact()
                    },
                icon: Icon(
                  Icons.notifications,
                  color: themeProvider.currentTheme.primaryColor,
                )),
          ],
        );
      },
    );
  }
}
