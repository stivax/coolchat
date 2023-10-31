import 'dart:async';

import 'package:coolchat/server/server.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  @override
  State<MainDropdownMenu> createState() => _MainDropdownMenuState();
}

class _MainDropdownMenuState extends State<MainDropdownMenu> {
  Account _account =
      Account(email: '', userName: '', password: '', avatar: '', id: 0);

  @override
  void initState() {
    super.initState();
    _readDataFromFile();
  }

  void _readDataFromFile() async {
    final data = await readAccountFuture();

    setState(() {
      _account = data;
    });
  }

  Future<void> handleLogIn(Account acc, BuildContext context) async {
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
      showPopupLogOut(acc, context);
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
                    await handleLogIn(_account, context);
                    final TokenBloc tokenBloc = context.read<TokenBloc>();
                    if (_account.id != 0) {
                      tokenBloc.add(TokenLoadEvent(
                          email: _account.email, password: _account.password));
                    } else {
                      tokenBloc.add(TokenClearEvent());
                    }
                  } else if (value == 'item6') {
                    const url = Server.server;
                    openUrl(url);
                  }
                },
                icon: Icon(Icons.menu_rounded,
                    color: themeProvider.currentTheme.primaryColor),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'item1',
                    child: Text(
                      'Chat rooms',
                      style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item2',
                    child: Text(
                      'Personal chats',
                      style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item3',
                    child: Text(
                      'Setting',
                      style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item4',
                    child: Text(
                      'Rules of the chat',
                      style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item5',
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item6',
                    child: Text(
                      'Go to our website',
                      style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'item7',
                    child: _account.userName != ''
                        ? Text(
                            'Log out: ${_account.userName}',
                            style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor),
                          )
                        : Text(
                            'Log in',
                            style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor),
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
  await launchUrlString(url);
}
