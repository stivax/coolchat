import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class Account {
  String name;
  int? id;
  String avatar;

  Account({required this.name, required this.avatar, int? id}) {
    this.id = id ?? Random.secure().nextInt(999999999);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "avatar": avatar,
    };
  }

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      name: json["name"],
      id: json["id"],
      avatar: json["avatar"],
    );
  }
}

void writeAccount(Account account) async {
  // Створити об’єкт `SharedPreferences`.
  final acc = await SharedPreferences.getInstance();

  // Встановити ключ і значення даних.
  final toWrite = jsonEncode(account);
  acc.setString("account", toWrite);
}

Future<Account> readAccountFuture() async {
  final acc = await SharedPreferences.getInstance();
  final userString = acc.getString("account");

  if (userString != null) {
    Map<String, dynamic> jsonData = json.decode(userString);
    Account account = Account.fromJson(jsonData);
    return account;
  } else {
    return Account(name: '', avatar: '');
  }
}
