import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'members.dart';
import 'themeProvider.dart';
import 'account.dart';

class Messeges extends StatelessWidget {
  String name;
  String messege;
  bool published;
  int memberID;
  String avatar;
  bool isPrivate;
  bool isPreviousSameMember;
  int receiver;
  int id;
  String created_at;

  Account _account = Account(name: '', avatar: '');
  late Future<Account> _accountFuture;

  Messeges({
    required this.name,
    required this.messege,
    required this.published,
    required this.memberID,
    required this.avatar,
    required this.isPrivate,
    required this.isPreviousSameMember,
    required this.receiver,
    required this.id,
    required this.created_at,
  });

  static List<Messeges> fromJsonList(List<dynamic> jsonList) {
    int previousMemberID = 0;
    return jsonList.map((json) {
      bool isSameMember = json['member_id'] == previousMemberID;
      previousMemberID = json['member_id'];

      // Отримати поточний часовий пояс пристрою
      final timeZone = DateTime.now().timeZoneOffset;

      // Додати цю різницю до created_at
      DateTime createdAt = DateTime.parse(json['created_at']);
      createdAt = createdAt.add(timeZone);

      return Messeges(
        name: json['name'],
        messege: json['message'],
        published: json['published'],
        memberID: json['member_id'],
        avatar: json['avatar'],
        isPrivate: json['is_privat'],
        isPreviousSameMember: isSameMember,
        receiver: json['receiver'],
        id: json['id'],
        created_at: createdAt.toString(),
      );
    }).toList();
  }

  static String formatTime(String created) {
    DateTime dateTime = DateTime.parse(created);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd MMM HH:mm').format(dateTime);
    }
  }

  void _readDataFromFile() {
    final data = readAccountFuture();
    _accountFuture = data;
  }

  @override
  Widget build(BuildContext context) {
    if (_account.name == '') {
      _readDataFromFile();
    }
    var screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<Account>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _account = snapshot.data!;
        }
        return _account.id == this.memberID
            ? MyMessege(
                screenWidth: screenWidth,
                name: name,
                messege: messege,
                published: true,
                memberID: memberID,
                avatar: avatar,
                isPrivate: isPrivate,
                isPreviousSameMember: isPreviousSameMember,
                receiver: receiver,
                id: id,
                created_at: formatTime(created_at),
              )
            : TheirMessege(
                screenWidth: screenWidth,
                name: name,
                messege: messege,
                published: true,
                memberID: memberID,
                avatar: avatar,
                isPrivate: isPrivate,
                isPreviousSameMember: isPreviousSameMember,
                receiver: receiver,
                id: id,
                created_at: formatTime(created_at),
              );
      },
    );
  }
}

class TheirMessege extends StatelessWidget {
  final double screenWidth;
  String name;
  String messege;
  bool published;
  int memberID;
  String avatar;
  bool isPrivate;
  bool isPreviousSameMember;
  int receiver;
  int id;
  String created_at;

  TheirMessege({
    super.key,
    required this.screenWidth,
    required this.name,
    required this.messege,
    required this.published,
    required this.memberID,
    required this.avatar,
    required this.isPrivate,
    required this.isPreviousSameMember,
    required this.receiver,
    required this.id,
    required this.created_at,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.all(2),
            width: screenWidth - 52,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 3, left: 3),
                    alignment: Alignment.topCenter,
                    width: screenWidth * 0.09,
                    height: 32,
                    child: isPreviousSameMember
                        ? Container()
                        : Stack(
                            alignment: Alignment.topCenter,
                            fit: StackFit.expand,
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned(
                                top: 2,
                                right: 2,
                                left: 2,
                                bottom: 0,
                                child: Container(
                                  width: 24,
                                  height: 32,
                                  decoration: ShapeDecoration(
                                    color: themeProvider
                                        .currentTheme.primaryColorDark,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 0.50,
                                          color: themeProvider
                                              .currentTheme.shadowColor),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x4C024A7A),
                                        blurRadius: 8,
                                        offset: Offset(2, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 1,
                                right: 1,
                                left: 1,
                                bottom: 0,
                                child: Container(
                                  width: 24,
                                  height: 32,
                                  child: Image(
                                    image: NetworkImage(avatar),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                alignment: Alignment.centerLeft,
                                child: isPreviousSameMember
                                    ? Container()
                                    : Text(
                                        name,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor,
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          height: 1.30,
                                        ),
                                      ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              alignment: Alignment.centerRight,
                              child: Opacity(
                                opacity: 0.50,
                                child: Text(
                                  created_at,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10.0),
                          decoration: ShapeDecoration(
                            color: themeProvider.currentTheme.hintColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: themeProvider.currentTheme.cardColor,
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Text(
                            messege,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              height: 1.30,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.09,
                  ),
                ]),
          ),
        );
      },
    );
  }
}

class MyMessege extends StatelessWidget {
  final double screenWidth;
  String name;
  String messege;
  bool published;
  int memberID;
  String avatar;
  bool isPrivate;
  bool isPreviousSameMember;
  int receiver;
  int id;
  String created_at;

  MyMessege({
    super.key,
    required this.screenWidth,
    required this.name,
    required this.messege,
    required this.published,
    required this.memberID,
    required this.avatar,
    required this.isPrivate,
    required this.isPreviousSameMember,
    required this.receiver,
    required this.id,
    required this.created_at,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.all(2),
            width: screenWidth - 52,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.09,
                  ),
                  Expanded(
                    flex: 12,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              alignment: Alignment.centerLeft,
                              child: Opacity(
                                opacity: 0.50,
                                child: Text(
                                  created_at,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: isPreviousSameMember
                                  ? Container()
                                  : Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor,
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          height: 1.30,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10.0),
                          decoration: ShapeDecoration(
                            color: themeProvider.currentTheme.hoverColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: themeProvider.currentTheme.cardColor,
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Text(
                            messege,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              height: 1.30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 3, left: 3),
                    alignment: Alignment.topCenter,
                    width: screenWidth * 0.09,
                    height: 32,
                    child: isPreviousSameMember
                        ? Container()
                        : Stack(
                            alignment: Alignment.topCenter,
                            fit: StackFit.expand,
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned(
                                  top: 2,
                                  right: 2,
                                  left: 2,
                                  bottom: 0,
                                  child: Container(
                                    width: 24,
                                    height: 32,
                                    decoration: ShapeDecoration(
                                      color: themeProvider
                                          .currentTheme.primaryColorDark,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 0.50,
                                            color: themeProvider
                                                .currentTheme.shadowColor),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: themeProvider
                                              .currentTheme.cardColor,
                                          blurRadius: 8,
                                          offset: Offset(2, 2),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                  )),
                              Positioned(
                                top: 1,
                                right: 1,
                                left: 1,
                                bottom: 0,
                                child: SizedBox(
                                  width: 24,
                                  height: 32,
                                  child: Image(
                                    image: NetworkImage(avatar),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ]),
          ),
        );
      },
    );
  }
}
