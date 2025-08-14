import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../utils/api_host.dart';
import 'auth_service.dart';

class PhotoService {
  final String baseUrl = getApiBaseUrl();

  // 获取照片列表 - 基础版本
  Future<List<Map<String, dynamic>>> getPhotos() async {
    // 使用本地资源照片
    return [
      _createPhotoData('故宫', 'assets/images/spots/故宫.png'),
      _createPhotoData('天坛', 'assets/images/spots/天坛.png'),
      _createPhotoData('前门', 'assets/images/spots/前门.png'),
      _createPhotoData('什刹海万宁桥', 'assets/images/spots/什刹海万宁桥.png'),
      _createPhotoData('永定门', 'assets/images/spots/永定门.png'),
      _createPhotoData('先农坛', 'assets/images/spots/先农坛.png'),
      _createPhotoData('钟鼓楼', 'assets/images/spots/钟鼓楼.png'),
    ];
  }

  Map<String, dynamic> _createPhotoData(String spotName, String assetPath) {
    // 如果是本地资源路径，保持原样，否则添加 API 前缀
    return {
      'id': spotName,
      'title': spotName,
      'description': '$spotName的美景',
      'path': assetPath,
      'spotName': spotName,
      'uploader': 'admin',
      'userRole': 'guide',
      'uploadTime': DateTime.now().toIso8601String(),
      'status': 'approved',
    };
  }

  // Web平台使用的上传方法
  Future<void> uploadPhotoBytes({
    required Uint8List bytes,
    required String fileName,
    required String title,
  }) async {
    try {
      if (!await AuthService().isLoggedIn()) {
        throw Exception('请先登录');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/photos'),
      );

      final authHeaders = await AuthService.getAuthHeaders();
      request.headers.addAll(authHeaders);

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      request.fields.addAll({
        'spotName': title,
        'title': '用户上传的照片',
        'description': '这是一张关于$title的照片',
      });

      var response = await request.send();
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('上传失败: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 获取照片列表 - 高级版本
  Future<Map<String, dynamic>> getPhotosAdvanced({
    String? status,
    String? spotName,
    String? uploader,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (spotName != null) queryParams['spotName'] = spotName;
      if (uploader != null) queryParams['uploader'] = uploader;

      var uri = Uri.parse('$baseUrl/api/photos').replace(queryParameters: queryParams);
      var response = await AuthService.authorizedRequest(
        uri,
        method: 'GET',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('获取照片列表失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  // 下载照片
  Future<void> downloadPhoto(String photoPath) async {
    try {
      // 这里我们可以直接把asset文件复制到相册
      // 但是因为是本地资源，我们先模拟一个下载过程
      await Future.delayed(const Duration(seconds: 1));
      // TODO: 实现实际的下载逻辑
    } catch (e) {
      rethrow;
    }
  }

  // Web环境下的批量上传方法
  Future<Map<String, dynamic>> uploadPhotosFromBytes({
    required List<PlatformFile> files,
    required String spotName,
    required User user,
    String? title,
    String? description,
  }) async {
    try {
      if (!kIsWeb) {
        throw Exception('此方法仅适用于Web环境');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/photos/upload'),
      );

      final authHeaders = await AuthService.getAuthHeaders();
      request.headers.addAll(authHeaders);

      for (var file in files) {
        if (file.bytes == null) continue;
        
        String mimeType = 'image/jpeg';
        if (file.name.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (file.name.toLowerCase().endsWith('.gif')) {
          mimeType = 'image/gif';
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'photos',
            file.bytes!,
            filename: file.name,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      request.fields.addAll({
        'spotName': spotName,
        'title': title ?? '用户上传的照片',
        'description': description ?? '这是一组关于$spotName的照片',
        'userId': user.id,
      });

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('上传失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('上传失败: $e');
    }
  }

  // 审核照片
  Future<void> reviewPhoto({
    required String photoId,
    required bool approved,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/photos/$photoId/review'),
        headers: await AuthService.getAuthHeaders(),
        body: json.encode({
          'approved': approved,
          if (comment != null) 'comment': comment,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('审核失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('审核失败: $e');
    }
  }

  // 删除照片
  Future<void> deletePhoto(String photoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/photos/$photoId'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('删除失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('删除失败: $e');
    }
  }

  // 获取照片统计信息
  Future<Map<String, dynamic>> getPhotoStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/photos/stats'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('获取统计信息失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取统计信息失败: $e');
    }
  }

  // 获取照片完整URL
  String getPhotoUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    if (photoPath.startsWith('assets/')) {
      return photoPath; // 本地资源文件直接返回路径
    }
    return '$baseUrl$photoPath';
  }
}
