import 'package:coolchat/account.dart';
import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/bloc/token_event.dart';
import 'package:coolchat/popap/register_popup.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:coolchat/servises/message_private_push_container.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/servises/token_container.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutPopup {
  final Account account;
  final BuildContext context;
  final TokenBloc tokenBloc;

  LogoutPopup(this.account, this.context, this.tokenBloc);

  Future<void> show() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: themeProvider.currentTheme.primaryColorDark,
              content: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: Container(
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
                        child: const Image(
                          image: AssetImage('assets/images/sova.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 170,
                      top: 50,
                      child: Text(
                        AppLocalizations.of(context).translate('logout_uhoo'),
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
                    Positioned(
                      left: 170,
                      top: 75,
                      child: Container(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('logout_are_you_sure'),
                          textScaler: TextScaler.noScaling,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          backgroundColor:
                              themeProvider.currentTheme.shadowColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 0.50,
                                color: themeProvider.currentTheme.shadowColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('logout_logout'),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            color: Color(0xFFF5FBFF),
                            fontSize: 20,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            height: 1.24,
                          ),
                        ),
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          tokenBloc.add(TokenClearEvent());
                          await writeAccountInStorage(
                              Account(
                                  email: '',
                                  userName: '',
                                  password: '',
                                  avatar: '',
                                  id: 0),
                              context);
                          MessagePrivatePushContainer.removeObjects();
                          TokenContainer.removeToken();
                          final clearFavorite = AccountSettingProvider();
                          clearFavorite.clearRoomFavorite(context);
                          final tabProvider = Provider.of<MainWidgetProvider>(
                              context,
                              listen: false);
                          tabProvider.switchToMain();
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
                      ),
                    )
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
