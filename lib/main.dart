import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:coolchat/screen/private_chat_list.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:coolchat/animation_start.dart';
import 'package:coolchat/message_provider.dart';
import 'package:coolchat/model/message_privat_push.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:coolchat/servises/message_private_push_container.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/token_repository.dart';

import 'account.dart';
import 'bloc/token_blok.dart';
import 'menu.dart';
import 'my_appbar.dart';
import 'rooms.dart';
import 'theme_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    return MaterialApp(
      title: 'Cool Chat',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/p': (context) => PrivateChatList(),
      },
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: themeProvider.currentTheme,
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
  late Map<dynamic, dynamic> token;
  bool scale = false;
  bool isListeningNotofication = false;
  bool refresh = false;
  StreamSubscription? _messageSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  late AccountProvider _accountProvider;
  late AccountSettingProvider _accountSettingProvider;
  late Timer _timerCheckAndRefreshListenWebsocket;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    requestPermissions();
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

  void timerCheckAndRefreshListenWebsocket() {
    _timerCheckAndRefreshListenWebsocket =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      print('timer ${timer.isActive.toString()}');
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
    print('onRefresh');
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
    print(token["access_token"].toString());
    if (token["access_token"].toString().isNotEmpty) {
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
        dynamic jsonMessage = jsonDecode(message);
        final messagePush = MessagePrivatPush.fromJson(jsonMessage);
        print(messagePush.messageId);
        MessagePrivatePushContainer.addObject(messagePush);
        MessagePrivatePushContainer.removeOldObjects();
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
      //listenSocket();
      startListenSocket();
    }
  }

  Future<void> getToken() async {
    final acc = await readAccountFromStorage();
    final tok = await loginProcess(acc.email, acc.password);
    setState(() {
      token = tok;
    });
  }

  Future<http.Response> _getData(String server) async {
    final url = Uri.https(server, '/rooms/');
    return await http.get(url);
  }

  Future<void> fetchData(String server) async {
    try {
      http.Response response = await _getData(server);
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<Room> rooms =
            Room.fromJsonList(jsonList, favoriteroomsList, scale).toList();
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

  Future<void> requestPermissions() async {
    final storagePermission = await Permission.storage.request();

    if (storagePermission.isGranted) {
    } else {}
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
            body: Column(
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
                        color: themeProvider.currentTheme.primaryColorDark),
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
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          const SliverToBoxAdapter(child: HeaderWidget()),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 30),
                          ),
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return SliverToBoxAdapter(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, bottom: 5, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Choose rooms for\ncommunication',
                                          textScaler: TextScaler.noScaling,
                                          style: TextStyle(
                                            color: themeProvider
                                                .currentTheme.primaryColor,
                                            fontSize: 24,
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w500,
                                            height: 1.24,
                                          ),
                                        ),
                                        Container(),
                                        IconButton(
                                            onPressed: () async {
                                              await _accountSettingProvider
                                                  .changeScale(context);
                                              await fetchData(Server.server);
                                            },
                                            icon: Icon(
                                                scale
                                                    ? Icons.grid_on
                                                    : Icons.grid_view,
                                                color: themeProvider
                                                    .currentTheme.primaryColor))
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          ScrollRoomsList(
                            roomsList: roomsList,
                            scale: scale,
                          ),
                          const SliverToBoxAdapter(
                              child:
                                  SizedBox(height: 8, width: double.infinity)),
                        ],
                      ),
                    ),
                  ),
                ),
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
      height: 428,
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
              'Welcome every\ntourist to Coolchat',
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
              'Chat about a wide variety of tourist equipment.\nCommunicate, get good advice and choose!',
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

class ScrollRoomsList extends StatelessWidget {
  final List<Room> roomsList;
  final bool scale;
  const ScrollRoomsList({
    super.key,
    required this.roomsList,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => roomsList[index],
          childCount: roomsList.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: scale ? 2 : 3,
          crossAxisSpacing: scale ? 16.0 : 10.0,
          mainAxisSpacing: scale ? 16.0 : 10.0,
          childAspectRatio: 0.826,
        ),
      ),
    );
  }
}
