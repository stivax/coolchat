import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'themeProvider.dart';
import 'account.dart';

class MyPopupDialog extends StatefulWidget {
  @override
  _MyPopupDialogState createState() => _MyPopupDialogState();
}

class _MyPopupDialogState extends State<MyPopupDialog> {
  TextEditingController _textFieldController = TextEditingController();
  String _textInput = '';
  String _selectedItems = '';
  FocusNode _textFieldFocusNode = FocusNode();

  void _addToSelectedItems(String item) {
    setState(() {
      _selectedItems = item;
    });
  }

  void _saveDataAndClosePopup() async {
    if (_textInput != '' && _selectedItems != '') {
      final acc = Account(name: _textInput, avatar: _selectedItems);
      writeAccount(acc);
      Navigator.pop(context, acc);
      _showPopupWelcome(acc, context);
    } else if (_selectedItems == '' && _textInput != '') {
      _showPopupErrorInput('Choise your avatar', context);
    } else if (_textInput == '' && _selectedItems != '') {
      _showPopupErrorInput('Choise your name', context);
    } else {
      _showPopupErrorInput('Choise your name and avatar', context);
    }
  }

  void handlePopupOpen() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = avatars();
    final screenSize = MediaQuery.of(context).size;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: themeProvider.currentTheme.primaryColorDark,
          scrollable: false,
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: screenSize.width * 0.8,
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'To send a message, write your name and choose an avatar',
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 20,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.24,
                            ),
                            textScaleFactor: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 5),
                            child: Text(
                              'Write your name',
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
                          Container(
                            padding: EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              focusNode: _textFieldFocusNode,
                              maxLength: 25,
                              controller: _textFieldController,
                              onChanged: (value) {
                                setState(() {
                                  _textInput = value;
                                });
                              },
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(_textFieldFocusNode);
                              },
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                counterStyle: TextStyle(
                                    color: themeProvider
                                        .currentTheme.primaryColor
                                        .withOpacity(0.5)),
                                border: InputBorder.none,
                                hintText: 'Name *',
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: screenSize.width * 0.8,
                    height: screenSize.height * 0.4,
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6.0,
                      mainAxisSpacing: 6.0,
                      children: List.generate(avatar.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            _addToSelectedItems(avatar[index]);
                          },
                          child: _selectedItems == avatar[index]
                              ? Avatar(
                                  image: NetworkImage(avatar[index]),
                                  isChoise: true,
                                )
                              : Avatar(
                                  image: NetworkImage(avatar[index]),
                                  isChoise: false,
                                ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: screenSize.width * 0.8, // 80% ширини екрану
              height: screenSize.height * 0.09,
              child: Center(
                child: ElevatedButton(
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
                  child: const Text(
                    'Approve',
                    textScaleFactor: 1,
                    style: TextStyle(
                      color: Color(0xFFF5FBFF),
                      fontSize: 24,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      height: 1.24,
                    ),
                  ),
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
                      child: Text(
                        text,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 1.24,
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

  void _showPopupWelcome(Account account, BuildContext context) {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 100,
                      child: Avatar(
                          image: NetworkImage(account.avatar), isChoise: false),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hello, ',
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 24,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.24,
                            ),
                          ),
                          TextSpan(
                            text: account.name,
                            style: TextStyle(
                              color: themeProvider.currentTheme.shadowColor,
                              fontSize: 24,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.24,
                            ),
                          ),
                          TextSpan(
                            text: '!',
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 24,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
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
                          'Chat',
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
}

class Avatar extends StatelessWidget {
  ImageProvider image;
  bool isChoise;
  Avatar({Key? key, required this.image, required this.isChoise})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
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
                      color: !isChoise
                          ? themeProvider.currentTheme.primaryColorDark
                          : themeProvider.currentTheme.shadowColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 0.50,
                            color: themeProvider.currentTheme.shadowColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x4C024A7A),
                          blurRadius: 3,
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
                  image: image,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<String> avatars() {
  List<String> avatars = [
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2010%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2011%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2012%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2013%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2014%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2015%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2016%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2017%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2018%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2019%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2020%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2021%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2022%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2023%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2024%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2025%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2026%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2027%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2028%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2029%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%2030%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%205%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%206%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%207%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%208%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Boy%209%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2010%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2011%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2012%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2013%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2014%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2015%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2016%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2017%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2018%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2019%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2020%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2021%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2022%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2023%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2024%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2025%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2026%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2027%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2028%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2029%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%2030%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%207%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%208%20mobile.png',
    'https://tygjaceleczftbswxxei.supabase.co/storage/v1/object/public/image_bucket/content%20common%20chat/Avatar%20Mobile/Girl%209%20mobile.png',
  ];

  return avatars;
}
