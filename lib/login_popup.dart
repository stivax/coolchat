// ignore_for_file: use_build_context_synchronously

import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/password_recovery.dart';
import 'package:coolchat/popap/welcome_popap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'account.dart';
import 'register_popup.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});
  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  bool _hidePass = true;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool alreadyPressedAprove = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  _saveDataAndClosePopup() async {
    if (_formKey.currentState!.validate()) {
      final token =
          await loginProcess(_emailController.text, _passwordController.text);
      Account acc = await readAccountFromServer(
          context, _emailController.text, _passwordController.text);
      if (acc.userName.isNotEmpty &&
          token["access_token"].toString().isNotEmpty) {
        await writeAccountInStorage(acc, context);
        alreadyPressedAprove = false;
        await WelcomePopup(acc, context).show();
        Navigator.pop(context, acc);
      } else if (acc.userName.isNotEmpty &&
          token["access_token"].toString().isEmpty) {
        alreadyPressedAprove = false;
        _showPopupErrorInput('Email or password is not valid', context);
      } else {
        alreadyPressedAprove = false;
        _showPopupErrorInput(acc.email, context);
      }
    } else {
      alreadyPressedAprove = false;
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
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('login_login_in'),
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
                            AppLocalizations.of(context)
                                .translate('login_write_your_email'),
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
                        MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaler: TextScaler.noScaling),
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
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              helperText: AppLocalizations.of(context)
                                  .translate('login_email_format'),
                              helperStyle: TextStyle(
                                color: themeProvider.currentTheme.primaryColor
                                    .withOpacity(0.5),
                              ),
                              suffixIcon: const Icon(Icons.person),
                              counterStyle: TextStyle(
                                  color: themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.5)),
                              border: InputBorder.none,
                              hintText: AppLocalizations.of(context)
                                  .translate('login_email'),
                              hintStyle: TextStyle(
                                  color: themeProvider.currentTheme.primaryColor
                                      .withOpacity(0.6)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                borderSide: BorderSide(
                                    width: 0.50,
                                    color:
                                        themeProvider.currentTheme.shadowColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
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
                        ),
                        // password form
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 5),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('login_write_your_password'),
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor
                                  .withOpacity(0.9),
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                        ),
                        MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaler: TextScaler.noScaling),
                          child: TextFormField(
                            obscureText: _hidePass,
                            maxLength: 8,
                            focusNode: _passFocus,
                            controller: _passwordController,
                            onTapOutside: (_) {
                              FocusScope.of(context).unfocus();
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                            },
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                                helperText: AppLocalizations.of(context)
                                    .translate('login_remember_your_password'),
                                helperStyle: TextStyle(
                                  color: themeProvider.currentTheme.primaryColor
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const PasswordRecoveryDialog();
                                  },
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('login_forgot_password'),
                                textScaler: TextScaler.noScaling,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: themeProvider.currentTheme.shadowColor,
                                  fontSize: 14,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        )
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
                        Navigator.of(context).pop(); // Close the AlertDialog
                      },
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 8),
                  width: screenSize.width * 0.5,
                  height: screenSize.height * 0.17,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        alreadyPressedAprove
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: themeProvider.currentTheme.shadowColor,
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  backgroundColor:
                                      themeProvider.currentTheme.shadowColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                                      .translate('login_log_in'),
                                  textScaleFactor: 1,
                                  style: TextStyle(
                                    color: const Color(0xFFF5FBFF),
                                    fontSize: screenSize.height * 0.03,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    height: 1.24,
                                  ),
                                ),
                              ),
                        const SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            backgroundColor:
                                themeProvider.currentTheme.primaryColorDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: themeProvider.currentTheme.shadowColor,
                                width: 1,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            Account acc = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return RegisterDialog();
                              },
                            );
                            Navigator.pop(context, acc);
                          },
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('login_register'),
                            textScaler: TextScaler.noScaling,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
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
              ),
            ],
          ),
          //actions: [],
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
}
