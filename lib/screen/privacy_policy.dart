import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/widget/main_appbar.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
            backgroundColor: themeProvider.currentTheme.primaryColorDark,
            appBar: MyAppBar(),
            body: Container(
              padding: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: themeProvider.currentTheme.primaryColorDark,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)
                                    .translate('privacy_policy_privacy_policy'),
                                textScaler: TextScaler.noScaling,
                                style: TextStyle(
                                  color:
                                      themeProvider.currentTheme.primaryColor,
                                  fontSize: 24,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/images/policy.png',
                              color: themeProvider.currentTheme.shadowColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppLocalizations.of(context)
                          .translate('privacy_policy_top'),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildListRow(
                              '1.',
                              AppLocalizations.of(context)
                                  .translate('privacy_policy_1'),
                              themeProvider),
                          buildListRow(
                              '2.',
                              AppLocalizations.of(context)
                                  .translate('privacy_policy_2'),
                              themeProvider),
                          buildListRow(
                              '3.',
                              AppLocalizations.of(context)
                                  .translate('privacy_policy_3'),
                              themeProvider),
                          buildListRow(
                              '4.',
                              AppLocalizations.of(context)
                                  .translate('privacy_policy_4'),
                              themeProvider),
                          buildListRow(
                              '5.',
                              AppLocalizations.of(context)
                                  .translate('privacy_policy_5'),
                              themeProvider),
                        ],
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)
                          .translate('privacy_policy_bottom'),
                      textScaler: TextScaler.noScaling,
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
            ),
          );
        },
      ),
    );
  }

  Widget buildListRow(String number, String text, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: themeProvider.currentTheme.primaryColor,
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                text,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: themeProvider.currentTheme.primaryColor,
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
