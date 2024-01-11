import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/my_appbar.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Privacy policy',
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 24,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'This privacy policy sets out the obligations and rules regarding the collection, use and disclosure of user’s personal information when communicating on TeamChat. ',
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
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
                        'We take the privacy of our users information seriously and are committed to protecting their privacy.',
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
                                'Collection and Use of Information: We may collect personal information such as name and email address only with users permission to provide better communication and provide personalized services. We use this information only for the purpose of improving the quality of our service and providing users with appropriate answers to their questions.',
                                themeProvider),
                            buildListRow(
                                '2.',
                                'Information Security: We take all possible security measures to protect the personal information of our users from unauthorized access, alteration, disclosure or destruction. Our systems are regularly updated and checked for possible threats.',
                                themeProvider),
                            buildListRow(
                                '3.',
                                'Disclosure of information to third parties: We do not share users personal information with third parties without their consent, except as required by law.',
                                themeProvider),
                            buildListRow(
                                '4.',
                                'Use of cookies: Our Chat for communication may use cookies and other technologies to collect information and improve the user experience. Users have the option to disable cookies in their web browser settings, but this may affect the functionality of TeamChat.',
                                themeProvider),
                            buildListRow(
                                '5.',
                                'Changes to the Privacy Policy: We may periodically update this Privacy Policy to reflect changes in legal requirements or information practices. Changes take effect from the moment of their public posting on this page.',
                                themeProvider),
                          ],
                        ),
                      ),
                      Text(
                        'This privacy policy is for your protection and remains binding on all TeamChat users. If you have any questions about our privacy policy, please contact us using the contact information provided on our website.',
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
