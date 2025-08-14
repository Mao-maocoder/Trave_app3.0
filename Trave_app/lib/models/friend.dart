class Friend {
  final String id;
  final String username;
  final String avatar;
  final String status;

  Friend({
    required this.id,
    required this.username,
    required this.avatar,
    required this.status,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      username: json['username'],
      avatar: json['avatar'] ?? '',
      status: json['status'] ?? 'accepted',
    );
  }
} 