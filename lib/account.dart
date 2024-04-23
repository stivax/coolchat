import 'dart:convert';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'bloc/token_blok.dart';
import 'bloc/token_event.dart';
import 'error_answer.dart';
import 'package:coolchat/servises/message_private_push_container.dart';

import 'theme_provider.dart';

class Account {
  String email;
  String userName;
  String password;
  String avatar;
  int id;

  Account(
      {required this.email,
      required this.userName,
      required this.password,
      required this.avatar,
      required this.id});

  Map<String, dynamic> toJsonWithId() {
    return {
      "email": email,
      "user_name": userName,
      "password": password,
      "avatar": avatar,
      "id": id,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "user_name": userName,
      "password": password,
      "avatar": avatar,
      "id": id
    };
  }

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      email: json["email"],
      userName: json["user_name"],
      password: json["password"],
      avatar: json["avatar"],
      id: json["id"],
    );
  }

  static Account fromJsonWithPassword(
      Map<String, dynamic> json, String password) {
    return Account(
      email: json["email"],
      userName: json["user_name"],
      password: password,
      avatar: json["avatar"],
      id: json["id"],
    );
  }

  static Map<String, String> fromJsonToken(Map<String, dynamic> json) {
    final token = <String, String>{};

    token['access_token'] = json['access_token'];
    token['token_type'] = json['token_type'];

    return token;
  }

  static int idFromJson(Map<String, dynamic> json) {
    return json["id"];
  }
}

Future<void> writeAccountInStorage(
    Account account, BuildContext context) async {
  final storage = FlutterSecureStorage();
  await storage.write(key: 'email', value: account.email);
  await storage.write(key: 'userName', value: account.userName);
  await storage.write(key: 'password', value: account.password);
  await storage.write(key: 'avatar', value: account.avatar);
  await storage.write(key: 'id', value: account.id.toString());
  //final acc = await SharedPreferences.getInstance();
  //final toWrite = jsonEncode(account);
  //acc.setString("account", toWrite);
  final accountProvider = Provider.of<AccountProvider>(context, listen: false);
  accountProvider.addAccount(account);
}

Future<Account> readAccountFromStorage() async {
  final storage = FlutterSecureStorage();
  try {
    String? email = await storage.read(key: 'email');

    if (email != null) {
      String? userName = await storage.read(key: 'userName');
      String? password = await storage.read(key: 'password');
      String? avatar = await storage.read(key: 'avatar');
      String? id = await storage.read(key: 'id');
      return Account(
          email: email,
          userName: userName!,
          password: password!,
          avatar: avatar!,
          id: int.parse(id!));
    } else {
      return Account(email: '', userName: '', password: '', avatar: '', id: 0);
    }
  } on Exception catch (_) {
    return Account(email: '', userName: '', password: '', avatar: '', id: 0);
  }
}

Future<String> sendUser(Account account, BuildContext context) async {
  const server = Server.server;
  const suffix = Server.suffix;
  final url = Uri.https(server, '/$suffix/users/');

  final jsonBody = {
    "email": account.email,
    "user_name": account.userName,
    "password": account.password,
    "avatar": account.avatar,
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(jsonBody),
  );

  if (response.statusCode == 201) {
    final responseData = json.decode(response.body);
    final id = responseData["id"].toString();
    return id;
  } else {
    final responseData = json.decode(response.body);
    final error = ErrorAnswer.fromJson(responseData);
    return '${error.detail}';
    //'Registration ${account.email} error';
  }
}

Future<String?> validationUser(String userName) async {
  const server = Server.server;
  const suffix = Server.suffix;
  final url = Uri.https(server, '/$suffix/users/audit/$userName');
  print(url);

  final response = await http.get(url);
  print(response.body);

  if (response.statusCode == 200) {
    return 'User with nickname $userName\nalready exist';
  } else {
    return null;
  }
}

Future<Account> readAccountFromServer(
    BuildContext context, String emailUser, String password) async {
  const server = Server.server;
  const suffix = Server.suffix;
  final url = Uri.https(server, '/$suffix/users/$emailUser');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final responseData = json.decode(utf8.decode(response.bodyBytes));
    final acc = Account.fromJsonWithPassword(responseData, password);
    return Account(
        email: acc.email,
        userName: acc.userName,
        password: acc.password,
        avatar: acc.avatar,
        id: acc.id);
  } else {
    final responseData = json.decode(response.body);
    final error = ErrorAnswer.fromJson(responseData);
    return Account(
        email: '${error.detail}',
        userName: '',
        password: '',
        avatar: '',
        id: 0);
  }
}

Future<Map<String, dynamic>> loginProcess(
    String emailUser, String passwordUser) async {
  String email = Uri.encodeComponent(emailUser);
  String password = Uri.encodeComponent(passwordUser);
  String server = Server.server;
  String suffix = Server.suffix;

  String body = 'username=$email&password=$password';

  try {
    final response = await http.post(
      Uri.https(server, '/$suffix/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      return Account.fromJsonToken(responseData);
    } else {
      return {"access_token": "", "token_type": ""};
    }
  } catch (error) {
    return {"access_token": "", "token_type": ""};
  }
}
