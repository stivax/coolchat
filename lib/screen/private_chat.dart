// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/bloc/token_event.dart';
import 'package:coolchat/bloc/token_state.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../menu.dart';
import '../message_provider.dart';
import '../messages_privat.dart';
import '../my_appbar.dart';
import '../theme_provider.dart';

class MessagePrivatData {
  List<MessagesPrivat> messages;
  int previousMemberID;

  MessagePrivatData()
      : messages = [],
        previousMemberID = 0;
}

final blockMessageStateKey = GlobalKey<_BlockPrivateMessagesState>();

class PrivateChatScreen extends StatefulWidget {
  final String receiverName;
  final int recipientId;
  final int myId;

  PrivateChatScreen(
      {super.key,
      required this.receiverName,
      required this.recipientId,
      required this.myId});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  bool isListening = false;
  final messagePrivatData = MessagePrivatData();
  bool emptyMessages = true;
  MessageProvider? providerInPrivateScreen;
  StreamSubscription? _messageSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print('dispose private in screen');
    providerInPrivateScreen!.dispose();
    super.dispose();
  }

  void messageListen() async {
    print('messagePrivateListen');
    if (providerInPrivateScreen !=
        MessageProviderContainer.instance
            .getProvider(widget.recipientId.toString())!) {
      providerInPrivateScreen = MessageProviderContainer.instance
          .getProvider(widget.recipientId.toString())!;
      print('listen begin');
      clearMessages();
      _messageSubscription = providerInPrivateScreen!.messagesStream.listen(
        (event) async {
          print(event);
          if (event.toString().startsWith('{"created_at"')) {
            formMessage(event.toString());
          }
          if (event.toString().startsWith('{"message":"Vote posted "}')) {
            print('clear');
            clearMessages();
          }
        },
        onDone: () {
          print('onDone');
          isListening = false;
          //providerInPrivateScreen!.setIsConnected = false;
        },
        onError: (e) {
          print('onError');
          isListening = false;
          //providerInPrivateScreen!.setIsConnected = false;
        },
      );
    }
  }

  Future<void> checkEmptyMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    blockMessageStateKey.currentState!.emptyMessagesFalse();
  }

  void connectivitySubscription() async {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        if (providerInPrivateScreen!.isConnected) {
          messageListen();
        }
      }
    });
  }

  void formMessage(String responseBody) {
    dynamic jsonMessage = jsonDecode(responseBody);
    MessagesPrivat message = MessagesPrivat.fromJsonMessage(
        jsonMessage, messagePrivatData.previousMemberID, widget.recipientId);
    messagePrivatData.previousMemberID = message.senderId.toInt();
    blockMessageStateKey.currentState!._messages.add(message);
    //blockMessageStateKey.currentState!.emptyMessages = false;
    blockMessageStateKey.currentState!.widget.updateState();
  }

  void clearMessages() {
    messagePrivatData.previousMemberID = 0;
    blockMessageStateKey.currentState!._messages.clear();
    blockMessageStateKey.currentState!.widget.updateState();
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
      child: BlocBuilder<TokenBloc, TokenState>(builder: (context, state) {
        if (state is TokenLoadingState) {
          return CommonChatScreen(
            state: 'loading',
            topicName: widget.receiverName,
            recepientId: widget.recipientId,
            messageData: messagePrivatData,
            emptyMessages: emptyMessages,
          );
        } else if (state is TokenLoadedState) {
          messageListen();
          _connectivitySubscription =
              Connectivity().onConnectivityChanged.listen((result) {
            if (result != ConnectivityResult.none) {
              if (!providerInPrivateScreen!.isConnected) {
                messageListen();
              }
            }
          });
          checkEmptyMessages();
          return CommonChatScreen(
            state: 'loaded',
            topicName: widget.receiverName,
            recepientId: widget.recipientId,
            messageProvider: providerInPrivateScreen,
            messageData: messagePrivatData,
            emptyMessages: emptyMessages,
          );
        } else {
          return CommonChatScreen(
            state: 'error',
            topicName: widget.receiverName,
            recepientId: widget.recipientId,
            messageData: messagePrivatData,
            emptyMessages: emptyMessages,
          );
        }
      }),
    );
  }
}

