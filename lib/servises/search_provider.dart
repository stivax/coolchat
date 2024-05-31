import 'package:coolchat/model/user_search.dart';
import 'package:coolchat/rooms.dart';
import 'package:coolchat/servises/search_controller.dart';
import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {
  List<Room> rooms = [];
  List<UserSearch> users = [];

  Future<void> searchUsersAndRooms(String searchSubstring) async {
    String result =
        await SearchingController.fetchSearchResult(searchSubstring);
    users = SearchingController.userSearchResult(result);
    rooms = SearchingController.roomSearchResult(result);
    notifyListeners();
  }

  void clear() {
    rooms.clear();
    users.clear();
    notifyListeners();
  }
}
