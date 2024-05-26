import 'package:coolchat/setting.dart';
import 'package:flutter/material.dart';

class AccountSettingProvider with ChangeNotifier {
  Setting _accountSettingCurentState =
      Setting(scale: false, favoriteroomList: []);

  AccountSettingProvider() {
    _loadSetting();
  }

  Setting get accountSettingProvider => _accountSettingCurentState;

  Future<void> _loadSetting() async {
    _accountSettingCurentState = await readSetting();
    notifyListeners();
  }

  void addSetting(Setting setting) {
    _accountSettingCurentState = setting;
    notifyListeners();
  }

  Future<void> changeScale(BuildContext context) async {
    _accountSettingCurentState.scale = !_accountSettingCurentState.scale;
    await writeSetting(_accountSettingCurentState, context);
    notifyListeners();
  }

  Future<void> addRoomToFavorite(String roomName, BuildContext context) async {
    _accountSettingCurentState.favoriteroomList.add(roomName);
    await writeSetting(_accountSettingCurentState, context);
    notifyListeners();
  }

  Future<void> removeRoomIntoFavorite(
      String roomName, BuildContext context) async {
    _accountSettingCurentState.favoriteroomList.remove(roomName);
    await writeSetting(_accountSettingCurentState, context);
    notifyListeners();
  }

  Future<void> clearRoomFavorite(BuildContext context) async {
    _accountSettingCurentState.favoriteroomList.clear();
    await writeSetting(_accountSettingCurentState, context);
    notifyListeners();
  }

  Future<void> refreshScreen() async {
    print('refreshMainScreen');
    notifyListeners();
  }
}
