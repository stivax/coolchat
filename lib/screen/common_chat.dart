// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/widget/write.dart';

import '../account.dart';
import '../beholder/scroll_chat_controll.dart';
import '../bloc/token_event.dart';
import '../bloc/token_state.dart';
import '../login_popup.dart';
import '../members.dart';
import '../menu.dart';
import '../message_provider.dart';
import '../messages.dart';
import '../my_appbar.dart';
import '../theme_provider.dart';

class MessageData {
  List<Messages> messages;
  int previousMemberID;

  MessageData()
      : messages = [],
        previousMemberID = 0;
}

final blockMessageStateKey = GlobalKey<_BlockMessagesState>();
final chatMembersStateKey = GlobalKey<_ChatMembersState>();
final chatScreenStateKey = GlobalKey<_ChatScreenState>();

class ChatScreen extends StatefulWidget {
  final String topicName;
  final int? id;
  final String server;
  final Account account;
  final MessageData messageData;
  final bool hasMessage;

  ChatScreen(
      {super.key,
      required this.topicName,
      this.id,
      required this.server,
      required this.account,
      required this.hasMessage})
      : messageData = MessageData();

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  bool isListening = false;
  late bool hasMessages;
  final messageData = MessageData();
  Account acc =
      Account(email: '', userName: '', password: '', avatar: '', id: 0);
  MessageProvider? providerInScreen;
  StreamSubscription? _messageSubscription;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    hasMessages = widget.hasMessage;
    WidgetsBinding.instance.addObserver(this);
    if (widget.account.email != '') {
      acc = widget.account;
    }
  }

  @override
  void dispose() {
    providerInScreen?.channel.sink.close();
    _messageSubscription?.cancel();
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
  }

  void messageListen() async {
    providerInScreen ??=
        MessageProviderContainer.instance.getProvider(widget.topicName)!;
    if (!isListening || _messageSubscription!.isPaused) {
      isListening = true;
      if (!providerInScreen!.isConnected) {
        await providerInScreen!.reconnect();
        await providerInScreen!.channel.ready;
      }
      print('listen begin');
      clearMessages();
      _messageSubscription?.cancel();
      _messageSubscription = providerInScreen!.messagesStream.listen(
        (event) async {
          print(event);
          if (event.toString().startsWith('{"created_at"')) {
            formMessage(event.toString());
          } else if (event.toString().startsWith('{"type":"active_users"')) {
            formMembersList(event.toString());
          } else if (event.toString().startsWith('{"message":"Vote posted')) {
            clearMessages();
          } else if (event.toString().startsWith('{"type":')) {
            showWriting(event.toString());
          }
        },
        onDone: () {
          print('onDone');
          isListening = false;
          providerInScreen!.setIsConnected = false;
        },
        onError: (e) {
          print('onError');
          isListening = false;
          providerInScreen!.setIsConnected = false;
        },
      );
    } else if (_messageSubscription!.isPaused) {
      print('messageSubscription resume');
      _messageSubscription!.resume();
    }
  }

  void formMessage(String responseBody) {
    dynamic jsonMessage = jsonDecode(responseBody);
    Messages message = Messages.fromJsonMessage(jsonMessage,
        messageData.previousMemberID, context, widget.topicName, acc.id);
    messageData.previousMemberID = message.ownerId.toInt();
    messageData.messages.add(message);
    blockMessageStateKey.currentState!._messages.add(message);
    blockMessageStateKey.currentState!.widget.updateState();
  }

  void clearMessages() {
    messageData.previousMemberID = 0;
    blockMessageStateKey.currentState!._messages.clear();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      messageListen();
    }
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
          //print(state.runtimeType);
          if (state is TokenEmptyState) {
            return CommonChatScreen(
              state: 'empty',
              topicName: widget.topicName,
              server: widget.server,
              account: widget.account,
              messageData: state.messagesList,
              hasMessage: hasMessages,
            );
          } else if (state is TokenLoadedState) {
            acc = state.account;
            providerInScreen ??= MessageProviderContainer.instance
                .getProvider(widget.topicName)!;
            messageListen();
            _connectivitySubscription =
                Connectivity().onConnectivityChanged.listen((result) {
              if (result != ConnectivityResult.none) {
                if (!providerInScreen!.isConnected) {
                  messageListen();
                }
              }
            });
            return CommonChatScreen(
              state: 'loaded',
              topicName: widget.topicName,
              messageProvider: providerInScreen,
              server: widget.server,
              account: acc,
              messageData: const [],
              hasMessage: hasMessages,
            );
          } else if (state is TokenErrorState) {
            return CommonChatScreen(
              state: state.error,
              topicName: widget.topicName,
              server: widget.server,
              account: widget.account,
              messageData: const [],
              hasMessage: hasMessages,
            );
          } else if (state is TokenLoadingState) {
            return CommonChatScreen(
              state: 'loading',
              topicName: widget.topicName,
              server: widget.server,
              account: widget.account,
              messageData: const [],
              hasMessage: hasMessages,
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
  final MessageProvider? messageProvider;
  final String server;
  final Account account;
  final String state;
  final List<Messages> messageData;
  final bool hasMessage;
  const CommonChatScreen(
      {super.key,
      required this.topicName,
      this.messageProvider,
      required this.server,
      required this.account,
      required this.state,
      required this.messageData,
      required this.hasMessage});

  @override
  State<CommonChatScreen> createState() => _CommonChatScreenState();
}

class _CommonChatScreenState extends State<CommonChatScreen> {
  late List<Messages> messageData;
  @override
  void initState() {
    super.initState();
    messageData = widget.messageData;
    final TokenBloc tokenBloc = context.read<TokenBloc>();
    if (widget.account.email.isNotEmpty) {
      tokenBloc.add(TokenLoadEvent(roomName: widget.topicName, type: 'ws'));
    } else {
      tokenBloc.add(
          TokenLoadFromGetEvent(roomName: widget.topicName, context: context));
    }
  }

  @override
  void dispose() {
    if (widget.messageProvider != null) {
      widget.messageProvider!.channel.sink.close();
      print('dispose in screen');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var paddingTop = MediaQuery.of(context).padding.top;
    var paddingButton = MediaQuery.of(context).padding.bottom;
    var screenHeight =
        MediaQuery.of(context).size.height - 56 - paddingTop - paddingButton;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: MyAppBar(
            roomName: widget.topicName,
          ),
          body: Container(
            alignment: Alignment.bottomCenter,
            height: screenHeight,
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
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
                      height: (screenHeight - 250) * 1,
                      child: BlockMessages(
                        key: blockMessageStateKey,
                        checkContext: context,
                        state: widget.state,
                        messageData: widget.messageData,
                        updateState: () {
                          setState(() {});
                        },
                        hasMessage: widget.hasMessage,
                        roomName: widget.topicName,
                      ),
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
  final List<Messages> messageData;
  final Function updateState;
  final String state;
  final BuildContext? checkContext;
  final bool hasMessage;
  final String roomName;
  const BlockMessages({
    super.key,
    this.checkContext,
    required this.messageData,
    required this.updateState,
    required this.state,
    required this.hasMessage,
    required this.roomName,
  });

  @override
  State<BlockMessages> createState() => _BlockMessagesState();
}

class _BlockMessagesState extends State<BlockMessages> {
  final List<Messages> _messages = [];
  bool showWrite = false;
  final controller = ScrollController();
  bool showArrow = true;
  final scrollChatController = ScrollChatControll();
  late double screenWidth;

  whenWriting(String name) async {
    setState(() {
      showWrite = true;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        showWrite = false;
      });
    });
  }

  void showingArrow() {
    setState(() {
      showArrow = !showArrow;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Container(
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
                      : widget.state == 'empty'
                          ? messegeViewFromGet(themeProvider)
                          : Center(
                              child: widget.state == 'loading'
                                  ? CircularProgressIndicator(
                                      color: themeProvider
                                          .currentTheme.shadowColor,
                                    )
                                  : Center(
                                      child: Text(
                                        widget.state,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor,
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          height: 1.30,
                                        ),
                                      ),
                                    )),
                  showWrite ? const WriteAnimated() : Container(),
                ],
              ),
            ));
      },
    );
  }

  List<Messages> _cachedMessages = [];

  Widget messageView(ThemeProvider themeProvider) {
    bool countNewMessages = (_messages.length - _cachedMessages.length) == 1;
    if (widget.hasMessage || _messages.isNotEmpty) {
      _cachedMessages = _messages.reversed.toList();
      return Observer(builder: (context, watch) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(left: 10, right: 10),
              reverse: true,
              controller: controller,
              itemCount: _cachedMessages.length,
              itemBuilder: (context, index) {
                if (controller.offset > 500 &&
                    !watch(scrollChatController.showArrow)) {
                  scrollChatController.clearNewMessagess();
                  scrollChatController.showingArrow();
                } else if (controller.offset < 500 &&
                    watch(scrollChatController.showArrow)) {
                  scrollChatController.showingArrow();
                  scrollChatController.clearNewMessagess();
                }
                if (countNewMessages && controller.offset > 500) {
                  countNewMessages = !countNewMessages;
                  scrollChatController.addNewMessage();
                  controller.jumpTo(controller.offset + 82);
                }
                return _cachedMessages[index];
              },
            ),
            AnimatedOpacity(
              opacity: watch(scrollChatController.showArrow) ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      scrollChatController.showingArrow();
                      scrollChatController.clearNewMessagess();
                      controller.animateTo(0.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linear);
                    },
                    backgroundColor: themeProvider.currentTheme.cardColor,
                    mini: true,
                    child: Icon(
                      Icons.arrow_downward,
                      color: themeProvider.currentTheme.primaryColor,
                    ),
                  ),
                  watch(scrollChatController.countNewMessages) != 0
                      ? Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            height: 14,
                            width: 14,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              watch(
                                scrollChatController.countNewMessages,
                              ).toString(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            )
          ],
        );
      });
    } else {
      return ClearBlockMessages(
        themeProvider: themeProvider,
      );
    }
  }

  Widget messegeViewFromGet(ThemeProvider themeProvider) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double fontSize = mediaQuery.size.width * 0.033;
    if (widget.messageData.isNotEmpty) {
      _cachedMessages = _messages.reversed.toList();
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 74),
            child: ListView.builder(
              reverse: true,
              itemCount: widget.messageData.length,
              itemBuilder: (context, index) {
                return widget.messageData[index];
              },
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 74,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: themeProvider.currentTheme.cardColor,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/logo_not_register.png',
                      color: themeProvider.currentTheme.shadowColor,
                      width: 32,
                      height: 32,
                    ),
                  ),
                  Expanded(
                    child: MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: TextScaler.noScaling),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'In order to read new messages, be able to\nwrite and create your own rooms - REGISTER\nor LOG IN ',
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: fontSize,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: '(look for this option in the menu)',
                              style: TextStyle(
                                color: themeProvider.currentTheme.disabledColor,
                                fontSize: fontSize,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    } else {
      return ClearBlockMessages(
        themeProvider: themeProvider,
      );
    }
  }
}

