import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_host.dart';

class AvatarDebugger {
  static Future<void> debugAvatarUrl(String avatarPath) async {
    print('\n🔍 头像调试开始 ===================');
    print('原始头像路径: $avatarPath');
    print('API基础URL: ${ApiHost.baseUrl}');
    
    // 构建不同的URL格式进行测试
    final testUrls = <String>[];
    
    // 1. 完整URL（如果已经是）
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      testUrls.add(avatarPath);
    }
    
    // 2. 相对路径格式
    if (avatarPath.startsWith('/')) {
      testUrls.add('${ApiHost.baseUrl}$avatarPath');
    }
    
    // 3. 文件名格式（添加/uploads前缀）
    if (!avatarPath.startsWith('http') && !avatarPath.startsWith('/')) {
      testUrls.add('${ApiHost.baseUrl}/uploads/$avatarPath');
    }
    
    // 4. 如果路径包含photos，尝试不同的组合
    if (avatarPath.contains('photos')) {
      testUrls.add('${ApiHost.baseUrl}$avatarPath');
      testUrls.add('${ApiHost.baseUrl}/uploads/$avatarPath');
    }
    
    print('\n📋 测试URL列表:');
    for (int i = 0; i < testUrls.length; i++) {
      print('  ${i + 1}. ${testUrls[i]}');
    }
    
    // 测试每个URL
    for (int i = 0; i < testUrls.length; i++) {
      await _testUrl(testUrls[i], i + 1);
    }
    
    print('🔍 头像调试结束 ===================\n');
  }
  
  static Future<void> _testUrl(String url, int index) async {
    print('\n🧪 测试URL $index: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TravelApp/1.0',
          'Accept': 'image/*,*/*',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('  状态码: ${response.statusCode}');
      print('  内容类型: ${response.headers['content-type']}');
      print('  内容长度: ${response.headers['content-length']} bytes');
      print('  缓存控制: ${response.headers['cache-control']}');
      print('  CORS: ${response.headers['access-control-allow-origin']}');
      
      if (response.statusCode == 200) {
        print('  ✅ URL $index 访问成功');
        
        // 检查内容类型
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.startsWith('image/')) {
          print('  ✅ 内容类型正确: $contentType');
        } else {
          print('  ⚠️  内容类型可能不正确: $contentType');
        }
        
        // 检查内容长度
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          final size = int.tryParse(contentLength) ?? 0;
          if (size > 0) {
            print('  ✅ 文件大小正常: ${size} bytes');
          } else {
            print('  ⚠️  文件大小异常: ${size} bytes');
          }
        }
      } else {
        print('  ❌ URL $index 访问失败');
        
        // 尝试解析错误响应
        try {
          final errorBody = json.decode(response.body);
          print('  错误信息: ${errorBody['message'] ?? '未知错误'}');
        } catch (e) {
          print('  错误响应: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        }
      }
    } catch (e) {
      print('  ❌ URL $index 网络错误: $e');
    }
  }
  
  static Future<void> debugUserAvatar(String userId, String username) async {
    print('\n👤 用户头像调试 ===================');
    print('用户ID: $userId');
    print('用户名: $username');
    
    try {
      // 获取用户信息
      final response = await http.get(
        Uri.parse('${ApiHost.baseUrl}/api/users'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['users'] != null) {
          final users = data['users'] as List;
          final user = users.firstWhere(
            (u) => u['id'] == userId || u['username'] == username,
            orElse: () => null,
          );
          
          if (user != null) {
            print('✅ 找到用户信息:');
            print('  用户ID: ${user['id']}');
            print('  用户名: ${user['username']}');
            print('  头像路径: ${user['avatar']}');
            
            if (user['avatar'] != null && user['avatar'].isNotEmpty) {
              await debugAvatarUrl(user['avatar']);
            } else {
              print('❌ 用户没有设置头像');
            }
          } else {
            print('❌ 未找到用户信息');
          }
        } else {
          print('❌ API返回数据格式错误');
        }
      } else {
        print('❌ 获取用户信息失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 获取用户信息时发生错误: $e');
    }
    
    print('👤 用户头像调试结束 ===================\n');
  }
} 