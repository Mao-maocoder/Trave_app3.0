import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/survey_stats.dart';
import '../models/feedback_stats.dart';

class AdminService {
  static const String baseUrl = 'https://trave-app2-0.onrender.com/api';

  static Future<SurveyStats> fetchSurveyStats() async {
    final res = await http.get(Uri.parse('$baseUrl/survey/stats'));
    if (res.statusCode == 200) {
      return SurveyStats.fromJson(json.decode(res.body));
    } else {
      throw Exception('获取问卷统计失败');
    }
  }

  static Future<FeedbackStats> fetchFeedbackStats() async {
    final res = await http.get(Uri.parse('$baseUrl/feedback/stats'));
    if (res.statusCode == 200) {
      return FeedbackStats.fromJson(json.decode(res.body));
    } else {
      throw Exception('获取评价统计失败');
    }
  }
} 