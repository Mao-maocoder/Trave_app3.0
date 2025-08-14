import 'user.dart';

class Chat {
  final String id;
  final String type;
  final List<User> participants;
  final String lastMsg;
  final String lastMsgTime;
  final int unreadCount;

  Chat({
    required this.id,
    required this.type,
    required this.participants,
    required this.lastMsg,
    required this.lastMsgTime,
    required this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      type: json['type'],
      participants: (json['participants'] as List).map((e) => User.fromJson(e)).toList(),
      lastMsg: json['lastMsg'] ?? '',
      lastMsgTime: json['lastMsgTime'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
} 