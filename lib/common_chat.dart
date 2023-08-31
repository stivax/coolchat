import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'formChatList.dart';
import 'menu.dart';
import 'my_appbar.dart';
import 'themeProvider.dart';
import 'members.dart';
import 'messeges.dart';
import 'account.dart';

class CommonChatScreen extends StatelessWidget {
  String topicName;
  int id;
  CommonChatScreen({required this.topicName, required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Account>(
      future: readAccountFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Account account = snapshot.data!;
          var paddingTop = MediaQuery.of(context).padding.top;
          var screenWidth = MediaQuery.of(context).size.width;
          var screenHeight =
              MediaQuery.of(context).size.height - 56 - paddingTop;

          return MaterialApp(
            home: BlocProvider(
              create: (context) => MenuBloc(),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Scaffold(
                    appBar: MyAppBar(),
                    body: Container(
                      height: screenHeight,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: themeProvider.currentTheme.primaryColorDark),
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  height: 27,
                                  child: TopicName(topicName: topicName)),
                              Container(height: 140, child: ChatMembers()),
                              Container(
                                  height: (screenHeight - 248) * 1,
                                  child: BlockMasseges(topicID: id.toString())),
                              TextAndSend(
                                account: account,
                                topicID: id.toString(),
                              ),
                            ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
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
    double textWidth = _calculateTextWidth() + 32;
    return textWidth > screenWidth;
  }

  double _calculateTextWidth() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'Topic: ' + widget.topicName,
        style: const TextStyle(
          fontSize: 20,
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
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 20,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          height: 1.24,
                        ),
                        blankSpace: MediaQuery.of(context).size.width,
                      )
                    : Text(
                        'Topic: ' + widget.topicName,
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 20,
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
            padding: EdgeInsets.only(top: 1, bottom: 8),
            decoration: ShapeDecoration(
              color: themeProvider.currentTheme.primaryColorDark,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 0.50, color: themeProvider.currentTheme.shadowColor),
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: [
                BoxShadow(
                  color: themeProvider.currentTheme.cardColor,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: screenWidth * 0.07,
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
                      children: formMembersMap().values.toList(),
                    ),
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

class BlockMasseges extends StatefulWidget {
  final topicID;

  BlockMasseges({super.key, required this.topicID});

  @override
  _BlockMassegesState createState() => _BlockMassegesState();
}

class _BlockMassegesState extends State<BlockMasseges>
    with SingleTickerProviderStateMixin {
  List<Messeges> messageList = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<http.Response> _getData() async {
    var url = 'http://35.228.45.65:8000/room_${widget.topicID}';
    return await http.get(Uri.parse(url));
  }

  Future<void> fetchData() async {
    try {
      http.Response response = await _getData();
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<Messeges> messages =
            Messeges.fromJsonList(jsonList).reversed.toList();
        if (mounted) {
          setState(() {
            messageList = messages;
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Container(
            padding: EdgeInsets.only(right: 10, left: 10),
            decoration: ShapeDecoration(
              color: themeProvider.currentTheme.primaryColorDark,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 0.50, color: themeProvider.currentTheme.shadowColor),
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: [
                BoxShadow(
                  color: themeProvider.currentTheme.cardColor,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: ListView.builder(
              reverse: true, // Scroll to the bottom by default
              itemCount: messageList.length,
              itemBuilder: (context, index) {
                final List<Widget> chatWidgets = messageList;
                return chatWidgets[index];
              },
            ),
          ),
        );
      },
    );
  }
}

class TextAndSend extends StatefulWidget {
  String topicID;
  Account account;

  TextAndSend({super.key, required this.topicID, required this.account});

  @override
  _TextAndSendState createState() => _TextAndSendState();
}

class _TextAndSendState extends State<TextAndSend> {
  final TextEditingController messageController = TextEditingController();

  void _sendMessage(String message) async {
    final url = Uri.parse('http://35.228.45.65:8000/room_${widget.topicID}/');

    final jsonBody = {
      'name': widget.account.name,
      'message': message,
      "published": true,
      "member_id": widget.account.id,
      "avatar": widget.account.avatar,
      "is_privat": false,
      "receiver": 0
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
      }, // Вказати тип відправлених даних
      body: json.encode(jsonBody), // Кодування JSON-об'єкта у рядок JSON
    );

    if (response.statusCode == 201) {
      print('Post request successful');
      // Оновлення списку повідомлень або інша логіка, яку ви хочете виконати
    } else {
      print('Post request failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.only(right: 8, left: 8),
                  decoration: ShapeDecoration(
                    color: themeProvider.currentTheme.primaryColorDark,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 0.50,
                          color: themeProvider.currentTheme.shadowColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: [
                      BoxShadow(
                        color: themeProvider.currentTheme.cardColor,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: messageController,
                    style: TextStyle(
                      color: themeProvider.currentTheme.primaryColor,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                    ),
                    focusNode: FocusNode(),
                    decoration: InputDecoration(
                      hintText: 'Write message...',
                      hintStyle: TextStyle(
                        color: themeProvider.currentTheme.primaryColor
                            .withOpacity(0.5),
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    onTap: () {
                      FocusScope.of(context).requestFocus(null);
                    },
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    final message = messageController.text;

                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      messageController.clear();

                      // Оновлення BlockMasseges після відправлення повідомлення
                      final blockMassegesKey = GlobalKey<_BlockMassegesState>();
                      final _blockMassegesState = blockMassegesKey.currentState;
                      if (_blockMassegesState != null) {
                        _blockMassegesState.fetchData();
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 14, bottom: 14),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: themeProvider.currentTheme.shadowColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
                        BoxShadow(
                          color: themeProvider.currentTheme.cardColor,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Send',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: Color(0xFFF5FBFF),
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.24,
                      ),
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
