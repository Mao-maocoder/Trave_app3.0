import 'package:flutter/material.dart';
import '../theme.dart';

/// 优化的卡片组件，解决溢出和性能问题
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showShadow;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;

  const OptimizedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.isSelected = false,
    this.showShadow = true,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor ?? AppTheme.cardBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: border ?? Border.all(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade100,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: showShadow ? [
          BoxShadow(
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 25 : 20,
            offset: Offset(0, isSelected ? 8 : 4),
            spreadRadius: isSelected ? 2 : 0,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 优化的行组件，自动处理溢出
class OptimizedRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const OptimizedRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 如果空间不足，使用Column布局
        if (constraints.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: child,
            )).toList(),
          );
        }
        
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children,
        );
      },
    );
  }
}

/// 优化的文本组件，自动处理溢出
class OptimizedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool flexible;

  const OptimizedText(
    this.text, {
    Key? key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.flexible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      text,
      style: style,
      maxLines: maxLines ?? 1,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign,
    );

    if (flexible) {
      return Flexible(child: textWidget);
    }

    return textWidget;
  }
}

/// 优化的按钮行组件
class OptimizedButtonRow extends StatelessWidget {
  final List<Widget> buttons;
  final double spacing;

  const OptimizedButtonRow({
    Key? key,
    required this.buttons,
    this.spacing = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 如果空间不足，垂直排列按钮
        if (constraints.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buttons.map((button) => Padding(
              padding: EdgeInsets.only(bottom: spacing / 2),
              child: button,
            )).toList(),
          );
        }

        // 空间充足时，水平排列
        return Row(
          children: buttons.asMap().entries.map((entry) {
            final index = entry.key;
            final button = entry.value;
            
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < buttons.length - 1 ? spacing : 0,
                ),
                child: button,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// 优化的芯片组件
class OptimizedChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const OptimizedChip({
    Key? key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: OptimizedText(
        label,
        style: TextStyle(
          fontSize: fontSize ?? 12,
          color: textColor,
        ),
        maxLines: 1,
        flexible: false,
      ),
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.blue[50],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

// 现代化渐变卡片
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Gradient gradient;
  final BorderRadius? borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    required this.gradient,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedCard(
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      onTap: onTap,
      gradient: gradient,
      borderRadius: borderRadius,
      showShadow: true,
      child: child,
    );
  }
}

// 现代化状态卡片
class StatusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color statusColor;
  final String statusText;
  final BorderRadius? borderRadius;

  const StatusCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    required this.statusColor,
    required this.statusText,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedCard(
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      onTap: onTap,
      borderRadius: borderRadius,
      border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 内容
          Expanded(child: child),
        ],
      ),
    );
  }
}

// 现代化信息卡片
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedCard(
      margin: margin,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accentColor ?? AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}
