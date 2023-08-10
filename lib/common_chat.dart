import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';

import 'formChatList.dart';
import 'menu.dart';
import 'my_appbar.dart';
import 'themeProvider.dart';

class CommonChatScreen extends StatefulWidget {
  String topicName;
  CommonChatScreen({required this.topicName});
  @override
  _CommonChatScreenState createState() =>
      _CommonChatScreenState(topicName: topicName);
}

class _CommonChatScreenState extends State<CommonChatScreen> {
  String topicName;
  _CommonChatScreenState({required this.topicName});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => MenuBloc(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              appBar: MyAppBar(),
              body: Container(
                padding: const EdgeInsets.all(10.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: themeProvider.currentTheme.primaryColorDark),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TopicName(topicName: topicName),
                      Expanded(flex: 2, child: _chatMembers()),
                      Expanded(flex: 5, child: _blockMasseges()),
                      Expanded(flex: 1, child: _textAndSend()),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TopicName extends StatelessWidget {
  String topicName;
  TopicName({super.key, required this.topicName});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          child: Text(
            topicName,
            style: TextStyle(
              color: themeProvider.currentTheme.primaryColor,
              fontSize: 24,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              height: 1.24,
            ),
          ),
        );
      },
    );
  }
}

class _chatMembers extends StatefulWidget {
  @override
  _chatMembersState createState() => _chatMembersState();
}

class _chatMembersState extends State<_chatMembers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black,
    );
  }
}

class _blockMasseges extends StatefulWidget {
  @override
  _blockMassegesState createState() => _blockMassegesState();
}

class _blockMassegesState extends State<_blockMasseges> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      padding: EdgeInsets.all(8),
    );
  }
}

class _textAndSend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      padding: EdgeInsets.all(8),
    );
  }
}
