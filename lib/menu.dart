import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:provider/provider.dart';
import 'account.dart';
import 'main.dart';
import 'themeProvider.dart';
import 'dart:async';
import 'login_popup.dart';

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
  late Account _account;

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
    if (acc.name == '') {
      showPopupDialog(context);
      setState(() {
        _account = acc;
      });
    } else {
      _showPopupLogOut(acc, context);
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
                if (value == 'item5') {
                  handleLogIn(_account, context);
                } else {
                  print("Selected: $value");
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
                    'Rools of the chat',
                    style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item5',
                  child: _account.name != ''
                      ? Text(
                          'Log out: ' + _account.name,
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
              shape: RoundedRectangleBorder(
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

  void _showPopupLogOut(Account acc, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              contentPadding: EdgeInsets.all(0),
              backgroundColor: themeProvider.currentTheme.primaryColorDark,
              content: Container(
                height: 250,
                width: 260,
                clipBehavior: Clip.none,
                child: Stack(children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      height: 250,
                      width: 260,
                      alignment: Alignment.bottomLeft,
                      child: Image(
                        image: AssetImage('assets/images/sova.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 170,
                    top: 50,
                    child: Text(
                      'UHOO!',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 20,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.24,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 170,
                    top: 75,
                    child: Container(
                      child: Text(
                        'Are you sure\nyou want to leave\nthe TeamChat?',
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 12,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 1.24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        backgroundColor: themeProvider.currentTheme.shadowColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 0.50,
                              color: themeProvider.currentTheme.shadowColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Log out',
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: Color(0xFFF5FBFF),
                          fontSize: 20,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.24,
                        ),
                      ),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        writeAccount(Account(name: '', avatar: ''));
                        setState(() {
                          _account = acc;
                        });
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ));
                      },
                    ),
                  )
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
