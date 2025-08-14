import 'package:flutter/material.dart';

enum AppLocale { zh, en, es }

class LocaleProvider extends ChangeNotifier {
  AppLocale _locale = AppLocale.zh;

  AppLocale get locale => _locale;
  
  // 获取当前语言代码
  String get localeCode {
    switch (_locale) {
      case AppLocale.zh:
        return 'zh';
      case AppLocale.en:
        return 'en';
      case AppLocale.es:
        return 'es';
    }
  }

  // 三语循环切换
  void toggleLocale() {
    switch (_locale) {
      case AppLocale.zh:
        _locale = AppLocale.en;
        break;
      case AppLocale.en:
        _locale = AppLocale.es;
        break;
      case AppLocale.es:
        _locale = AppLocale.zh;
        break;
    }
    notifyListeners();
  }

  // 设置指定语言
  void setLocale(AppLocale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  // 根据语言代码设置语言
  void setLocaleByCode(String code) {
    switch (code) {
      case 'zh':
        setLocale(AppLocale.zh);
        break;
      case 'en':
        setLocale(AppLocale.en);
        break;
      case 'es':
        setLocale(AppLocale.es);
        break;
    }
  }

  // 获取语言显示名称
  String getLanguageDisplayName(String langCode) {
    switch (langCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return langCode;
    }
  }

  // 获取所有支持的语言
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'zh', 'name': '中文', 'nativeName': '中文'},
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    ];
  }
} 