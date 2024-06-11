import 'dart:async';

import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/popup/login_popup.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/servises/tab_controller.dart';
import 'package:coolchat/servises/my_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screen/common_chat.dart';
import '../server/server.dart';
import '../theme_provider.dart';
import '../account.dart';
import '../rooms.dart';

class TabAddDialog extends StatefulWidget {
  const TabAddDialog({super.key});

  @override
  _TabAddDialogState createState() => _TabAddDialogState();
}

class _TabAddDialogState extends State<TabAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameRoomController = TextEditingController();
  String _selectedItems = '';
  final _nameRoomFocus = FocusNode();
  List<String> listRoom = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchRoomList();
  }

  @override
  void dispose() {
    super.dispose();
    _nameRoomController.dispose();
    _nameRoomFocus.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _addToSelectedItems(String item) {
    setState(() {
      _selectedItems = item;
    });
  }

  Future<void> _saveDataAndClosePopup() async {
    if (_formKey.currentState!.validate() && _selectedItems != '') {
      final answer = await TabViewController.createTab(
          _nameRoomController.text, _selectedItems);
      if (answer == '') {
        final provider =
            Provider.of<MainWidgetProvider>(context, listen: false);
        await provider.loadTab();
        provider.tabShow(true);
        await Future.delayed(const Duration(seconds: 1));
        final countTab = provider.allTab.length;
        provider.moveToTab(countTab - 1);
        Navigator.pop(context);
        // move to tab
      } else {
        _showPopupErrorInput(answer, context);
      }
    } else if (_formKey.currentState!.validate() && _selectedItems == '') {
      _showPopupErrorInput(
          AppLocalizations.of(context).translate('add_room_image_is_reqired'),
          context);
    } else {
      FocusScope.of(context).requestFocus(_nameRoomFocus);
    }
  }

  void handlePopupOpen() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void fetchRoomList() async {
    final result = await fetchData();
    result.removeAt(0);
    setState(() {
      listRoom = result;
    });
  }

  List<Widget> makeListIconGrid() {
    final listIcons = MyIcons.getAllIconNames();
    return List.generate(listIcons.length, (index) {
      return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return GestureDetector(
            onTap: () {
              _addToSelectedItems(listIcons[index]);
            },
            child: _selectedItems == listIcons[index]
                ? Icon(MyIcons.returnIconData(listIcons[index]),
                    color: Colors.red)
                : Icon(MyIcons.returnIconData(listIcons[index]),
                    color: themeProvider.currentTheme.shadowColor));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: themeProvider.currentTheme.primaryColorDark,
          content: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  height: screenSize.height * 0.6,
                  width: screenSize.width * 0.8,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('add_tab_add'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 20,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    height: 1.24,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 5),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('add_tab_name'),
                                  style: TextStyle(
                                    color: themeProvider
                                        .currentTheme.primaryColor
                                        .withOpacity(0.9),
                                    fontSize: 16,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              // room name form
                              TextFormField(
                                keyboardType: TextInputType.name,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLength: 50,
                                validator: _roomNameValidate,
                                focusNode: _nameRoomFocus,
                                controller: _nameRoomController,
                                onTapOutside: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                onFieldSubmitted: (_) {
                                  _fieldFocusChange(
                                      context, _nameRoomFocus, FocusNode());
                                },
                                style: TextStyle(
                                  color:
                                      themeProvider.currentTheme.primaryColor,
                                  fontSize: 16,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  helperText: AppLocalizations.of(context)
                                      .translate('add_room_max_length'),
                                  helperStyle: TextStyle(
                                    color: themeProvider
                                        .currentTheme.primaryColor
                                        .withOpacity(0.5),
                                  ),
                                  suffixIcon:
                                      Icon(Icons.door_front_door_outlined),
                                  counterStyle: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor
                                          .withOpacity(0.5)),
                                  border: InputBorder.none,
                                  hintText: AppLocalizations.of(context)
                                      .translate('add_tab_name_2'),
                                  hintStyle: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor
                                          .withOpacity(0.6)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        width: 0.50,
                                        color: themeProvider
                                            .currentTheme.shadowColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        width: 0.50,
                                        color: themeProvider
                                            .currentTheme.shadowColor),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        width: 0.50, color: Colors.red),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        width: 0.50, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => makeListIconGrid()[index],
                            childCount: makeListIconGrid().length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 2.0,
                            childAspectRatio: 0.84,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    padding: const EdgeInsets.all(0),
                    alignment: Alignment.center,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      icon: Icon(
                        Icons.close,
                        color: themeProvider.currentTheme.shadowColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                backgroundColor: themeProvider.currentTheme.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                handlePopupOpen();
                _saveDataAndClosePopup();
              },
              child: Text(
                AppLocalizations.of(context).translate('add_room_approve'),
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Color(0xFFF5FBFF),
                  fontSize: screenSize.height * 0.03,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  height: 1.24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPopupErrorInput(String text, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: themeProvider.currentTheme.primaryColorDark,
              scrollable: true,
              content: SizedBox(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 105,
                      child: Image.asset('assets/images/fire.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Fire!',
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 20,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.24,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeProvider.currentTheme.primaryColor,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            height: 1.24,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          backgroundColor:
                              themeProvider.currentTheme.shadowColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 0.50,
                                color: themeProvider.currentTheme.shadowColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: Color(0xFFF5FBFF),
                            fontSize: 24,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            height: 1.24,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? _roomNameValidate(String? value) {
    final nameExp = RegExp(
        r'^(?=[^ ])(?=[\S\s]*[^\s][\S\s]*[^\s])[\w\u0430-\u044F\u0410-\u042F\u0456\u0406\u0457\u0407\u0491\u0490\u0454\u0404\u04E7\u04E6 ()_]{3,}$');
    if (value!.isEmpty) {
      _nameRoomFocus.requestFocus();
      return AppLocalizations.of(context).translate('add_room_name_is_reqired');
    } else if (!nameExp.hasMatch(value)) {
      return AppLocalizations.of(context).translate('add_room_name_correct');
    } else {
      return null;
    }
  }
}

Future<void> addTabDialog(BuildContext context) async {
  Account acc = await readAccountFromStorage();
  if (acc.userName == '') {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LoginDialog();
      },
    );
    acc = await readAccountFromStorage();
    if (acc.userName != '') {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const TabAddDialog();
        },
      );
    }
  } else {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const TabAddDialog();
      },
    );
  }
}