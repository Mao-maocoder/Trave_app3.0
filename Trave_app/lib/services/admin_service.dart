import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/survey_stats.dart';
import '../models/feedback_stats.dart';
import '../utils/api_host.dart';
import 'auth_service.dart';

class AdminService {
  static Future<SurveyStats> fetchSurveyStats() async {
    final res = await AuthService.authorizedRequest(
      Uri.parse(getApiBaseUrl(path: '/api/survey/stats')),
    );
    if (res.statusCode == 200) {
      return SurveyStats.fromJson(json.decode(res.body));
    } else {
      throw Exception('获取问卷统计失败');
    }
  }

  static Future<FeedbackStats> fetchFeedbackStats() async {
    final res = await AuthService.authorizedRequest(
      Uri.parse(getApiBaseUrl(path: '/api/feedback/stats')),
    );
    if (res.statusCode == 200) {
      return FeedbackStats.fromJson(json.decode(res.body));
    } else {
      throw Exception('获取评价统计失败');
    }
  }
} 