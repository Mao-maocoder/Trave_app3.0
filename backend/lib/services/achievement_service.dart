import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/achievement.dart';

class AchievementService {
  static Future<List<Achievement>> fetchAchievements() async {
    final response = await http.get(Uri.parse('https://trave-app-u6jr.onrender.com/api/achievements'));
    final List data = jsonDecode(response.body);
    return data.map((e) => Achievement.fromJson(e)).toList();
  }

  static Future<bool> unlockAchievement(String userId, String achievementId) async {
    final response = await http.post(
      Uri.parse('https://trave-app-u6jr.onrender.com/api/achievements/unlock'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'achievementId': achievementId}),
    );
    return jsonDecode(response.body)['success'] == true;
  }
} 