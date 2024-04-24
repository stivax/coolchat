// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';

import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/popap/welcome_popap.dart';
import 'package:coolchat/server/server.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'account.dart';
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
  String? answerValidator;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedItems = '';
  List<String> avatarList = [];
  bool alreadyPressedAprove = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchDataAvatarList();
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

  Future<void> fetchDataAvatarList() async {
    const server = Server.server;
    const suffix = Server.suffix;
    final url = Uri.https(server, '/$suffix/images/Avatar');
    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<String> result = [];
        for (var item in jsonList) {
          result.add(item['images']);
        }
        setState(() {
          avatarList = result;
        });
      } else {}
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> _saveDataAndClosePopup() async {
    if (_nicknameController.text.isNotEmpty) {
      answerValidator = await validationUser(_nicknameController.text);
    }
    if (_formKey.currentState!.validate() && _selectedItems != '') {
      Account acc = Account(
          email: _emailController.text,
          userName: _nicknameController.text,
          password: _passwordController.text,
          avatar: _selectedItems,
          id: 0);
      final answer = await sendUser(acc, context);
      int? answerInt = int.tryParse(answer);
      if (answerInt != null) {
        final acc = Account(
            email: _emailController.text,
            userName: _nicknameController.text,
            password: _passwordController.text,
            avatar: _selectedItems,
            id: answerInt);
        await writeAccountInStorage(acc, context);
        alreadyPressedAprove = false;
        await WelcomePopup(acc, context).show();
        Navigator.pop(context, acc);
      } else {
        alreadyPressedAprove = false;
        _showPopupErrorInput(answer, context);
      }
    } else if (_formKey.currentState!.validate() && _selectedItems == '') {
      alreadyPressedAprove = false;
      _showPopupErrorInput(
          AppLocalizations.of(context).translate('register_no_avatar'),
          context);
    } else {
      alreadyPressedAprove = false;
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
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: themeProvider.currentTheme.primaryColorDark,
          content: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: screenSize.height * 0.8,
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
                                        .translate('register_in'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor,
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
                                    AppLocalizations.of(context)
                                        .translate('login_write_your_email'),
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor
                                          .withOpacity(0.9),
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textScaleFactor: 1,
                                  ),
                                ),
                                // email form
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.noScaling),
                                  child: TextFormField(
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
                                      color: themeProvider
                                          .currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      helperText: AppLocalizations.of(context)
                                          .translate('login_email_format'),
                                      helperStyle: TextStyle(
                                        color: themeProvider
                                            .currentTheme.primaryColor
                                            .withOpacity(0.5),
                                      ),
                                      suffixIcon: Icon(Icons.person),
                                      counterStyle: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor
                                              .withOpacity(0.5)),
                                      border: InputBorder.none,
                                      hintText: AppLocalizations.of(context)
                                          .translate('login_email'),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            width: 0.50, color: Colors.red),
                                      ),
                                      focusedErrorBorder:
                                          const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            width: 0.50, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                                // password form
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, bottom: 5),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('login_write_your_password'),
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor
                                          .withOpacity(0.9),
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textScaleFactor: 1,
                                  ),
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.noScaling),
                                  child: TextFormField(
                                    obscureText: _hidePass,
                                    maxLength: 8,
                                    focusNode: _passFocus,
                                    controller: _passwordController,
                                    validator: _passValidator,
                                    onTapOutside: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    onFieldSubmitted: (_) {
                                      _fieldFocusChange(context, _passFocus,
                                          _confirmPassFocus);
                                    },
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                        helperText: AppLocalizations.of(context)
                                            .translate(
                                                'login_remember_your_password'),
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
                                        hintText: AppLocalizations.of(context)
                                            .translate('login_password'),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              width: 0.50, color: Colors.red),
                                        ),
                                        focusedErrorBorder:
                                            const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
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
                                ),
                                // confirm password form
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, bottom: 5),
                                  child: Text(
                                    AppLocalizations.of(context).translate(
                                        'register_in_confirm_password'),
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor
                                          .withOpacity(0.9),
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textScaleFactor: 1,
                                  ),
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.noScaling),
                                  child: TextFormField(
                                    obscureText: _hidePass,
                                    maxLength: 8,
                                    focusNode: _confirmPassFocus,
                                    controller: _confirmPasswordController,
                                    validator: _passValidator,
                                    onTapOutside: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    onFieldSubmitted: (_) {
                                      _fieldFocusChange(context,
                                          _confirmPassFocus, _nickNameFocus);
                                    },
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      helperText: AppLocalizations.of(context)
                                          .translate(
                                              'register_in_confirm_to_remember'),
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
                                      hintText: AppLocalizations.of(context)
                                          .translate(
                                              'register_in_confirm_password'),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            width: 0.50, color: Colors.red),
                                      ),
                                      focusedErrorBorder:
                                          const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
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
                                ),
                                // nickname form
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, bottom: 5),
                                  child: Text(
                                    AppLocalizations.of(context).translate(
                                        'register_in_write_your_nickname'),
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor
                                          .withOpacity(0.9),
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textScaleFactor: 1,
                                  ),
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.noScaling),
                                  child: TextFormField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
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
                                      color: themeProvider
                                          .currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      helperText: '',
                                      helperStyle: TextStyle(
                                        color: themeProvider
                                            .currentTheme.primaryColor
                                            .withOpacity(0.5),
                                      ),
                                      suffixIcon: Icon(Icons.person),
                                      counterStyle: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor
                                              .withOpacity(0.5)),
                                      border: InputBorder.none,
                                      hintText: AppLocalizations.of(context)
                                          .translate('register_in_nickname'),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            width: 0.50, color: Colors.red),
                                      ),
                                      focusedErrorBorder:
                                          const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                            width: 0.50, color: Colors.red),
                                      ),
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
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.only(top: 16, bottom: 0),
                            //width: screenSize.width * 0.8,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  alreadyPressedAprove
                                      ? CircularProgressIndicator(
                                          color: themeProvider
                                              .currentTheme.shadowColor,
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 10),
                                            backgroundColor: themeProvider
                                                .currentTheme.shadowColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (!alreadyPressedAprove) {
                                              alreadyPressedAprove = true;
                                              handlePopupOpen();
                                              _saveDataAndClosePopup();
                                            }
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    'register_in_approve'),
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                              color: const Color(0xFFF5FBFF),
                                              fontSize:
                                                  screenSize.height * 0.03,
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
                                          return const LoginDialog();
                                        },
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(context).translate(
                                          'register_in_already_registered'),
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                        color: themeProvider
                                            .currentTheme.shadowColor,
                                        fontSize: 16,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -16.0,
                    right: -16.0,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: themeProvider.currentTheme.shadowColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          //actions: [],
        );
      },
    );
  }

  List<Widget> generateListAvatars() {
    return List.generate(avatarList.length, (index) {
      return GestureDetector(
        onTap: () {
          _addToSelectedItems(avatarList[index]);
        },
        child: _selectedItems == avatarList[index]
            ? Avatar(
                image: CachedNetworkImageProvider(avatarList[index]),
                isChoise: true,
              )
            : Avatar(
                image: CachedNetworkImageProvider(avatarList[index]),
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
              content: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: SizedBox(
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
                                  color:
                                      themeProvider.currentTheme.shadowColor),
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
              ),
            );
          },
        );
      },
    );
  }

  String? _nameValidate(String? value) {
    final nameExp = RegExp(
        r'^[a-zA-Z\u0430-\u044F\u0410-\u042F\u0456\u0406\u0457\u0407\u0491\u0490\u0454\u0404\u04E7\u04E6 ()_.]+$');
    if (value!.isEmpty) {
      return 'Name is reqired';
    } else if (!nameExp.hasMatch(value)) {
      return 'Please input correct Name';
    } else {
      return answerValidator;
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
    final passRegExp = RegExp(
      r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!])(?!.*\s).{4,8}$',
    );
    if (!passRegExp.hasMatch(_passwordController.text)) {
      return 'Use at least one: (0-9), (a-z),\n(A-Z), (@#\$%^&+=!) length 4-8';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      return 'Password does not much';
    } else {
      return null;
    }
  }
}

class Avatar extends StatelessWidget {
  final ImageProvider image;
  final bool isChoise;
  const Avatar({super.key, required this.image, required this.isChoise});

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
