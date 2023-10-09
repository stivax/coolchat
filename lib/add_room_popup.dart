import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common_chat.dart';
import 'image.dart';
import 'theme_provider.dart';
import 'account.dart';
import 'rooms.dart';

class RoomAddDialog extends StatefulWidget {
  const RoomAddDialog({super.key});

  @override
  _RoomAddDialogState createState() => _RoomAddDialogState();
}

class _RoomAddDialogState extends State<RoomAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameRoomController = TextEditingController();
  String _selectedItems = '';
  final _nameRoomFocus = FocusNode();
  List<String> listRoom = [];

  @override
  void initState() {
    fetchRoomList();
    super.initState();
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
      final acc = await readAccountFuture();
      // ignore: use_build_context_synchronously
      final answer = await sendRoom(
          context, _nameRoomController.text, _selectedItems, acc);
      if (answer == '') {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommonChatScreen(
              topicName: _nameRoomController.text,
            ),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        _showPopupErrorInput(answer, context);
      }
    } else if (_formKey.currentState!.validate() && _selectedItems == '') {
      _showPopupErrorInput(
          'It seems that you have not selected your room image', context);
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

  List<Widget> makeListRoomAvatar() {
    return List.generate(listRoom.length, (index) {
      return GestureDetector(
        onTap: () {
          _addToSelectedItems(listRoom[index]);
        },
        child: _selectedItems == listRoom[index]
            ? RoomAvatar(
                image: CachedImageProvider(listRoom[index]),
                isChoise: true,
              )
            : RoomAvatar(
                image: CachedImageProvider(listRoom[index]),
                isChoise: false,
              ),
      );
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
          content: Container(
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
                            'Add a new \nchat room',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 20,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.24,
                            ),
                            textScaleFactor: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 5),
                          child: Text(
                            'Name of the chat room',
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor
                                  .withOpacity(0.9),
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            ),
                            textScaleFactor: 1,
                          ),
                        ),
                        // room name form
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          maxLength: 50,
                          validator: _roomNameValidate,
                          autofocus: true,
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
                            color: themeProvider.currentTheme.primaryColor,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            helperText: 'Max 50 characters',
                            helperStyle: TextStyle(
                              color: themeProvider.currentTheme.primaryColor
                                  .withOpacity(0.5),
                            ),
                            suffixIcon: Icon(Icons.door_front_door_outlined),
                            counterStyle: TextStyle(
                                color: themeProvider.currentTheme.primaryColor
                                    .withOpacity(0.5)),
                            border: InputBorder.none,
                            hintText: 'Name room *',
                            hintStyle: TextStyle(
                                color: themeProvider.currentTheme.primaryColor
                                    .withOpacity(0.6)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                  width: 0.50,
                                  color:
                                      themeProvider.currentTheme.shadowColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                  width: 0.50,
                                  color:
                                      themeProvider.currentTheme.shadowColor),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(width: 0.50, color: Colors.red),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(width: 0.50, color: Colors.red),
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
                      (context, index) => makeListRoomAvatar()[index],
                      childCount: makeListRoomAvatar().length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.84,
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(bottom: 0),
              width: screenSize.width * 0.8,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
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
                        'Approve',
                        textScaleFactor: 1,
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
                          textScaleFactor: 1,
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
    final _nameExp = RegExp(r'^[a-zA-Z ]+$');
    if (value!.isEmpty) {
      return 'Name is reqired';
    } else if (!_nameExp.hasMatch(value)) {
      return 'Please input correct Name (char, number and _)';
    } else {
      return null;
    }
  }
}