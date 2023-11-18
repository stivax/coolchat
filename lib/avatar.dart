import 'package:coolchat/account.dart';
import 'package:coolchat/message_provider.dart';
import 'package:coolchat/screen/private_chat.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvatarMember extends StatelessWidget {
  ImageProvider avatar;
  String name;
  int memberID;
  bool isOnline = true;
  AvatarMember(
      {required this.avatar,
      required this.name,
      required this.isOnline,
      required this.memberID});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    print(screenWidth);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTapDown: (details) {
            _showPopupMenu(context, themeProvider, details.globalPosition);
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
              /*
              Positioned(
                top: 1,
                right: 10,
                child: isOnline
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: ShapeDecoration(
                          color: themeProvider
                              .currentTheme.shadowColor,
                          shape: const OvalBorder(),
                        ),
                      )
                    : Container(),
              ),
              */
            ],
          ),
        );
      },
    );
  }

  void _showPopupMenu(
      BuildContext context, ThemeProvider themeProvider, Offset tapPosition) {
    showMenu(
      context: context,
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
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      items: [
        PopupMenuItem(
          height: 36,
          onTap: () async {
            final String id = memberID.toString();
            final account = await readAccountFuture();
            final token =
                await loginProcess(context, account.email, account.password);
            final MessageProvider messageProvider = MessageProvider(
                'wss://cool-chat.club/private/$id?token=${token["access_token"]}');
            print('id = $id , token = $token');
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PrivateChatScreen(
                      receiverName: name, messageProvider: messageProvider)),
            );
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
