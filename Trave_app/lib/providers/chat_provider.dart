import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/friend.dart';
import '../models/user.dart';
import '../services/chat_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  List<Message> _messages = [];
  List<Friend> _friends = [];
  List<User> _searchResults = [];
  bool _loadingChats = false;
  bool _loadingMessages = false;
  bool _loadingFriends = false;
  String? _error;
  List<Map<String, dynamic>> _friendRequests = [];
  int _unreadCount = 0;
  ChatService? _wsService;
  String? _wsUserId;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  List<Friend> get friends => _friends;
  List<User> get searchResults => _searchResults;
  bool get loadingChats => _loadingChats;
  bool get loadingMessages => _loadingMessages;
  bool get loadingFriends => _loadingFriends;
  String? get error => _error;
  List<Map<String, dynamic>> get friendRequests => _friendRequests;
  int get unreadCount => _unreadCount;

  Future<void> loadChats(BuildContext context) async {
    _loadingChats = true;
    notifyListeners();
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.currentUser?.id;
      if (userId != null) {
        _chats = await ChatService.getChats(userId: userId);
        // 只保留与当前用户身份互补的会话
        final myRole = auth.currentUser?.role;
        if (myRole != null) {
          final targetRole = myRole == UserRole.tourist ? UserRole.guide : UserRole.tourist;
          _chats = _chats.where((chat) => chat.participants.any((u) => u.role == targetRole)).toList();
        }
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loadingChats = false;
    notifyListeners();
  }

  Future<void> loadMessages(String chatId, {String? userId}) async {
    _loadingMessages = true;
    notifyListeners();
    try {
      _messages = await ChatService.getMessages(chatId, userId: userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loadingMessages = false;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String chatId,
    required String to,
    required String type,
    String? content,
    String? imageUrl,
    String? voiceUrl,
    String? fileUrl,
    String? from,
  }) async {
    try {
      final msg = await ChatService.sendMessage(
        chatId: chatId,
        to: to,
        type: type,
        content: content,
        imageUrl: imageUrl,
        voiceUrl: voiceUrl,
        fileUrl: fileUrl,
        from: from,
      );
      _messages.add(msg);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFriends() async {
    _loadingFriends = true;
    notifyListeners();
    try {
      _friends = await ChatService.getFriends();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loadingFriends = false;
    notifyListeners();
  }

  Future<void> addFriend(String username) async {
    try {
      final friend = await ChatService.addFriend(username);
      _friends.add(friend);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFriend(String userId, String friendId) async {
    try {
      await ChatService.deleteFriend(userId, friendId);
      _friends.removeWhere((friend) => friend.id == friendId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchUsers(String keyword, BuildContext context) async {
    try {
      // 不再限制角色，所有用户都能查到
      _searchResults = await ChatService.searchUsers(keyword);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendFriendRequest(String fromId, String toId) async {
    try {
      await ChatService.sendFriendRequest(fromId, toId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFriendRequests(String userId) async {
    try {
      _friendRequests = await ChatService.getFriendRequests(userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest(String requestId, BuildContext context, String userId) async {
    try {
      await ChatService.acceptFriendRequest(requestId);
      await loadFriendRequests(userId);
      await loadFriends();
      await loadChats(context);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectFriendRequest(String requestId, String userId) async {
    try {
      await ChatService.rejectFriendRequest(requestId);
      await loadFriendRequests(userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await ChatService.markMessagesAsRead(chatId, userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId, String userId) async {
    try {
      await ChatService.deleteMessage(messageId, userId);
      _messages.removeWhere((msg) => msg.id == messageId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount(String userId) async {
    try {
      _unreadCount = await ChatService.getUnreadMessageCount(userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createOrGetPrivateChat(String userId1, String userId2) async {
    try {
      final result = await ChatService.createOrGetPrivateChat(userId1, userId2);
      _error = null;
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createGroupChat(String groupName, List<String> memberIds) async {
    try {
      await ChatService.createGroupChat(groupName, memberIds);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
  
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void connectWebSocket(String userId) {
    if (_wsUserId == userId && _wsService != null) return;
    _wsUserId = userId;
    _wsService?.disconnect();
    _wsService = ChatService(userId);
    _wsService!.connect();
    _wsService!.onMessage((msg) {
      final message = Message.fromJson(Map<String, dynamic>.from(msg));
      _messages.add(message);
      notifyListeners();
    });
  }

  void disconnectWebSocket() {
    _wsService?.disconnect();
    _wsService = null;
    _wsUserId = null;
  }
} 