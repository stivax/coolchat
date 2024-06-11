import 'package:coolchat/model/tab.dart';
import 'package:coolchat/servises/tab_controller.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class MainWidgetProvider with ChangeNotifier {
  List<MyTab> _allTab = [];
  MyTab _tab = MyTab();
  bool _showAddVariant = false;
  bool _showTab = false;
  final InfiniteScrollController _infiniteCarouselController =
      InfiniteScrollController();

  MainWidgetProvider() {
    _loadMainTab();
  }

  MyTab get tab => _tab;
  List<MyTab> get allTab => _allTab;
  bool get showAddVariant => _showAddVariant;
  bool get showTab => _showTab;
  InfiniteScrollController get infiniteCarouselController =>
      _infiniteCarouselController;

  void _loadMainTab() async {
    _tab = await TabViewController.fetchTabAllRoom();
    notifyListeners();
  }

  Future<void> loadTab() async {
    _allTab = await TabViewController.fetchTab();
    notifyListeners();
  }

  void switchTab(MyTab myTab) {
    _tab = myTab;
    notifyListeners();
  }

  Future<void> updateCurrentTab() async {
    _allTab = await TabViewController.fetchTab();
    //_showTab = true;
    int idCurrentTab = 0;
    for (MyTab t in _allTab) {
      if (t.nameTab == _tab.nameTab) {
        break;
      }
      idCurrentTab++;
    }
    _tab = _allTab[idCurrentTab];
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500));
    _infiniteCarouselController.animateToItem(idCurrentTab);
  }

  void switchAndUpdateToMain() async {
    _tab = await TabViewController.fetchTabAllRoom();
    notifyListeners();
  }

  Future<void> moveToMain() async {
    _showTab = true;
    _tab = _allTab[0];
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500));
    _infiniteCarouselController.animateToItem(0);
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

  void moveToTab(int tabId) {
    notifyListeners();
    _infiniteCarouselController.jumpToItem(tabId);
  }
}
