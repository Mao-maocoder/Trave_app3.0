import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_host.dart';
import 'auth_service.dart';

class TranslationService {
  /// 后端API调用
  static Future<String> translate(String text, String from, String to) async {
    if (text.trim().isEmpty) {
      return '';
    }
    try {
      final response = await AuthService.authorizedRequest(
        Uri.parse(getApiBaseUrl(path: '/api/translate')),
        method: 'POST',
        body: json.encode({'text': text, 'from': from, 'to': to}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['translation'] != null) {
          return data['translation'];
        } else {
          throw Exception('翻译失败: \\${data['message'] ?? '未知错误'}');
        }
      } else {
        throw Exception('网络请求失败: \\${response.statusCode}');
      }
    } catch (e) {
      print('翻译错误: $e');
      throw Exception('翻译服务暂时不可用，请稍后重试');
    }
  }

  /// 中文转英文
  static Future<String> translateToEnglish(String chineseText) async {
    return await translate(chineseText, 'zh-CHS', 'en');
  }

  /// 英文转中文
  static Future<String> translateToChinese(String englishText) async {
    return await translate(englishText, 'en', 'zh-CHS');
  }

  /// 检测文本语言
  static String detectLanguage(String text) {
    final chineseRegex = RegExp(r'[\u4e00-\u9fff]');
    final englishRegex = RegExp(r'[a-zA-Z]');
    final hasChinese = chineseRegex.hasMatch(text);
    final hasEnglish = englishRegex.hasMatch(text);
    if (hasChinese && !hasEnglish) {
      return 'zh-CHS';
    } else if (hasEnglish && !hasChinese) {
      return 'en';
    } else {
      return 'zh-CHS';
    }
  }

  /// 自动翻译（自动检测语言）
  static Future<String> autoTranslate(String text) async {
    final detectedLang = detectLanguage(text);
    if (detectedLang == 'zh-CHS') {
      return await translateToEnglish(text);
    } else {
      return await translateToChinese(text);
    }
  }
} 