class ClearBlockMessages extends StatelessWidget {
  final ThemeProvider themeProvider;
  const ClearBlockMessages({
    super.key,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
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
            height: 8,
          ),
          Text(
            'Oops.. there are no messages here yet \nWrite first!',
            textAlign: TextAlign.center,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: themeProvider.currentTheme.primaryColor.withOpacity(0.5),
              fontSize: 16,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              height: 1.16,
            ),
          ),
        ],
      ),
    );
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        hintText: widget.state == 'empty'
                            ? 'Please log in or register...'
                            : widget.state == 'loaded'
                                ? 'Write message...'
                                : 'Loading...',
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
                        if (widget.state == 'empty' &&
                            widget.account.email.isEmpty) {
                          FocusScope.of(context).unfocus();
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return LoginDialog();
                            },
                          );
                          final TokenBloc tokenBloc = context.read<TokenBloc>();
                          tokenBloc.add(TokenLoadEvent(
                              roomName: widget.topicName, type: 'ws'));
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
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    final message = messageController.text;
                    if (message.isNotEmpty && widget.state == 'loaded') {
                      _sendMessage(message);
                      messageController.clear();
                      await Future.delayed(const Duration(milliseconds: 500));
                      blockMessageStateKey.currentState!.controller.jumpTo(0.0);
                      blockMessageStateKey.currentState!.scrollChatController
                          .showingArrow();
                      blockMessageStateKey.currentState!.scrollChatController
                          .clearNewMessagess();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
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
                      textScaler: TextScaler.noScaling,
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
