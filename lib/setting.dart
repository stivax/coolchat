import 'dart:convert';

import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting {
  bool scale;
  List<String> favoriteroomList;

  Setting({
    required this.scale,
    required this.favoriteroomList,
  });

  Map<String, dynamic> toJson() {
    return {
      "scale": scale,
      "favoriteroomList": favoriteroomList,
    };
  }

  static Setting fromJson(Map<String, dynamic> json) {
    return Setting(
      scale: json["scale"],
      favoriteroomList: List<String>.from(json["favoriteroomList"]),
    );
  }
}

Future<void> writeSetting(Setting setting, BuildContext context) async {
  final set = await SharedPreferences.getInstance();
  final toWrite = jsonEncode(setting);
  set.setString("setting", toWrite);
  final settingProvider =
      Provider.of<AccountSettingProvider>(context, listen: false);
  settingProvider.addSetting(setting);
}

Future<Setting> readSetting() async {
  final set = await SharedPreferences.getInstance();
  final userString = set.getString("setting");

  if (userString != null) {
    Map<String, dynamic> jsonData = json.decode(userString);
    Setting account = Setting.fromJson(jsonData);
    return account;
  } else {
    return Setting(
      scale: true,
      favoriteroomList: [],
    );
  }
}
