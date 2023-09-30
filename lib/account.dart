import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'themeProvider.dart';

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
        content: Text(
          'Registration successful',
          style: TextStyle(
            color: Colors.red,
            fontSize: 24,
          ),
        ),
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
  String email = Uri.encodeComponent(emailUser);
  String password = Uri.encodeComponent(passwordUser);

  String body = 'username=$email&password=$password';

  try {
    final response = await http.post(
      Uri.parse('http://35.228.45.65:8800/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      return Account.fromJsonToken(responseData);
    } else {
      print('Помилка: ${response.statusCode}');
      return {"access_token": "", "token_type": ""};
    }
  } catch (error) {
    print('Помилка: ${error}');
    return {"access_token": "", "token_type": ""};
  }
}

void showPopupLogOut(Account acc, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            contentPadding: EdgeInsets.all(0),
            backgroundColor: themeProvider.currentTheme.primaryColorDark,
            content: Container(
              height: 250,
              width: 260,
              clipBehavior: Clip.none,
              child: Stack(children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    height: 250,
                    width: 260,
                    alignment: Alignment.bottomLeft,
                    child: Image(
                      image: AssetImage('assets/images/sova.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Positioned(
                  left: 170,
                  top: 50,
                  child: Text(
                    'UHOO!',
                    textScaleFactor: 1,
                    style: TextStyle(
                      color: themeProvider.currentTheme.primaryColor,
                      fontSize: 20,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      height: 1.24,
                    ),
                  ),
                ),
                Positioned(
                  left: 170,
                  top: 75,
                  child: Container(
                    child: Text(
                      'Are you sure\nyou want to leave\nthe TeamChat?',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      backgroundColor: themeProvider.currentTheme.shadowColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 0.50,
                            color: themeProvider.currentTheme.shadowColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Log out',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: Color(0xFFF5FBFF),
                        fontSize: 20,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.24,
                      ),
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      writeAccount(Account(
                          email: '', userName: '', password: '', avatar: ''));
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                      ));
                    },
                  ),
                )
              ]),
            ),
          );
        },
      );
    },
  );
}
