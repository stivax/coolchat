import 'package:coolchat/screen/private_chat.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvatarMember extends StatelessWidget {
  final ImageProvider avatar;
  final String name;
  final int memberID;
  bool isOnline = true;
  final BuildContext contextAvatarMember;
  bool big;
  AvatarMember(
      {super.key,
      required this.avatar,
      required this.name,
      required this.isOnline,
      required this.memberID,
      required this.contextAvatarMember,
      required this.big});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTapDown: (details) {
            final _accountProvider =
                Provider.of<AccountProvider>(context, listen: false);
            if (_accountProvider.isLoginProvider) {
              _showPopupMenu(
                  contextAvatarMember, themeProvider, details.globalPosition);
            }
          },
          child: Padding(
            padding: EdgeInsets.only(right: big ? 4 : 0, left: big ? 4 : 0),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: avatar,
                  fit: BoxFit.cover,
                ),
                color: themeProvider.currentTheme.primaryColorDark,
                border: Border.all(
                    width: 0.50, color: themeProvider.currentTheme.shadowColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4C024A7A),
                    blurRadius: 8,
                    offset: Offset(2, 2),
                    spreadRadius: 0,
                  )
                ],
                borderRadius: BorderRadius.circular(big ? 10 : 6),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPopupMenu(BuildContext contextAvatarMember,
      ThemeProvider themeProvider, Offset tapPosition) async {
    var newTapPosition = Offset(tapPosition.dx,
        tapPosition.dy + MediaQuery.of(contextAvatarMember).viewInsets.bottom);
    FocusScope.of(contextAvatarMember).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    showMenu(
      context: contextAvatarMember,
      color: themeProvider.currentTheme.hintColor,
      position: RelativeRect.fromLTRB(
        newTapPosition.dx,
        newTapPosition.dy,
        newTapPosition.dx + 1,
        newTapPosition.dy + 1,
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
          onTap: () {
            print('start chat with ${name.toString()}');
            Navigator.push(
              contextAvatarMember,
              MaterialPageRoute(
                  builder: (contextAvatarMember) => PrivateChatScreen(
                        receiverName: name,
                        recipientId: memberID,
                        myId: memberID,
                      )),
            );
          },
          child: MediaQuery(
            data: MediaQuery.of(contextAvatarMember)
                .copyWith(textScaler: TextScaler.noScaling),
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
      ],
      elevation: 8.0,
      shadowColor: themeProvider.currentTheme.cardColor,
    );
  }
}
