import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutChatDialog extends StatelessWidget {
  const AboutChatDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: themeProvider.currentTheme.primaryColorDark,
            title: SizedBox(
              width: double.maxFinite,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Center(
                    child: Text(
                      'About us',
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
                    //top: -16.0,
                    right: -16.0,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
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
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MemberTeam(
                      name: 'Project Manager -\nIryna Pytlovana',
                      linkedIn:
                          'https://www.linkedin.com/in/iryna-pytlovana-70959312b/'),
                  const MemberTeam(
                      name: 'Designer -\nYuliia Nikolaienko',
                      linkedIn:
                          'https://www.linkedin.com/in/yuliia-nikolaienko-976392232/'),
                  const MemberTeam(
                      name: 'QA -\nOlena Kapysh',
                      linkedIn:
                          'https://www.linkedin.com/in/olena-kapysh-404b86269/'),
                  const MemberTeam(
                      name: 'BackEnd -\nDmytro Nevoit',
                      linkedIn: 'https://www.linkedin.com/in/dmytro-nevoit/'),
                  const MemberTeam(
                      name: 'FrontEnd (Web) -\nYura Platonov',
                      linkedIn: 'https://www.linkedin.com/in/yura-platonov/'),
                  const MemberTeam(
                      name: 'FrontEnd (App) -\nIvan Stepanchenko',
                      linkedIn: 'https://www.linkedin.com/in/stivax/'),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      backgroundColor: themeProvider.currentTheme.shadowColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Color(0xFFF5FBFF),
                        fontSize: 24,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //actions: [],
          );
        },
      ),
    );
  }
}

class MemberTeam extends StatelessWidget {
  final String name;
  final String linkedIn;
  const MemberTeam({
    super.key,
    required this.name,
    required this.linkedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.maxFinite,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: themeProvider.currentTheme.primaryColor,
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  height: 1.24,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await launchUrlString(linkedIn,
                        mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    height: 32,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/linkedin.png',
                      color: themeProvider.currentTheme.shadowColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
