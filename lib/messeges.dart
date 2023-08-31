import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'members.dart';
import 'themeProvider.dart';

class Messeges extends StatelessWidget {
  String messege;
  String created_at;
  String id;
  String name;
  bool published;

  Messeges(
      {required this.messege,
      required this.created_at,
      required this.id,
      required this.name,
      required this.published});

  static List<Messeges> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return Messeges(
        messege: json['message'],
        created_at: formatTime(json['created_at']),
        id: json['id'].toString(),
        name: json['name'],
        published: json['published'],
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
      return 'yesterday ' + DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('dd MMM HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return !published
        ? MyMessege(
            screenWidth: screenWidth,
            name: name,
            id: id,
            created_at: created_at,
            messege: messege,
            published: true,
          )
        : TheirMessege(
            screenWidth: screenWidth,
            name: name,
            id: id,
            created_at: created_at,
            messege: messege,
            published: true,
          );
  }
}

class TheirMessege extends StatelessWidget {
  final double screenWidth;
  String messege;
  String created_at;
  String id;
  String name;
  bool published;

  TheirMessege(
      {super.key,
      required this.screenWidth,
      required this.messege,
      required this.created_at,
      required this.id,
      required this.name,
      required this.published});

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
                    child: Stack(
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
                              color:
                                  themeProvider.currentTheme.primaryColorDark,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 0.50,
                                    color:
                                        themeProvider.currentTheme.shadowColor),
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
                              image: AssetImage('assets/images/ava2girl.png'),
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
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    height: 1.30,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                alignment: Alignment.centerRight,
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Text(
                                    created_at,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor,
                                      fontSize: 12,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
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
  String messege;
  String created_at;
  String id;
  String name;
  bool published;

  MyMessege(
      {super.key,
      required this.screenWidth,
      required this.messege,
      required this.created_at,
      required this.id,
      required this.name,
      required this.published});

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
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Text(
                                    created_at,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor,
                                      fontSize: 12,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
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
                    child: Stack(
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
                                color:
                                    themeProvider.currentTheme.primaryColorDark,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 0.50,
                                      color: themeProvider
                                          .currentTheme.shadowColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: themeProvider.currentTheme.cardColor,
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
                          child: Container(
                            width: 24,
                            height: 32,
                            child: Image(
                              image: AssetImage('assets/images/ava2girl.png'),
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
