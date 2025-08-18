import 'package:flutter/material.dart';

class AppTheme {
  // 1. 统一主色为米色/金色/深棕色宫廷风
  static const Color primaryColor = Color(0xFFB45A1B); // 深棕色
  static const Color secondaryColor = Color(0xFFD2B48C); // 浅金色
  static const Color accentColor = Color(0xFFF8E3C7); // 米色
  static const Color tertiaryColor = Color(0xFFF6C177); // 金色
  static const Color quaternaryColor = Color(0xFFE6CBA8); // 浅米色
  
  // 背景色
  static const Color backgroundColor = Color(0xFFF8F3E8); // 米色
  static const Color surfaceColor = Color(0xFFFFFBF5); // 更柔和米色
  static const Color cardBackground = Color(0xFFFFFBF5);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF8C6E4B); // 深棕色
  static const Color textSecondary = Color(0xFFB45A1B); // 金棕色
  static const Color textLight = Color(0xFFD2B48C); // 浅金色
  static const Color textMuted = Color(0xFFBFA888); // 米灰色
  
  // 状态颜色
  static const Color successColor = Color(0xFFB7A16A); // 宫廷金
  static const Color warningColor = Color(0xFFF6C177); // 金色
  static const Color errorColor = Color(0xFFD2691E); // 棕红色
  static const Color infoColor = Color(0xFFE6CBA8); // 浅米色

  // 现代化渐变色定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, tertiaryColor],
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [quaternaryColor, errorColor],
  );
  
  static const LinearGradient rainbowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor, accentColor, tertiaryColor],
  );

  // 阴影
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Color(0x33B45A1B), // 深棕色半透明
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Color(0x44B45A1B),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Color(0x66B45A1B),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // 字体
  static const String fontFamily = 'SourceHanSerifSC, PingFang SC, Roboto Slab, serif';

  static final ThemeData lightTheme = ThemeData(
    fontFamily: fontFamily,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      background: backgroundColor,
      surface: cardBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: fontFamily),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          fontFamily: fontFamily,
        ),
      ),
    ),
    
    // 文本按钮主题 - 更现代的设计
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    
    // 现代化输入框样式 - 更精致的边框和阴影
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: quaternaryColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: quaternaryColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(
        color: textMuted,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      labelStyle: TextStyle(
        color: textSecondary,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
    ),
    
    // 现代化卡片样式 - 更丰富的阴影和边框
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: quaternaryColor, width: 1),
      ),
      margin: const EdgeInsets.all(8),
      color: cardBackground,
    ),
    
    // 现代化Chip样式 - 更圆润的设计
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: surfaceColor,
      selectedColor: primaryColor.withOpacity(0.15),
      side: BorderSide(color: quaternaryColor, width: 1),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: fontFamily,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // 现代化的分割线样式
    dividerTheme: DividerThemeData(
      color: quaternaryColor,
      thickness: 1,
      space: 1,
    ),
    
    // 现代化列表瓦片样式 - 更丰富的视觉效果
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.2,
        fontFamily: fontFamily,
      ),
      subtitleTextStyle: const TextStyle(
        fontSize: 14,
        color: textSecondary,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      leadingAndTrailingTextStyle: const TextStyle(
        fontSize: 14,
        color: textLight,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
    ),
    
    // 图标主题 - 更丰富的颜色
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
    
    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: quaternaryColor,
    ),
    
    // 开关主题 - 更现代的设计
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return quaternaryColor;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.3);
        }
        return quaternaryColor.withOpacity(0.3);
      }),
    ),
    
    // 复选框主题 - 更圆润的设计
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    // 文本主题
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: -1.0,
        fontFamily: fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.8,
        fontFamily: fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.6,
        fontFamily: fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.5,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.2,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimary,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.3,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.4,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
    ),
  );

  // 深色主题
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade800, width: 1),
      ),
      margin: const EdgeInsets.all(8),
    ),
  );
}