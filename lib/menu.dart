import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'account.dart';
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

  void handleLogIn(Account acc, BuildContext context) {
    if (acc.userName == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return LoginDialog();
        },
      );
      setState(() {
        _account = acc;
      });
    } else {
      showPopupLogOut(acc, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _readDataFromFile();
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return PopupMenuButton<String>(
              offset: const Offset(0, kToolbarHeight),
              onSelected: (value) {
                FocusScope.of(context).unfocus();
                if (value == 'item7') {
                  handleLogIn(_account, context);
                } else if (value == 'item6') {
                  openUrl('cool-chat.club');
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
      },
    );
  }
}

void openUrl(String url) async {
  await launchUrlString(url);
}
