// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:coolchat/add_room_popup.dart';
import 'package:coolchat/screen/private_chat.dart';
import 'package:coolchat/server_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'screen/common_chat.dart';
import 'error_answer.dart';
import 'login_popup.dart';
import 'main.dart';
import 'message_provider.dart';
import 'server/server.dart';
import 'theme_provider.dart';
import 'account.dart';

class RoomPrivate extends StatelessWidget {
  int recipientId;
  String recipientName;
  String recipientAvatar;
  bool isRead;
  Account account;

  RoomPrivate(
      {required this.recipientId,
      required this.recipientName,
      required this.recipientAvatar,
      required this.isRead,
      required this.account});

  static List<RoomPrivate> fromJsonList(
      List<dynamic> jsonList, Account account) {
    return jsonList.map((json) {
      return RoomPrivate(
        recipientId: json['recipient_id'],
        recipientName: json['recipient_name'],
        recipientAvatar: json['recipient_avatar'],
        isRead: json['is_read'],
        account: account,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool switchColorMail = true;
    return GestureDetector(
      onTap: () async {
        const server = Server.server;
        final String id = recipientId.toString();
        final account = await readAccountFuture();
        final token =
            await loginProcess(context, account.email, account.password);
        final MessageProvider messageProvider = MessageProvider(
            'wss://$server/private/$id?token=${token["access_token"]}');
        print('id = $id , token = $token');
        //Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PrivateChatScreen(
                  receiverName: recipientName,
                  messageProvider: messageProvider)),
        );
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            height: 207,
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: themeProvider.currentTheme.primaryColorDark,
                  blurRadius: 0,
                  offset: Offset(1, 1),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/direct_chat.jpg'),
                          fit: BoxFit.cover,
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 0.50,
                              color: themeProvider.currentTheme.shadowColor),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned(
                              top: 5,
                              right: 15,
                              left: 15,
                              bottom: 0,
                              child: Container(
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1, color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 1,
                              right: 1,
                              left: 1,
                              bottom: 1,
                              child: Image(
                                image:
                                    CachedNetworkImageProvider(recipientAvatar),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: themeProvider.currentTheme.shadowColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 0.50,
                              color: themeProvider.currentTheme.shadowColor),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 4, bottom: 4),
                        child: Row(
                          //verticalDirection: VerticalDirection.down,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                recipientName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFF5FBFF),
                                  fontSize: 14,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  height: 0.09,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(width: double.infinity),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 3, bottom: 5),
                              child: Icon(
                                Icons.mail,
                                size: 20,
                                color: switchColorMail
                                    ? const Color(0xFFF5FBFF)
                                    : const Color(0xFFE02849),
                              ),
                            ),
                            const Text(
                              '0',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF5FBFF),
                                fontSize: 14,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
