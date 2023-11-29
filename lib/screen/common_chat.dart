// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/model/token.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/widget/write.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../account.dart';
import '../bloc/token_event.dart';
import '../bloc/token_state.dart';
import '../login_popup.dart';
import '../main.dart';
import '../members.dart';
import '../menu.dart';
import '../message_provider.dart';
import '../messages.dart';
import '../my_appbar.dart';
import '../server_provider.dart';
import '../theme_provider.dart';

class MessageData {
  Set<Messages> messages = {};
  int previousMemberID = 0;
  String responseBody;

  MessageData(this.messages, this.previousMemberID, this.responseBody);
}

final blockMessageStateKey = GlobalKey<_BlockMessagesState>();
final chatMembersStateKey = GlobalKey<_ChatMembersState>();
final chatScreenStateKey = GlobalKey<_ChatScreenState>();

class ChatScreen extends StatefulWidget {
  final String topicName;
  final int? id;
  final String server;
  final Account account;
  MessageData messageData;

  ChatScreen(
      {super.key,
      required this.topicName,
      this.id,
      required this.server,
      required this.account})
      : messageData = MessageData({}, 0, '[]');

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isListening = false;
  Token? token;

  void messageListen(MessageProvider messageProvider) {
    if (!isListening && !messageProvider.messagesStream.isBroadcast) {
      isListening = true;
      messageProvider.messagesStream.listen((event) async {
        print(event);
        if (event.toString().startsWith('{"created_at"')) {
          formMessage(event.toString());
        } else if (event.toString().startsWith('{"type":"active_users"')) {
          formMembersList(event.toString());
        } else {
          showWriting(event.toString());
        }
      });
    }
  }

  void formMessage(String responseBody) {
    dynamic jsonMessage = jsonDecode(responseBody);
    Messages message = Messages.fromJsonMessage(
        jsonMessage, widget.messageData.previousMemberID, context);
    widget.messageData.previousMemberID = message.ownerId.toInt();
    blockMessageStateKey.currentState!._messages.add(message);
    blockMessageStateKey.currentState!.widget.updateState();
  }

  void formMembersList(String responseBody) {
    dynamic jsonMemberList = jsonDecode(responseBody);
    Set<Member> membersList = Member.fromJsonSet(jsonMemberList, context);
    chatMembersStateKey.currentState!.members.clear();
    chatMembersStateKey.currentState!.members.addAll(membersList);
    chatMembersStateKey.currentState!.widget.updateState();
  }

  void showWriting(String name) {
    blockMessageStateKey.currentState!.whenWriting(name);
  }

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
        builder: (context, state) {
          print(state.runtimeType);
          if (state is TokenEmptyState) {
            final MessageProvider messageProvider = MessageProvider(
                'wss://${widget.server}/ws/${widget.topicName}?token=null');
            return CommonChatScreen(
              state: 'empty',
              topicName: widget.topicName,
              messageProvider: messageProvider,
              server: widget.server,
              account: widget.account,
              messageData: widget.messageData,
            );
          } else if (state is TokenLoadedState) {
            print('loaded');
            token = state.token;
            MessageProvider? provider =
                MessageProviderContainer.instance.getProvider(widget.topicName);
            messageListen(provider!);
            return CommonChatScreen(
              state: 'loaded',
              topicName: widget.topicName,
              messageProvider: state.messageProvider,
              server: widget.server,
              account: widget.account,
              messageData: widget.messageData,
            );
          } else {
            return const Center(child: LinearProgressIndicator());
          }
        },
      ),
    );
  }
}

class CommonChatScreen extends StatefulWidget {
  final String topicName;
  final MessageProvider messageProvider;
  final String server;
  final Account account;
  final String state;
  MessageData messageData;
  CommonChatScreen(
      {super.key,
      required this.topicName,
      required this.messageProvider,
      required this.server,
      required this.account,
      required this.state,
      required this.messageData});

