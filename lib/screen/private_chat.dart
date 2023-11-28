// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../bloc/token_event.dart';
import '../login_popup.dart';
import '../menu.dart';
import '../message_provider.dart';
import '../messages_privat.dart';
import '../my_appbar.dart';
import '../theme_provider.dart';

class MessageData {
  Set<MessagesPrivat> messages = {};
  int previousMemberID = 0;
  String responseBody;

  MessageData(this.messages, this.previousMemberID, this.responseBody);
}

final blockMessageStateKey = GlobalKey<_BlockMessagesState>();

class PrivateChatScreen extends StatefulWidget {
  final String receiverName;
  final MessageProvider messageProvider;
  MessageData messagePrivatData;

  PrivateChatScreen(
      {super.key, required this.receiverName, required this.messageProvider})
      : messagePrivatData = MessageData({}, 0, '[]');

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  bool isListening = false;

  void messageListen(MessageProvider messageProvider) {
    if (!isListening && !messageProvider.messagesStream.isBroadcast) {
      isListening = true;
      messageProvider.messagesStream.listen((event) async {
        print(event);
        if (event.toString().startsWith('{"created_at"')) {
          formMessage(event.toString());
        } else {
          //formMembersList(event.toString());
        }
      });
    }
  }

  void formMessage(String responseBody) {
    dynamic jsonMessage = jsonDecode(responseBody);
    MessagesPrivat message = MessagesPrivat.fromJsonMessage(
        jsonMessage, widget.messagePrivatData.previousMemberID);
    widget.messagePrivatData.previousMemberID = message.senderId.toInt();
    blockMessageStateKey.currentState!._messages.add(message);
    blockMessageStateKey.currentState!.widget.updateState();
  }

  @override
  Widget build(BuildContext context) {
    messageListen(widget.messageProvider);
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
      child: CommonChatScreen(
        topicName: widget.receiverName,
        messageProvider: widget.messageProvider,
        messageData: widget.messagePrivatData,
      ),
    );
  }
}

class CommonChatScreen extends StatefulWidget {
  final String topicName;
  final MessageProvider messageProvider;
  MessageData messageData;
  CommonChatScreen(
      {super.key,
      required this.topicName,
      required this.messageProvider,
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
  }

  @override
  void dispose() {
    print('dispose private in screen');
    widget.messageProvider.channel.sink.close();
    super.dispose();
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
                        height: (screenHeight - 108) * 1,
                        child: BlockMessages(
                            key: blockMessageStateKey,
                            messageData: widget.messageData,
                            updateState: () {
                              setState(() {});
                            }),
                      ),
                      TextAndSend(
                        topicName: widget.topicName,
                        messageProvider: widget.messageProvider,
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
        text: 'Direct chat: ${widget.topicName}',
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
                        text: 'Direct chat: ${widget.topicName}',
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
                        'Direct chat: ${widget.topicName}',
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

class BlockMessages extends StatefulWidget {
  final MessageData messageData;
  final Function updateState;
  const BlockMessages({
    Key? key,
    required this.messageData,
    required this.updateState,
  }) : super(key: key);

  @override
  State<BlockMessages> createState() => _BlockMessagesState();
}

class _BlockMessagesState extends State<BlockMessages> {
  final Set<MessagesPrivat> _messages = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
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
              child: messageView(themeProvider),
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
  final MessageProvider messageProvider;
  const TextAndSend({
    super.key,
    required this.topicName,
    required this.messageProvider,
  });

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
      'messages': message,
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
                    onTap: () {
                      print(context.widget);
                      FocusScope.of(context).requestFocus(_textFieldFocusNode);
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
                    if (message.isNotEmpty) {
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
