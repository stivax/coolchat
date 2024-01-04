import 'package:coolchat/screen/private_chat.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'message_provider.dart';
import 'server/server.dart';
import 'theme_provider.dart';
import 'account.dart';

class RoomPrivate extends StatelessWidget {
  final int recipientId;
  final String recipientName;
  final String recipientAvatar;
  bool isRead;
  final Account account;
  final BuildContext contextPrivateRoom;
  final Map<dynamic, dynamic> token;

  RoomPrivate(
      {required this.recipientId,
      required this.recipientName,
      required this.recipientAvatar,
      required this.isRead,
      required this.account,
      required this.contextPrivateRoom,
      required this.token});

  static List<RoomPrivate> fromJsonList(List<dynamic> jsonList, Account account,
      Map<dynamic, dynamic> token, BuildContext context) {
    return jsonList.map((json) {
      return RoomPrivate(
        recipientId: json['recipient_id'],
        recipientName: json['recipient_name'],
        recipientAvatar: json['recipient_avatar'],
        isRead: json['is_read'],
        account: account,
        contextPrivateRoom: context,
        token: token,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        late MessageProvider messageProvider;
        bool messageProviderCreated = false;
        const server = Server.server;
        final String id = recipientId.toString();
        const maxAttempts = 5;
        //const delayBetweenAttempts = Duration(milliseconds: 500);
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
          try {
            messageProvider = MessageProvider(
                'wss://$server/private/$id?token=${token["access_token"]}');
            messageProviderCreated = true;
            // new
            MessageProviderContainer.instance
                .addProvider('direct', messageProvider);
            break;
          } catch (e) {
            print('Error $e');
            if (attempt < maxAttempts) {
              //await Future.delayed(delayBetweenAttempts);
              print('Reconnecting... Attempt $attempt');
            } else {
              print('Max attempts reached. Connection failed.');
            }
          }
        }
        print('start chat with ${recipientName.toString()}');
        //Navigator.pop(context);
        if (messageProviderCreated) {
          Navigator.push(
            contextPrivateRoom,
            MaterialPageRoute(
                builder: (contextPrivateRoom) => PrivateChatScreen(
                    receiverName: recipientName,
                    messageProvider: messageProvider)),
          );
        }
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
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              recipientName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFF5FBFF),
                                fontSize: 12,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Expanded(
                              child: Container(width: double.infinity),
                            ),
                            Icon(
                              Icons.mail,
                              size: 20,
                              color: !isRead
                                  ? const Color(0xFFF5FBFF)
                                  : const Color(0xFFE02849),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF5FBFF),
                                fontSize: 12,
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
