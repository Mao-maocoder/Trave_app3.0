import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../constants.dart';

class TranslationService {
  static const String _appKey = YoudaoTranslationConfig.appKey;
  static const String _appSecret = YoudaoTranslationConfig.appSecret;

  /// 有道翻译API调用
  static Future<String> translate(String text, String from, String to) async {
    if (text.trim().isEmpty) {
      return '';
    }

    try {
      final salt = Random().nextInt(100000).toString();
      final curtime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signStr = _appKey + _truncate(text) + salt + curtime + _appSecret;
      final sign = sha256.convert(utf8.encode(signStr)).toString();

      final url = Uri.parse('https://openapi.youdao.com/api');
      final response = await http.post(
        url,
        body: {
          'q': text,
          'from': from,
          'to': to,
          'appKey': _appKey,
          'salt': salt,
          'sign': sign,
          'signType': 'v3',
          'curtime': curtime,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['translation'] != null && data['translation'].isNotEmpty) {
          return data['translation'][0];
        } else if (data['errorCode'] != null) {
          throw Exception('翻译失败: ${data['errorCode']} - ${data['errorMsg'] ?? '未知错误'}');
        } else {
          throw Exception('翻译失败: 未获取到翻译结果');
        }
      } else {
        throw Exception('网络请求失败: ${response.statusCode}');
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

  /// 有道签名算法需要对文本做截断
  static String _truncate(String q) {
    if (q.length <= 20) return q;
    return q.substring(0, 10) + q.length.toString() + q.substring(q.length - 10);
  }

  /// 检测文本语言
  static String detectLanguage(String text) {
    // 简单的语言检测逻辑
    final chineseRegex = RegExp(r'[\u4e00-\u9fff]');
    final englishRegex = RegExp(r'[a-zA-Z]');
    
    final hasChinese = chineseRegex.hasMatch(text);
    final hasEnglish = englishRegex.hasMatch(text);
    
    if (hasChinese && !hasEnglish) {
      return 'zh-CHS';
    } else if (hasEnglish && !hasChinese) {
      return 'en';
    } else {
      // 如果同时包含中英文，默认按中文处理
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