import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/api_host.dart';

class AuthService {
  static const String _userKey = 'user';
  static const String _tokenKey = 'token';
  static const String _rememberMeKey = 'rememberMe';
  
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  final String _baseUrl = getApiBaseUrl();

  // 登录
  Future<User?> login(String username, String password, {bool rememberMe = false}) async {
    try {
      print('🔄 开始登录请求...');
      print('📤 请求URL: $_baseUrl/api/auth/login');
      print('📤 请求数据: username=$username');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📥 响应状态码: ${response.statusCode}');
      print('📥 响应内容: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ 登录成功，开始解析用户数据...');
        print('📊 用户数据: ${data['user']}');

        final user = User.fromJson(data['user']);
        print('✅ 用户数据解析成功: ${user.username}');

        // 保存用户信息
        await _saveUser(user);
        await _saveRememberMe(rememberMe);
        print('✅ 用户数据保存成功');

        // 保存 token
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, data['token']);
          print('✅ Token 已保存');
        }

        return user;
      } else {
        print('❌ 登录失败: ${data['message']}');
        throw Exception(data['message'] ?? '登录失败');
      }
    } catch (e) {
      print('❌ 登录异常: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('网络连接失败，请检查网络设置: $e');
    }
  }

  // 注册
  Future<User> register(String username, String email, String password, {UserRole role = UserRole.tourist}) async {
    try {
      print('🔄 开始注册请求...');
      print('📤 请求URL: $_baseUrl/api/auth/register');
      print('📤 请求数据: username=$username, email=$email, role=${role.toString().split('.').last}');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role.toString().split('.').last,
        }),
      );

      print('📥 响应状态码: ${response.statusCode}');
      print('📥 响应内容: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true && data['user'] != null) {
        print('✅ 注册成功，开始解析用户数据...');
        final user = User.fromJson(data['user']);
        print('✅ 用户数据解析成功: ${user.username}');
        
        // 保存用户信息
        await _saveUser(user);
        print('✅ 用户数据保存成功');
        
        return user;
      } else {
        print('❌ 注册失败: ${data['message']}');
        throw Exception(data['message'] ?? '注册失败');
      }
    } catch (e) {
      print('❌ 注册异常: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('网络连接失败，请检查网络设置: $e');
    }
  }

  // 登出
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  // 获取当前用户
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // 获取记住我状态
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // 保存用户信息
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // 保存记住我状态
  Future<void> _saveRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  // 更新用户信息
  Future<void> updateUser(User user) async {
    await _saveUser(user);
  }

  // 忘记密码请求
  Future<bool> forgotPassword(String email) async {
    try {
      print('🔄 开始忘记密码请求...');
      print('📤 请求URL: $_baseUrl/api/auth/forgot-password');
      print('📤 请求数据: email=$email');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      print('📥 响应状态码: ${response.statusCode}');
      print('📥 响应内容: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ 忘记密码请求成功');
        return true;
      } else {
        print('❌ 忘记密码请求失败: ${data['message']}');
        throw Exception(data['message'] ?? '请求失败');
      }
    } catch (e) {
      print('❌ 忘记密码请求异常: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('网络连接失败，请检查网络设置: $e');
    }
  }

  // 获取 token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 封装带 token 的 http 请求
  static Future<http.Response> authorizedRequest(
    Uri url, {
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await getToken();
    final authHeaders = {
      if (headers != null) ...headers,
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(url, headers: authHeaders, body: body);
      case 'PUT':
        return await http.put(url, headers: authHeaders, body: body);
      case 'DELETE':
        return await http.delete(url, headers: authHeaders, body: body);
      default:
        return await http.get(url, headers: authHeaders);
    }
  }
} 