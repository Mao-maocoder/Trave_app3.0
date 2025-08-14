import 'dart:async';
import 'package:flutter/material.dart';

/// 性能优化配置
class PerformanceConfig {
  // 防抖延迟时间
  static const Duration debounceDelay = Duration(milliseconds: 300);
  
  // 动画持续时间 - 根据性能模式动态调整
  static Duration get shortAnimation => _isPerformanceMode 
    ? const Duration(milliseconds: 100) 
    : const Duration(milliseconds: 200);
  static Duration get mediumAnimation => _isPerformanceMode 
    ? const Duration(milliseconds: 150) 
    : const Duration(milliseconds: 300);
  static Duration get longAnimation => _isPerformanceMode 
    ? const Duration(milliseconds: 200) 
    : const Duration(milliseconds: 400);
  
  // 列表项缓存大小
  static const int listCacheExtent = 200; // 减少缓存大小
  
  // 图片缓存配置
  static const int imageCacheSize = 50; // 减少缓存大小
  static const int imageCacheWidth = 200; // 减少图片尺寸
  static const int imageCacheHeight = 200;
  
  // 性能开关 - 根据性能模式动态调整
  static bool get enableComplexAnimations => !_isPerformanceMode;
  static bool get enableParticleEffects => !_isPerformanceMode;
  static bool get enableHeavyAnimations => !_isPerformanceMode;
  static bool get enableGradients => !_isPerformanceMode; // 新增：关闭渐变
  static bool get enableShadows => !_isPerformanceMode; // 新增：关闭阴影
  static bool get enableBlurEffects => !_isPerformanceMode; // 新增：关闭模糊效果
  
  // 性能优化选项
  static bool _isPerformanceMode = false; // 性能模式开关
  
  // 文本样式缓存
  static const Map<String, TextStyle> _textStyleCache = {};
  
  /// 获取缓存的文本样式
  static TextStyle getTextStyle(String key, TextStyle style) {
    return _textStyleCache[key] ?? style;
  }
  
  /// 优化的ListView构建器
  static Widget buildOptimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      cacheExtent: listCacheExtent.toDouble(),
      physics: _isPerformanceMode 
        ? const ClampingScrollPhysics() // 性能模式使用更简单的滚动物理
        : const BouncingScrollPhysics(),
      addAutomaticKeepAlives: !_isPerformanceMode, // 性能模式关闭自动保持
      addRepaintBoundaries: !_isPerformanceMode, // 性能模式关闭重绘边界
      addSemanticIndexes: !_isPerformanceMode, // 性能模式关闭语义索引
    );
  }
  
  /// 优化的GridView构建器
  static Widget buildOptimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      cacheExtent: listCacheExtent.toDouble(),
      physics: _isPerformanceMode 
        ? const ClampingScrollPhysics()
        : const BouncingScrollPhysics(),
      addAutomaticKeepAlives: !_isPerformanceMode,
      addRepaintBoundaries: !_isPerformanceMode,
      addSemanticIndexes: !_isPerformanceMode,
    );
  }
  
  /// 检查设备性能并调整配置
  static void adjustForDevicePerformance() {
    // 默认保留所有功能，用户可以选择开启性能模式
    _isPerformanceMode = false;
  }
  
  /// 获取性能模式状态
  static bool get isPerformanceMode => _isPerformanceMode;
  
  /// 开启性能模式
  static void enablePerformanceMode() {
    _isPerformanceMode = true;
  }
  
  /// 关闭性能模式
  static void disablePerformanceMode() {
    _isPerformanceMode = false;
  }
}

/// 防抖工具类
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = PerformanceConfig.debounceDelay});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// 性能监控工具
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};
  
  static void startTimer(String name) {
    _stopwatches[name] = Stopwatch()..start();
  }
  
  static void endTimer(String name) {
    final stopwatch = _stopwatches[name];
    if (stopwatch != null) {
      stopwatch.stop();
      debugPrint('Performance [$name]: ${stopwatch.elapsedMilliseconds}ms');
      _stopwatches.remove(name);
    }
  }
}

/// 内存优化的图片组件
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        cacheWidth: width?.toInt() ?? PerformanceConfig.imageCacheWidth,
        cacheHeight: height?.toInt() ?? PerformanceConfig.imageCacheHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? 
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? 
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
        },
      ),
    );
  }
}

/// 优化的动画组件
class OptimizedAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;

  OptimizedAnimatedContainer({
    Key? key,
    required this.child,
    Duration? duration,
    this.curve = Curves.easeInOut,
    this.onEnd,
  })  : duration = duration ?? PerformanceConfig.mediumAnimation,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        onEnd: onEnd,
        child: child,
      ),
    );
  }
}
