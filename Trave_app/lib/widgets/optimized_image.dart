import 'package:flutter/material.dart';
import '../constants.dart';

class OptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final bool enableCache;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableCache = true,
  }) : super(key: key);

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (widget.imageUrl.startsWith('assets/')) {
      // 本地资源图片
      imageWidget = Image.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.enableCache ? (widget.width?.toInt() ?? 300) : null,
        cacheHeight: widget.enableCache ? (widget.height?.toInt() ?? 300) : null,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            _isLoaded = true;
            _animationController.forward();
            return _buildImageWithBorder(child);
          }
          if (frame != null) {
            if (!_isLoaded) {
              _isLoaded = true;
              _animationController.forward();
            }
            return _buildImageWithBorder(child);
          }
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          _hasError = true;
          return _buildErrorWidget();
        },
      );
    } else {
      // 网络图片
      imageWidget = Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.enableCache ? (widget.width?.toInt() ?? 300) : null,
        cacheHeight: widget.enableCache ? (widget.height?.toInt() ?? 300) : null,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            if (!_isLoaded) {
              _isLoaded = true;
              _animationController.forward();
            }
            return _buildImageWithBorder(child);
          }
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          _hasError = true;
          return _buildErrorWidget();
        },
      );
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _isLoaded ? _fadeAnimation.value : 1.0,
          child: imageWidget,
        );
      },
    );
  }

  Widget _buildImageWithBorder(Widget child) {
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }
    return child;
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '加载中...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              '图片加载失败',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 