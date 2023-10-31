// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import 'account.dart';
import 'bloc/token_event.dart';
import 'bloc/token_state.dart';
import 'login_popup.dart';
import 'main.dart';
import 'members.dart';
import 'menu.dart';
import 'message_provider.dart';
import 'messages.dart';
import 'my_appbar.dart';
import 'server_provider.dart';
import 'theme_provider.dart';

class MessageData {
  List<Messages> messages = [];
  int previousMemberID = 0;
  String responseBody;

  MessageData(this.messages, this.previousMemberID, this.responseBody);
}

class ChatScreen extends StatelessWidget {
  String topicName;
  int? id;
  String server;
  Account account;
  MessageProvider messageProvider;
  ChatScreen(
      {super.key,
      required this.topicName,
      this.id,
      required this.server,
      required this.account})
      : messageProvider = MessageProvider('wss://$server/ws/$topicName?token=');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MenuBloc>(
          create: (context) => MenuBloc(),
        ),
        BlocProvider<TokenBloc>(
          create: (context) => TokenBloc(
            tokenRepository: context.read<TokenRepository>(),
          ),
        )
      ],
      child: BlocBuilder<TokenBloc, TokenState>(
        //buildWhen: (previousState, currentState) {
        //  return previousState is! TokenLoadedState;
        // },
        builder: (context, state) {
          if (state is TokenEmptyState) {
            messageProvider =
                MessageProvider('wss://$server/ws/$topicName?token=null');
            return CommonChatScreen(
                topicName: topicName,
                messageProvider: messageProvider,
                server: server,
                account: account);
          }
          if (state is TokenLoadedState) {
            messageProvider = MessageProvider(
                'wss://$server/ws/$topicName?token=${state.token.token["access_token"]}');
            return CommonChatScreen(
                topicName: topicName,
                messageProvider: messageProvider,
                server: server,
                account: account);
          } else {
            return const Center(child: LinearProgressIndicator());
          }
        },
      ),
    );
  }
}

class CommonChatScreen extends StatefulWidget {
  String topicName;
  MessageProvider messageProvider;
  String server;
  Account account;
  CommonChatScreen(
      {super.key,
      required this.topicName,
      required this.messageProvider,
      required this.server,
      required this.account});

  @override
  State<CommonChatScreen> createState() => _CommonChatScreenState();
}

class _CommonChatScreenState extends State<CommonChatScreen> {
  late MessageData messageData;

  @override
  void initState() {
    super.initState();
    messageData = MessageData([], 0, '[]');
    final TokenBloc tokenBloc = context.read<TokenBloc>();
    tokenBloc.add(TokenLoadEvent(
        email: widget.account.email, password: widget.account.password));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _overloadMain();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateScreen() {
    setState(() {});
  }

  _overloadMain() async {
    await myHomePageStateKey.currentState
        ?.fetchData(ServerProvider.of(context).server);
  }

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQuery.of(context).padding.top;
    var screenHeight = MediaQuery.of(context).size.height - 56 - paddingTop;

    return MaterialApp(
      home: Consumer<ThemeProvider>(
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
                            server: widget.server,
                          )),
                      SizedBox(
                        height: (screenHeight - 248) * 1,
                        child: BlockMessages(
                          messageProvider: widget.messageProvider,
                          messageData: messageData,
                        ),
                      ),
                      TextAndSend(
                        topicName: widget.topicName,
                        server: widget.server,
                        messageProvider: widget.messageProvider,
                        account: widget.account,
                      ),
                    ]),
              ),
            ),
          );
        },
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
    final url = Uri.https(widget.server, '/messagesDev/${widget.topicName}');
    return await http.get(url);
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
                SizedBox(
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

class BlockMessages extends StatelessWidget {
  final MessageProvider messageProvider;
  final MessageData messageData;
  const BlockMessages({
    Key? key,
    required this.messageProvider,
    required this.messageData,
  }) : super(key: key);

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
            child: StreamBuilder(
              stream: messageProvider.messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String responseBody = snapshot.data;
                  print('response ${jsonDecode(responseBody).toString()}');
                  if (responseBody != '[]') {
                    if (jsonDecode(responseBody).runtimeType == List<dynamic>) {
                      List<dynamic> jsonList = jsonDecode(responseBody);
                      messageData.messages = Messages.fromJsonList(jsonList);
                      messageData.previousMemberID = messageData.messages != []
                          ? messageData.messages.last.ownerId.toInt()
                          : 0;
                      // } else if (messageData.responseBody != responseBody) {
                    } else {
                      messageData.responseBody = responseBody;
                      dynamic jsonMessage = jsonDecode(responseBody);
                      Messages message = Messages.fromJsonMessage(
                          jsonMessage, messageData.previousMemberID);
                      messageData.previousMemberID = message.ownerId.toInt();
                      messageData.messages.add(message);
                    } //else {}
                    return ListView.builder(
                      reverse: true,
                      itemCount: messageData.messages.reversed.toList().length,
                      itemBuilder: (context, index) {
                        return messageData.messages.reversed.toList()[index];
                      },
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage(
                                'assets/images/clear_block_messages.png'),
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 50,
                            child: Text(
                              'Oops.. there are no messages here yet \nWrite first!',
                              textAlign: TextAlign.center,
                              textScaleFactor: 1,
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor
                                    .withOpacity(0.5),
                                fontSize: 16,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                height: 1.16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class TextAndSend extends StatefulWidget {
  final String topicName;
  final String server;
  final MessageProvider messageProvider;
  final Account account;
  const TextAndSend(
      {super.key,
      required this.topicName,
      required this.server,
      required this.messageProvider,
      required this.account});

  @override
  _TextAndSendState createState() => _TextAndSendState();
}

class _TextAndSendState extends State<TextAndSend> {
  final TextEditingController messageController = TextEditingController();
  var token = {};
  final _textFieldFocusNode = FocusNode();
  bool isWriting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sendMessage(String message) {
    widget.messageProvider.sendMessage(json.encode({
      'message': message,
      'is_privat': false,
      'receiver': 1,
      'rooms': widget.topicName,
    }));
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
                      //if (widget.account.userName == '') {
                      print(widget.messageProvider.serverUrl);
                      if (widget.messageProvider.serverUrl
                          .toString()
                          .endsWith('l')) {
                        FocusScope.of(context).unfocus();
                        final account = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LoginDialog();
                          },
                        );
                        final TokenBloc tokenBloc = context.read<TokenBloc>();
                        tokenBloc.add(TokenLoadEvent(
                            email: account.email, password: account.password));
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
                    if (message.isNotEmpty &&
                        !widget.messageProvider.serverUrl
                            .toString()
                            .endsWith('l')) {
                      _sendMessage(message);
                      messageController.clear();
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
