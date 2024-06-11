import 'package:coolchat/screen/common_chat.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'theme_provider.dart';
import 'account.dart';

class RoomPrivate extends StatelessWidget {
  final int recipientId;
  final String recipientName;
  final String recipientAvatar;
  final bool isRead;
  final Account account;
  final BuildContext contextPrivateRoom;
  final Map<dynamic, dynamic> token;

  const RoomPrivate(
      {super.key,
      required this.recipientId,
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
        recipientId: json['receiver_id'],
        recipientName: json['receiver_name'],
        recipientAvatar: json['receiver_avatar'],
        isRead: json['is_read'],
        account: account,
        contextPrivateRoom: context,
        token: token,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final _accountSettingProvider =
        Provider.of<AccountSettingProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          contextPrivateRoom,
          MaterialPageRoute(
              builder: (contextPrivateRoom) => ChatScreen(
                    screenName: recipientName,
                    screenId: recipientId,
                    hasMessage: false,
                    private: true,
                  )),
        ).then((value) => {_accountSettingProvider.refreshScreen()});
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
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  recipientName,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Color(0xFFF5FBFF),
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
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
