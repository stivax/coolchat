import 'package:coolchat/servises/file_controller.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';

class ContentViewAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titleText;
  final bool fileSend;
  final String imageUrl;
  final ThemeProvider themeProvider;

  const ContentViewAppBar({
    super.key,
    required this.titleText,
    required this.fileSend,
    required this.imageUrl,
    required this.themeProvider,
  });

  @override
  _ContentViewAppBarState createState() => _ContentViewAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(56);
}

class _ContentViewAppBarState extends State<ContentViewAppBar> {
  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      backgroundColor: widget.themeProvider.currentTheme.primaryColorDark,
      title: Text(
        widget.titleText,
        style: TextStyle(
          color: widget.themeProvider.currentTheme.primaryColor,
          fontSize: 16,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          height: 1.24,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: widget.themeProvider.currentTheme.primaryColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        !widget.fileSend
            ? SizedBox(
                child: downloading
                    ? IconButton(
                        icon: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: widget
                                  .themeProvider.currentTheme.shadowColor),
                        ),
                        onPressed: () {},
                      )
                    : IconButton(
                        icon: Icon(Icons.download,
                            color:
                                widget.themeProvider.currentTheme.primaryColor),
                        onPressed: () async {
                          setState(() {
                            downloading = true;
                          });
                          await FileController.manageFileDownload(
                              context, widget.themeProvider, widget.imageUrl);
                          setState(() {
                            downloading = false;
                          });
                        },
                      ),
              )
            : const SizedBox(),
      ],
    );
  }
}
