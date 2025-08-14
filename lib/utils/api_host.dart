import 'config.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_env.dart'; // 导入ngrok地址

const bool isProduction = true; // 生产环境使用Render.com

// 兼容性函数 - 保持向后兼容
String getApiBaseUrl({String path = ''}) {
  if (!isProduction) {
    // 开发环境
    if (kIsWeb) {
      return 'http://localhost:3000$path';
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://192.168.1.100:3000$path'; // 换成你电脑的局域网IP
    }
    return 'http://localhost:3000$path';
  } else {
    // 生产环境（Render公网）
    return 'https://trave-app2-0.onrender.com$path';
  }
}

String getApiBase() {
  return 'https://trave-app2-0.onrender.com';
}

class ApiHost {
  static const String baseUrl = 'https://trave-app2-0.onrender.com';
  
  // 静态方法，方便在常量中使用
  static String getApiUrl(String path) {
    return baseUrl + path;
  }
} 