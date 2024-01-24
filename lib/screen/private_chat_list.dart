import 'dart:convert';

import 'package:coolchat/account.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/my_appbar.dart';
import 'package:coolchat/private_rooms.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PrivateChatList extends StatefulWidget {
  PrivateChatList({super.key});

  @override
  _PrivateChatListState createState() => _PrivateChatListState();
}

class _PrivateChatListState extends State<PrivateChatList> {
  final _scrollController = ScrollController();
  List<RoomPrivate> roomsList = [];
  bool emptyChat = true;
  bool refresh = false;
  final server = Server.server;
  late AccountSettingProvider _accountSettingProvider;
  late Account account;
  late Map<dynamic, dynamic> token;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _accountSettingProvider =
        Provider.of<AccountSettingProvider>(context, listen: false);
    _accountSettingProvider.addListener(_onRefresh);
    getToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData(server);
  }

  void _onRefresh() async {
    print('onRefresh');
    await fetchData(server);
    setState(() {});
  }

  getToken() async {
    final acc = await readAccountFuture();
    final tok = await loginProcess(acc.email, acc.password);
    setState(() {
      token = tok;
      account = acc;
    });
    fetchData(server);
  }

  Future<http.Response> _getData(String server) async {
    final url = Uri.https(server, '/direct/${account.id}');
    return await http.get(url);
  }

  Future<void> fetchData(String server) async {
    try {
      http.Response response = await _getData(server);
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<RoomPrivate> rooms =
            RoomPrivate.fromJsonList(jsonList, account, token, context)
                .toList();
        if (mounted) {
          setState(() {
            roomsList = rooms;
            emptyChat = false;
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
      _handleScrollDown();
    }
  }

  void _handleScrollDown() {
    fetchData(server);
  }

  Future<void> _updateScreen() async {
    await fetchData(server);
  }

  Future<void> refreshPrivateScreen() async {
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
    double screenHeight = MediaQuery.of(context).size.height;
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
            backgroundColor: themeProvider.currentTheme.primaryColorDark,
            appBar: MyAppBar(),
            body: emptyChat
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(64.0),
                      child: CircularProgressIndicator(
                        color: themeProvider.currentTheme.shadowColor,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: refresh ? 70 : 0,
                        alignment: Alignment.center,
                        color: themeProvider.currentTheme.primaryColorDark,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: themeProvider.currentTheme.shadowColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                color: themeProvider
                                    .currentTheme.primaryColorDark),
                            child: NotificationListener(
                              onNotification: (notification) {
                                if (notification is OverscrollNotification &&
                                    !refresh) {
                                  if (notification.overscroll < 0) {
                                    refreshPrivateScreen();
                                  }
                                }
                                return false;
                              },
                              child: CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, bottom: 5, right: 20),
                                        child: Text(
                                          'Your personal chats',
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
                                      ),
                                    ),
                                  ),
                                  roomsList.isNotEmpty
                                      ? ScrollRoomsList(
                                          roomsList: roomsList,
                                        )
                                      : const EmptyPrivatChatList(),
                                  const SliverToBoxAdapter(
                                      child: SizedBox(
                                          height: 8, width: double.infinity)),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class EmptyPrivatChatList extends StatelessWidget {
  const EmptyPrivatChatList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Image.asset('assets/images/clear_personal_chats.png'),
              ),
              Text(
                'Your personal chats\nwill be here soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      themeProvider.currentTheme.primaryColor.withOpacity(0.6),
                  fontSize: 24,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ScrollRoomsList extends StatelessWidget {
  final List<RoomPrivate> roomsList;
  const ScrollRoomsList({super.key, required this.roomsList});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => roomsList[index],
          childCount: roomsList.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.826,
        ),
      ),
    );
  }
}
