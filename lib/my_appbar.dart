import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu.dart';
import 'theme_provider.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AppBar(
          toolbarHeight: 56,
          backgroundColor: themeProvider.currentTheme.primaryColorDark,
          title: Container(
            width: 70,
            height: 35,
            child: Image(
              image: themeProvider.isLightMode
                  ? AssetImage('assets/images/logo_light_tema.png')
                  : AssetImage('assets/images/logo_dark_tema.png'),
            ),
          ),
          leading: MainDropdownMenu(),
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                  child: Image(
                    image: themeProvider.isLightMode
                        ? AssetImage('assets/images/toogle_light.png')
                        : AssetImage('assets/images/toogle_dark.png'),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                GestureDetector(
                  onTap: () {},
                  child: Image(
                    image: themeProvider.isLightMode
                        ? AssetImage('assets/images/lang_en_light.png')
                        : AssetImage('assets/images/lang_en_dark.png'),
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
