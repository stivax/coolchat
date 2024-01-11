import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/my_appbar.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class RoolsOfChat extends StatelessWidget {
  const RoolsOfChat({super.key});

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rools of the chat',
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 24,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      pointRools(
                          'assets/images/rools01.png',
                          'Be polite and respect other users. ',
                          'Avoid rudeness, offensive language and threats. Respect the opinions of others, even if you don\'t agree with them.',
                          themeProvider,
                          true),
                      pointRools(
                          'assets/images/rools02.png',
                          'Avoid spam and flooding.',
                          'Do not send many messages at once, do not write unrelated or unnecessary texts.',
                          themeProvider,
                          false),
                      pointRools(
                          'assets/images/rools03.png',
                          'Do not use caps lock or lots of punctuation.',
                          'It can look like yelling or being overly emotional.',
                          themeProvider,
                          true),
                      pointRools(
                          'assets/images/rools04.png',
                          'Avoid political and religious discussions unless it is the topic of the chat.',
                          'Such topics can cause conflicts and misunderstandings.',
                          themeProvider,
                          false),
                      pointRools(
                          'assets/images/rools05.png',
                          'Be careful about privacy. ',
                          'Do not share personal information about yourself or other users.',
                          themeProvider,
                          true),
                      pointRools(
                          'assets/images/rools06.png',
                          'Do not use offensive or obscene language. ',
                          'Such expressions can offend others and violate the civility of the chat.',
                          themeProvider,
                          false),
                      pointRools(
                          'assets/images/rools07.png',
                          'Be patient and friendly. ',
                          'Communicate with others as you want to be communicated with.',
                          themeProvider,
                          true),
                      pointRools(
                          'assets/images/rools08.png',
                          'Do not post unnatural or false information.',
                          'Avoid spreading myths, deception or false information.',
                          themeProvider,
                          false),
                      pointRools(
                          'assets/images/rools09.png',
                          'Be careful when using emojis and emoticons. ',
                          'What may look like a joke to you may be perceived as offensive by other users.',
                          themeProvider,
                          true),
                      pointRools(
                          'assets/images/rools10.png',
                          'If you encounter a conflict situation, please contact a chat administrator or moderator for assistance. ',
                          'Do not try to solve the situation yourself or respond to rudeness with rudeness.',
                          themeProvider,
                          false),
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
