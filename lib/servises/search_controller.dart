import 'dart:convert';

import 'package:coolchat/model/user_search.dart';
import 'package:coolchat/rooms.dart';
import 'package:coolchat/server/server.dart';
import 'package:http/http.dart' as http;

class SearchingController {
  static const server = Server.server;
  static const suffix = Server.suffix;

  static Future<String> fetchSearchResult(String searchSubstring) async {
    final url = Uri.https(server, '/$suffix/search/$searchSubstring');
    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        return responseBody;
      } else {
        return '';
      }
    } catch (error) {
      return '';
    }
  }

  static List<UserSearch> userSearchResult(String searchResponse) {
    if (searchResponse.isNotEmpty) {
      List<dynamic> jsonList = jsonDecode(searchResponse)['users'];
      List<UserSearch> users = UserSearch.fromJsonList(jsonList);
      return users;
    } else {
      return [];
    }
  }

  static List<Room> roomSearchResult(String searchResponse) {
    if (searchResponse.isNotEmpty) {
      List<dynamic> jsonList = jsonDecode(searchResponse)['rooms'];
      List<Room> rooms = Room.fromJsonList(jsonList);
      return rooms;
    } else {
      return [];
    }
  }
}
