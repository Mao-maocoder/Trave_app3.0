import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/itinerary_item.dart';
import '../utils/api_host.dart';
import 'auth_service.dart';

class ItineraryService {
  static String get baseUrl => ApiHost.baseUrl;

  // 获取用户行程
  static Future<List<ItineraryItem>> getUserItinerary(String userId) async {
    try {
      final response = await AuthService.authorizedRequest(
        Uri.parse('$baseUrl/api/itinerary?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final itineraries = data['data'] as List;
          if (itineraries.isNotEmpty) {
            // 获取最新的行程（按更新时间排序）
            itineraries.sort((a, b) => 
              DateTime.parse(b['updatedAt'] ?? b['createdAt'] ?? '')
                  .compareTo(DateTime.parse(a['updatedAt'] ?? a['createdAt'] ?? ''))
            );
            
            final latestItinerary = itineraries.first;
            final items = latestItinerary['itineraryItems'] as List;
            
            return items.map((item) => ItineraryItem.fromJson(item)).toList();
          }
        }
      }
      
      return [];
    } catch (e) {
      print('❌ 获取行程失败: $e');
      return [];
    }
  }

  // 保存用户行程
  static Future<bool> saveUserItinerary(String userId, List<ItineraryItem> items) async {
    try {
      final response = await AuthService.authorizedRequest(
        Uri.parse('$baseUrl/api/itinerary'),
        method: 'POST',
        body: json.encode({
          'userId': userId,
          'itineraryItems': items.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ 保存行程失败: $e');
      return false;
    }
  }

  // 删除用户行程
  static Future<bool> deleteUserItinerary(String userId) async {
    try {
      final response = await AuthService.authorizedRequest(
        Uri.parse('$baseUrl/api/itinerary?userId=$userId'),
        method: 'DELETE',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ 删除行程失败: $e');
      return false;
    }
  }
} 