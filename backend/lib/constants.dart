import 'package:flutter/material.dart';

// 现代化颜色方案
const kPrimaryColor = Color(0xFF667eea);
const kSecondaryColor = Color(0xFF764ba2);
const kAccentColor = Color(0xFFf093fb);
const kTertiaryColor = Color(0xFF4facfe);
const kQuaternaryColor = Color(0xFF00f2fe);

const kErrorColor = Color(0xFFf56565);
const kSuccessColor = Color(0xFF48bb78);
const kWarningColor = Color(0xFFed8936);
const kInfoColor = Color(0xFF4299e1);

// 背景色系
const kBackgroundColor = Color(0xFFf8fafc);
const kSurfaceColor = Color(0xFFffffff);
const kCardBackground = Color(0xFFffffff);

// 文字颜色系
const kTextPrimary = Color(0xFF1a202c);
const kTextSecondary = Color(0xFF4a5568);
const kTextLight = Color(0xFF718096);
const kTextMuted = Color(0xFFa0aec0);

const kPadding = 16.0;

// 现代化间距系统
const kSpaceXs = 4.0;
const kSpaceS = 8.0;
const kSpaceM = 16.0;
const kSpaceL = 24.0;
const kSpaceXl = 32.0;
const kSpaceXxl = 48.0;

// 现代化圆角系统
const kRadiusXs = 4.0;
const kRadiusS = 8.0;
const kRadiusM = 12.0;
const kRadiusL = 16.0;
const kRadiusXl = 20.0;
const kRadiusXxl = 24.0;
const kRadiusXxxl = 32.0;

// 现代化阴影系统
const kShadowLight = [
  BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  ),
];

const kShadowMedium = [
  BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  ),
];

const kShadowHeavy = [
  BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 8),
    blurRadius: 32,
    spreadRadius: 0,
  ),
];

const kShadowColored = [
  BoxShadow(
    color: Color(0x1A667eea),
    offset: Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  ),
];

// 渐变色定义
const kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryColor, kSecondaryColor],
);

const kAccentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kAccentColor, kTertiaryColor],
);

const kRainbowGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryColor, kSecondaryColor, kAccentColor, kTertiaryColor],
);

// 字体大小系统
const double kFontSizeXs = 12.0;
const double kFontSizeS = 14.0;
const double kFontSizeM = 16.0;
const double kFontSizeL = 18.0;
const double kFontSizeXl = 20.0;
const double kFontSizeXxl = 24.0;
const double kFontSizeXxxl = 32.0;

// 百度语音API配置
class BaiduVoiceConfig {
  // 百度语音API密钥配置
  static const String apiKey = 'GD5XCi0eK4xS3jqsLhLQmUdXpWVNZYyC';
  static const String secretKey = 'kxwTL9BbAIs7h82NKv3Ni0lFWOePGySE';
  static const String appId = '116990948';
}

// 有道翻译API配置
class YoudaoTranslationConfig {
  static const String appKey = 'GD5XCiOeK4xS3jqsLhLQmUdXpWVNZYyC';
  static const String appSecret = 'mc5SZtwcjCpAbrynyFwmlewjSSB2UMhq';
}

// 高德地图API配置
class AmapConfig {
  static const String apiKey = '826bcdfca376ddb37c01a4ff945adf9a';
  static const String baseUrl = 'https://restapi.amap.com/v3';
}

// AppColors类 - 用于统一管理应用颜色
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF667eea);
  static const Color secondary = Color(0xFF764ba2);
  static const Color accent = Color(0xFFf093fb);
  static const Color tertiary = Color(0xFF4facfe);
  static const Color quaternary = Color(0xFF00f2fe);
  
  // 状态颜色
  static const Color success = Color(0xFF48bb78);
  static const Color warning = Color(0xFFed8936);
  static const Color error = Color(0xFFf56565);
  static const Color info = Color(0xFF4299e1);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF1a202c);
  static const Color textSecondary = Color(0xFF4a5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textMuted = Color(0xFFa0aec0);
  
  // 背景颜色
  static const Color background = Color(0xFFf8fafc);
  static const Color surface = Colors.white;
  static const Color cardBackground = Color(0xFFffffff);
}