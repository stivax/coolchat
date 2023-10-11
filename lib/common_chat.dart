import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'login_popup.dart';
import 'menu.dart';
import 'my_appbar.dart';
import 'server.dart';
import 'theme_provider.dart';
import 'members.dart';
import 'messages.dart';
import 'account.dart';
import 'main.dart';

class CommonChatScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final topicName;
  // ignore: prefer_typing_uninitialized_variables
  final id;
  const CommonChatScreen({super.key, required this.topicName, this.id});

  @override
  State<CommonChatScreen> createState() => _CommonChatScreenState();
}

class _CommonChatScreenState extends State<CommonChatScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQuery.of(context).padding.top;
    var screenHeight = MediaQuery.of(context).size.height - 56 - paddingTop;
    String server = ServerProvider.of(context).server;

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
                        SizedBox(
                            height: 27,
                            child: TopicName(topicName: widget.topicName)),
                        SizedBox(
                            height: 140,
                            child: ChatMembers(
                              topicName: widget.topicName,
                              server: server,
                            )),
                        SizedBox(
                            height: (screenHeight - 248) * 1,
                            child: BlockMasseges(
                              topicName: widget.topicName,
                              server: server,
                            )),
                        TextAndSend(
                          topicName: widget.topicName,
                          server: server,
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
}

class TopicName extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final topicName;
  const TopicName({super.key, required this.topicName});

  @override
  State<TopicName> createState() => _TopicNameState();
}

class _TopicNameState extends State<TopicName> {
  bool shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        text: 'Topic: ${widget.topicName}',
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
          padding: const EdgeInsets.all(1),
          alignment: Alignment.topLeft,
          child: Center(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                child: shouldAnimate
                    ? Marquee(
                        text: 'Topic: ${widget.topicName}',
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
                        'Topic: ${widget.topicName}',
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
  final topicName;
  String server;

  ChatMembers({super.key, required this.topicName, required this.server});

  @override
  _ChatMembersState createState() => _ChatMembersState();
}

class _ChatMembersState extends State<ChatMembers> {
  List<Member> members = [];
  List<Messages> messageList = [];
  late Timer _timer;
  String localResponseBody = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    formMembersList();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchData();
      formMembersList();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<http.Response> _getData() async {
    var url = '${widget.server}messagesDev/${widget.topicName}';
    return await http.get(Uri.parse(url));
  }

  Future<void> fetchData() async {
    try {
      http.Response response = await _getData();
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        if (responseBody != localResponseBody) {
          localResponseBody = responseBody;
          List<dynamic> jsonList = jsonDecode(responseBody);
          List<Messages> messages =
              Messages.fromJsonList(jsonList).reversed.toList();
          if (mounted) {
            setState(() {
              messageList = messages;
            });
          }
        }
      }
    } catch (error) {}
  }

  List<Member> formMembersList() {
    List<Member> result = [];
    result.addAll(getLastHourAndWeekMembers(messageList));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 1, bottom: 8),
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
                  offset: const Offset(2, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: formMembersList(),
                      ),
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
  // ignore: prefer_typing_uninitialized_variables
  final topicName;
  String server;

  BlockMasseges({super.key, required this.topicName, required this.server});

  @override
  _BlockMassegesState createState() => _BlockMassegesState();
}

class _BlockMassegesState extends State<BlockMasseges>
    with SingleTickerProviderStateMixin {
  List<Messages> messageList = [];
  String localResponseBody = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<http.Response> _getData() async {
    var url = '${widget.server}messagesDev/${widget.topicName}';
    return await http.get(Uri.parse(url));
  }

  Future<void> fetchData() async {
    try {
      http.Response response = await _getData();
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        if (responseBody != localResponseBody) {
          localResponseBody = responseBody;
          List<dynamic> jsonList = jsonDecode(responseBody);
          List<Messages> messages =
              Messages.fromJsonList(jsonList).reversed.toList();
          if (mounted) {
            setState(() {
              messageList = messages;
            });
          }
        }
      }
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Container(
            padding: const EdgeInsets.only(right: 10, left: 10),
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
                  offset: const Offset(2, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: ListView.builder(
              reverse: true,
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
  // ignore: prefer_typing_uninitialized_variables
  final topicName;
  String server;
  TextAndSend({super.key, required this.topicName, required this.server});

  @override
  _TextAndSendState createState() => _TextAndSendState();
}

class _TextAndSendState extends State<TextAndSend> {
  final TextEditingController messageController = TextEditingController();
  Account account =
      Account(email: '', userName: '', password: '', avatar: '', id: 0);
  var token = {};
  late Timer _timer;
  final _textFieldFocusNode = FocusNode();
  bool isWriting = false;
  final _blockMassegesState = GlobalKey<_BlockMassegesState>().currentState;

  @override
  void initState() {
    super.initState();
    _readAccount();
    _makeToken(context);
    //_startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      //_sendStatus();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _sendStatus() async {
    if (messageController.text.isNotEmpty) {
      setState(() {
        isWriting = true;
      });
    } else {
      setState(() {
        isWriting = false;
      });
    }
    if (account.userName.isNotEmpty) {
      final url = Uri.parse('${widget.server}user_status/${account.id}');
      final jsonBody = {"room_name": widget.topicName, "status": !isWriting};
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonBody),
      );
      if (response.statusCode == 200) {
      } else {}
    }
  }

  Future<void> _readAccount() async {
    Account acc = await readAccountFuture();
    setState(() {
      account = acc;
    });
  }

  Future<void> _makeToken(BuildContext context) async {
    //account = await readAccountFuture();
    var tok = await loginProcess(context, account.email, account.password);
    setState(() {
      token = tok;
    });
  }

  void _sendMessage(String message) async {
    final url = Uri.parse('${widget.server}messagesDev/');

    final jsonBody = {
      'message': message,
      "is_privat": false,
      "receiver": 0,
      "rooms": widget.topicName
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${token["access_token"]}',
        'Content-Type': 'application/json'
      },
      body: json.encode(jsonBody),
    );

    if (response.statusCode == 201) {
    } else {}
  }

  void _onTapOutside(BuildContext context) {
    GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    );
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
                  padding: const EdgeInsets.only(right: 8, left: 8),
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
                        offset: const Offset(2, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    showCursor: true,
                    cursorColor: themeProvider.currentTheme.shadowColor,
                    controller: messageController,
                    textCapitalization: TextCapitalization.sentences,
                    focusNode: _textFieldFocusNode,
                    style: TextStyle(
                      color: themeProvider.currentTheme.primaryColor,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                    ),
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
                    onTap: () async {
                      if (account.userName == '') {
                        FocusScope.of(context).unfocus();
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LoginDialog();
                          },
                        );
                        await _readAccount();
                        await _makeToken(context);
                        setState(() {});
                      } else {
                        FocusScope.of(context)
                            .requestFocus(_textFieldFocusNode);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    final message = messageController.text;
                    if (message.isNotEmpty && account.userName.isNotEmpty) {
                      _sendMessage(message);
                      messageController.clear();

                      // Оновлення BlockMasseges після відправлення повідомлення
                      _blockMassegesState?.fetchData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 14, bottom: 14),
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
                          offset: const Offset(2, 2),
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
