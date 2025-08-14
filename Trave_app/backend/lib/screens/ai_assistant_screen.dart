import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// API密钥应该从环境变量或配置文件中读取，不应硬编码
const String kTongyiApiKey = 'sk-d34111b4a3924d0e80fc394f606effca';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _apiKey = kTongyiApiKey;
  DateTime? _lastRequestTime; // 添加请求时间控制

  @override
  void initState() {
    super.initState();
    _testAPIConnection();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // 测试API连接
  Future<void> _testAPIConnection() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ 未配置API密钥，AI助手暂时不可用。',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: '🔄 正在测试API连接...',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    try {
      final response = await _callTongyiAPI('你好');
      setState(() {
        _messages.removeLast(); // 移除测试消息
        _messages.add(ChatMessage(
          text: '✅ AI助手已就绪！您可以开始提问了。\n\n$response',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast(); // 移除测试消息
        _messages.add(ChatMessage(
          text: '❌ API连接失败: $e\n\n请检查:\n1. API密钥是否正确\n2. 账户是否有余额\n3. 网络连接是否正常',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_isLoading) return; // 防止重复请求
    
    // 检查请求频率
    if (_lastRequestTime != null) {
      final timeDiff = DateTime.now().difference(_lastRequestTime!);
      if (timeDiff.inSeconds < 2) { // 至少间隔2秒
        setState(() {
          _messages.add(ChatMessage(
            text: '请求过于频繁，请稍等${2 - timeDiff.inSeconds}秒后再试',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        return;
      }
    }

    if (_apiKey == null || _apiKey!.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: '未配置API密钥，请联系开发者。',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      return;
    }

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _lastRequestTime = DateTime.now(); // 记录请求时间

    try {
      final response = await _callTongyiAPI(userMessage);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '抱歉，发生了错误：$e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  Future<String> _callTongyiAPI(String message) async {
    // 使用代理服务器解决CORS跨域问题
    const proxyUrl = 'http://localhost:3001/api/tongyi';

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = {
      'message': message,
      'apiKey': _apiKey,
    };

    try {
      print('Sending request to proxy: $proxyUrl');
      print('API Key: ${_apiKey?.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 检查是否有错误
        if (data['code'] != null && data['code'] != '200') {
          throw Exception('API错误: ${data['message'] ?? data['code']}');
        }

        // 通义千问的响应格式解析
        if (data['output'] != null) {
          // 新版本格式：output.choices[0].message.content
          if (data['output']['choices'] != null && data['output']['choices'].isNotEmpty) {
            final choice = data['output']['choices'][0];
            if (choice['message'] != null && choice['message']['content'] != null) {
              return choice['message']['content'].toString().trim();
            }
          }

          // 旧版本格式：output.text
          if (data['output']['text'] != null) {
            return data['output']['text'].toString().trim();
          }

          // 另一种格式：output.message.content
          if (data['output']['message'] != null && data['output']['message']['content'] != null) {
            return data['output']['message']['content'].toString().trim();
          }
        }

        throw Exception('响应格式错误，无法解析回复内容。响应数据: ${response.body}');
      } else if (response.statusCode == 401) {
        final errorData = jsonDecode(response.body);
        throw Exception('API密钥无效或已过期: ${errorData['message'] ?? '请检查密钥是否正确'}');
      } else if (response.statusCode == 403) {
        final errorData = jsonDecode(response.body);
        throw Exception('API访问被拒绝: ${errorData['message'] ?? '请检查账户权限和余额'}');
      } else if (response.statusCode == 429) {
        throw Exception('请求频率过高，请等待1-2分钟后再试');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception('请求参数错误: ${errorData['message'] ?? '请检查请求格式'}');
      } else if (response.statusCode == 500) {
        throw Exception('服务器内部错误，请稍后重试');
      } else {
        String errorMsg = '未知错误';
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['message'] ?? errorData['error'] ?? response.body;
        } catch (e) {
          errorMsg = response.body;
        }
        throw Exception('API调用失败 (${response.statusCode}): $errorMsg');
      }
    } catch (e) {
      print('API Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('网络连接失败（Web端可能是CORS跨域限制），请用真机或模拟器测试。');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('响应格式解析失败');
      }
      throw Exception('请求失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI旅游助手'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '开始与AI助手对话吧！',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text('AI正在思考...'),
                            ],
                          ),
                        );
                      }
                      
                      final message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: message.isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!message.isUser) ...[
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: message.isUser
                                      ? const Color(0xFF667eea)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.isUser
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            if (message.isUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // 输入框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '输入您的问题...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 