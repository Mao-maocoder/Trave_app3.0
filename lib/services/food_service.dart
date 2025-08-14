import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodService {
  static Future<String?> traceFood(String foodName) async {
    final response = await http.post(
      Uri.parse('https://trave-app-u6jr.onrender.com/api/food/trace'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'foodName': foodName}),
    );
    final data = jsonDecode(response.body);
    return data['story'] as String?;
  }
} 