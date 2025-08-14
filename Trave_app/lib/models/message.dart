import 'user.dart';

class Message {
  final String id;
  final String chatId;
  final User from;
  final User to;
  final String content;
  final String type;
  final String? imageUrl;
  final String timestamp;
  final String status;

  Message({
    required this.id,
    required this.chatId,
    required this.from,
    required this.to,
    required this.content,
    required this.type,
    this.imageUrl,
    required this.timestamp,
    required this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'],
      from: User.fromJson(json['from']),
      to: User.fromJson(json['to']),
      content: json['content'] ?? '',
      type: json['type'],
      imageUrl: json['imageUrl'],
      timestamp: json['timestamp'],
      status: json['status'],
    );
  }
} 