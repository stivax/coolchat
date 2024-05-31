import 'dart:convert';

import 'package:coolchat/error_answer.dart';
import 'package:coolchat/model/tab.dart';
import 'package:coolchat/popap/add_tab_popup.dart';
import 'package:coolchat/rooms.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/servises/my_icons.dart';
import 'package:coolchat/servises/token_container.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TabViewController {
  static const server = Server.server;
  static const suffix = Server.suffix;

  static Future<List<MyTab>> fetchTab() async {
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
    return myTabs;
  }

  static Future<MyTab> fetchTabAllRoom() async {
    final url = Uri.https(server, '/$suffix/rooms/');
    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<Room> rooms = Room.fromJsonList(jsonList).toList();
        rooms.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return 0;
          } else if (a.isFavorite) {
            return -1;
          }
          return 1;
        });
        return MyTab(nameTab: 'All room', imageTab: 'home', rooms: rooms);
      } else {
        return MyTab(nameTab: 'All room', imageTab: 'home', rooms: []);
      }
    } catch (error) {
      return MyTab(nameTab: 'All room', imageTab: 'home', rooms: []);
    }
  }

  static Future<MyTab> fetchTabMyRoom() async {
    final token = TokenContainer.viewToken();
    if (token.token.isNotEmpty) {
      final url = Uri.https(server, '/$suffix/user_rooms/');
      try {
        http.Response response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer ${token.token["access_token"]}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode == 200) {
          String responseBody = utf8.decode(response.bodyBytes);
          List<dynamic> jsonList = jsonDecode(responseBody);
          List<Room> rooms = Room.fromJsonList(jsonList).toList();
          rooms.sort((a, b) {
            if (a.isFavorite == b.isFavorite) {
              return 0;
            } else if (a.isFavorite) {
              return -1;
            }
            return 1;
          });
          return MyTab(nameTab: 'My room', imageTab: 'favorite', rooms: rooms);
        } else {
          return MyTab(nameTab: 'My room', imageTab: 'favorite', rooms: []);
        }
      } catch (error) {
        return MyTab(nameTab: 'My room', imageTab: 'favorite', rooms: []);
      }
    } else {
      return MyTab(nameTab: 'My room', imageTab: 'favorite', rooms: []);
    }
  }

  static Future<MyTab> fetchTabSecretRoom() async {
    final token = TokenContainer.viewToken();
    if (token.token.isNotEmpty) {
      final url = Uri.https(server, '/$suffix/secret/');
      try {
        http.Response response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer ${token.token["access_token"]}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode == 200) {
          String responseBody = utf8.decode(response.bodyBytes);
          List<dynamic> jsonList = jsonDecode(responseBody);
          List<Room> rooms = Room.fromJsonList(jsonList).toList();
          rooms.sort((a, b) {
            if (a.isFavorite == b.isFavorite) {
              return 0;
            } else if (a.isFavorite) {
              return -1;
            }
            return 1;
          });
          return MyTab(
              nameTab: 'My secret room', imageTab: 'lock', rooms: rooms);
        } else {
          return MyTab(nameTab: 'My secret room', imageTab: 'lock', rooms: []);
        }
      } catch (error) {
        return MyTab(nameTab: 'My secret room', imageTab: 'lock', rooms: []);
      }
    } else {
      return MyTab(nameTab: 'My secret room', imageTab: 'lock', rooms: []);
    }
  }

  static Future<List<MyTab>> fetchAllTab() async {
    final token = TokenContainer.viewToken();
    if (token.token.isNotEmpty) {
      final url = Uri.https(server, '/$suffix/tabs/');
      try {
        http.Response response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer ${token.token["access_token"]}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode == 200) {
          String responseBody = utf8.decode(response.bodyBytes);
          Map<String, dynamic> jsonList = jsonDecode(responseBody);
          List<MyTab> tabs = MyTab.fromJsonList(jsonList);

          return tabs;
        } else {
          return [];
        }
      } catch (error) {
        return [];
      }
    } else {
      return [];
    }
  }

  static Future<String> createTab(String tabName, String tabIcon) async {
    final token = TokenContainer.viewToken();
    final url = Uri.https(server, '/$suffix/tabs/');

    final jsonBody = {
      "name_tab": tabName,
      "image_tab": tabIcon,
    };
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${token.token["access_token"]}',
        'Content-Type': 'application/json'
      },
      body: json.encode(jsonBody),
    );
    if (response.statusCode == 200) {
      return '';
    } else {
      final responseData = json.decode(response.body);
      final error = ErrorAnswer.fromJson(responseData);
      return '${error.detail}';
    }
  }

  static Future<String> putRoomInTab(int tabId, int roomId) async {
    final token = TokenContainer.viewToken();
    final url = Uri.https(server, '/$suffix/tabs/add-room-to-tab/$tabId');

    final jsonBody = '[$roomId]';
    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer ${token.token["access_token"]}',
        'Content-Type': 'application/json'
      },
      body: jsonBody,
    );
    if (response.statusCode == 200) {
      return '';
    } else {
      final responseData = json.decode(response.body);
      final error = ErrorAnswer.fromJson(responseData);
      return '${error.detail}';
    }
  }

  static List<PopupMenuEntry> tabToPopupMenuItem(ThemeProvider themeProvider,
      BuildContext context, List<MyTab> tabs, int roomId) {
    final List<PopupMenuEntry> menuItem = [];
    for (var tab in tabs) {
      menuItem.add(
        PopupMenuItem(
          height: 36,
          onTap: () async {
            await TabViewController.putRoomInTab(tab.id!, roomId);
            final provider =
                Provider.of<MainWidgetProvider>(context, listen: false);
            await provider.loadTab();
            Navigator.pop(context);
            HapticFeedback.lightImpact();
          },
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Row(
              children: <Widget>[
                Icon(
                  MyIcons.returnIconData(tab.imageTab!),
                  color: themeProvider.currentTheme.primaryColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  tab.nameTab!,
                  style:
                      TextStyle(color: themeProvider.currentTheme.primaryColor),
                ),
              ],
            ),
          ),
        ),
      );
    }
    menuItem.add(
      PopupMenuItem(
        height: 36,
        onTap: () async {
          final provider =
              Provider.of<MainWidgetProvider>(context, listen: false);
          await addTabDialog(context);
          Navigator.pop(context);
          final indexNewTab = provider.allTab.length - 1;
          await TabViewController.putRoomInTab(
              provider.allTab[indexNewTab].id!, roomId);
          await provider.loadTab();
          provider.updateCurrentTab();
          HapticFeedback.lightImpact();
        },
        child: MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.add,
                color: themeProvider.currentTheme.primaryColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Add tab',
                style:
                    TextStyle(color: themeProvider.currentTheme.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
    return menuItem;
  }

  static Future<String> deleteTab(int tabId) async {
    final token = TokenContainer.viewToken();
    if (token.token.isNotEmpty) {
      final url = Uri.https(server, '/$suffix/tabs/', {'id': tabId.toString()});
      try {
        http.Response response = await http.delete(
          url,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer ${token.token["access_token"]}',
          },
        );
        print('response ${response.statusCode}');
        if (response.statusCode == 200) {
          //String responseBody = utf8.decode(response.bodyBytes);
          //List<dynamic> jsonList = jsonDecode(responseBody);
          //List<Room> rooms = Room.fromJsonList(jsonList).toList();
          return '';
        } else {
          return '';
        }
      } catch (error) {
        return '';
      }
    } else {
      return '';
    }
  }

  static Future<void> showMenuTabFunction(BuildContext context,
      ThemeProvider themeProvider, Offset tapPosition, int idTab) async {
    await showMenu(
      context: context,
      color: themeProvider.currentTheme.hintColor,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      shape: RoundedRectangleBorder(
        side:
            BorderSide(width: 1, color: themeProvider.currentTheme.shadowColor),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      items: [
        PopupMenuItem(
          height: 36,
          onTap: () async {
            await TabViewController.deleteTab(idTab);
            HapticFeedback.lightImpact();
          },
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Text(
              'Delete tab',
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
      elevation: 8.0,
      shadowColor: themeProvider.currentTheme.cardColor,
    );
  }
}
