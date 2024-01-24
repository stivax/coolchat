import 'package:coolchat/avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'messages.dart';

class Member extends StatelessWidget {
  ImageProvider avatar;
  String name;
  int memberID;
  bool isOnline = true;
  final BuildContext contextMember;
  Member(
      {super.key,
      required this.avatar,
      required this.name,
      required this.isOnline,
      required this.memberID,
      required this.contextMember});

  factory Member.fromJson(Map<String, dynamic> json, BuildContext context) {
    return Member(
      avatar: NetworkImage(json['avatar']),
      name: json['user_name'],
      memberID: json['user_id'],
      isOnline: true,
      contextMember: context,
    );
  }

  static Set<Member> fromJsonSet(
      Map<String, dynamic> json, BuildContext context) {
    Set<Member> members = {};
    if (json['type'] == 'active_users' && json['data'] != null) {
      var memberList = json['data'] as List;
      for (var memberJson in memberList) {
        var member = Member.fromJson(memberJson, context);
        if (!members.any(
            (existingMember) => existingMember.memberID == member.memberID)) {
          members.add(member);
        }
      }
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
          child: SizedBox(
            width: 65,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: AvatarMember(
                      avatar: avatar,
                      name: name,
                      isOnline: isOnline,
                      memberID: memberID,
                      contextAvatarMember: contextMember,
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
