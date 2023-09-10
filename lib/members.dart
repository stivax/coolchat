import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'themeProvider.dart';
import 'messeges.dart';

class Member extends StatefulWidget {
  ImageProvider avatar;
  String name;
  int? memberID;
  bool isOnline = true;
  Member(
      {required this.avatar,
      required this.name,
      required this.isOnline,
      this.memberID});
  @override
  _MemberState createState() => _MemberState();
}

class _MemberState extends State<Member> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: Container(
            width: 65,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                            top: 5,
                            right: 5,
                            left: 5,
                            bottom: 0,
                            child: Container(
                              decoration: ShapeDecoration(
                                color:
                                    themeProvider.currentTheme.primaryColorDark,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 0.50,
                                      color: themeProvider
                                          .currentTheme.shadowColor),
                                  borderRadius: BorderRadius.circular(10),
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
                            )),
                        Positioned(
                          top: 1,
                          right: 1,
                          left: 1,
                          bottom: 0,
                          child: Image(
                            image: widget.avatar,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Positioned(
                          top: 1,
                          right: 10,
                          child: widget.isOnline
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: ShapeDecoration(
                                    color:
                                        themeProvider.currentTheme.shadowColor,
                                    shape: const OvalBorder(),
                                  ),
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 2),
                    height: screenWidth * 0.04,
                    child: Text(
                      widget.name,
                      textScaleFactor: 0.99,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: screenWidth * 0.03,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.30,
                      ),
                    ),
                  ),
                ]),
          ),
        );
      },
    );
  }
}

List<Member> getLastHourMembers(List<Messeges> messages) {
  final List<Member> members = [];

  final DateTime now = DateTime.now();
  final DateTime lastHour = now.subtract(Duration(hours: 1));

  for (final message in messages) {
    final DateTime messageDate = DateTime.parse(message.created_at);
    if (messageDate.isAfter(lastHour)) {
      final Member member = Member(
        avatar: NetworkImage(message.avatar),
        name: message.name,
        memberID: message.memberID,
        isOnline: true,
      );
      members.add(member);
    }
  }

  return members;
}

List<Member> getLastWeekMembers(List<Messeges> messages) {
  final List<Member> members = [];

  final DateTime now = DateTime.now();
  final DateTime lastHour = now.subtract(Duration(hours: 1));
  final DateTime lastWeek = now.subtract(Duration(days: 7));

  for (final message in messages) {
    final DateTime messageDate = DateTime.parse(message.created_at);
    if (messageDate.isAfter(lastWeek) && messageDate.isBefore(lastHour)) {
      final Member member = Member(
        avatar: NetworkImage(message.avatar),
        name: message.name,
        memberID: message.memberID,
        isOnline: false,
      );
      members.add(member);
    }
  }

  return members;
}

Map<String, Member> formMembersMap() {
  return {
    '00001': Member(
      avatar: AssetImage('assets/images/ava2girl.png'),
      name: 'Anna',
      isOnline: true,
    ),
    '00002': Member(
      avatar: AssetImage('assets/images/ava3girl.png'),
      name: 'Yuliia',
      isOnline: true,
    ),
    '00003': Member(
      avatar: AssetImage('assets/images/ava4girl.png'),
      name: 'Anna',
      isOnline: true,
    ),
    '00004': Member(
      avatar: AssetImage('assets/images/ava1boy.png'),
      name: 'Dmytro',
      isOnline: true,
    ),
    '00005': Member(
      avatar: AssetImage('assets/images/ava2boy.png'),
      name: 'Ivan',
      isOnline: true,
    ),
    '00006': Member(
      avatar: AssetImage('assets/images/ava3boy.png'),
      name: 'Sergii',
      isOnline: true,
    ),
  };
}
