import 'package:http/http.dart' as http;
import 'dart:convert';

class MusicService {
  static Future<String?> composeMusic() async {
    final response = await http.post(
      Uri.parse('https://trave-app-u6jr.onrender.com/api/music/compose'),
    );
    final data = jsonDecode(response.body);
    return data['musicUrl'] as String?;
  }
} 