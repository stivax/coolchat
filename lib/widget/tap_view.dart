import 'dart:ui';

import 'package:coolchat/model/tab.dart';
import 'package:coolchat/servises/my_icons.dart';
import 'package:coolchat/servises/tab_controller.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:provider/provider.dart';

class IconCarousel extends StatefulWidget {
  @override
  _IconCarouselState createState() => _IconCarouselState();
}

class _IconCarouselState extends State<IconCarousel> {
  final List<MyTab> tabs = [];
  bool showTap = false;

  int currentIndex = 0;
  late InfiniteScrollController controller;
  late MainWidgetProvider provider;

  @override
  void initState() {
    super.initState();
    controller = InfiniteScrollController();
    provider = Provider.of<MainWidgetProvider>(context, listen: false);
    provider.addListener(_onShow);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    provider.removeListener(_onShow);
  }

  void _onShow() {
    setState(() {
      showTap = provider.showTab;
    });
  }

  void onIconTap(int index) {
    setState(() {
      currentIndex = index;
    });
    controller.animateToItem(index);
  }

  Future<void> fetchTab() async {
    final allRooms = await TabViewController.fetchTabAllRoom();
    final myRoom = await TabViewController.fetchTabMyRoom();
    final mySecretRoom = await TabViewController.fetchTabSecretRoom();
    final allTab = await TabViewController.fetchAllTab();
    final List<MyTab> myTabs = [];
    myTabs.add(allRooms);
    myTabs.add(myRoom);
    myTabs.add(mySecretRoom);
    for (var t in allTab) {
      myTabs.add(t);
    }
    setState(() {
      tabs.clear();
      tabs.addAll(myTabs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Container(
            width: 50.0,
            //height: 350,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10)),
              border: Border.all(
                color: themeProvider.currentTheme.primaryColor.withOpacity(0.3),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                showTap
                    ? SizedBox(
                        height: tabs.length <= 6 ? tabs.length * 50.0 : 300.0,
                        child: InfiniteCarousel.builder(
                          center: false,
                          controller: controller,
                          axisDirection: Axis.vertical,
                          itemExtent: 50,
                          anchor: 0.0,
                          itemBuilder: (context, index, realIndex) {
                            final bool isActive = index == currentIndex;
                            final Color color = isActive
                                ? Colors.red
                                : themeProvider.currentTheme.primaryColor;
                            return IconButton(
                                onPressed: () {
                                  onIconTap(index);
                                  final tabProvider =
                                      Provider.of<MainWidgetProvider>(context,
                                          listen: false);
                                  tabProvider.switchTab(tabs[index]);
                                },
                                icon: Icon(
                                  MyIcons.returnIconData(tabs[index].imageTab!),
                                  color: color,
                                ));
                          },
                          itemCount: tabs.length,
                          onIndexChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                            final tabProvider = Provider.of<MainWidgetProvider>(
                                context,
                                listen: false);
                            tabProvider.switchTab(tabs[index]);
                            //onIconTap(index); // Call tap handler if desired
                          },
                        ),
                      )
                    : Container(),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: themeProvider.currentTheme.primaryColor
                          .withOpacity(0.2)),
                  child: IconButton(
                      onPressed: () async {
                        await fetchTab();
                        provider.switchTabShow();
                        await Future.delayed(const Duration(milliseconds: 100));
                        controller.animateToItem(currentIndex);
                      },
                      icon: Icon(
                        showTap ? Icons.arrow_downward : Icons.arrow_upward,
                        color: themeProvider.currentTheme.primaryColor,
                      )),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