class CommonChatScreen extends StatefulWidget {
  final String topicName;
  final MessageProvider? messageProvider;
  final String state;
  final int recepientId;
  MessagePrivatData messageData;
  bool emptyMessages;

  CommonChatScreen(
      {super.key,
      required this.topicName,
      this.messageProvider,
      required this.state,
      required this.recepientId,
      required this.messageData,
      required this.emptyMessages});

  @override
  State<CommonChatScreen> createState() => _CommonChatScreenState();
}

class _CommonChatScreenState extends State<CommonChatScreen>
    with WidgetsBindingObserver {
  late MessagePrivatData messageData;
  BuildContext? _buildContext;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    messageData = widget.messageData;
    final TokenBloc tokenBloc = context.read<TokenBloc>();
    tokenBloc.add(TokenLoadEvent(
        roomName: widget.recepientId.toString(), type: 'private'));
  }

  @override
  void dispose() {
    if (widget.messageProvider != null) {
      widget.messageProvider!.dispose();
      WidgetsBinding.instance.removeObserver(this);
      print('dispose in screen');
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _buildContext != null) {
      print('resume!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      final TokenBloc tokenBloc = _buildContext!.read<TokenBloc>();
      tokenBloc.add(TokenLoadEvent(
          roomName: widget.recepientId.toString(), type: 'private'));
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    var paddingTop = MediaQuery.of(context).padding.top;
    var screenHeight = MediaQuery.of(context).size.height - 56 - paddingTop;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: MyAppBar(),
          body: Container(
            height: screenHeight,
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: themeProvider.currentTheme.primaryColorDark),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 27,
                        child: ReceiverName(topicName: widget.topicName)),
                    SizedBox(
                      height: (screenHeight - 108) * 1,
                      child: BlockPrivateMessages(
                          key: blockMessageStateKey,
                          state: widget.state,
                          messageData: widget.messageData,
                          emptyMessages: widget.emptyMessages,
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
    );
  }
}

class ReceiverName extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final topicName;
  const ReceiverName({super.key, required this.topicName});

  @override
  State<ReceiverName> createState() => _ReceiverNameState();
}

class _ReceiverNameState extends State<ReceiverName> {
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

class BlockPrivateMessages extends StatefulWidget {
  final String state;
  final MessagePrivatData messageData;
  final Function updateState;
  final bool emptyMessages;
  const BlockPrivateMessages({
    Key? key,
    required this.state,
    required this.messageData,
    required this.updateState,
    required this.emptyMessages,
  }) : super(key: key);

  @override
  State<BlockPrivateMessages> createState() => _BlockPrivateMessagesState();
}

class _BlockPrivateMessagesState extends State<BlockPrivateMessages> {
  final Set<MessagesPrivat> _messages = {};
  late bool emptyMessages;

  @override
  void initState() {
    super.initState();
    emptyMessages = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  void emptyMessagesFalse() {
    setState(() {
      emptyMessages = false;
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
              child: widget.state == 'loading'
                  ? Center(
                      child: CircularProgressIndicator(
                      color: themeProvider.currentTheme.shadowColor,
                    ))
                  : messageView(themeProvider),
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
    } else if (!emptyMessages) {
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
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: themeProvider.currentTheme.shadowColor,
        ),
      );
    }
  }
}

class TextAndSend extends StatefulWidget {
  final String topicName;
  final MessageProvider? messageProvider;
  const TextAndSend({
    super.key,
    required this.topicName,
    this.messageProvider,
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
    final messageForSend = message.trimRight().trimLeft();
    if (messageForSend.isNotEmpty) {
      widget.messageProvider!.sendMessage(json.encode({
        'messages': messageForSend,
      }));
    }
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
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
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
                        FocusScope.of(context)
                            .requestFocus(_textFieldFocusNode);
                      },
                    ),
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
