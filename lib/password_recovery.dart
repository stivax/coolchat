// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:coolchat/error_answer.dart';
import 'package:coolchat/server/server.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'theme_provider.dart';
import 'account.dart';
import 'register_popup.dart';

class PasswordRecoveryDialog extends StatefulWidget {
  const PasswordRecoveryDialog({super.key});
  @override
  _PasswordRecoveryDialogState createState() => _PasswordRecoveryDialogState();
}

class _PasswordRecoveryDialogState extends State<PasswordRecoveryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  String _emailValidationAnswer = '';

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  _saveDataAndClosePopup() async {
    final requestValidation = await sendEmailToRecovery(_emailController.text);
    setState(() {
      _emailValidationAnswer = requestValidation;
    });
    if (_formKey.currentState!.validate()) {
      _showPopupAnswer(_emailValidationAnswer, true, context);
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
          content: Stack(
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
                        'Password\nrecovery',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 20,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.24,
                        ),
                        textScaler: TextScaler.noScaling,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Enter your email address below and we will send you an email to reset your password',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 0.95,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Text(
                        'E-mail',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor
                              .withOpacity(0.9),
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
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
                          FocusScope.of(context).unfocus();
                        },
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.person),
                          counterStyle: TextStyle(
                              color: themeProvider.currentTheme.primaryColor
                                  .withOpacity(0.5)),
                          border: InputBorder.none,
                          hintText: 'E-mail *',
                          hintStyle: TextStyle(
                              color: themeProvider.currentTheme.primaryColor
                                  .withOpacity(0.6)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                width: 0.50,
                                color: themeProvider.currentTheme.shadowColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                width: 0.50,
                                color: themeProvider.currentTheme.shadowColor),
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
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8, top: 8),
                //width: screenSize.width * 0.5,
                //height: screenSize.height * 0.17,
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
                    onPressed: () async {
                      handlePopupOpen();
                      await _saveDataAndClosePopup();
                    },
                    child: Text(
                      'Send',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: const Color(0xFFF5FBFF),
                        fontSize: screenSize.height * 0.03,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.24,
                      ),
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

  void _showPopupAnswer(String text, bool exist, BuildContext context) async {
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 105,
                      child: exist
                          ? Image.asset(
                              'assets/images/email_correct.png',
                              color: themeProvider.currentTheme.shadowColor,
                            )
                          : Image.asset('assets/images/fire.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: exist
                          ? Text(
                              _emailController.text,
                              textAlign: TextAlign.center,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              'Fire!',
                              textScaler: TextScaler.noScaling,
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
                          textScaler: TextScaler.noScaling,
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
    if (exist) {
      Navigator.of(context).pop();
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
      if (_emailValidationAnswer.startsWith('Email')) {
        return null;
      } else {
        return _emailValidationAnswer;
      }
    }
  }

  Future<String> sendEmailToRecovery(String email) async {
    const server = Server.server;
    final url = Uri.https(server, '/password/request/');

    final jsonBody = {"email": email};
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(jsonBody),
    );

    if (response.statusCode == 202) {
      final responseData = json.decode(response.body);
      final String answer = responseData['msg'];
      return answer;
    } else {
      final responseData = json.decode(response.body);
      final error = ErrorAnswer.fromJson(responseData);
      return '${error.detail}';
    }
  }
}
