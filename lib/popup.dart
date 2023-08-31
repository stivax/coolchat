import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void _addToSelectedItems(String item) {
    setState(() {
      _selectedItems = item;
    });
  }

  void _saveDataAndClosePopup() async {
    if (_textInput != '' && _selectedItems != '') {
      final acc = Account(name: _textInput, avatar: _selectedItems);
      writeAccount(acc);
      Navigator.of(context).pop();
    } else if (_selectedItems == '' && _textInput != '') {
      _showPopupErrorInput('Choise your avatar', context);
    } else if (_textInput == '' && _selectedItems != '') {
      _showPopupErrorInput('Choise your name', context);
    } else {
      _showPopupErrorInput('Choise your name and avatar', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = avatars();
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AlertDialog(
          backgroundColor: themeProvider.currentTheme.primaryColorDark,
          scrollable: true,
          content: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To send a message, write your name and choose an avatar',
                  style: TextStyle(
                      fontSize: 20,
                      color: themeProvider.currentTheme.primaryColor),
                  textScaleFactor: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Text(
                    'Write your name',
                    style: TextStyle(
                      color: themeProvider.currentTheme.primaryColor,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                TextFormField(
                  maxLength: 25,
                  controller: _textFieldController,
                  onChanged: (value) {
                    setState(() {
                      _textInput = value;
                    });
                  },
                  style: TextStyle(
                    color: themeProvider.currentTheme.primaryColor,
                    fontSize: 16,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    counterStyle: TextStyle(
                        color: themeProvider.currentTheme.primaryColor
                            .withOpacity(0.5)),
                    border: InputBorder.none,
                    hintText: 'Name *',
                    hintStyle: TextStyle(
                        color: themeProvider.currentTheme.primaryColor
                            .withOpacity(0.6)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                          width: 0.50,
                          color: themeProvider.currentTheme.shadowColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                          width: 0.50,
                          color: themeProvider.currentTheme.shadowColor),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: Container(
                    height: 250,
                    width: 250,
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
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: themeProvider.currentTheme.shadowColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveDataAndClosePopup,
                child: Text(
                  'Approve',
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Color(0xFFF5FBFF),
                    fontSize: 16,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    height: 1.24,
                  ),
                ),
              ),
            ),
          ],
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

void _showPopupErrorInput(String text, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor: themeProvider.currentTheme.primaryColorLight,
            title: Text(
              'Attention!',
              style: TextStyle(color: themeProvider.currentTheme.primaryColor),
            ),
            content: Text(
              text,
              style: TextStyle(color: themeProvider.currentTheme.primaryColor),
            ),
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    backgroundColor: themeProvider.currentTheme.shadowColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 0.50,
                          color: themeProvider.currentTheme.shadowColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
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
