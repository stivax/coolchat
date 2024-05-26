import 'dart:ui';

import 'package:coolchat/rooms.dart';
import 'package:coolchat/popap/add_tab_popup.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MainFooter extends StatefulWidget {
  const MainFooter({super.key});

  @override
  State<MainFooter> createState() => _MainFooterState();
}

class _MainFooterState extends State<MainFooter> {
  bool pressed = false;
  late MainWidgetProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<MainWidgetProvider>(context, listen: false);
    provider.addListener(_onShow);
  }

  @override
  void dispose() {
    provider.removeListener(_onShow);
    super.dispose();
  }

  void _onShow() {
    setState(() {
      pressed = provider.showAddVariant;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Column(
        children: [
          AnimatedContainer(
            alignment: Alignment.bottomCenter,
            duration: const Duration(milliseconds: 500),
            curve: Curves.decelerate,
            height: pressed ? 50 : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    addRoomDialog(context);
                    provider.switchAddVariantsShow();
                  },
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                color: themeProvider.currentTheme.primaryColor
                                    .withOpacity(0.3),
                                width: 1.0,
                                style: BorderStyle.solid,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.3),
                                  themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Text(
                              'Add room',
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 20,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                height: 1.24,
                              ),
                            ),
                          ))),
                ),
                const SizedBox(
                  width: 32,
                ),
                GestureDetector(
                  onTap: () {
                    addTabDialog(context);
                    provider.switchAddVariantsShow();
                  },
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                color: themeProvider.currentTheme.primaryColor
                                    .withOpacity(0.3),
                                width: 1.0,
                                style: BorderStyle.solid,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.3),
                                  themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Text(
                              'Add tab',
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 20,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                height: 1.24,
                              ),
                            ),
                          ))),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                padding: const EdgeInsets.all(0),
                //width: 50.0,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: themeProvider.currentTheme.primaryColor
                        .withOpacity(0.3),
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeProvider.currentTheme.primaryColor.withOpacity(0.3),
                      themeProvider.currentTheme.primaryColor.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home_outlined,
                        color: themeProvider.currentTheme.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search_outlined,
                        color: themeProvider.currentTheme.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/bubble.png'),
                        IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 100),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return RotationTransition(
                                  turns: animation, child: child);
                            },
                            child: Icon(
                              pressed ? Icons.close_outlined : Icons.add,
                              key: ValueKey<bool>(pressed),
                              color: themeProvider.currentTheme.primaryColor,
                            ),
                          ),
                          onPressed: () {
                            provider.switchAddVariantsShow();
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.message_outlined,
                        color: themeProvider.currentTheme.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.account_circle_outlined,
                        color: themeProvider.currentTheme.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
