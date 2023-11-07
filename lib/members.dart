import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'messages.dart';

class Member extends StatelessWidget {
  ImageProvider avatar;
  String name;
  int memberID;
  bool isOnline = true;
  Member(
      {required this.avatar,
      required this.name,
      required this.isOnline,
      required this.memberID});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      avatar: NetworkImage(json['avatar']),
      name: json['user_name'],
      memberID: json['user_id'],
      isOnline: true,
    );
  }

  static Set<Member> fromJsonSet(Map<String, dynamic> json) {
    Set<Member> members = {};
    if (json['type'] == 'active_users' && json['data'] != null) {
      var memberList = json['data'] as List;
      memberList.forEach((memberJson) {
        var member = Member.fromJson(memberJson);
        if (!members.any(
            (existingMember) => existingMember.memberID == member.memberID)) {
          members.add(member);
        }
      });
    }
    return members;
  }

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
                            image: avatar,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Positioned(
                          top: 1,
                          right: 10,
                          child: isOnline
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
                      name,
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

List<Member> getLastHourAndWeekMembers(List<Messages> messages) {
  final Map<int, Member> membersMap = {};
  final timeZone = DateTime.now().timeZoneOffset;

  final DateTime now = DateTime.now().add(timeZone);
  final DateTime lastHour = now.subtract(const Duration(hours: 1));
  final DateTime lastWeek = now.subtract(const Duration(days: 7));

  for (final message in messages.reversed) {
    final DateTime messageDate = DateTime.parse(message.createdAt.toString());
    if (messageDate.isAfter(lastWeek)) {
      final Member member = Member(
        avatar: NetworkImage(message.avatar),
        name: message.userName,
        memberID: message.ownerId,
        isOnline: messageDate
            .isAfter(lastHour), // Определяємо isOnline відповідно до умови
      );
      membersMap[member.memberID] =
          member; // Додаємо або оновлюємо значення в Map
    }
  }

  // Перетворюємо Map в список
  var membersList = membersMap.values.toList().reversed.toList();

  // Сортуємо список за параметром isOnline (спершу онлайн, потім офлайн)
  membersList.sort((a, b) {
    if (a.isOnline && !b.isOnline) {
      return -1;
    } else if (!a.isOnline && b.isOnline) {
      return 1;
    } else {
      return 0;
    }
  });

  return membersList;
}
