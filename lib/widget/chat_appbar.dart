// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beep/flutter_beep.dart';

import '../theme_provider.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String roomName;
  const ChatAppBar({
    super.key,
    required this.roomName,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
                HapticFeedback.lightImpact();
              },
              child: Text(
                roomName,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: themeProvider.currentTheme.primaryColor,
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  height: 1.24,
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: themeProvider.currentTheme.primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
                onPressed: () => {
                      FlutterBeep.playSysSound(1004),
                      HapticFeedback.lightImpact()
                    },
                icon: Icon(
                  Icons.more_vert,
                  color: themeProvider.currentTheme.primaryColor,
                )),
          ],
        );
      },
    );
  }
}
