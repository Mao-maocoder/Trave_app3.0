import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/friend.dart';
import '../utils/api_host.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  static Future<List<Friend>> getFriends() async {
    final res = await http.get(Uri.parse('${ApiHost.baseUrl}/api/friends'));
    final data = json.decode(res.body);
    if (data['success']) {
      return (data['friends'] as List).map((e) => Friend.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? '获取好友失败');
  }

  static Future<Friend> addFriend(String username) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/friends/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username}),
    );
    final data = json.decode(res.body);
    if (data['success']) {
      return Friend.fromJson(data['friend']);
    }
    throw Exception(data['message'] ?? '添加好友失败');
  }

  static Future<List<Chat>> getChats({required String userId}) async {
    final uri = Uri.parse('${ApiHost.baseUrl}/api/chats?userId=$userId');
    final res = await http.get(uri);
    final data = json.decode(res.body);
    if (data['success']) {
      return (data['chats'] as List).map((e) => Chat.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? '获取会话失败');
  }

  static Future<List<Message>> getMessages(String chatId, {int limit = 30, String? userId}) async {
    final queryParams = <String, String>{
      'chatId': chatId,
      'limit': limit.toString(),
    };
    if (userId != null) {
      queryParams['userId'] = userId;
    }
    
    final uri = Uri.parse('${ApiHost.baseUrl}/api/messages').replace(queryParameters: queryParams);
    final res = await http.get(uri);
    final data = json.decode(res.body);
    if (data['success']) {
      return (data['messages'] as List).map((e) => Message.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? '获取消息失败');
  }

  static Future<Message> sendMessage({
    required String chatId,
    required String to,
    required String type,
    String? content,
    String? imageUrl,
    String? voiceUrl,
    String? fileUrl,
    String? from,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/messages/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'chatId': chatId,
        'to': to,
        'type': type,
        'content': content,
        'imageUrl': imageUrl,
        'voiceUrl': voiceUrl,
        'fileUrl': fileUrl,
        'from': from,
      }),
    );
    final data = json.decode(res.body);
    if (data['success']) {
      return Message.fromJson(data['message']);
    }
    throw Exception(data['message'] ?? '发送消息失败');
  }

  static Future<List<User>> searchUsers(String keyword, {String? role}) async {
    final roleParam = role != null ? '&role=$role' : '';
    final res = await http.get(Uri.parse('${ApiHost.baseUrl}/api/users/search?keyword=$keyword$roleParam'));
    final data = json.decode(res.body);
    if (data['success']) {
      return (data['users'] as List).map((e) => User.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? '搜索用户失败');
  }

  static Future<void> sendFriendRequest(String fromId, String toId) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/friends/request'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fromId': fromId, 'toId': toId}),
    );
    final data = json.decode(res.body);
    if (!data['success']) throw Exception(data['message'] ?? '发送好友请求失败');
  }

  static Future<List<Map<String, dynamic>>> getFriendRequests(String userId) async {
    final res = await http.get(Uri.parse('${ApiHost.baseUrl}/api/friends/requests?userId=$userId'));
    final data = json.decode(res.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['requests']);
    }
    throw Exception(data['message'] ?? '获取好友请求失败');
  }

  static Future<void> acceptFriendRequest(String requestId) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/friends/accept'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'requestId': requestId}),
    );
    final data = json.decode(res.body);
    if (!data['success']) throw Exception(data['message'] ?? '同意好友请求失败');
  }

  static Future<void> rejectFriendRequest(String requestId) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/friends/reject'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'requestId': requestId}),
    );
    final data = json.decode(res.body);
    if (!data['success']) throw Exception(data['message'] ?? '拒绝好友请求失败');
  }

  // 新增方法
  static Future<void> deleteFriend(String userId, String friendId) async {
    final res = await http.delete(
      Uri.parse('${ApiHost.baseUrl}/api/friends/$friendId?userId=$userId'),
    );
    final data = json.decode(res.body);
    if (!data['success']) throw Exception(data['message'] ?? '删除好友失败');
  }

  static Future<void> markMessagesAsRead(String chatId, String userId) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/messages/read'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'chatId': chatId, 'userId': userId}),
    );
    final data = json.decode(res.body);
    if (!data['success']) throw Exception(data['message'] ?? '标记已读失败');
  }

  static Future<void> deleteMessage(String messageId, String userId) async {
    final res = await http.delete(
      Uri.parse('${ApiHost.baseUrl}/api/messages/$messageId?userId=$userId'),
    );
    final data = json.decode(res.body);
    if (!data['success']) throw Exception(data['message'] ?? '删除消息失败');
  }

  static Future<int> getUnreadMessageCount(String userId) async {
    final res = await http.get(Uri.parse('${ApiHost.baseUrl}/api/messages/unread?userId=$userId'));
    final data = json.decode(res.body);
    if (data['success']) {
      return data['unreadCount'] ?? 0;
    }
    throw Exception(data['message'] ?? '获取未读消息数量失败');
  }

  static Future<Map<String, dynamic>> createOrGetPrivateChat(String userId1, String userId2) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/chats/private'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId1': userId1, 'userId2': userId2}),
    );
    final data = json.decode(res.body);
    if (data['success']) {
      return {
        'chatId': data['chatId'],
        'isNew': data['isNew'],
      };
    }
    throw Exception(data['message'] ?? '创建会话失败');
  }

  static Future<void> createGroupChat(String groupName, List<String> memberIds) async {
    final res = await http.post(
      Uri.parse('${ApiHost.baseUrl}/api/chats/group'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': groupName, 'memberIds': memberIds}),
    );
    final data = json.decode(res.body);
    if (!data['success']) throw Exception(data['message'] ?? '创建群聊失败');
  }

  late IO.Socket socket;
  final String userId;

  ChatService(this.userId);

  void connect() {
    socket = IO.io('http://localhost:3001', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'userId': userId},
    });
    socket.connect();
  }

  void sendWsMessage(String to, String content) {
    final msg = {
      'from': userId,
      'to': to,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };
    socket.emit('private_message', msg);
  }

  void onMessage(void Function(Map msg) handler) {
    socket.on('private_message', (data) => handler(Map<String, dynamic>.from(data)));
  }

  void disconnect() {
    socket.disconnect();
  }
} 