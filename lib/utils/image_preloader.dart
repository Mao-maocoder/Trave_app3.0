import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';

class ImagePreloader {
  static final Map<String, ui.Image?> _imageCache = {};
  static final Set<String> _loadingImages = {};

  /// 预加载图片
  static Future<void> preloadImage(String imagePath) async {
    if (_imageCache.containsKey(imagePath) || _loadingImages.contains(imagePath)) {
      return;
    }

    _loadingImages.add(imagePath);
    
    try {
      final ImageProvider provider = imagePath.startsWith('assets/')
          ? AssetImage(imagePath)
          : NetworkImage(imagePath) as ImageProvider;
      
      final Completer<ui.Image> completer = Completer<ui.Image>();
      final ImageStream stream = provider.resolve(ImageConfiguration.empty);
      
      stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }));
      
      final ui.Image image = await completer.future;
      _imageCache[imagePath] = image;
    } catch (e) {
      print('Failed to preload image: $imagePath, error: $e');
    } finally {
      _loadingImages.remove(imagePath);
    }
  }

  /// 预加载多个图片
  static Future<void> preloadImages(List<String> imagePaths) async {
    final futures = imagePaths.map((path) => preloadImage(path));
    await Future.wait(futures);
  }

  /// 获取缓存的图片
  static ui.Image? getCachedImage(String imagePath) {
    return _imageCache[imagePath];
  }

  /// 清除缓存
  static void clearCache() {
    _imageCache.clear();
  }

  /// 获取缓存大小
  static int get cacheSize => _imageCache.length;

  /// 检查图片是否已缓存
  static bool isCached(String imagePath) {
    return _imageCache.containsKey(imagePath);
  }
} 