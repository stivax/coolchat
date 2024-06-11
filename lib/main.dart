// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:coolchat/screen/search_screen.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/servises/message_block_function_provider.dart';
import 'package:coolchat/servises/messages_list_provider.dart';
import 'package:coolchat/servises/search_provider.dart';
import 'package:coolchat/widget/main_footer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:coolchat/animation_start.dart';
import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/model/message_privat_push.dart';
import 'package:coolchat/screen/private_chat_list.dart';
import 'package:coolchat/screen/setting.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:coolchat/servises/change_message_provider.dart';
import 'package:coolchat/servises/locale_provider.dart';
import 'package:coolchat/servises/message_private_push_container.dart';
import 'package:coolchat/servises/socket_connect.dart';
import 'package:coolchat/servises/socket_connect_container.dart';
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
        ChangeNotifierProvider<SearchProvider>(
            create: (context) => SearchProvider()),
        ChangeNotifierProvider<MessagesListProvider>(
            create: (context) => MessagesListProvider()),
        ChangeNotifierProvider<MessagesBlockFunctionProvider>(
            create: (context) => MessagesBlockFunctionProvider()),
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
  static final SocketConnectContainer socketConnectContainer =
      SocketConnectContainer.instance;
  const MyApp({super.key});

  void hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status != PermissionStatus.granted) {
        await Permission.notification.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        '/search': (context) => const SearchScreen(),
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
  SocketConnect? socketConnect;
  final server = Server.server;
  final suffix = Server.suffix;
  bool isListeningNotofication = false;
  bool refresh = false;
  StreamSubscription? _messageSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  List<MessagePrivatPush> oldMessagePrivatPushList = [];
  List<MessagePrivatPush> differenceList = [];
  late AccountProvider _accountProvider;
  late Timer _timerCheckAndRefreshListenWebsocket;
  late MainWidgetProvider provider;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    loadAndPeriodicReloadToken();
    _accountProvider = Provider.of<AccountProvider>(context, listen: false);
    _accountProvider.addListener(_onAccountChange);
    provider = Provider.of<MainWidgetProvider>(context, listen: false);
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
    socketConnect?.dispose();
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

  void loadAndPeriodicReloadToken() {
    getToken();
    Timer.periodic(const Duration(minutes: 20), (timer) {
      getToken();
    });
  }

  void timerCheckAndRefreshListenWebsocket() {
    _timerCheckAndRefreshListenWebsocket =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_accountProvider.isLoginProvider) {
        if (!isListeningNotofication) {
          print('isListeningNotofication');
          startListenSocket();
        } else if (socketConnect == null) {
          print('timer socketConnect == null');
          startListenSocket();
        } else if (!socketConnect!.isConnected) {
          print('timer socketConnect!.isConnected');
          startListenSocket();
        } else if (_messageSubscription == null) {
          print('timer messageSubscription == null');
          startListenSocket();
        } else if (_messageSubscription!.isPaused) {
          print('timer messageSubscription!.isPaused');
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData();
  }

  Future<void> startListenSocket() async {
    await getToken();
    final token = TokenContainer.viewToken();
    if (token.token["access_token"].toString().isNotEmpty) {
      await createProvider();
      listenSocket();
    }
  }

  Future<void> createProvider() async {
    final token = TokenContainer.viewToken();
    socketConnect = await SocketConnect.create(
        'wss://$server/notification?token=${token.token["access_token"]}');
    SocketConnectContainer.instance.addProvider('main', socketConnect!);
    createConnectivitySubscription();
  }

  Future<void> listenSocket() async {
    socketConnect ??= SocketConnectContainer.instance.getProvider('main')!;
    _messageSubscription?.cancel();
    isListeningNotofication = true;
    _messageSubscription = socketConnect!.messagesStream.listen(
      (event) async {
        if (event.toString().startsWith('{"update":"room update"')) {
          provider.updateCurrentTab();
        } else {
          final messagePushList = MessagePrivatPush.fromJsonList(event);
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
              _showNotification(mes.sender,
                  '${differenceList.length.toString()} new messages');
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
        }
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
      socketConnect!.sendMessage('ping');
    });
  }

  void createConnectivitySubscription() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        if (!isListeningNotofication) {
          startListenSocket();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    fetchData();
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
    if (tok.token["access_token"].toString().isNotEmpty) {
      TokenContainer.addToken(tok);
    }
    final provider = Provider.of<MainWidgetProvider>(context, listen: false);
    provider.loadTab();
  }

  Future<void> refreshScreen() async {
    setState(() {
      refresh = !refresh;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      refresh = !refresh;
    });
    await provider.updateCurrentTab();
    HapticFeedback.lightImpact();
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
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 10),
                                TabName(),
                                Expanded(
                                  child: ScrollRoomsList(),
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
  const ScrollRoomsList({super.key});

  @override
  State<ScrollRoomsList> createState() => _ScrollRoomsListState();
}

class _ScrollRoomsListState extends State<ScrollRoomsList> {
  bool scale = true;
  List<Room> rooms = [];
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
    _tabProvider.switchAndUpdateToMain();
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

  void _onSwitchTab() {
    setState(() {
      rooms = _tabProvider.tab.rooms!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 8),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => rooms[index],
                childCount: rooms.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: scale ? 2 : 3,
                crossAxisSpacing: scale ? 16.0 : 10.0,
                mainAxisSpacing: scale ? 16.0 : 10.0,
                childAspectRatio: 0.826,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 68),
          ),
        ],
      ),
    );
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
                    await fetchData();
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
        ? IgnorePointer(
            ignoring: true,
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height - 100,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
