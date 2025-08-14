import 'package:flutter/material.dart';

class AppTheme {
  // 主色调 - 使用更丰富的渐变色系
  static const Color primaryColor = Color(0xFF667eea);
  static const Color secondaryColor = Color(0xFF764ba2);
  static const Color accentColor = Color(0xFFf093fb);
  static const Color tertiaryColor = Color(0xFF4facfe);
  static const Color quaternaryColor = Color(0xFF00f2fe);
  
  // 背景色 - 更柔和的色调
  static const Color backgroundColor = Color(0xFFf8fafc);
  static const Color surfaceColor = Colors.white;
  static const Color cardBackground = Color(0xFFffffff);
  
  // 文字颜色 - 更丰富的层次
  static const Color textPrimary = Color(0xFF1a202c);
  static const Color textSecondary = Color(0xFF4a5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textMuted = Color(0xFFa0aec0);
  
  // 状态颜色 - 更现代的色彩
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const Color infoColor = Color(0xFF4299e1);

  // 渐变色定义
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
  
  static const LinearGradient rainbowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor, accentColor, tertiaryColor],
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    
    // 现代化AppBar样式 - 更丰富的视觉效果
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 26,
      ),
    ),
    
    // 现代化按钮样式 - 更丰富的渐变和阴影
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
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
          letterSpacing: 0.5,
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
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryColor, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: errorColor, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // 现代化卡片样式 - 更丰富的阴影和边框
    cardTheme: CardTheme(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      margin: const EdgeInsets.all(12),
      color: cardBackground,
    ),
    
    // 现代化Chip样式 - 更圆润的设计
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      backgroundColor: Colors.grey.shade50,
      selectedColor: primaryColor.withOpacity(0.15),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // 现代化的分割线样式
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1.5,
      space: 1,
    ),
    
    // 现代化列表瓦片样式 - 更丰富的视觉效果
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.3,
      ),
      subtitleTextStyle: const TextStyle(
        fontSize: 14,
        color: textSecondary,
        fontWeight: FontWeight.w500,
      ),
      leadingAndTrailingTextStyle: const TextStyle(
        fontSize: 14,
        color: textLight,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // 图标主题 - 更丰富的颜色
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 26,
    ),
    
    // 进度指示器主题
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: Color(0xFFe2e8f0),
    ),
    
    // 开关主题 - 更现代的设计
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.3);
        }
        return Colors.grey.shade300;
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
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    
    // 文本主题
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textSecondary,
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
      scrolledUnderElevation: 0.5,
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
    cardTheme: CardTheme(
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