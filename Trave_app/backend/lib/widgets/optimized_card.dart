import 'package:flutter/material.dart';
import '../constants.dart';

/// 优化的卡片组件，解决溢出和性能问题
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const OptimizedCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin ?? const EdgeInsets.only(bottom: kSpaceM),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(kRadiusL),
        boxShadow: elevation != null ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation! * 2,
            offset: Offset(0, elevation! / 2),
          ),
        ] : kShadowLight,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(kRadiusL),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(kSpaceM),
              child: child,
            ),
          ),
        ),
      ),
    );

    return cardContent;
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
    this.spacing = kSpaceM,
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
