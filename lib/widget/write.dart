import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WriteAnimated extends StatefulWidget {
  const WriteAnimated({Key? key}) : super(key: key);

  @override
  _WriteAnimatedState createState() => _WriteAnimatedState();
}

class _WriteAnimatedState extends State<WriteAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _leftAnimation;
  late Animation<Offset> _rightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _leftAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _rightAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: EdgeInsets.all(3),
          height: 20,
          width: 100,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SlideTransition(
                position: _rightAnimation,
                child: Image.asset(
                  'assets/images/feather.png',
                  color: themeProvider.currentTheme.shadowColor,
                  fit: BoxFit.cover,
                ),
              ),
              SlideTransition(
                position: _leftAnimation,
                child: Image.asset(
                  'assets/images/wave.png',
                  color: themeProvider.currentTheme.shadowColor,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
