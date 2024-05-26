// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/widget/chat_appbar.dart';
import 'package:coolchat/model/messages_list.dart';
import 'package:coolchat/screen/image_view_screen.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:coolchat/servises/audio_player.dart';
import 'package:coolchat/servises/change_message_provider.dart';
import 'package:coolchat/servises/custom_stopwatch.dart';
import 'package:coolchat/servises/file_controller.dart';
import 'package:coolchat/servises/reply_provider.dart';
import 'package:coolchat/servises/send_file_provider.dart';
import 'package:coolchat/servises/video_recorder.dart';
import 'package:coolchat/servises/video_recorder_provider.dart';
import 'package:coolchat/servises/voice_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/widget/write.dart';

import '../account.dart';
import '../beholder/scroll_chat_controll.dart';
import '../bloc/token_event.dart';
import '../bloc/token_state.dart';
import '../popap/login_popup.dart';
import '../members.dart';
import '../menu.dart';
import '../servises/message_provider.dart';
import '../model/messages.dart';
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
  final ListMessages listMessages = ListMessages();
  late BuildContext contextScreen;

  @override
  void initState() {
    super.initState();
    hasMessages = widget.hasMessage;
    WidgetsBinding.instance.addObserver(this);
    if (widget.account.email != '') {
      acc = widget.account;
    }
    contextScreen = context;
  }

  @override
  void dispose() {
    listMessages.clearObjects();
    providerInScreen?.dispose();
    _messageSubscription?.cancel();
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void messageListen() async {
    if (providerInScreen !=
        MessageProviderContainer.instance.getProvider(widget.topicName)!) {
      providerInScreen =
          MessageProviderContainer.instance.getProvider(widget.topicName)!;
      await _messageSubscription?.cancel();
      //print('listen begin');
      clearMessages();
      _messageSubscription = providerInScreen!.messagesStream.listen(
        (event) async {
          if (event.toString().startsWith('{"created_at"')) {
            formMessage(event.toString());
          } else if (event.toString().startsWith('{"type":"active_users"')) {
            formMembersList(event.toString());
          } else if (event.toString().startsWith('{"message":')) {
            clearMessages();
          } else if (event.toString().startsWith('{"type":')) {
            showWriting(event.toString());
          }
        },
        onDone: () {
          print('onDone');
          isListening = false;
          //providerInScreen!.setIsConnected = false;
        },
        onError: (e) {
          print('onError');
          isListening = false;
          //providerInScreen!.setIsConnected = false;
        },
      );
    }
  }

  void formMessage(String responseBody) {
    dynamic jsonMessage = jsonDecode(responseBody);
    Messages message = Messages.fromJsonMessage(jsonMessage,
        messageData.previousMemberID, context, widget.topicName, acc.id);
    messageData.previousMemberID = message.ownerId!.toInt();
    messageData.messages.add(message);
    listMessages.addObject(message);
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
          if (state is TokenEmptyState) {
            return CommonChatScreen(
              state: 'empty',
              topicName: widget.topicName,
              server: widget.server,
              account: widget.account,
              messageData: state.messagesList,
              hasMessage: hasMessages,
              contextScreen: contextScreen,
            );
          } else if (state is TokenLoadedState) {
            acc = state.account;
            //providerInScreen = MessageProviderContainer.instance.getProvider(widget.topicName)!;
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
              contextScreen: contextScreen,
            );
          } else if (state is TokenErrorState) {
            return CommonChatScreen(
              state: state.error,
              topicName: widget.topicName,
              server: widget.server,
              account: widget.account,
              messageData: const [],
              hasMessage: hasMessages,
              contextScreen: contextScreen,
            );
          } else if (state is TokenLoadingState) {
            return CommonChatScreen(
              state: 'loading',
              topicName: widget.topicName,
              server: widget.server,
              account: widget.account,
              messageData: const [],
              hasMessage: hasMessages,
              contextScreen: contextScreen,
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
  final BuildContext contextScreen;
  const CommonChatScreen(
      {super.key,
      required this.topicName,
      this.messageProvider,
      required this.server,
      required this.account,
      required this.state,
      required this.messageData,
      required this.hasMessage,
      required this.contextScreen});

  @override
  State<CommonChatScreen> createState() => _CommonChatScreenState();
}

class _CommonChatScreenState extends State<CommonChatScreen>
    with WidgetsBindingObserver {
  late List<Messages> messageData;
  late SendFileProvider showFileSend;
  late ChangeMessageProvider changer;
  late VideoRecorderProvider videoRecorderProvider;
  BuildContext? _buildContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    messageData = widget.messageData;
    showFileSend = Provider.of<SendFileProvider>(context, listen: false);
    showFileSend.addListener(_onShowFileSend);
    changer = Provider.of<ChangeMessageProvider>(context, listen: false);
    changer.addListener(_onChangeMessage);
    videoRecorderProvider =
        Provider.of<VideoRecorderProvider>(context, listen: false);
    videoRecorderProvider.addListener(_onVideoRecorder);
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
    showFileSend.removeListener(_onShowFileSend);
    changer.removeListener(_onChangeMessage);
    changer.clearChangeMessage();
    videoRecorderProvider.removeListener(_onVideoRecorder);
    if (widget.messageProvider != null) {
      widget.messageProvider!.dispose();
      WidgetsBinding.instance.removeObserver(this);
      //print('dispose in screen');
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _buildContext != null) {
      final TokenBloc tokenBloc = _buildContext!.read<TokenBloc>();
      if (widget.account.email.isNotEmpty) {
        tokenBloc.add(TokenLoadEvent(roomName: widget.topicName, type: 'ws'));
      } else {
        tokenBloc.add(TokenLoadFromGetEvent(
            roomName: widget.topicName, context: context));
      }
    }
  }

  void _onShowFileSend() {
    setState(() {});
  }

  void _onChangeMessage() {
    setState(() {});
  }

  void _onVideoRecorder() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    var paddingTop = MediaQuery.of(context).padding.top;
    var paddingButton = MediaQuery.of(context).padding.bottom;
    var screenHeight =
        MediaQuery.of(context).size.height - 56 - paddingTop - paddingButton;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: ChatAppBar(
            roomName: widget.topicName,
          ),
          body: Container(
            alignment: Alignment.bottomCenter,
            height: screenHeight,
            padding:
                const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: themeProvider.currentTheme.primaryColorDark),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //SizedBox(
                      //    height: 27,
                      //    child: TopicName(topicName: widget.topicName)),
                      /*SizedBox(
                          height: 140,
                          child: ChatMembers(
                              key: chatMembersStateKey,
                              topicName: widget.topicName,
                              server: widget.server,
                              updateState: () {
                                setState(() {});
                              })),*/
                      Expanded(
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
                      showFileSend.readyToSend
                          ? SizedBox(
                              //height: 58,
                              child: FileSend(
                                roomName: widget.topicName,
                                messageProvider: widget.messageProvider,
                              ),
                            )
                          : Container(),
                      showFileSend.addComent
                          ? AddComentToFile(
                              state: widget.state,
                              contextScreen: widget.contextScreen)
                          : changer.readyToChangeMessage
                              ? ChangeMessage(
                                  state: widget.state,
                                  contextScreen: widget.contextScreen)
                              : TextAndSend(
                                  state: widget.state,
                                  topicName: widget.topicName,
                                  server: widget.server,
                                  messageProvider: widget.messageProvider,
                                  account: widget.account,
                                  contextScreen: widget.contextScreen,
                                ),
                    ]),
                videoRecorderProvider.isRecording
                    ? VideoRecorder(
                        cameras: videoRecorderProvider.videoController.cameras,
                        controller:
                            videoRecorderProvider.videoController.controller,
                      )
                    : Container(),
              ],
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
        text:
            '${AppLocalizations.of(context).translate('common_chats_topic')}${widget.topicName}',
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
                        text:
                            '${AppLocalizations.of(context).translate('common_chats_topic')}${widget.topicName}',
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
                        '${AppLocalizations.of(context).translate('common_chats_topic')}${widget.topicName}',
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
                        AppLocalizations.of(context)
                            .translate('common_chats_chat_members'),
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
  List<Messages> _cachedMessages = [];
  bool showWrite = false;
  final controller = ScrollController();
  bool showArrow = true;
  final scrollChatController = ScrollChatControll();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  late double screenWidth;
  late ReplyProvider isReplying;
  int? lastIndex;
  double? lastOffset;

  @override
  void initState() {
    super.initState();
    isReplying = Provider.of<ReplyProvider>(context, listen: false);
    isReplying.addListener(_onReplying);
  }

  void _onReplying() async {
    setState(() {});
  }

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
    isReplying.afterReplyToMessage();
    isReplying.removeListener(_onReplying);
    //isReplying.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            child: Container(
              /*decoration: ShapeDecoration(
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
              ),*/
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
                ],
              ),
            ));
      },
    );
  }

  Widget messageView(ThemeProvider themeProvider) {
    bool countNewMessages = (_messages.length - _cachedMessages.length) == 1;
    if (widget.hasMessage || _messages.isNotEmpty) {
      _cachedMessages = _messages.reversed.toList();
      return Observer(builder: (context, watch) {
        return Stack(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: isReplying.isReplying ? 74 : 0),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ScrollablePositionedList.builder(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    reverse: true,
                    itemScrollController: isReplying.itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    scrollOffsetController: scrollOffsetController,
                    scrollOffsetListener: scrollOffsetListener,
                    itemCount: _cachedMessages.length,
                    itemBuilder: (context, index) {
                      final position =
                          itemPositionsListener.itemPositions.value;
                      if (position.isNotEmpty) {
                        if (position.first.index > 10 &&
                            !watch(scrollChatController.showArrow)) {
                          scrollChatController.clearNewMessagess();
                          scrollChatController.showingArrow();
                        } else if (position.first.index < 10 &&
                            watch(scrollChatController.showArrow)) {
                          scrollChatController.showingArrow();
                          scrollChatController.clearNewMessagess();
                        }
                        if (countNewMessages && position.first.index > 10) {
                          countNewMessages = !countNewMessages;
                          scrollChatController.addNewMessage();
                          scrollOffsetController.animateScroll(
                              offset: 82,
                              duration: const Duration(microseconds: 1));
                        }
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
                          onPressed: () async {
                            isReplying.itemScrollController.scrollTo(
                                index: 0,
                                duration: const Duration(milliseconds: 10));
                            await Future.delayed(
                                const Duration(milliseconds: 50));
                            scrollChatController.showingArrow();
                            scrollChatController.clearNewMessagess();
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
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  showWrite ? const WriteAnimated() : Container(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: isReplying.isReplying ? 74 : 0,
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
                        'assets/images/reply.png',
                        color: themeProvider.currentTheme.shadowColor,
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Expanded(
                      child: MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaler: TextScaler.noScaling),
                          child: Padding(
                            padding: EdgeInsets.only(top: 6, bottom: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context).translate('common_reply')} ${isReplying.nameRecevierMessage}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.shadowColor,
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                isReplying.fileUrl == null
                                    ? Messages.isImageLink(
                                            isReplying.textMessageToReply)
                                        ? Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Image.network(
                                              Messages.extractFirstUrl(
                                                  isReplying
                                                      .textMessageToReply)!,
                                              //width: screenWidth * 0.3,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Text(
                                            isReplying.textMessageToReply,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: themeProvider
                                                  .currentTheme.primaryColor
                                                  .withOpacity(0.9),
                                              fontSize: 14,
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )
                                    : Messages.isImageLink(isReplying.fileUrl!)
                                        ? Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Image.network(
                                              Messages.extractFirstUrl(
                                                  isReplying.fileUrl!)!,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.file_copy,
                                                  color: themeProvider
                                                      .currentTheme.shadowColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      Messages.extractFileName(
                                                          isReplying.fileUrl!),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      textScaler:
                                                          TextScaler.noScaling,
                                                      style: TextStyle(
                                                        color: themeProvider
                                                            .currentTheme
                                                            .primaryColor,
                                                        fontSize: 14,
                                                        fontFamily: 'Manrope',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      )),
                                                ),
                                              ],
                                            ))
                              ],
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: isReplying.isReplying
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: themeProvider.currentTheme.shadowColor,
                              ),
                              onPressed: () {
                                isReplying.afterReplyToMessage();
                                HapticFeedback.lightImpact();
                              },
                            )
                          : Container(),
                    )
                  ],
                ),
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
                              text: AppLocalizations.of(context)
                                  .translate('common_in_order'),
                              style: TextStyle(
                                color: themeProvider.currentTheme.primaryColor,
                                fontSize: fontSize,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('common_look'),
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
            AppLocalizations.of(context)
                .translate('common_chats_clear_message'),
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

class FileSend extends StatefulWidget {
  final String roomName;
  final MessageProvider? messageProvider;

  const FileSend({
    super.key,
    required this.roomName,
    required this.messageProvider,
  });

  @override
  State<FileSend> createState() => _FileSendState();
}

class _FileSendState extends State<FileSend> {
  double progress = 0.0;
  late bool sending;
  late SendFileProvider sendFile;
  late int size;
  late ReplyProvider isReplying;

  @override
  void initState() {
    super.initState();
    sendFile = Provider.of<SendFileProvider>(context, listen: false);
    isReplying = Provider.of<ReplyProvider>(context, listen: false);
    sending = false;
  }

  void _sendMessage() async {
    FileController uploader = FileController();
    setState(() {
      sending = true;
    });
    final size = await sendFile.file!.length();
    final messageForSend = await uploader.uploadFileDio(
        sendFile.file!.path, size, onProgress: (int sent, int total) {
      setState(() {
        progress = sent / total;
      });
    });
    final coment = sendFile.coment;
    final reply = isReplying.idMessageToReplying;
    if (messageForSend.isNotEmpty) {
      widget.messageProvider?.sendMessage(json.encode({
        "send": {
          "original_message_id": isReplying.isReplying ? reply : null,
          "message": coment,
          "fileUrl": messageForSend
        }
      }));
    }
    setState(() {
      sending = false;
    });
    isReplying.afterReplyToMessage();
    sendFile.clearFileFromSend();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
        child: Container(
            padding:
                const EdgeInsets.only(right: 0, left: 0, top: 0, bottom: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  themeProvider.currentTheme.shadowColor.withOpacity(0.4),
                  themeProvider.currentTheme.shadowColor.withOpacity(0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            FileController.isImageFileName(
                                    sendFile.file!.path.split('/').last)
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ImageViewScreen(
                                            fileSend: true,
                                            imageUrl: sendFile.file!.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: FileController.isImageFileName(
                                            sendFile.file!.path.split('/').last)
                                        ? Image.file(sendFile.file!,
                                            width: 32, height: 32)
                                        : Icon(
                                            Icons.file_copy,
                                            color: themeProvider
                                                .currentTheme.primaryColor,
                                            size: 32,
                                          ),
                                  )
                                : FileController.isAacFileName(
                                        sendFile.file!.path)
                                    ? AudioPlayerWidget(
                                        filePath: sendFile.file!.path)
                                    : Icon(
                                        Icons.file_copy,
                                        color: themeProvider
                                            .currentTheme.primaryColor,
                                        size: 32,
                                      ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(sendFile.file!.path.split('/').last,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: themeProvider
                                            .currentTheme.primaryColor,
                                        fontSize: 14,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          '${(sendFile.file!.statSync().size / 1000000).toStringAsFixed(3)} MB',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: themeProvider
                                                .currentTheme.primaryColor,
                                            fontSize: 14,
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w400,
                                          )),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            sendFile.startAddComent();
                                          },
                                          child: Text(
                                              sendFile.coment == null
                                                  ? AppLocalizations.of(context)
                                                      .translate(
                                                          'common_chats_add_comment')
                                                  : sendFile.coment!,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: themeProvider
                                                    .currentTheme.shadowColor,
                                                fontSize: 14,
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w400,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            sending
                                ? Container(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: themeProvider
                                          .currentTheme.shadowColor,
                                    ),
                                  )
                                : SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: IconButton(
                                      onPressed: () {
                                        _sendMessage();
                                      },
                                      padding: EdgeInsets.zero,
                                      splashRadius: 1,
                                      icon: Icon(
                                        Icons.send,
                                        color: themeProvider
                                            .currentTheme.shadowColor,
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: 32,
                              width: 32,
                              child: IconButton(
                                onPressed: () {
                                  sendFile.clearFileFromSend();
                                  sendFile.endAddComent();
                                },
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.close,
                                  color: themeProvider.currentTheme.shadowColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    )),
                Container(
                  width: (MediaQuery.of(context).size.width - 16) * progress,
                  height: 2,
                  decoration: ShapeDecoration(
                    color: themeProvider.currentTheme.shadowColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }
}

class TextAndSend extends StatefulWidget {
  final String topicName;
  final String server;
  final MessageProvider? messageProvider;
  final Account account;
  final String state;
  final BuildContext contextScreen;
  const TextAndSend(
      {super.key,
      required this.topicName,
      required this.server,
      required this.messageProvider,
      required this.account,
      required this.state,
      required this.contextScreen});

  @override
  _TextAndSendState createState() => _TextAndSendState();
}

class _TextAndSendState extends State<TextAndSend> with WidgetsBindingObserver {
  final TextEditingController messageController = TextEditingController();
  var token = {};
  final _textFieldFocusNode = FocusNode();
  bool isWriting = false;
  bool recording = false;
  late ReplyProvider isReplying;
  late AccountProvider _accountProvider;
  final CustomStopwatch _stopwatch = CustomStopwatch();
  String _displayTime = "00:00.00";
  final recorder = VoiceRecorder();
  String? voiceFilePath;
  late VideoRecorderProvider videoRecorderProvider;
  bool sendVideoIcon = true;

  @override
  void initState() {
    super.initState();
    isReplying = Provider.of<ReplyProvider>(context, listen: false);
    _accountProvider = Provider.of<AccountProvider>(context, listen: false);
    videoRecorderProvider =
        Provider.of<VideoRecorderProvider>(context, listen: false);
    _stopwatch.tickStream.listen((time) {
      setState(() {
        _displayTime = time;
      });
    });
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
      widget.messageProvider?.sendMessage(json.encode({
        "send": {
          "original_message_id":
              isReplying.isReplying ? isReplying.idMessageToReplying : null,
          "message": messageForSend,
          "fileUrl": null
        }
      }));
      isReplying.afterReplyToMessage();
    }
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
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.only(
                      right: 8, left: 8, top: 0, bottom: 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        themeProvider.currentTheme.shadowColor.withOpacity(0.4),
                        themeProvider.currentTheme.shadowColor.withOpacity(0.1)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  /*decoration: ShapeDecoration(
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
                  ),*/
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
                            ? AppLocalizations.of(context)
                                .translate('chats_please_log_in_or_register')
                            : widget.state == 'loaded'
                                ? recording
                                    ? _displayTime
                                    : AppLocalizations.of(context)
                                        .translate('chats_write_message')
                                : AppLocalizations.of(context)
                                    .translate('chats_loading'),
                        hintStyle: TextStyle(
                          color: themeProvider.currentTheme.primaryColor
                              .withOpacity(0.5),
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTapDown: (details) async {
                                if (_accountProvider.isLoginProvider) {
                                  FileController.showPopupMenu(
                                      widget.contextScreen,
                                      themeProvider,
                                      details.globalPosition);
                                }
                              },
                              child: Icon(
                                Icons.attach_file,
                                color: themeProvider.currentTheme.primaryColor,
                              ),
                            ),
                            sendVideoIcon
                                ? GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        sendVideoIcon = !sendVideoIcon;
                                      });
                                    },
                                    onLongPress: () async {
                                      if (_accountProvider.isLoginProvider) {
                                        await recorder.init();
                                        if (recorder.isRecorderInitialized) {
                                          _stopwatch.start();
                                          final filePath =
                                              await recorder.startRecording();
                                          setState(() {
                                            recording = true;
                                            voiceFilePath = filePath;
                                          });
                                        }
                                      }
                                    },
                                    onLongPressUp: () async {
                                      if (_accountProvider.isLoginProvider &&
                                          recorder.isRecording) {
                                        await recorder.stopRecording(
                                            context, voiceFilePath!);
                                        setState(() {
                                          recording = false;
                                        });
                                        _stopwatch.stop();
                                        _stopwatch.reset();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6, left: 6),
                                      child: Icon(
                                        Icons.mic,
                                        color: themeProvider
                                            .currentTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        sendVideoIcon = !sendVideoIcon;
                                      });
                                    },
                                    onLongPress: () async {
                                      if (_accountProvider.isLoginProvider) {
                                        await videoRecorderProvider
                                            .startRecording();
                                        if (videoRecorderProvider
                                            .videoController.isRecording) {
                                          setState(() {
                                            recording = true;
                                          });
                                          _stopwatch.start();
                                        }
                                      }
                                    },
                                    onLongPressUp: () async {
                                      if (_accountProvider.isLoginProvider &&
                                          videoRecorderProvider
                                              .videoController.isRecording) {
                                        await videoRecorderProvider
                                            .stopRecording(context);
                                        setState(() {
                                          recording = false;
                                        });
                                        _stopwatch.stop();
                                        _stopwatch.reset();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6, left: 6),
                                      child: Icon(
                                        Icons.camera,
                                        color: themeProvider
                                            .currentTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
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
                          if (_accountProvider.isLoginProvider) {
                            final TokenBloc tokenBloc =
                                context.read<TokenBloc>();
                            tokenBloc.add(TokenLoadEvent(
                                roomName: widget.topicName, type: 'ws'));
                          } else {
                            _textFieldFocusNode.unfocus();
                          }
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
                      blockMessageStateKey
                          .currentState!.isReplying.itemScrollController
                          .jumpTo(index: 0);
                      blockMessageStateKey.currentState!.scrollChatController
                          .showingArrow();
                      blockMessageStateKey.currentState!.scrollChatController
                          .clearNewMessagess();
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 0, bottom: 0),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/send_dark.png',
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                      )),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}

class AddComentToFile extends StatefulWidget {
  final String state;
  final BuildContext contextScreen;
  const AddComentToFile(
      {super.key, required this.state, required this.contextScreen});

  @override
  _AddComentToFileState createState() => _AddComentToFileState();
}

class _AddComentToFileState extends State<AddComentToFile>
    with WidgetsBindingObserver {
  final TextEditingController addComentController = TextEditingController();
  final _textFieldFocusNode = FocusNode();
  late ReplyProvider isReplying;
  late SendFileProvider sendFile;

  @override
  void initState() {
    super.initState();
    isReplying = Provider.of<ReplyProvider>(context, listen: false);
    sendFile = Provider.of<SendFileProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void dispose() {
    //isReplying.dispose();
    //sendFile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.only(
                      right: 8, left: 8, top: 0, bottom: 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        themeProvider.currentTheme.shadowColor.withOpacity(0.4),
                        themeProvider.currentTheme.shadowColor.withOpacity(0.1)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: TextFormField(
                      showCursor: true,
                      cursorColor: themeProvider.currentTheme.shadowColor,
                      controller: addComentController,
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
                        hintText: AppLocalizations.of(context)
                            .translate('chats_add_coment_to_file'),
                        hintStyle: TextStyle(
                          color: themeProvider.currentTheme.primaryColor
                              .withOpacity(0.5),
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        suffixIcon: GestureDetector(
                          onTapDown: (_) async {
                            sendFile.endAddComent();
                          },
                          child: Icon(
                            Icons.close,
                            color: themeProvider.currentTheme.primaryColor,
                          ),
                        ),
                      ),
                      maxLines: null,
                      onTap: () => FocusScope.of(context)
                          .requestFocus(_textFieldFocusNode),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    final coment = addComentController.text;
                    if (coment.isNotEmpty) {
                      sendFile.addComentToSend(coment);
                    }
                    sendFile.endAddComent();
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 0, bottom: 0),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/send_dark.png',
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                      )),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}

class ChangeMessage extends StatefulWidget {
  final String state;
  final BuildContext contextScreen;
  const ChangeMessage(
      {super.key, required this.state, required this.contextScreen});

  @override
  _ChangeMessageState createState() => _ChangeMessageState();
}

class _ChangeMessageState extends State<ChangeMessage>
    with WidgetsBindingObserver {
  final TextEditingController changeMessageController = TextEditingController();
  final _textFieldFocusNode = FocusNode();
  late ChangeMessageProvider changer;

  @override
  void initState() {
    super.initState();
    changer = Provider.of<ChangeMessageProvider>(context, listen: false);
    changeMessageController.text = changer.oldMessage!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void dispose() {
    //changer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.only(
                      right: 8, left: 8, top: 0, bottom: 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        themeProvider.currentTheme.shadowColor.withOpacity(0.4),
                        themeProvider.currentTheme.shadowColor.withOpacity(0.1)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: TextFormField(
                      showCursor: true,
                      cursorColor: themeProvider.currentTheme.shadowColor,
                      controller: changeMessageController,
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
                        hintText: AppLocalizations.of(context)
                            .translate('chats_add_coment_to_file'),
                        hintStyle: TextStyle(
                          color: themeProvider.currentTheme.primaryColor
                              .withOpacity(0.5),
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        suffixIcon: GestureDetector(
                          onTapDown: (_) async {
                            changer.finishWithNoChangeMessage();
                          },
                          child: Icon(
                            Icons.close,
                            color: themeProvider.currentTheme.primaryColor,
                          ),
                        ),
                      ),
                      maxLines: null,
                      onTap: () => FocusScope.of(context)
                          .requestFocus(_textFieldFocusNode),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    final newMessage = changeMessageController.text;
                    if (newMessage.isNotEmpty) {
                      changer.finishChangeMessage(newMessage);
                    }
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 0, bottom: 0),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/send_dark.png',
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                      )),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}
