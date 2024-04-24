import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/my_appbar.dart';
import 'package:coolchat/servises/locale_provider.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MenuBloc>(
          create: (context) => MenuBloc(),
        ),
        BlocProvider<TokenBloc>.value(
          value: TokenBloc(
            tokenRepository: context.read<TokenRepository>(),
          ),
        )
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
              appBar: MyAppBar(),
              body: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: themeProvider.currentTheme.primaryColorDark,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                .translate('setting_language'),
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 24,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          DropdownButton<Locale>(
                            dropdownColor:
                                themeProvider.currentTheme.primaryColorDark,
                            focusColor:
                                themeProvider.currentTheme.primaryColorLight,
                            value: Provider.of<LocaleProvider>(context,
                                    listen: false)
                                .currentLocale,
                            underline: Container(
                              height: 2,
                              color: themeProvider.currentTheme.primaryColor,
                            ),
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null) {
                                Provider.of<LocaleProvider>(context,
                                        listen: false)
                                    .setLocale(newLocale);
                              }
                            },
                            items: L10n.all.map((locale) {
                              String flag = L10n.getFlag(locale.languageCode);
                              return DropdownMenuItem(
                                value: locale,
                                child: Text(flag),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                .translate('setting_theme'),
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 24,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          DropdownButton<String>(
                            dropdownColor:
                                themeProvider.currentTheme.primaryColorDark,
                            focusColor:
                                themeProvider.currentTheme.primaryColorLight,
                            value: themeProvider.isLightMode
                                ? AppLocalizations.of(context)
                                    .translate('setting_theme_light')
                                : AppLocalizations.of(context)
                                    .translate('setting_theme_dark'),
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                            ),
                            underline: Container(
                              height: 2,
                              color: themeProvider.currentTheme.primaryColor,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue ==
                                  AppLocalizations.of(context)
                                      .translate('setting_theme_light')) {
                                themeProvider.toggleTheme(forceLightMode: true);
                              } else {
                                themeProvider.toggleTheme(
                                    forceLightMode: false);
                              }
                            },
                            items: <String>[
                              AppLocalizations.of(context)
                                  .translate('setting_theme_light'),
                              AppLocalizations.of(context)
                                  .translate('setting_theme_dark')
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          /*GestureDetector(
                            onTap: () {
                              themeProvider.toggleTheme();
                            },
                            child: SizedBox(
                              width: 48,
                              height: 26,
                              child: Image(
                                image: themeProvider.isLightMode
                                    ? const AssetImage(
                                        'assets/images/toogle_light.png')
                                    : const AssetImage(
                                        'assets/images/toogle_dark.png'),
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    ],
                  ),
                );
              }));
        },
      ),
    );
  }
}
