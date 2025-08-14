import 'package:flutter/material.dart';
import '../constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final LinearGradient? gradient;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 20,
    this.shadows,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ?? kPrimaryGradient,
        boxShadow: shadows ?? kShadowColored,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpaceL),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: textColor ?? Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: kSpaceS),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor ?? Colors.white,
                            fontSize: kFontSizeM,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? kPrimaryColor,
          width: 2,
        ),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpaceL),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: textColor ?? kPrimaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: textColor ?? kPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: kSpaceS),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor ?? kPrimaryColor,
                            fontSize: kFontSizeM,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final LinearGradient gradient;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final List<BoxShadow>? shadows;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient = kRainbowGradient,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 20,
    this.shadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient,
        boxShadow: shadows ?? kShadowHeavy,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kSpaceL),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: textColor ?? Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: kSpaceS),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor ?? Colors.white,
                            fontSize: kFontSizeM,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// 使用示例
class ButtonExamples extends StatelessWidget {
  const ButtonExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('现代化按钮示例')),
      body: Padding(
        padding: const EdgeInsets.all(kSpaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 主要按钮
            PrimaryButton(
              text: '主要按钮',
              onPressed: () {},
            ),
            const SizedBox(height: kSpaceM),
            
            // 次要按钮
            SecondaryButton(
              text: '次要按钮',
              onPressed: () {},
            ),
            const SizedBox(height: kSpaceM),
            
            // 边框按钮
            GradientButton(
              text: '边框按钮',
              onPressed: () {},
            ),
            const SizedBox(height: kSpaceM),
            
            // 幽灵按钮
            PrimaryButton(
              text: '幽灵按钮',
              onPressed: () {},
            ),
            const SizedBox(height: kSpaceM),
            
            // 带图标的按钮
            PrimaryButton(
              text: '带图标',
              icon: Icons.add,
              onPressed: () {},
            ),
            const SizedBox(height: kSpaceM),
            
            // 加载状态按钮
            PrimaryButton(
              text: '加载中...',
              onPressed: () {},
              isLoading: true,
            ),
            const SizedBox(height: kSpaceM),
            
            // 小尺寸按钮
            PrimaryButton(
              text: '小按钮',
              onPressed: () {},
              width: 100,
              height: 40,
              borderRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}