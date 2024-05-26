import 'dart:convert';

import 'package:coolchat/error_answer.dart';
import 'package:coolchat/model/tab.dart';
import 'package:coolchat/rooms.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/my_icons.dart';
import 'package:coolchat/servises/token_container.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class TabViewController {
  static const server = Server.server;
  static const suffix = Server.suffix;

  static getTab() {}

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
  }

  static Future<MyTab> fetchTabSecretRoom() async {
    final token = TokenContainer.viewToken();
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
        return MyTab(nameTab: 'My secret room', imageTab: 'lock', rooms: rooms);
      } else {
        return MyTab(nameTab: 'My secret room', imageTab: 'lock', rooms: []);
      }
    } catch (error) {
      return MyTab(nameTab: 'My secret room', imageTab: 'lock', rooms: []);
    }
  }

  static Future<List<MyTab>> fetchAllTab() async {
    final token = TokenContainer.viewToken();
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
    print('tab $tabId room $roomId');
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
    print(response.statusCode);
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
    tabs.forEach((tab) {
      menuItem.add(
        PopupMenuItem(
          height: 36,
          onTap: () async {
            await TabViewController.putRoomInTab(tab.id!, roomId);
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
    });
    return menuItem;
  }
}