  @override
  State<CommonChatScreen> createState() => _CommonChatScreenState();
}

class _CommonChatScreenState extends State<CommonChatScreen> {
  late MessageData messageData;
  @override
  void initState() {
    super.initState();
    messageData = widget.messageData;
    if (widget.account.email.isNotEmpty) {
      final TokenBloc tokenBloc = context.read<TokenBloc>();
      tokenBloc.add(TokenLoadEvent(
          email: widget.account.email,
          password: widget.account.password,
          roomName: widget.topicName));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _overloadMain();
  }

  @override
  void dispose() {
    print('dispose in screen');
    widget.messageProvider.channel.sink.close();
    super.dispose();
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
            appBar: MyAppBar(
              roomName: widget.topicName,
            ),
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
                              key: chatMembersStateKey,
                              topicName: widget.topicName,
                              server: widget.server,
                              updateState: () {
                                setState(() {});
                              })),
                      SizedBox(
                        height: (screenHeight - 248) * 1,
                        child: BlockMessages(
                            key: blockMessageStateKey,
                            state: widget.state,
                            messageData: widget.messageData,
                            updateState: () {
                              setState(() {});
                            }),
                      ),
                      TextAndSend(
                        state: widget.state,
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
  final String topicName;
  final String server;
  final Function updateState;

  const ChatMembers(
      {super.key,
      required this.topicName,
      required this.server,
      required this.updateState});

  @override
  _ChatMembersState createState() => _ChatMembersState();
}

class _ChatMembersState extends State<ChatMembers> {
  Set<Member> members = {};

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
                        children: members.toList(),
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

class BlockMessages extends StatefulWidget {
  final MessageData messageData;
  final Function updateState;
  final String state;
  const BlockMessages({
    Key? key,
    required this.messageData,
    required this.updateState,
    required this.state,
  }) : super(key: key);

  @override
  State<BlockMessages> createState() => _BlockMessagesState();
}

class _BlockMessagesState extends State<BlockMessages> {
  final Set<Messages> _messages = {};
  bool showWrite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  whenWriting(String name) {
    setState(() {
      showWrite = true;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        showWrite = false;
      });
    });
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
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  widget.state == 'loaded'
                      ? messageView(themeProvider)
                      : const Center(child: CircularProgressIndicator()),
                  showWrite ? const WriteAnimated() : Container(),
                ],
              ),
            ));
      },
    );
  }

  Widget messageView(ThemeProvider themeProvider) {
    if (_messages.isNotEmpty) {
      return ListView.builder(
        reverse: true,
        itemCount: _messages.toList().length,
        itemBuilder: (context, index) {
          return _messages.toList().reversed.toList()[index];
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
              image: AssetImage('assets/images/clear_block_messages.png'),
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
                  color:
                      themeProvider.currentTheme.primaryColor.withOpacity(0.5),
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
  }
}

class TextAndSend extends StatefulWidget {
  final String topicName;
  final String server;
  final MessageProvider? messageProvider;
  final Account account;
  final String state;
  const TextAndSend(
      {super.key,
      required this.topicName,
      required this.server,
      required this.messageProvider,
      required this.account,
      required this.state});

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sendMessage(String message) {
    widget.messageProvider?.sendMessage(json.encode({
      'message': message,
    }));
  }

  void _sendStatus() {
    widget.messageProvider?.sendMessage(json.encode({'type': "typing"}));
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
                      hintText: widget.state == 'empty'
                          ? 'Please log in or register'
                          : 'Write message...',
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
                      if (widget.messageProvider!.serverUrl
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
                            email: account.email,
                            password: account.password,
                            roomName: widget.topicName));
                      } else {
                        FocusScope.of(context)
                            .requestFocus(_textFieldFocusNode);
                      }
                    },
                    onChanged: (_) {
                      _sendStatus();
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
                    if (message.isNotEmpty && widget.state == 'loaded') {
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