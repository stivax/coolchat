import 'package:coolchat/account.dart';
import 'package:coolchat/message_provider.dart';
import 'package:coolchat/screen/private_chat.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvatarMember extends StatelessWidget {
  final ImageProvider avatar;
  final String name;
  final int memberID;
  bool isOnline = true;
  final BuildContext contextAvatarMember;
  AvatarMember(
      {super.key,
      required this.avatar,
      required this.name,
      required this.isOnline,
      required this.memberID,
      required this.contextAvatarMember});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTapDown: (details) {
            _showPopupMenu(
                contextAvatarMember, themeProvider, details.globalPosition);
          },
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
                    color: themeProvider.currentTheme.primaryColorDark,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 0.50,
                          color: themeProvider.currentTheme.shadowColor),
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
                ),
              ),
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
            ],
          ),
        );
      },
    );
  }

  void _showPopupMenu(BuildContext contextAvatarMember,
      ThemeProvider themeProvider, Offset tapPosition) {
    showMenu(
      context: contextAvatarMember,
      color: themeProvider.currentTheme.primaryColorDark,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      shape: RoundedRectangleBorder(
        side:
            BorderSide(width: 1, color: themeProvider.currentTheme.shadowColor),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      items: [
        PopupMenuItem(
          height: 36,
          onTap: () async {
            late MessageProvider messageProvider;
            bool messageProviderCreated = false;
            const server = Server.server;
            final String id = memberID.toString();
            final account = await readAccountFuture();
            const maxAttempts = 5;
            const delayBetweenAttempts = Duration(milliseconds: 500);
            for (int attempt = 1; attempt <= maxAttempts; attempt++) {
              try {
                final token =
                    await loginProcess(account.email, account.password);
                messageProvider = MessageProvider(
                    'wss://$server/private/$id?token=${token["access_token"]}');
                await messageProvider.channel.ready;
                messageProviderCreated = true;
                break;
              } catch (e) {
                print('Error $e');
                if (attempt < maxAttempts) {
                  await Future.delayed(delayBetweenAttempts);
                  print('Reconnecting... Attempt $attempt');
                } else {
                  print('Max attempts reached. Connection failed.');
                }
              }
            }
            print('start chat with ${name.toString()}');
            //Navigator.pop(contextAvatarMember);
            if (messageProviderCreated) {
              Navigator.push(
                contextAvatarMember,
                MaterialPageRoute(
                    builder: (contextAvatarMember) => PrivateChatScreen(
                        receiverName: name, messageProvider: messageProvider)),
              );
            }
          },
          child: Container(
            child: Text(
              'Send private message',
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          height: 36,
          onTap: () {
            // Add code for handling "Info" here
            //Navigator.pop(context);
          },
          child: Container(
            child: Text(
              'User info',
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
      elevation: 8.0,
      shadowColor: themeProvider.currentTheme.cardColor,
    );
  }
}
