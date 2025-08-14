enum UserRole {
  tourist,  // 游客
  guide,    // 导游
}

class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final bool isActive;
  final UserRole role;  // 新增角色字段
  final bool hasCompletedSurvey; // 是否完成问卷

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
    this.isActive = true,
    this.role = UserRole.tourist,  // 默认为游客
    this.hasCompletedSurvey = false, // 默认未完成问卷
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.tourist,
      ),
      hasCompletedSurvey: json['hasCompletedSurvey'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'role': role.toString().split('.').last,
      'hasCompletedSurvey': hasCompletedSurvey,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    DateTime? createdAt,
    bool? isActive,
    UserRole? role,
    bool? hasCompletedSurvey,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      hasCompletedSurvey: hasCompletedSurvey ?? this.hasCompletedSurvey,
    );
  }

  // 便捷方法
  bool get isTourist => role == UserRole.tourist;
  bool get isGuide => role == UserRole.guide;
} 