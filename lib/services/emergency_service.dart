import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyService {
  static Future<String?> getWeatherWarning() async {
    final response = await http.get(Uri.parse('https://trave-app-u6jr.onrender.com/api/weather/warning'));
    final data = jsonDecode(response.body);
    return data['warning'] as String?;
  }
  static Future<bool> sendHelpRequest(String userId, String location) async {
    final response = await http.post(
      Uri.parse('https://trave-app-u6jr.onrender.com/api/emergency/help'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'location': location}),
    );
    return jsonDecode(response.body)['success'] == true;
  }
} 