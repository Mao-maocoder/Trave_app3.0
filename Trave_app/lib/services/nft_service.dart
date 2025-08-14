import 'package:http/http.dart' as http;
import 'dart:convert';

class NftService {
  static Future<String?> mintNft(String userId) async {
    final response = await http.post(
      Uri.parse('https://trave-app-u6jr.onrender.com/api/nft/mint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    final data = jsonDecode(response.body);
    return data['nftUrl'] as String?;
  }
} 