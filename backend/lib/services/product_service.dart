import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://trave-app-u6jr.onrender.com/api/products'));
    final List data = jsonDecode(response.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }
  static Future<String?> redeemProduct(String userId, String productId) async {
    final response = await http.post(
      Uri.parse('https://trave-app-u6jr.onrender.com/api/products/redeem'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'productId': productId}),
    );
    final data = jsonDecode(response.body);
    return data['qrUrl'] as String?;
  }
} 