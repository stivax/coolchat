import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/model/user_search.dart';
import 'package:coolchat/rooms.dart';
import 'package:coolchat/screen/common_chat.dart';
import 'package:coolchat/screen/private_chat.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:coolchat/servises/main_widget_provider.dart';
import 'package:coolchat/servises/search_provider.dart';
import 'package:coolchat/widget/main_appbar.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Room> rooms = [];
  List<UserSearch> users = [];
  final TextEditingController _controller = TextEditingController();
  final _textFieldFocusNode = FocusNode();
  late SearchProvider provider;
  late AccountProvider accountProvider;
  bool showUser = false;
  bool showRoom = false;
  bool isLogin = false;

  @override
  void initState() {
    provider = Provider.of<SearchProvider>(context, listen: false);
    provider.addListener(_onSearch);
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    isLogin = accountProvider.isLoginProvider;
    accountProvider.addListener(_onLogin);
    _textFieldFocusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    provider.removeListener(_onSearch);
    super.dispose();
  }

  void _onSearch() {
    setState(() {
      rooms = provider.rooms;
      users = provider.users;
      if (users.isNotEmpty) {
        showUser = true;
      } else {
        showUser = false;
      }
      if (rooms.isNotEmpty) {
        showRoom = true;
      } else {
        showRoom = false;
      }
    });
  }

  void _onLogin() {
    setState(() {
      isLogin = accountProvider.isLoginProvider;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MenuBloc>(
          create: (context) => MenuBloc(),
        ),
        BlocProvider<TokenBloc>.value(
          value: TokenBloc(
            tokenRepository: context.read<TokenRepository>(),
          ),
        )
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            backgroundColor: themeProvider.currentTheme.primaryColorDark,
            appBar: MyAppBar(),
            body: Container(
                padding: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: themeProvider.currentTheme.primaryColorDark,
                ),
                child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: Column(
                    children: [
                      TextFormField(
                        cursorColor: themeProvider.currentTheme.shadowColor,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: themeProvider.currentTheme.primaryColor,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: themeProvider.currentTheme.shadowColor
                                .withOpacity(0.7),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                              color: themeProvider.currentTheme.shadowColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                              color: themeProvider.currentTheme.shadowColor,
                              width: 1,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                              color: themeProvider.currentTheme.shadowColor,
                              width: 1,
                            ),
                          ),
                          labelText: 'Search',
                        ),
                        controller: _controller,
                        focusNode: _textFieldFocusNode,
                        style: TextStyle(
                          color: themeProvider.currentTheme.primaryColor,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                        onChanged: (_) {
                          if (_controller.text.length > 2) {
                            provider.searchUsersAndRooms(_controller.text);
                          } else {
                            provider.clear();
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: (!showUser &&
                                      !showRoom &&
                                      _controller.text.length > 2)
                                  ? Text(
                                      'Not found',
                                      style: TextStyle(
                                        color: themeProvider
                                            .currentTheme.primaryColor
                                            .withOpacity(0.8),
                                        fontSize: 16,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : Container(),
                            ),
                            SliverToBoxAdapter(
                              child: showUser
                                  ? Text(
                                      'User',
                                      style: TextStyle(
                                        color: themeProvider
                                            .currentTheme.primaryColor
                                            .withOpacity(0.8),
                                        fontSize: 16,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : Container(),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return UserSearchResultWidget(
                                    user: users[index],
                                    themeProvider: themeProvider,
                                    subString: _controller.text,
                                    accountProvider: accountProvider,
                                  );
                                },
                                childCount: users.length,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: showRoom
                                  ? Text(
                                      'Room',
                                      style: TextStyle(
                                        color: themeProvider
                                            .currentTheme.primaryColor
                                            .withOpacity(0.8),
                                        fontSize: 16,
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : Container(),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return RoomSearchResultWidget(
                                      room: rooms[index],
                                      themeProvider: themeProvider,
                                      subString: _controller.text,
                                      accountProvider: accountProvider);
                                },
                                childCount: rooms.length,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }
}

class UserSearchResultWidget extends StatelessWidget {
  final UserSearch user;
  final String subString;
  final ThemeProvider themeProvider;
  final AccountProvider accountProvider;
  const UserSearchResultWidget(
      {super.key,
      required this.user,
      required this.themeProvider,
      required this.subString,
      required this.accountProvider});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: HighlightText(
          themeProvider: themeProvider,
          word: user.userName,
          subWord: subString),
      trailing: accountProvider.isLoginProvider
          ? IconButton(
              icon: Icon(
                Icons.mail,
                color: themeProvider.currentTheme.shadowColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (contextPrivateRoom) => ChatScreen(
                      screenName: user.userName,
                      screenId: user.id,
                      hasMessage: false,
                      private: true,
                    ),
                  ),
                );
              },
            )
          : IconButton(
              icon: Icon(
                Icons.mail_lock,
                color: themeProvider.currentTheme.shadowColor,
              ),
              onPressed: () {},
            ),
    );
  }
}

class RoomSearchResultWidget extends StatelessWidget {
  final Room room;
  final String subString;
  final ThemeProvider themeProvider;
  final AccountProvider accountProvider;
  const RoomSearchResultWidget(
      {super.key,
      required this.room,
      required this.themeProvider,
      required this.subString,
      required this.accountProvider});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: HighlightText(
            themeProvider: themeProvider, word: room.name, subWord: subString),
        trailing: IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: themeProvider.currentTheme.shadowColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  screenName: room.name,
                  screenId: room.id,
                  hasMessage: room.countMessages > 0,
                  private: false,
                ),
              ),
            ).then((value) async {
              final provider =
                  Provider.of<MainWidgetProvider>(context, listen: false);
              await provider.loadTab();
              provider.updateCurrentTab();
            });
          },
        ));
  }
}

class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.themeProvider,
    required this.word,
    required this.subWord,
  });

  final ThemeProvider themeProvider;
  final String word;
  final String subWord;

  @override
  Widget build(BuildContext context) {
    if (subWord.isEmpty) {
      return Text(word,
          style: TextStyle(
            color: themeProvider.currentTheme.primaryColor,
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
          ));
    }

    String lowerWord = word.toLowerCase();
    String lowerSubWord = subWord.toLowerCase();

    List<TextSpan> spans = [];
    int startIndex = 0;
    int subWordIndex;

    while ((subWordIndex = lowerWord.indexOf(lowerSubWord, startIndex)) != -1) {
      if (subWordIndex > startIndex) {
        spans.add(TextSpan(
          text: word.substring(startIndex, subWordIndex),
          style: TextStyle(
            color: themeProvider.currentTheme.primaryColor,
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
          ),
        ));
      }

      spans.add(TextSpan(
        text: word.substring(subWordIndex, subWordIndex + subWord.length),
        style: TextStyle(
          color: themeProvider.currentTheme.primaryColor,
          fontSize: 16,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
          backgroundColor:
              themeProvider.currentTheme.shadowColor.withOpacity(0.5),
        ),
      ));

      startIndex = subWordIndex + subWord.length;
    }

    if (startIndex < word.length) {
      spans.add(TextSpan(
        text: word.substring(startIndex),
        style: TextStyle(
          color: themeProvider.currentTheme.primaryColor,
          fontSize: 16,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
        ),
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}
