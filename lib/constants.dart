import 'package:flutter/material.dart';

// 主色及色阶
const kPrimaryColor = Color(0xFFB45A1B); // 深棕色
const kPrimaryLight = Color(0xFFF8E3C7); // 主色浅色
const kSecondaryColor = Color(0xFFD2B48C); // 浅金色
const kAccentColor = Color(0xFFF6C177); // 金色
const kPurpleColor = Color(0xFF8B5CF6); // 紫色

// 文本色
const kTextPrimary = Color(0xFF8C6E4B); // 深棕色
const kTextSecondary = Color(0xFFB45A1B); // 金棕色
const kTextLight = Color(0xFFD2B48C); // 浅金色
const kTextMuted = Color(0xFFBFA888); // 米灰色

// 状态色
const kErrorColor = Color(0xFFD2691E); // 错误色
const kDangerColor = Color(0xFFEF4444); // 危险色
const kSuccessColor = Color(0xFFB7A16A); // 成功色
const kWarningColor = Color(0xFFF6C177); // 警告色
const kInfoColor = Color(0xFFE6CBA8); // 信息色

// 色阶（手动定义）
const kSuccessColorLight = Color(0xFFF6F8E8);
const kSuccessColorDark = Color(0xFFB7A16A);
const kWarningColorLight = Color(0xFFFFF8E1);
const kWarningColorExtraLight = Color(0xFFFFFBEA);
const kWarningColorDark = Color(0xFFF6C177);
const kAccentColorLight = Color(0xFFF8E3C7);
const kAccentColorDark = Color(0xFFB45A1B);
const kCardBackgroundLight = Color(0xFFFFFDF8);

// 渐变
const kSuccessGradient = LinearGradient(
  colors: [kSuccessColor, kSuccessColor],
);
const kWarningGradient = LinearGradient(
  colors: [kWarningColor, kWarningColor],
);

// 背景色/卡片色/输入框色
const kCardBackground = Color(0xFFFFFBF5);
const kBackgroundColor = Color(0xFFF8F3E8);
const kInputBackground = Color(0xFFF8F3E8);

// 边框色
const kBorderColor = Color(0xFFE6D3B3);

// 圆角
const kRadiusS = 8.0;
const kRadiusM = 12.0;
const kRadiusL = 16.0;
const kRadiusXl = 20.0;
const kRadiusCard = 20.0;
const kRadiusButton = 20.0;
const kRadiusInput = 20.0;

