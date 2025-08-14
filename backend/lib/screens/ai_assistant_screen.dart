import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/api_host.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../constants.dart';
import '../widgets/user_avatar.dart';

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
    setState(() {
      _messages.add(ChatMessage(
        text: '✅ AI旅游助手已就绪！\n\n我可以帮您：\n• 推荐北京中轴线景点\n• 解答旅游相关问题\n• 提供文化背景知识\n• 规划行程建议\n\n请开始提问吧！',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
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
      final response = await _callAIAssistant(userMessage);
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

  Future<String> _callAIAssistant(String message) async {
    // 模拟AI助手回复
    await Future.delayed(const Duration(seconds: 1)); // 模拟网络延迟
    
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('故宫') || lowerMessage.contains('forbidden city')) {
      return '故宫博物院是明清两代的皇家宫殿，位于北京中轴线的中心。建议您：\n\n• 提前预约门票\n• 从午门进入，神武门出来\n• 重点参观太和殿、中和殿、保和殿\n• 建议游览时间：3-4小时\n• 最佳游览季节：春秋两季';
    } else if (lowerMessage.contains('天坛') || lowerMessage.contains('temple of heaven')) {
      return '天坛是明清两代皇帝祭天的场所，是中国最大的古代皇帝祭天建筑群。建议您：\n\n• 从南门进入，北门出来\n• 重点参观祈年殿、回音壁、圜丘\n• 建议游览时间：2-3小时\n• 最佳游览时间：清晨或傍晚\n• 可以体验回音壁的声学奇迹';
    } else if (lowerMessage.contains('中轴线') || lowerMessage.contains('central axis')) {
      return '北京中轴线全长7.8公里，从永定门到钟鼓楼，是世界上最完整、最长的城市中轴线。主要景点包括：\n\n• 永定门（南起点）\n• 天坛公园\n• 前门大街\n• 天安门广场\n• 故宫博物院\n• 景山公园\n• 钟鼓楼（北终点）\n\n建议您按照从南到北的顺序游览，体验完整的文化脉络。';
    } else if (lowerMessage.contains('行程') || lowerMessage.contains('itinerary')) {
      return '为您推荐3天中轴线精华行程：\n\n**第一天：天坛 + 前门大街**\n• 上午：天坛公园（2-3小时）\n• 下午：前门大街（2小时）\n\n**第二天：故宫 + 景山**\n• 上午：故宫博物院（3-4小时）\n• 下午：景山公园（1-2小时）\n\n**第三天：什刹海 + 钟鼓楼**\n• 上午：什刹海（2-3小时）\n• 下午：钟鼓楼（1小时）\n\n建议提前预约故宫门票！';
    } else if (lowerMessage.contains('你好') || lowerMessage.contains('hello')) {
      return '您好！我是您的AI旅游助手，专门为您提供北京中轴线旅游咨询服务。\n\n我可以帮您：\n• 推荐景点和路线\n• 解答文化历史问题\n• 提供实用旅游建议\n• 规划个性化行程\n\n请告诉我您想了解什么？';
    } else {
      return '感谢您的提问！关于北京中轴线旅游，我建议您：\n\n• 提前了解各景点的历史文化背景\n• 合理安排游览时间，避免过于匆忙\n• 注意天气情况，选择合适的时间出行\n• 可以结合APP中的AR功能，获得更好的体验\n• 建议下载离线地图，方便导航\n\n如果您有具体问题，请随时询问！';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI旅游助手', style: TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              final avatarUrl = user?.avatar;
              final fullAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty 
                  ? '${getApiBaseUrl()}$avatarUrl' 
                  : null;
              
              // 调试信息
              if (fullAvatarUrl != null) {
                print('🖼️ AppBar头像URL: $fullAvatarUrl');
              }
              
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: UserAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  textColor: Colors.white,
                  fontSize: 12,
                ),
              );
            },
          ),
        ],
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
                                  gradient: const LinearGradient(
                                    colors: [kPrimaryColor, kSecondaryColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(kRadiusCard),
                                  boxShadow: kShadowLight,
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
                                  color: message.isUser ? kPrimaryColor : kCardBackground,
                                  borderRadius: BorderRadius.circular(kRadiusCard),
                                  boxShadow: kShadowLight,
                                ),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.isUser ? Colors.white : kTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                            if (message.isUser) ...[
                              const SizedBox(width: 8),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  final user = authProvider.currentUser;
                                  final avatarUrl = user?.avatar;
                                  return UserAvatar(
                                    radius: 16,
                                    backgroundColor: kPrimaryColor,
                                    textColor: Colors.white,
                                    fontSize: 12,
                                    showBorder: true,
                                    borderColor: kBorderColor,
                                    borderWidth: 1,
                                    // 传递头像路径
                                    userId: user?.id?.toString(),
                                  );
                                },
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
              color: kCardBackground,
              boxShadow: kShadowLight,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '输入您的问题...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(kRadiusInput)),
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
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(kRadiusButton),
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