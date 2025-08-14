import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants.dart';

class AmapService {
  static const String _apiKey = AmapConfig.apiKey;
  static const String _baseUrl = AmapConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  /// 地理编码 - 将地址转换为坐标
  static Future<LatLng?> geocode(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/geocode/geo?key=$_apiKey&address=$address&city=北京'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['geocodes'].isNotEmpty) {
          final location = data['geocodes'][0]['location'];
          final coords = location.split(',');
          return LatLng(
            double.parse(coords[1]), // 纬度
            double.parse(coords[0]), // 经度
          );
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// 逆地理编码 - 将坐标转换为地址
  static Future<String?> reverseGeocode(LatLng location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/geocode/regeo?key=$_apiKey&location=${location.longitude},${location.latitude}'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          return data['regeocode']['formatted_address'];
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    return null;
  }

  /// 路径规划 - 计算两点间的距离和时间
  static Future<Map<String, dynamic>?> calculateRoute(
    LatLng origin,
    LatLng destination,
    String strategy, // 路径策略：0-速度最快，1-费用最低，2-距离最短，3-不走高速
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/direction/driving?key=$_apiKey'
          '&origin=${origin.longitude},${origin.latitude}'
          '&destination=${destination.longitude},${destination.latitude}'
          '&strategy=$strategy',
        ),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['route']['paths'].isNotEmpty) {
          final path = data['route']['paths'][0];
          return {
            'distance': path['distance'], // 距离（米）
            'duration': path['duration'], // 时间（秒）
            'steps': path['steps'], // 详细路径
          };
        }
      }
    } catch (e) {
      print('Route calculation error: $e');
    }
    return null;
  }

  /// 搜索周边POI
  static Future<List<Map<String, dynamic>>> searchNearby(
    LatLng location,
    String keywords, {
    int radius = 1000, // 搜索半径（米）
    String types = '', // POI类型
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/around?key=$_apiKey'
          '&location=${location.longitude},${location.latitude}'
          '&keywords=$keywords'
          '&radius=$radius'
          '&types=$types',
        ),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          return List<Map<String, dynamic>>.from(data['pois']);
        }
      }
    } catch (e) {
      print('Nearby search error: $e');
    }
    return [];
  }

  /// 获取天气信息
  static Future<Map<String, dynamic>?> getWeather(String cityCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather/weatherInfo?key=$_apiKey&city=$cityCode&extensions=all'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          return data['forecasts'][0];
        }
      }
    } catch (e) {
      print('Weather info error: $e');
    }
    return null;
  }

  /// 获取北京中轴线相关景点
  static Future<List<Map<String, dynamic>>> getCentralAxisSpots() async {
    try {
      // 搜索北京中轴线相关的景点
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/text?key=$_apiKey'
          '&keywords=北京中轴线景点'
          '&city=北京'
          '&types=风景名胜',
        ),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          return List<Map<String, dynamic>>.from(data['pois']);
        }
      }
    } catch (e) {
      print('Central axis spots search error: $e');
    }
    return [];
  }

  /// 计算两点间的直线距离
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // 地球半径（米）
    
    final lat1Rad = point1.latitude * (pi / 180);
    final lat2Rad = point2.latitude * (pi / 180);
    final deltaLat = (point2.latitude - point1.latitude) * (pi / 180);
    final deltaLon = (point2.longitude - point1.longitude) * (pi / 180);

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 格式化距离显示
  static String formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}米';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
  }

  /// 格式化时间显示
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }
} 