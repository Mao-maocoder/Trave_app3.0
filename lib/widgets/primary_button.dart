// 注意：不要在此文件导出或声明IconButton，避免与Flutter原生IconButton冲突。
import 'package:flutter/material.dart';
import '../theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;
  final bool showShadow;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 56,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.gradient,
    this.showShadow = true,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : (widget.gradient ?? AppTheme.primaryGradient),
                color: widget.isOutlined 
                    ? Colors.transparent 
                    : (widget.backgroundColor ?? AppTheme.primaryColor),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                border: widget.isOutlined 
                    ? Border.all(
                        color: widget.backgroundColor ?? AppTheme.primaryColor,
                        width: 2,
                      )
                    : null,
                boxShadow: widget.showShadow && !widget.isOutlined ? [
                  BoxShadow(
                    color: (widget.backgroundColor ?? AppTheme.primaryColor).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ] : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isOutlined 
                                    ? (widget.backgroundColor ?? AppTheme.primaryColor)
                                    : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ] else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.isOutlined 
                                ? (widget.backgroundColor ?? AppTheme.primaryColor)
                                : (widget.textColor ?? Colors.white),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: widget.isOutlined 
                                ? (widget.backgroundColor ?? AppTheme.primaryColor)
                                : (widget.textColor ?? Colors.white),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 现代化图标按钮
class PrimaryIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showShadow;
  final BorderRadius? borderRadius;

  const PrimaryIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
    this.showShadow = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: showShadow ? [
          BoxShadow(
            color: (backgroundColor ?? AppTheme.primaryColor).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

// 现代化浮动操作按钮
class FloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const FloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
} 