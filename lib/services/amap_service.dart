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
      // 对中文地址进行URL编码
      final encodedAddress = Uri.encodeComponent(address);
      final response = await http.get(
        Uri.parse('$_baseUrl/geocode/geo?key=$_apiKey&address=$encodedAddress&city=北京'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['geocodes'] != null && data['geocodes'].isNotEmpty) {
          final location = data['geocodes'][0]['location'];
          final coords = location.split(',');
          if (coords.length == 2) {
            // 高德API返回格式：经度,纬度
            return LatLng(
              double.parse(coords[1]), // 纬度
              double.parse(coords[0]), // 经度
            );
          }
        } else {
          print('Geocoding failed: ${data['info']}');
        }
      } else {
        print('Geocoding HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// 逆地理编码 - 将坐标转换为地址
  static Future<String?> reverseGeocode(LatLng location) async {
    try {
      // 高德API要求：经度,纬度
      final response = await http.get(
        Uri.parse('$_baseUrl/geocode/regeo?key=$_apiKey&location=${location.longitude},${location.latitude}'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['regeocode'] != null) {
          return data['regeocode']['formatted_address'];
        } else {
          print('Reverse geocoding failed: ${data['info']}');
        }
      } else {
        print('Reverse geocoding HTTP error: ${response.statusCode}');
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
        if (data['status'] == '1' && 
            data['route'] != null && 
            data['route']['paths'] != null && 
            data['route']['paths'].isNotEmpty) {
          final path = data['route']['paths'][0];
          return {
            'distance': int.tryParse(path['distance']?.toString() ?? '0') ?? 0, // 距离（米）
            'duration': int.tryParse(path['duration']?.toString() ?? '0') ?? 0, // 时间（秒）
            'steps': path['steps'] ?? [], // 详细路径
            'tolls': int.tryParse(path['tolls']?.toString() ?? '0') ?? 0, // 过路费（元）
            'traffic_lights': int.tryParse(path['traffic_lights']?.toString() ?? '0') ?? 0, // 红绿灯数量
          };
        } else {
          print('Route calculation failed: ${data['info']}');
        }
      } else {
        print('Route calculation HTTP error: ${response.statusCode}');
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
    int page = 1, // 页码
    int offset = 20, // 每页条数
  }) async {
    try {
      final encodedKeywords = Uri.encodeComponent(keywords);
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/around?key=$_apiKey'
          '&location=${location.longitude},${location.latitude}'
          '&keywords=$encodedKeywords'
          '&radius=$radius'
          '&types=$types'
          '&page=$page'
          '&offset=$offset',
        ),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['pois'] != null) {
          return List<Map<String, dynamic>>.from(data['pois']);
        } else {
          print('Nearby search failed: ${data['info']}');
        }
      } else {
        print('Nearby search HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Nearby search error: $e');
    }
    return [];
  }

  /// 文本搜索POI
  static Future<List<Map<String, dynamic>>> searchPOI(
    String keywords, {
    String city = '北京',
    String types = '',
    int page = 1,
    int offset = 20,
  }) async {
    try {
      final encodedKeywords = Uri.encodeComponent(keywords);
      final encodedCity = Uri.encodeComponent(city);
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/text?key=$_apiKey'
          '&keywords=$encodedKeywords'
          '&city=$encodedCity'
          '&types=$types'
          '&page=$page'
          '&offset=$offset',
        ),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['pois'] != null) {
          return List<Map<String, dynamic>>.from(data['pois']);
        } else {
          print('POI search failed: ${data['info']}');
        }
      } else {
        print('POI search HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('POI search error: $e');
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
        if (data['status'] == '1' && 
            data['forecasts'] != null && 
            data['forecasts'].isNotEmpty) {
          return data['forecasts'][0];
        } else {
          print('Weather info failed: ${data['info']}');
        }
      } else {
        print('Weather info HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Weather info error: $e');
    }
    return null;
  }

  /// 获取北京中轴线相关景点
  static Future<List<Map<String, dynamic>>> getCentralAxisSpots() async {
    try {
      // 使用多个关键词搜索，提高覆盖率
      final keywords = [
        '北京中轴线',
        '故宫',
        '天安门',
        '景山公园',
        '北海公园',
        '什刹海',
        '钟鼓楼',
        '雍和宫',
        '地坛',
        '奥林匹克公园',
        '鸟巢',
        '水立方'
      ];
      
      final Set<String> uniqueSpots = {};
      final List<Map<String, dynamic>> allSpots = [];

      for (final keyword in keywords) {
        try {
          final spots = await searchPOI(
            keyword,
            city: '北京',
            types: '风景名胜|文物古迹|博物馆',
            offset: 10,
          );
          
          for (final spot in spots) {
            final id = spot['id'];
            if (id != null && !uniqueSpots.contains(id)) {
              uniqueSpots.add(id);
              allSpots.add(spot);
            }
          }
          
          // 避免请求过于频繁
          await Future.delayed(Duration(milliseconds: 100));
        } catch (e) {
          print('Error searching for $keyword: $e');
          continue;
        }
      }

      return allSpots;
    } catch (e) {
      print('Central axis spots search error: $e');
      return [];
    }
  }

  /// 获取POI详细信息
  static Future<Map<String, dynamic>?> getPOIDetail(String poiId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/place/detail?key=$_apiKey&id=$poiId'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['pois'] != null && data['pois'].isNotEmpty) {
          return data['pois'][0];
        } else {
          print('POI detail failed: ${data['info']}');
        }
      } else {
        print('POI detail HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('POI detail error: $e');
    }
    return null;
  }

  /// 计算两点间的直线距离（保持不变，这个实现很好）
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

  /// 检查API响应是否成功
  static bool _isResponseSuccess(Map<String, dynamic> data) {
    return data['status'] == '1';
  }

  /// 获取错误信息
  static String _getErrorMessage(Map<String, dynamic> data) {
    return data['info'] ?? '未知错误';
  }
}