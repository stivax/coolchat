// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'account.dart';
import 'add_room_popup.dart';
import 'login_popup.dart';
import 'theme_provider.dart';

class RegisterDialog extends StatefulWidget {
  RegisterDialog({
    Key? key,
  }) : super(key: key);

  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  bool _hidePass = true;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedItems = '';

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmPassFocus = FocusNode();
  final _nickNameFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();
    _nickNameFocus.dispose();
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
      Account acc = Account(
          email: _emailController.text,
          userName: _nicknameController.text,
          password: _passwordController.text,
          avatar: _selectedItems,
          id: 0);
      final answer = await sendUser(acc, context);
      if (answer.isEmpty) {
        final token = await loginProcess(
            context, _emailController.text, _passwordController.text);
        Account acc = await readAccountFromServer(
            context, _emailController.text, _passwordController.text);
        await writeAccount(acc);
        final answer = await _showPopupWelcome(acc, context);
        Navigator.pop(context, token);
      } else {
        _showPopupErrorInput(answer, context);
      }
    } else if (_formKey.currentState!.validate() && _selectedItems == '') {
      _showPopupErrorInput(
          'It seems that you have not selected your avatar', context);
    } else {
      FocusScope.of(context).requestFocus(_emailFocus);
    }
  }

  void handlePopupOpen() {
    FocusManager.instance.primaryFocus?.unfocus();
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
          content: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
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
                                'Register \nin TeamChat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      themeProvider.currentTheme.primaryColor,
                                  fontSize: 20,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                  height: 1.24,
                                ),
                                textScaleFactor: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 5),
                              child: Text(
                                'Write your e-mail',
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
                            // email form
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              validator: _emailValidate,
                              autofocus: true,
                              focusNode: _emailFocus,
                              controller: _emailController,
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                              },
                              onFieldSubmitted: (_) {
                                _fieldFocusChange(
                                    context, _emailFocus, _passFocus);
                              },
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                helperText: 'E-mail format xxxxx@xxx.xx',
                                helperStyle: TextStyle(
                                  color: themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.5),
                                ),
                                suffixIcon: Icon(Icons.person),
                                counterStyle: TextStyle(
                                    color: themeProvider
                                        .currentTheme.primaryColor
                                        .withOpacity(0.5)),
                                border: InputBorder.none,
                                hintText: 'E-mail *',
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
                            // password form
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 5),
                              child: Text(
                                'Write your password',
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
                            TextFormField(
                              obscureText: _hidePass,
                              maxLength: 8,
                              focusNode: _passFocus,
                              controller: _passwordController,
                              validator: _passValidator,
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                              },
                              onFieldSubmitted: (_) {
                                _fieldFocusChange(
                                    context, _passFocus, _confirmPassFocus);
                              },
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                  helperText: 'Remember your password',
                                  helperStyle: TextStyle(
                                    color: themeProvider
                                        .currentTheme.primaryColor
                                        .withOpacity(0.5),
                                  ),
                                  counterStyle: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor
                                          .withOpacity(0.5)),
                                  border: InputBorder.none,
                                  hintText: 'Password *',
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
                                  suffixIcon: IconButton(
                                    icon: Icon(_hidePass
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _hidePass = !_hidePass;
                                      });
                                    },
                                  )),
                            ),
                            // confirm password form
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 5),
                              child: Text(
                                'Confirm password',
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
                            TextFormField(
                              obscureText: _hidePass,
                              maxLength: 8,
                              focusNode: _confirmPassFocus,
                              controller: _confirmPasswordController,
                              validator: _passValidator,
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                              },
                              onFieldSubmitted: (_) {
                                _fieldFocusChange(
                                    context, _confirmPassFocus, _nickNameFocus);
                              },
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                helperText: 'Confirm to remember',
                                helperStyle: TextStyle(
                                  color: themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.5),
                                ),
                                counterStyle: TextStyle(
                                    color: themeProvider
                                        .currentTheme.primaryColor
                                        .withOpacity(0.5)),
                                border: InputBorder.none,
                                hintText: 'Confirm password *',
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
                                suffixIcon: IconButton(
                                  icon: Icon(_hidePass
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _hidePass = !_hidePass;
                                    });
                                  },
                                ),
                              ),
                            ),
                            // nickname form
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 5),
                              child: Text(
                                'Write your nickname',
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
                            TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.name,
                              validator: _nameValidate,
                              maxLength: 25,
                              focusNode: _nickNameFocus,
                              controller: _nicknameController,
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                              },
                              onFieldSubmitted: (_) {
                                _fieldFocusChange(
                                    context, _nickNameFocus, FocusNode());
                              },
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                helperText: '',
                                helperStyle: TextStyle(
                                  color: themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.5),
                                ),
                                suffixIcon: Icon(Icons.person),
                                counterStyle: TextStyle(
                                    color: themeProvider
                                        .currentTheme.primaryColor
                                        .withOpacity(0.5)),
                                border: InputBorder.none,
                                hintText: 'Nickname *',
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
                      padding: const EdgeInsets.all(0.0),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => generateListAvatars()[index],
                          childCount: generateListAvatars().length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.84,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: -16.0,
                right: -16.0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the AlertDialog
                  },
                ),
              ),
            ],
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
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LoginDialog();
                          },
                        );
                      },
                      child: Text(
                        'Already registered',
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: themeProvider.currentTheme.shadowColor,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> generateListAvatars() {
    return List.generate(avatars().length, (index) {
      return GestureDetector(
        onTap: () {
          _addToSelectedItems(avatars()[index]);
        },
        child: _selectedItems == avatars()[index]
            ? Avatar(
                image: CachedNetworkImageProvider(avatars()[index]),
                isChoise: true,
              )
            : Avatar(
                image: CachedNetworkImageProvider(avatars()[index]),
                isChoise: false,
              ),
      );
    });
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

  Future<String> _showPopupWelcome(
      Account account, BuildContext context) async {
    String answer = '';
    await showDialog(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            text: account.userName,
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
                    Text(
                      'Welcome \nto the TeamChat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.24,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
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
                          Navigator.pop(context);
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
    return answer;
  }

  String? _nameValidate(String? value) {
    final nameExp = RegExp(
        r'^[a-zA-Z\u0430-\u044F\u0410-\u042F\u0456\u0406\u0457\u0407\u0491\u0490\u0454\u0404\u04E7\u04E6 ()_.]+$');
    if (value!.isEmpty) {
      return 'Name is reqired';
    } else if (!nameExp.hasMatch(value)) {
      return 'Please input correct Name';
    } else {
      return null;
    }
  }

  String? _emailValidate(String? value) {
    final emailRegExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );
    if (value!.isEmpty) {
      return 'Fild is reqired';
    } else if (!emailRegExp.hasMatch(_emailController.text)) {
      return 'Pleare input correct email';
    } else {
      return null;
    }
  }

  String? _passValidator(String? value) {
    if (_passwordController.text.length != 8) {
      return '8 character required for password';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      return 'Password does not much';
    } else {
      return null;
    }
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
                  left: 0,
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
