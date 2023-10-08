import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedImageProvider extends ImageProvider<CachedImageProvider> {
  final String imageUrl;

  CachedImageProvider(this.imageUrl);

  @override
  ImageStreamCompleter load(CachedImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(),
      scale: 1.0,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<CachedImageProvider>('Image key', key);
      },
    );
  }

  Future<ui.Codec> _loadAsync() async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    if (file != null) {
      final Uint8List bytes = await file.readAsBytes();
      return await ui.instantiateImageCodec(bytes);
    } else {
      throw Exception('Failed to load image: $imageUrl');
    }
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedImageProvider && other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => imageUrl.hashCode;
}
