import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_host.dart';
import 'package:fl_chart/fl_chart.dart';

class GuideService {
  static String get baseUrl => getApiBaseUrl();

  // 获取导游信息
  static Future<Map<String, dynamic>> getGuideInfo(String guideId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/guides/$guideId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load guide info');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 获取问卷统计数据
  static Future<Map<String, dynamic>> getSurveyStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/surveys/statistics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load survey statistics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 获取绑定的游客列表
  static Future<List<Map<String, dynamic>>> getBoundTourists(String guideId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/guides/$guideId/tourists'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['tourists']);
      } else {
        throw Exception('Failed to load bound tourists');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 处理绑定请求
  static Future<bool> handleBindingRequest(String requestId, bool isApproved) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/guides/binding-requests/$requestId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'approved': isApproved}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
