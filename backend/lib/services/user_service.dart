import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/binding.dart';
import '../utils/api_host.dart';
import 'auth_service.dart';

class UserService {
  // 获取用户列表
  static Future<List<User>> fetchUsers() async {
    try {
      final response = await AuthService.authorizedRequest(
        Uri.parse(getApiBaseUrl(path: '/api/users')),
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
      final response = await AuthService.authorizedRequest(
        Uri.parse(getApiBaseUrl(path: '/api/users/stats')),
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

  // 游客发起绑定导游请求
  static Future<bool> bindGuide(String touristId, String guideId) async {
    final response = await http.post(
      Uri.parse(getApiBaseUrl(path: '/api/bind_guide')),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'touristId': touristId, 'guideId': guideId}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      // 捕获后端唯一性校验等错误
      return false;
    }
  }

  // 导游审批绑定请求
  static Future<bool> reviewBindRequest(int bindingId, String status) async {
    final response = await http.post(
      Uri.parse(getApiBaseUrl(path: '/api/review_bind_request')),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'bindingId': bindingId, 'status': status}),
    );
    final data = json.decode(response.body);
    return data['success'] == true;
  }

  // 游客解绑导游
  static Future<bool> unbindGuide(String touristId) async {
    final response = await http.post(
      Uri.parse(getApiBaseUrl(path: '/api/unbind_guide')),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'touristId': touristId}),
    );
    final data = json.decode(response.body);
    return data['success'] == true;
  }

  // 查询游客当前绑定的导游
  static Future<Binding?> getBindingByTourist(String touristId) async {
    final response = await http.get(
      Uri.parse(getApiBaseUrl(path: '/api/binding/guide/$touristId')),
    );
    final data = json.decode(response.body);
    if (data['success'] == true && data['binding'] != null) {
      return Binding.fromJson(data['binding']);
    }
    return null;
  }

  // 查询导游待审批的绑定请求
  static Future<List<Binding>> getPendingBindingsByGuide(String guideId) async {
    final response = await http.get(
      Uri.parse(getApiBaseUrl(path: '/api/binding/pending/$guideId')),
    );
    final data = json.decode(response.body);
    if (data['success'] == true && data['requests'] != null) {
      return (data['requests'] as List).map((e) => Binding.fromJson(e)).toList();
    }
    return [];
  }

  // 查询导游已绑定的游客
  static Future<List<dynamic>> getApprovedTouristsByGuide(String guideId) async {
    final response = await http.get(
      Uri.parse(getApiBaseUrl(path: '/api/binding/tourists/$guideId')),
    );
    final data = json.decode(response.body);
    if (data['success'] == true && data['tourists'] != null) {
      return data['tourists'];
    }
    return [];
  }

  // 用户修改昵称和头像
  static Future<bool> updateProfile(String userId, {String? username, String? avatarUrl}) async {
    // 如果是资源路径的头像，不需要发送到后端
    final isAssetAvatar = avatarUrl != null && avatarUrl.startsWith('assets/');
    
    final response = await http.post(
      Uri.parse(getApiBaseUrl(path: '/api/user/update_profile')),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        if (username != null) 'username': username,
        if (avatarUrl != null && !isAssetAvatar) 'avatar': avatarUrl,
      }),
    );
    final data = json.decode(response.body);
    return data['success'] == true;
  }

  // 上传头像，返回图片URL（移动端）
  static Future<String?> uploadAvatar(File file) async {
    if (kIsWeb) {
      throw Exception('Web平台请使用uploadAvatarBytes方法');
    }
    final uri = Uri.parse(getApiBaseUrl(path: '/api/photos/upload'));
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('photos', file.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = json.decode(response.body);
    if (data['success'] == true && data['photos'] != null && data['photos'].isNotEmpty) {
      return data['photos'][0]['path'];
    }
    return null;
  }

  // 上传头像，返回图片URL（Web端）
  static Future<String?> uploadAvatarBytes(Uint8List bytes, String filename) async {
    final uri = Uri.parse(getApiBaseUrl(path: '/api/photos/upload'));
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('photos', bytes, filename: filename));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = json.decode(response.body);
    if (data['success'] == true && data['photos'] != null && data['photos'].isNotEmpty) {
      return data['photos'][0]['path'];
    }
    return null;
  }

  // 通过用户ID获取用户详细信息
  static Future<User?> getUserById(String userId) async {
    final response = await http.get(
      Uri.parse(getApiBaseUrl(path: '/api/users')),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['users'] != null) {
        final users = (data['users'] as List).map((json) => User.fromJson(json)).toList();
        try {
          return users.firstWhere((u) => u.id == userId);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  // 清理重复的绑定记录
  static Future<bool> cleanupDuplicateBindings() async {
    try {
      final response = await http.post(
        Uri.parse(getApiBaseUrl(path: '/api/binding/cleanup')),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('清理重复绑定记录失败: $e');
      return false;
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
