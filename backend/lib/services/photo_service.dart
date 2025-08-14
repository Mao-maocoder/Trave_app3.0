import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/user.dart';

class PhotoService {
  static const String baseUrl = 'https://trave-app2-0.onrender.com/api';

  // 上传照片 - 支持Web和移动端
  static Future<Map<String, dynamic>> uploadPhotos({
    required List<File> photos,
    required String spotName,
    required User user,
    String? title,
    String? description,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photos/upload'),
      );

      // 添加表单数据
      request.fields['spotName'] = spotName;
      request.fields['uploader'] = user.username;
      request.fields['userRole'] = user.role.toString().split('.').last;
      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;

      // 添加照片文件
      for (int i = 0; i < photos.length; i++) {
        if (kIsWeb) {
          // Web环境下的处理方式
          throw Exception('Web环境下请使用uploadPhotosFromBytes方法');
        } else {
          // 移动端的处理方式
          var stream = http.ByteStream(photos[i].openRead());
          var length = await photos[i].length();
          var multipartFile = http.MultipartFile(
            'photos',
            stream,
            length,
            filename: photos[i].path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var result = json.decode(responseData);

      if (response.statusCode == 200) {
        return result;
      } else {
        throw Exception(result['message'] ?? '上传失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  // Web环境专用的上传方法
  static Future<Map<String, dynamic>> uploadPhotosFromBytes({
    required List<PlatformFile> files,
    required String spotName,
    required User user,
    String? title,
    String? description,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photos/upload'),
      );

      // 添加表单数据
      request.fields['spotName'] = spotName;
      request.fields['uploader'] = user.username;
      request.fields['userRole'] = user.role.toString().split('.').last;
      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;

      // 添加照片文件
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        if (file.bytes != null) {
          var multipartFile = http.MultipartFile.fromBytes(
            'photos',
            file.bytes!,
            filename: file.name,
          );
          request.files.add(multipartFile);
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var result = json.decode(responseData);

      if (response.statusCode == 200) {
        return result;
      } else {
        throw Exception(result['message'] ?? '上传失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  // 获取照片列表
  static Future<Map<String, dynamic>> getPhotos({
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

      var uri = Uri.parse('$baseUrl/photos').replace(queryParameters: queryParams);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('获取照片列表失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  // 审核照片
  static Future<Map<String, dynamic>> reviewPhoto({
    required String photoId,
    required String status,
    String? reason,
  }) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/photos/$photoId/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('审核失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  // 删除照片
  static Future<Map<String, dynamic>> deletePhoto(String photoId) async {
    try {
      var response = await http.delete(
        Uri.parse('$baseUrl/photos/$photoId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('删除失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  // 获取照片统计
  static Future<Map<String, dynamic>> getPhotoStats() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/photos/stats'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('获取统计失败');
      }
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  // 获取照片URL
  static String getPhotoUrl(String photoPath) {
    return 'https://trave-app2-0.onrender.com' + photoPath;
  }
} 