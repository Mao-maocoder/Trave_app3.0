import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// UI性能优化工具类
class UIPerformance {
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  static const Duration _animationDuration = Duration(milliseconds: 250);
  
  /// 防抖执行器
  static final Map<String, Timer> _debounceTimers = {};
  
  /// 防抖执行
  static void debounce(String key, VoidCallback callback) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(_debounceDelay, callback);
  }
  
  /// 清理防抖定时器
  static void clearDebounce(String key) {
    _debounceTimers[key]?.cancel();
    _debounceTimers.remove(key);
  }
  
  /// 延迟执行，避免阻塞UI
  static void scheduleFrame(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
  
  /// 分批处理大量数据，避免UI卡顿
  static Future<void> processBatch<T>(
    List<T> items,
    void Function(T item) processor, {
    int batchSize = 10,
    Duration delay = const Duration(milliseconds: 16), // 60fps
  }) async {
    for (int i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      final batch = items.sublist(i, end);
      
      for (final item in batch) {
        processor(item);
      }
      
      // 让出控制权，避免阻塞UI
      await Future.delayed(delay);
    }
  }
}

/// 性能优化的State基类
abstract class PerformantState<T extends StatefulWidget>
    extends State<T> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // 保持状态，避免重复构建
  
  /// 防抖setState
  void debouncedSetState(VoidCallback fn, [String? key]) {
    final debounceKey = key ?? runtimeType.toString();
    UIPerformance.debounce(debounceKey, () {
      if (mounted) {
        setState(fn);
      }
    });
  }
  
  /// 安全的setState
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
  
  @override
  void dispose() {
    UIPerformance.clearDebounce(runtimeType.toString());
    super.dispose();
  }
}

/// 优化的ListView构建器
class PerformantListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PerformantListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 使用RepaintBoundary包装每个item
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const BouncingScrollPhysics(),
      cacheExtent: 500, // 增加缓存范围
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: false, // 我们手动添加了RepaintBoundary
      addSemanticIndexes: true,
    );
  }
}

/// 优化的GridView构建器
class PerformantGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PerformantGridView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      gridDelegate: gridDelegate,
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const BouncingScrollPhysics(),
      cacheExtent: 500,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: false,
      addSemanticIndexes: true,
    );
  }
}

/// 懒加载组件
class LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  final Duration delay;

  const LazyWidget({
    Key? key,
    required this.builder,
    this.placeholder,
    this.delay = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  Widget? _child;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  void _loadWidget() {
    Timer(widget.delay, () {
      if (mounted) {
        setState(() {
          _child = widget.builder();
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _child != null) {
      return _child!;
    }
    
    return widget.placeholder ?? 
      const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
  }
}

/// 性能监控Widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String? name;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.name,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
  }

  @override
  void didUpdateWidget(PerformanceMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _stopwatch.stop();
    final elapsed = _stopwatch.elapsedMilliseconds;
    if (elapsed > 16) { // 超过一帧的时间
      debugPrint('Performance Warning [${widget.name ?? 'Unknown'}]: ${elapsed}ms');
    }
    _stopwatch = Stopwatch()..start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
