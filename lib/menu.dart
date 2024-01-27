// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:coolchat/main.dart';
import 'package:coolchat/screen/privacy_policy.dart';
import 'package:coolchat/screen/private_chat_list.dart';
import 'package:coolchat/screen/rools.dart';
import 'package:coolchat/servises/message_private_push_container.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:coolchat/server/server.dart';

import 'account.dart';
import 'bloc/token_blok.dart';
import 'bloc/token_event.dart';
import 'bloc/token_state.dart';
import 'login_popup.dart';
import 'theme_provider.dart';

enum MenuStatus { open, closed }

class MenuState extends Equatable {
  final MenuStatus status;

  const MenuState(this.status);

  @override
  List<Object> get props => [status];
}

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class ToggleMenu extends MenuEvent {}

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState(MenuStatus.closed));

  @override
  Stream<MenuState> mapEventToState(MenuEvent event) async* {
    if (event is ToggleMenu) {
      yield state.status == MenuStatus.open
          ? const MenuState(MenuStatus.closed)
          : const MenuState(MenuStatus.open);
    }
  }
}

class MainDropdownMenu extends StatefulWidget {
  String? roomName;
  MainDropdownMenu({
    super.key,
    this.roomName,
  });
  @override
  State<MainDropdownMenu> createState() => _MainDropdownMenuState();
}

class _MainDropdownMenuState extends State<MainDropdownMenu> {
  Account _account =
      Account(email: '', userName: '', password: '', avatar: '', id: 0);
  late Timer _timer;
  bool haveNewMessages = false;

  @override
  void initState() {
    super.initState();
    _readDataFromFile();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      checkNewMessage();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void checkNewMessage() {
    MessagePrivatePushContainer.removeOldObjects();
    if (MessagePrivatePushContainer.viewSet().isNotEmpty) {
      setState(() {
        haveNewMessages = true;
      });
    } else {
      setState(() {
        haveNewMessages = false;
      });
    }
  }

  void _readDataFromFile() async {
    final data = await readAccountFuture();

    setState(() {
      _account = data;
    });
  }

  Future<void> handleLogIn(
      Account acc, TokenBloc tokenBloc, BuildContext context) async {
    if (acc.userName == '') {
      final account = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return LoginDialog();
        },
      );
      setState(() {
        _account = account;
      });
    } else {
      setState(() {
        _account =
            Account(email: '', userName: '', password: '', avatar: '', id: 0);
      });
      await writeAccount(_account, context);
      showPopupLogOut(acc, tokenBloc, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _readDataFromFile();
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return BlocBuilder<TokenBloc, TokenState>(builder: (context, state) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return PopupMenuButton<String>(
                offset: const Offset(0, kToolbarHeight),
                onSelected: (value) async {
                  FocusScope.of(context).unfocus();
                  if (value == 'item7') {
                    final TokenBloc tokenBloc = context.read<TokenBloc>();
                    await handleLogIn(_account, tokenBloc, context);
                    if (_account.id != 0 && widget.roomName != null) {
                      tokenBloc.add(TokenLoadEvent(
                          roomName: widget.roomName, type: 'ws'));
                    } else {
                      //tokenBloc.add(TokenClearEvent());
                    }
                  } else if (value == 'item6') {
                    const url = Server.server;
                    openUrl(url);
                  } else if (value == 'item2') {
                    if (_account.email.isNotEmpty) {
                      MessageProviderContainer.instance
                          .getProvider('direct')
                          ?.channel
                          .sink
                          .close();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivateChatList(),
                        ),
                      );
                    } else {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return LoginDialog();
                        },
                      );
                      final acc = await readAccountFuture();
                      if (acc.userName != '') {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivateChatList(),
                          ),
                        );
                      }
                    }
                  } else if (value == 'item1') {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  } else if (value == 'item5') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicy(),
                      ),
                    );
                  } else if (value == 'item4') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoolsOfChat(),
                      ),
                    );
                  }
                },
                icon: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/images/menu.png',
                        color: themeProvider.currentTheme.primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: haveNewMessages
                          ? Image.asset(themeProvider.isLightMode
                              ? 'assets/images/fenix_light.png'
                              : 'assets/images/fenix_dark.png')
                          : Container(),
                    )
                  ],
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'item1',
                    child: Text(
                      'Chat rooms',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.16,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item2',
                    child: Row(
                      children: [
                        Text(
                          'Personal chats',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: themeProvider.currentTheme.primaryColor,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            height: 1.16,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: haveNewMessages
                              ? Image.asset(themeProvider.isLightMode
                                  ? 'assets/images/mail_light.png'
                                  : 'assets/images/mail_dark.png')
                              : Container(),
                        ),
                      ],
                    ),
                  ),
                  /*PopupMenuItem<String>(
                    value: 'item3',
                    child: Text(
                      'Settings',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.16,
                      ),
                    ),
                  ),*/
                  PopupMenuItem<String>(
                    value: 'item4',
                    child: Text(
                      'Rules of the chat',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.16,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item5',
                    child: Text(
                      'Privacy Policy',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.16,
                      ),
                    ),
                  ),
                  /*PopupMenuItem<String>(
                    value: 'item6',
                    child: Text(
                      'Go to our website',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.16,
                      ),
                    ),
                  ),*/
                  PopupMenuItem<String>(
                    value: 'item7',
                    child: _account.userName != ''
                        ? Text(
                            'Log out: ${_account.userName}',
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.16,
                            ),
                          )
                        : Text(
                            'Log in',
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.16,
                            ),
                          ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item8',
                    child: Text(
                      'Version: v0.13.35',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor
                            .withOpacity(0.5),
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.16,
                      ),
                    ),
                  ),
                ],
                //
                color: themeProvider.currentTheme.primaryColorDark,
                elevation: 8,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
              );
            },
          );
        });
      },
    );
  }
}

void openUrl(String url) async {
  await launchUrlString('https://$url', mode: LaunchMode.externalApplication);
}
