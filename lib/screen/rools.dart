import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/widget/main_appbar.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class RoolsOfChat extends StatelessWidget {
  const RoolsOfChat({super.key});

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
            body: Container(
              padding: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: themeProvider.currentTheme.primaryColorDark,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .translate('rules_of_the_chat_rules'),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 24,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    pointRools(
                        'assets/images/rools01.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_1_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_1_2'),
                        themeProvider,
                        true),
                    pointRools(
                        'assets/images/rools02.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_2_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_2_2'),
                        themeProvider,
                        false),
                    pointRools(
                        'assets/images/rools03.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_3_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_3_2'),
                        themeProvider,
                        true),
                    pointRools(
                        'assets/images/rools04.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_4_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_4_2'),
                        themeProvider,
                        false),
                    pointRools(
                        'assets/images/rools05.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_5_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_5_2'),
                        themeProvider,
                        true),
                    pointRools(
                        'assets/images/rools06.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_6_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_6_2'),
                        themeProvider,
                        false),
                    pointRools(
                        'assets/images/rools07.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_7_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_7_2'),
                        themeProvider,
                        true),
                    pointRools(
                        'assets/images/rools08.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_8_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_8_2'),
                        themeProvider,
                        false),
                    pointRools(
                        'assets/images/rools09.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_9_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_9_2'),
                        themeProvider,
                        true),
                    pointRools(
                        'assets/images/rools10.png',
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_10_1'),
                        AppLocalizations.of(context)
                            .translate('rules_of_the_chat_10_2'),
                        themeProvider,
                        false),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget pointRools(String image, String text1, String text2,
      ThemeProvider themeProvider, bool left) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          left ? Container() : Expanded(flex: 3, child: Container()),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  image,
                  width: 45,
                  height: 45,
                  color: themeProvider.currentTheme.shadowColor,
                ),
                Text.rich(
                  textScaler: TextScaler.noScaling,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: text1,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: text2,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          !left ? Container() : Expanded(flex: 3, child: Container()),
        ],
      ),
    );
  }
}
