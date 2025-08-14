import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const String _baseUrl = 'https://trave-app2-0.onrender.com/api';

  // 获取用户列表
  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> usersJson = data['users'];
          return usersJson.map((json) => User.fromJson(json)).toList();
        }
      }
      throw Exception('获取用户列表失败');
    } catch (e) {
      throw Exception('网络连接失败: ${e.toString()}');
    }
  }

  // 获取用户统计
  static Future<UserStats> fetchUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserStats.fromJson(data['stats']);
        }
      }
      throw Exception('获取用户统计失败');
    } catch (e) {
      throw Exception('网络连接失败: ${e.toString()}');
    }
  }
}

class UserStats {
  final int total;
  final int active;
  final int inactive;
  final int tourists;
  final int guides;
  final int recentRegistrations;

  UserStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.tourists,
    required this.guides,
    required this.recentRegistrations,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      tourists: json['tourists'] ?? 0,
      guides: json['guides'] ?? 0,
      recentRegistrations: json['recentRegistrations'] ?? 0,
    );
  }
}
