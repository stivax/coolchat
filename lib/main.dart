// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/widget/main_footer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:coolchat/animation_start.dart';
import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/model/message_privat_push.dart';
import 'package:coolchat/model/token.dart';
import 'package:coolchat/screen/private_chat_list.dart';
import 'package:coolchat/screen/setting.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:coolchat/servises/change_message_provider.dart';
import 'package:coolchat/servises/locale_provider.dart';
import 'package:coolchat/servises/message_private_push_container.dart';
import 'package:coolchat/servises/message_provider.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/reply_provider.dart';
import 'package:coolchat/servises/send_file_provider.dart';
import 'package:coolchat/servises/token_container.dart';
import 'package:coolchat/servises/token_provider.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/servises/video_recorder_provider.dart';

import 'account.dart';
import 'bloc/token_blok.dart';
import 'menu.dart';
import 'rooms.dart';
import 'theme_provider.dart';
import 'widget/main_appbar.dart';
import 'widget/tap_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider()),
        ChangeNotifierProvider<AccountProvider>(
            create: (context) => AccountProvider()),
        ChangeNotifierProvider<AccountSettingProvider>(
            create: (context) => AccountSettingProvider()),
        ChangeNotifierProvider<ReplyProvider>(
            create: (context) => ReplyProvider()),
        ChangeNotifierProvider<LocaleProvider>(
            create: (context) => LocaleProvider()),
        ChangeNotifierProvider<SendFileProvider>(
            create: (context) => SendFileProvider()),
        ChangeNotifierProvider<ChangeMessageProvider>(
            create: (context) => ChangeMessageProvider()),
        ChangeNotifierProvider<VideoRecorderProvider>(
            create: (context) => VideoRecorderProvider()),
        ChangeNotifierProvider<MainWidgetProvider>(
            create: (context) => MainWidgetProvider()),
      ],
      child: RepositoryProvider(
          create: (context) => TokenRepository(), child: const StartScreen()),
    ),
  );
}

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 4)),
      builder: (context, snapshot) {
        if (themeProvider.isThemeChange &&
            snapshot.connectionState == ConnectionState.waiting) {
          return AnimationStart(
            size: 200,
          );
        } else {
          return const MyApp();
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  static final MessageProviderContainer messageProviderContainer =
      MessageProviderContainer.instance;
  const MyApp({super.key});

  void hasNotificationPermission() async {
    print('Platform.isAndroid ${Platform.isAndroid}');
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      print('status $status');
      if (status != PermissionStatus.granted) {
        await Permission.notification.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //hasNotificationPermission();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Cool Chat',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/p': (context) => PrivateChatList(),
        '/s': (context) => const SettingScreen(),
      },
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: themeProvider.currentTheme,

      ///
      ///
      locale: provider.currentLocale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  List<Room> roomsList = [];
  List<String> favoriteroomsList = [];
  MessageProvider? messageProvider;
  final server = Server.server;
  final suffix = Server.suffix;
  late Map<String, String> token;
  bool scale = false;
  bool isListeningNotofication = false;
  bool refresh = false;
  StreamSubscription? _messageSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  List<MessagePrivatPush> oldMessagePrivatPushList = [];
  List<MessagePrivatPush> differenceList = [];
  late AccountProvider _accountProvider;
  late AccountSettingProvider _accountSettingProvider;
  late Timer _timerCheckAndRefreshListenWebsocket;

  //
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    //requestPermissions();
    _accountProvider = Provider.of<AccountProvider>(context, listen: false);
    _accountProvider.addListener(_onAccountChange);
    _accountSettingProvider =
        Provider.of<AccountSettingProvider>(context, listen: false);
    _accountSettingProvider.addListener(_onScaleChange);
    scale = _accountSettingProvider.accountSettingProvider.scale;
    _accountSettingProvider.addListener(_onFavoriteRoomChange);
    favoriteroomsList =
        _accountSettingProvider.accountSettingProvider.favoriteroomList;
    _accountSettingProvider.addListener(_onRefresh);
    timerCheckAndRefreshListenWebsocket();

    // Ініціалізація плагіна
    var androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _accountProvider.removeListener(_onAccountChange);
    _accountSettingProvider.removeListener(_onScaleChange);
    _accountSettingProvider.removeListener(_onFavoriteRoomChange);
    messageProvider?.dispose();
    _messageSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _timerCheckAndRefreshListenWebsocket.cancel();
    super.dispose();
  }

  Future<void> _showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'Local Notification',
      channelDescription: 'New messages',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: Int64List?.fromList([0, 100]),
      playSound: false,
    );
    var iosDetails = const DarwinNotificationDetails();
    var generalNotificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      generalNotificationDetails,
    );
  }

  void timerCheckAndRefreshListenWebsocket() {
    _timerCheckAndRefreshListenWebsocket =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_accountProvider.isLoginProvider) {
        print('is Login');
        print('isListeningNotofication $isListeningNotofication');
        if (!isListeningNotofication) {
          print('isListeningNotofication');
          startListenSocket();
        } else if (messageProvider == null) {
          print('timer messageProvider == null');
          startListenSocket();
        } else if (!messageProvider!.isConnected) {
          print('timer messageProvider!.isConnected');
          startListenSocket();
        } else if (_messageSubscription == null) {
          print('timer messageSubscription == null');
          //listenSocket();
          startListenSocket();
        } else if (_messageSubscription!.isPaused) {
          print('timer messageSubscription!.isPaused');
          //_messageSubscription!.resume();
          startListenSocket();
        }
      }
    });
  }

  void _onAccountChange() {
    if (_accountProvider.isLoginProvider) {
      startListenSocket();
    } else {
      _messageSubscription?.cancel();
    }
  }

  void _onScaleChange() async {
    setState(() {
      scale = _accountSettingProvider.accountSettingProvider.scale;
    });
  }

  void _onRefresh() async {
    await fetchData(server);
    setState(() {});
  }

  void _onFavoriteRoomChange() async {
    setState(() {
      favoriteroomsList =
          _accountSettingProvider.accountSettingProvider.favoriteroomList;
    });
    await fetchData(server);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData(server);
  }

  Future<void> startListenSocket() async {
    await getToken();
    if (token["access_token"].toString().isNotEmpty) {
      TokenContainer.addToken(Token(token: token));
      await createProvider();
      listenSocket();
    }
  }

  Future<void> createProvider() async {
    print('createProvider()');
    messageProvider = await MessageProvider.create(
        'wss://$server/notification?token=${token["access_token"]}');
    MessageProviderContainer.instance.addProvider('main', messageProvider!);
    createConnectivitySubscription();
  }

  Future<void> listenSocket() async {
    messageProvider ??= MessageProviderContainer.instance.getProvider('main')!;
    //if ((_messageSubscription != null && _messageSubscription!.isPaused) || _messageSubscription == null) {
    print('listenSocket()');
    _messageSubscription?.cancel();
    isListeningNotofication = true;
    _messageSubscription = messageProvider!.messagesStream.listen(
      (message) async {
        final messagePushList = MessagePrivatPush.fromJsonList(message);
        if (messagePushList.isNotEmpty) {
          differenceList = MessagePrivatPush.differenceList(
              oldMessagePrivatPushList, messagePushList);
          if (differenceList.length == 1) {
            final mes = differenceList.last;
            _showNotification(
                mes.sender,
                mes.message.length > 20
                    ? '${mes.message.substring(0, 20)} ...'
                    : mes.message);
          } else if (MessagePrivatPush.checkSenderIdConsistency(
              differenceList)) {
            final mes = differenceList.last;
            _showNotification(
                mes.sender, '${differenceList.length.toString()} new messages');
          } else {
            _showNotification('Multiple senders',
                '${differenceList.length.toString()} new messages');
          }
        } else {
          differenceList.clear();
        }
        MessagePrivatePushContainer.removeObjects();
        MessagePrivatePushContainer.addObject(differenceList);
        oldMessagePrivatPushList = messagePushList;
      },
      onDone: () {
        print('onDone');
        isListeningNotofication = false;
      },
      onError: (e) {
        print('onError');
        isListeningNotofication = false;
      },
    );
    Timer.periodic(const Duration(seconds: 5), (timer) {
      messageProvider!.sendMessage('ping');
    });
    //}
  }

  void createConnectivitySubscription() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        if (!isListeningNotofication) {
          //listenSocket();
          startListenSocket();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    fetchData(server);
    if (state == AppLifecycleState.resumed) {
      if (!isListeningNotofication) {
        startListenSocket();
      }
    }
  }

  Future<void> getToken() async {
    final tokenProvider = TokenProvider();
    final acc = await readAccountFromStorage();
    final tok = await tokenProvider.loginProcess(acc.email, acc.password);
    setState(() {
      token = tok.token;
    });
  }

  Future<http.Response> _getData(String server) async {
    const suffix = Server.suffix;
    final url = Uri.https(server, '/$suffix/rooms/');
    return await http.get(url);
  }

  Future<void> fetchData(String server) async {
    try {
      http.Response response = await _getData(server);
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<Room> rooms = Room.fromJsonList(jsonList).toList();
        if (mounted) {
          rooms.sort((a, b) {
            if (a.isFavorite == b.isFavorite) {
              return 0;
            } else if (a.isFavorite) {
              return -1;
            }
            return 1;
          });
          setState(() {
            roomsList = rooms;
          });
        }
      } else {}
      // ignore: empty_catches
    } catch (error) {}
  }

  void _onScroll() {
    double offset = _scrollController.position.pixels;
    double maxOffset = _scrollController.position.maxScrollExtent;
    if (offset >= maxOffset &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      _updateScreen();
    }
  }

  Future<void> _updateScreen() async {
    await fetchData(server);
  }

  Future<void> refreshScreen() async {
    setState(() {
      refresh = !refresh;
    });
    await _updateScreen();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      refresh = !refresh;
    });
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            appBar: MyAppBar(),
            body: Stack(
              alignment: Alignment.centerRight,
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: refresh ? 70 : 0,
                        alignment: Alignment.center,
                        color: themeProvider.currentTheme.primaryColorDark,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: AnimationRefresh(size: 38)),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color:
                                  themeProvider.currentTheme.primaryColorDark),
                          child: NotificationListener(
                            onNotification: (notification) {
                              if (notification is OverscrollNotification &&
                                  !refresh) {
                                if (notification.overscroll < 0) {
                                  refreshScreen();
                                }
                              }
                              return false;
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                const TabName(),
                                Expanded(
                                  child: ScrollRoomsList(
                                    roomsList: roomsList,
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
                const Positioned.fill(child: BlurBackground()),
                Positioned(right: 0, bottom: 100, child: IconCarousel()),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: MainFooter(),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: 393,
      height: 228,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              AppLocalizations.of(context).translate('main_welcome1'),
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: const Color(0xFFF5FBFF),
                fontSize: screenWidth * 0.095,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.16,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
            child: Text(
              AppLocalizations.of(context).translate('main_welcome2'),
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: const Color(0xFFF5FBFF),
                fontSize: screenWidth * 0.038,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScrollRoomsList extends StatefulWidget {
  final List<Room> roomsList;
  const ScrollRoomsList({
    super.key,
    required this.roomsList,
  });

  @override
  State<ScrollRoomsList> createState() => _ScrollRoomsListState();
}

class _ScrollRoomsListState extends State<ScrollRoomsList> {
  bool scale = true;
  late List<Room> rooms;
  late MainWidgetProvider _tabProvider;
  late AccountSettingProvider _accountSettingProvider;

  @override
  void initState() {
    super.initState();
    _tabProvider = Provider.of<MainWidgetProvider>(context, listen: false);
    _tabProvider.addListener(_onSwitchTab);
    _accountSettingProvider =
        Provider.of<AccountSettingProvider>(context, listen: false);
    _accountSettingProvider.addListener(_onSwitchScale);
    rooms = widget.roomsList;
  }

  @override
  void dispose() {
    _tabProvider.removeListener(_onSwitchTab);
    _accountSettingProvider.removeListener(_onSwitchScale);
    super.dispose();
  }

  void _onSwitchScale() {
    setState(() {
      scale = _accountSettingProvider.accountSettingProvider.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 8),
      child: GridView.builder(
        itemBuilder: (context, index) => rooms[index],
        itemCount: rooms.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: scale ? 2 : 3,
          crossAxisSpacing: scale ? 16.0 : 10.0,
          mainAxisSpacing: scale ? 16.0 : 10.0,
          childAspectRatio: 0.826,
        ),
      ),
    );
  }

  void _onSwitchTab() {
    setState(() {
      rooms = _tabProvider.tab.rooms!;
    });
  }
}

class TabName extends StatefulWidget {
  const TabName({super.key});

  @override
  State<TabName> createState() => _TabNameState();
}

class _TabNameState extends State<TabName> {
  String name = 'All room';
  bool scale = false;
  late MainWidgetProvider _tabProvider;
  late AccountSettingProvider _accountSettingProvider;

  @override
  void initState() {
    super.initState();
    _tabProvider = Provider.of<MainWidgetProvider>(context, listen: false);
    _tabProvider.addListener(_onSwitchTab);
    _accountSettingProvider =
        Provider.of<AccountSettingProvider>(context, listen: false);
    _accountSettingProvider.addListener(_onSwitchScale);
  }

  @override
  void dispose() {
    _tabProvider.removeListener(_onSwitchTab);
    _accountSettingProvider.removeListener(_onSwitchScale);
    super.dispose();
  }

  void _onSwitchTab() {
    setState(() {
      name = _tabProvider.tab.nameTab!;
    });
  }

  void _onSwitchScale() {
    setState(() {
      scale = _accountSettingProvider.accountSettingProvider.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: themeProvider.currentTheme.primaryColor,
                    fontSize: 20,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    height: 1.24,
                  ),
                ),
              ),
              Container(),
              IconButton(
                  onPressed: () async {
                    await _accountSettingProvider.changeScale(context);
                    await fetchData(Server.server);
                  },
                  icon: Icon(scale ? Icons.grid_on : Icons.grid_view,
                      color: themeProvider.currentTheme.primaryColor))
            ],
          ),
        ),
      );
    });
  }
}

class BlurBackground extends StatefulWidget {
  const BlurBackground({super.key});

  @override
  State<BlurBackground> createState() => _BlurBackgroundState();
}

class _BlurBackgroundState extends State<BlurBackground> {
  bool show = false;
  late MainWidgetProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<MainWidgetProvider>(context, listen: false);
    provider.addListener(_onShow);
  }

  @override
  void dispose() {
    provider.removeListener(_onShow);
    super.dispose();
  }

  void _onShow() {
    setState(() {
      show = provider.showAddVariant;
    });
  }

  @override
  Widget build(BuildContext context) {
    return show
        ? Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 100,
                  ),
                ),
              ),
            ],
          )
        : Container();
  }
}
