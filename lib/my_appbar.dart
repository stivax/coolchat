// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:coolchat/about.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'menu.dart';
import 'theme_provider.dart';

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
          title: GestureDetector(
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
          leading: MainDropdownMenu(roomName: roomName),
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                  child: SizedBox(
                    width: 48,
                    height: 26,
                    child: Image(
                      image: themeProvider.isLightMode
                          ? const AssetImage('assets/images/toogle_light.png')
                          : const AssetImage('assets/images/toogle_dark.png'),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: 48,
                    height: 26,
                    child: Image(
                      image: themeProvider.isLightMode
                          ? const AssetImage('assets/images/lang_en_light.png')
                          : const AssetImage('assets/images/lang_en_dark.png'),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
