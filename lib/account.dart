import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Account {
  String email;
  String userName;
  String password;
  String avatar;
  int? id;

  Account(
      {required this.email,
      required this.userName,
      required this.password,
      required this.avatar,
      this.id});

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

  static int idFromJson(Map<String, dynamic> json) {
    return json["id"];
  }
}

void writeAccount(Account account) async {
  final acc = await SharedPreferences.getInstance();
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
    return Account(email: '', userName: '', password: '', avatar: '');
  }
}

void sendUser(Account account, BuildContext context) async {
  final url = Uri.parse('http://35.228.45.65:8800/users/');

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
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 50),
      ),
    );
  } else {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration error'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 50),
      ),
    );
  }
}

Future<Account> readAccountFromServer(String emailUser) async {
  final url = Uri.parse('http://35.228.45.65:8800/users/');

  final jsonBody = {"email": emailUser};

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(jsonBody),
  );

  if (response.statusCode == 201) {
    final responseData = json.decode(response.body);
    final acc = Account.fromJson(responseData);
    return Account(
        email: acc.email,
        userName: acc.userName,
        password: acc.password,
        avatar: acc.avatar,
        id: acc.id);
  } else {
    return Account(email: '', userName: '', password: '', avatar: '');
  }
}

Future<Map<String, dynamic>> loginProcess(
    String emailUser, String passwordUser) async {
  final url = Uri.parse('http://35.228.45.65:8800/login/');

  final jsonBody = {
    "email": emailUser,
    "password": passwordUser,
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: jsonBody,
  );
  final responseData = json.decode(response.body);

  if (response.statusCode == 200) {
    return {
      "access_token": responseData['access_token'],
      "token_type": responseData['token_type']
    };
  } else {
    return {"access_token": '', "token_type": ''};
  }
}
