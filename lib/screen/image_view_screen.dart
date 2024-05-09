import 'dart:io';

import 'package:coolchat/servises/file_controller.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:coolchat/widget/content_view_appbar.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewScreen extends StatefulWidget {
  final String imageUrl;
  bool fileSend = false;

  ImageViewScreen({super.key, required this.imageUrl, required this.fileSend});

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  bool downloading = false;
  File? imageFile;
  ImageProvider? imageProvider;

  @override
  Widget build(BuildContext context) {
    String imageName =
        widget.imageUrl.substring(widget.imageUrl.lastIndexOf('/') + 1);
    if (widget.fileSend) {
      imageFile = File(widget.imageUrl);
      imageProvider = FileImage(imageFile!);
    }
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor: themeProvider.currentTheme.primaryColorDark,
        drawerScrimColor: themeProvider.currentTheme.primaryColorDark,
        appBar: ContentViewAppBar(
            titleText: imageName,
            fileSend: widget.fileSend,
            imageUrl: widget.imageUrl,
            themeProvider: themeProvider),
        body: PhotoView(
          imageProvider: widget.fileSend
              ? imageProvider
              : CachedNetworkImageProvider(widget.imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration:
              BoxDecoration(color: themeProvider.currentTheme.primaryColorDark),
        ),
      );
    });
  }
}
