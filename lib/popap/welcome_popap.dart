import 'package:coolchat/account.dart';
import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/register_popup.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomePopup {
  final Account account;
  final BuildContext context;

  WelcomePopup(this.account, this.context);

  Future<void> show() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: themeProvider.currentTheme.primaryColorDark,
              scrollable: true,
              content: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: SizedBox(
                  width: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 100,
                        child: Avatar(
                            image: NetworkImage(account.avatar),
                            isChoise: false),
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('login_hello'),
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
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context).translate('login_welcome'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 1.24,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                color: themeProvider.currentTheme.shadowColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('login_chat'),
                            style: const TextStyle(
                              color: Color(0xFFF5FBFF),
                              fontSize: 24,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              height: 1.24,
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
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
}