// 阴影
const kShadowLight = [
  BoxShadow(
    color: Color(0x33B45A1B),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];
const kShadowMedium = [
  BoxShadow(
    color: Color(0x44B45A1B),
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
];
const kShadowHeavy = [
  BoxShadow(
    color: Color(0x66B45A1B),
    offset: Offset(0, 8),
    blurRadius: 32,
    spreadRadius: 0,
  ),
];

// 渐变色定义
const kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryColor, kTertiaryColor],
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

// 字体家族
const String kFontFamily = 'SourceHanSerifSC, PingFang SC, Roboto Slab, serif';

// 百度语音API配置
class BaiduVoiceConfig {
  // 百度语音API密钥配置
  static const String apiKey = 'GD5XCi0eK4xS3jqsLhLQmUdXpWVNZYyC';
  static const String secretKey = 'kxwTL9BbAIs7h82NKv3Ni0lFWOePGySE';
  static const String appId = '116990948';
}

// 有道翻译API配置
class YoudaoTranslationConfig {
  static const String appKey = '756be7cbc6396ebc';
  static const String appSecret = 'x9G2YowscXeguafHoFwOJ2QVXmgYYmLl';
}

// 高德地图API配置
class AmapConfig {
  static const String apiKey = '1cbfee9274efbe7ee57cc703bac40851';
  static const String baseUrl = 'https://restapi.amap.com/v3';
}

// AppColors类 - 用于统一管理应用颜色（与AppTheme保持一致）
class AppColors {
  // 主色调 - 与AppTheme保持一致
  static const Color primary = Color(0xFF667eea); // 主色调
  static const Color secondary = Color(0xFF764ba2); // 次要色调
  static const Color accent = Color(0xFFf093fb); // 强调色
  static const Color tertiary = Color(0xFF4facfe); // 第三色调
  static const Color quaternary = Color(0xFF00f2fe); // 第四色调
  
  // 状态颜色 - 与AppTheme保持一致
  static const Color success = Color(0xFF48bb78);
  static const Color warning = Color(0xFFed8936);
  static const Color error = Color(0xFFf56565);
  static const Color info = Color(0xFF4299e1);
  
  // 文字颜色 - 与AppTheme保持一致
  static const Color textPrimary = Color(0xFF1a202c);
  static const Color textSecondary = Color(0xFF4a5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textMuted = Color(0xFFa0aec0);
  
  // 背景颜色 - 与AppTheme保持一致
  static const Color background = Color(0xFFf8fafc);
  static const Color surface = Color(0xFFffffff);
  static const Color cardBackground = Color(0xFFffffff);
}

// 其它主色
const kTertiaryColor = Color(0xFFE6CBA8); // 浅米色
const kQuaternaryColor = Color(0xFFF8F3E8); // 更浅米色

// 现代化圆角系统（兼容旧用法）
const kRadius = 20.0;

// 现代化间距系统
const kSpaceXs = 4.0;
const kSpaceS = 8.0;
const kSpaceM = 16.0;
const kSpaceL = 24.0;
const kSpaceXl = 32.0;
const kSpaceXxl = 48.0;

// ========== 自动补全缺失常量 ========== //

// 标题字体家族 - Web兼容版本
const String kFontFamilyTitle = 'STKaiti, SimSun, serif';

// Web端安全的字体家族 - 用于输入框等组件
const String kFontFamilySafe = 'sans-serif';

// 通用白色/灰色/黑色
const kWhite = Colors.white;
const kWhite70 = Colors.white70;
const kBlack = Colors.black;
const kBlack54 = Colors.black54;
const kBlack45 = Colors.black45;
const kGrey = Colors.grey;
const kGrey300 = Color(0xFFE0E0E0);
const kGrey400 = Color(0xFFBDBDBD);
const kGrey500 = Color(0xFF9E9E9E);
const kGrey600 = Color(0xFF757575);
const kGrey700 = Color(0xFF616161);
const kLightGrey = Color(0xFFF5F5F5);

// 语义色阶
const kSuccessColorDarker = Color(0xFF6D5C1B);
const kWarningColorDarker = Color(0xFFB45A1B);
const kInfoColorDark = Color(0xFFB45A1B);
const kInfoColorDarker = Color(0xFF8C6E4B);
const kErrorColorDark = Color(0xFF8C1E1E);

// 文字色
const kTextPrimaryColor = Color(0xFF8C6E4B);
const kTextSecondaryColor = Color(0xFFB45A1B);
const kTextHint = Color(0xFFBFA888);
const kTextLightColor = Color(0xFFD2B48C);

// 卡片/表面色
const kSurfaceColor = Color(0xFFFFFBF5);

// 现代化圆角/间距（兼容旧用法）
const kBorderRadius = 20.0;
const kSpaceXS = 4.0;
// kSpaceS/kSpaceM/kSpaceL/kSpaceXl/kSpaceXxl 已有

// 渐变
const kPrimaryGradientLight = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryLight, kTertiaryColor],
);
const kPurple = Color(0xFF8B5CF6);
const kPurpleBlueGradientLight = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0x1A8B5CF6), Color(0x1AE6CBA8)], // 10%透明度
);
const kTitleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryColor, kAccentColor],
);
const kSubtitleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kAccentColor, kTertiaryColor],
);

// 阴影
const kShadowLarge = [
  BoxShadow(
    color: Color(0x338C6E4B),
    blurRadius: 24,
    offset: Offset(0, 8),
  ),
];

// 阴影
const List<Shadow> kTextShadow = [
  Shadow(color: Color(0x33B45A1B), blurRadius: 4, offset: Offset(0, 2)),
];
// 深色主色
const Color kPrimaryColorDark = Color(0xFFD2691E);
// 极小圆角
const double kRadiusXS = 6.0;
// 分割线颜色
const Color kDividerColor = Color(0xFFE0E0E0);

// ========== END 自动补全 ========== //