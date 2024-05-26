import 'package:coolchat/model/tab.dart';
import 'package:coolchat/servises/tab_controller.dart';
import 'package:flutter/material.dart';

class MainWidgetProvider with ChangeNotifier {
  MyTab _tab = MyTab();
  bool _showAddVariant = false;
  bool _showTab = false;

  MainWidgetProvider() {
    _loadMainTab();
  }

  MyTab get tab => _tab;
  bool get showAddVariant => _showAddVariant;
  bool get showTab => _showTab;

  void _loadMainTab() async {
    _tab = await TabViewController.fetchTabAllRoom();
    notifyListeners();
  }

  void switchTab(MyTab myTab) {
    _tab = myTab;
    notifyListeners();
  }

  void switchToMain() async {
    _tab = await TabViewController.fetchTabAllRoom();
    notifyListeners();
  }

  void switchAddVariantsShow() {
    _showAddVariant = !_showAddVariant;
    notifyListeners();
  }

  void switchTabShow() {
    _showTab = !_showTab;
    notifyListeners();
  }

  void tabShow(bool show) {
    _showTab = show;
    notifyListeners();
  }
}
