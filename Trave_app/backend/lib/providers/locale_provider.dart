import 'package:flutter/material.dart';

enum AppLocale { zh, en }

class LocaleProvider extends ChangeNotifier {
  AppLocale _locale = AppLocale.zh;

  AppLocale get locale => _locale;

  void toggleLocale() {
    _locale = _locale == AppLocale.zh ? AppLocale.en : AppLocale.zh;
    notifyListeners();
  }

  void setLocale(AppLocale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
} 