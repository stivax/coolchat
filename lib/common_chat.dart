// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import 'formChatList.dart';
import 'menu.dart';
import 'my_appbar.dart';
import 'themeProvider.dart';

class CommonChatScreen extends StatelessWidget {
  String topicName;
  CommonChatScreen({required this.topicName});

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
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: themeProvider.currentTheme.primaryColorDark),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 40, child: TopicName(topicName: topicName)),
                      Expanded(flex: 224, child: ChatMembers()),
                      Expanded(flex: 640, child: BlockMasseges()),
                      Expanded(flex: 94, child: _textAndSend()),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TopicName extends StatefulWidget {
  String topicName;
  TopicName({super.key, required this.topicName});

  @override
  State<TopicName> createState() => _TopicNameState();
}

class _TopicNameState extends State<TopicName> {
  bool shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        shouldAnimate = _shouldAnimate();
      });
    });
  }

  bool _shouldAnimate() {
    double screenWidth = MediaQuery.of(context).size.width;
    double textWidth = calculateTextWidth() + 32;
    return textWidth > screenWidth;
  }

  double calculateTextWidth() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'Topic: ' + widget.topicName,
        style: const TextStyle(
          fontSize: 24,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          height: 1.24,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: EdgeInsets.all(1),
          alignment: Alignment.topLeft,
          child: Center(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                child: shouldAnimate
                    ? Marquee(
                        text: 'Topic: ' + widget.topicName,
                        textScaleFactor: 0.97,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: screenWidth * 0.05,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.24,
                        ),
                        blankSpace: MediaQuery.of(context).size.width,
                      )
                    : Text(
                        'Topic: ' + widget.topicName,
                        textScaleFactor: 0.97,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: screenWidth * 0.05,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.24,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChatMembers extends StatefulWidget {
  @override
  _ChatMembersState createState() => _ChatMembersState();
}

class _ChatMembersState extends State<ChatMembers> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 8, left: 8, top: 1, bottom: 8),
            decoration: ShapeDecoration(
              color: themeProvider.currentTheme.primaryColorDark,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 0.50, color: themeProvider.currentTheme.shadowColor),
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x4C024A7A),
                  blurRadius: 8,
                  offset: Offset(2, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 16, bottom: 4, top: 4, left: 8),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chat members',
                        textScaleFactor: 0.99,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: screenWidth * 0.038,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TypeAvatar(
                            avatar: AssetImage('assets/images/ava1girl.png'),
                            name: 'Irina',
                            isOnline: true,
                          ),
                          TypeAvatar(
                            avatar: AssetImage('assets/images/ava2girl.png'),
                            name: 'Anna',
                            isOnline: true,
                          ),
                          TypeAvatar(
                            avatar: AssetImage('assets/images/ava3girl.png'),
                            name: 'Yuliia',
                            isOnline: true,
                          ),
                          TypeAvatar(
                            avatar: AssetImage('assets/images/ava4girl.png'),
                            name: 'Anna',
                            isOnline: true,
                          ),
                          TypeAvatar(
                            avatar: AssetImage('assets/images/ava1boy.png'),
                            name: 'Dmytro',
                            isOnline: true,
                          ),
                          TypeAvatar(
                            avatar: AssetImage('assets/images/ava2boy.png'),
                            name: 'Ivan',
                            isOnline: true,
                          ),
                          TypeAvatar(
                            avatar: AssetImage('assets/images/ava3boy.png'),
                            name: 'Sergii',
                            isOnline: true,
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TypeAvatar extends StatefulWidget {
  ImageProvider avatar;
  String name;
  bool isOnline = true;
  TypeAvatar({
    required this.avatar,
    required this.name,
    required this.isOnline,
  });
  @override
  _TypeAvatarState createState() => _TypeAvatarState();
}

class _TypeAvatarState extends State<TypeAvatar> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: Container(
            width: screenWidth * 0.137,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                            top: 5,
                            right: 5,
                            left: 5,
                            bottom: 0,
                            child: Container(
                              decoration: ShapeDecoration(
                                color:
                                    themeProvider.currentTheme.primaryColorDark,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 0.50,
                                      color: themeProvider
                                          .currentTheme.shadowColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x4C024A7A),
                                    blurRadius: 8,
                                    offset: Offset(2, 2),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                            )),
                        Positioned(
                          top: 1,
                          right: 1,
                          left: 1,
                          bottom: 0,
                          child: Image(
                            image: widget.avatar,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Positioned(
                          top: 1,
                          right: 10,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: ShapeDecoration(
                              color: themeProvider.currentTheme.shadowColor,
                              shape: OvalBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.name,
                      textScaleFactor: 0.99,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor,
                        fontSize: screenWidth * 0.0333,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.30,
                      ),
                    ),
                  ),
                ]),
          ),
        );
      },
    );
  }
}

class BlockMasseges extends StatefulWidget {
  @override
  _BlockMassegesState createState() => _BlockMassegesState();
}

class _BlockMassegesState extends State<BlockMasseges>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _controller.forward();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: themeProvider.currentTheme.primaryColorDark,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 0.50, color: themeProvider.currentTheme.shadowColor),
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x4C024A7A),
                  blurRadius: 8,
                  offset: Offset(2, 2),
                  spreadRadius: 0,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _textAndSend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                flex: 225,
                child: Container(
                  decoration: ShapeDecoration(
                    color: themeProvider.currentTheme.primaryColorDark,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 0.50,
                          color: themeProvider.currentTheme.shadowColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x4C024A7A),
                        blurRadius: 8,
                        offset: Offset(2, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 120,
                child: Container(
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: themeProvider.currentTheme.shadowColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Color(0xFFF5FBFF),
                      fontSize: 24,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      height: 1.24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
