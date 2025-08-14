import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/api_host.dart';
import '../utils/avatar_debugger.dart';
import '../constants.dart';

class UserAvatar extends StatelessWidget {
  final String? username;
  final String? userId;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  const UserAvatar({
    Key? key,
    this.username,
    this.userId,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ?? AppColors.primary;
    final defaultTextColor = textColor ?? Colors.white;
    final defaultFontSize = fontSize ?? (radius * 0.6);

    // 如果有用户名，优先使用用户名获取用户信息
    if (username != null) {
      return FutureBuilder<User?>(
        future: _fetchUserByUsername(username!),
        builder: (context, snapshot) {
          return _buildAvatar(
            context,
            snapshot.data,
            defaultBackgroundColor,
            defaultTextColor,
            defaultFontSize,
          );
        },
      );
    }
    
    // 如果有用户ID，使用用户ID获取用户信息
    if (userId != null) {
      return FutureBuilder<User?>(
        future: UserService.getUserById(userId!),
        builder: (context, snapshot) {
          return _buildAvatar(
            context,
            snapshot.data,
            defaultBackgroundColor,
            defaultTextColor,
            defaultFontSize,
          );
        },
      );
    }

    // 如果都没有，使用当前登录用户
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        return _buildAvatar(
          context,
          currentUser,
          defaultBackgroundColor,
          defaultTextColor,
          defaultFontSize,
        );
      },
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    User? user,
    Color backgroundColor,
    Color textColor,
    double fontSize,
  ) {
    final displayName = user?.username ?? username ?? 'U';
    final avatarUrl = user?.avatar;

    print('🔄 构建用户头像:');
    print('- 用户名: $displayName');
    print('- 用户ID: ${user?.id}');
    print('- 原始头像路径: $avatarUrl');
    print('- ApiHost.baseUrl: ${ApiHost.baseUrl}');

    return Container(
      decoration: showBorder ? BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
          width: borderWidth ?? 2,
        ),
      ) : null,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? ClipOval(
                child: _AvatarImage(
                  imageUrl: _buildAvatarUrl(avatarUrl),
                  originalPath: avatarUrl,
                  width: radius * 2,
                  height: radius * 2,
                  fallbackWidget: _buildFallbackAvatar(displayName, textColor, fontSize),
                  backgroundColor: backgroundColor,
                  textColor: textColor,
                ),
              )
            : _buildFallbackAvatar(displayName, textColor, fontSize),
      ),
    );
  }

  Widget _buildFallbackAvatar(String displayName, Color textColor, double fontSize) {
    return Text(
      displayName[0].toUpperCase(),
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    );
  }

  String _buildAvatarUrl(String avatarPath) {
    print('🔄 构建头像URL: $avatarPath');
    
    // 清理路径，移除多余的空格和斜杠
    final cleanPath = avatarPath.trim();
    
    // 如果是资源路径，直接返回
    if (cleanPath.startsWith('assets/')) {
      print('✅ 资源路径，直接使用: $cleanPath');
      return cleanPath;
    }
    
    // 如果已经是完整的URL，直接返回
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      print('✅ 完整URL，直接使用: $cleanPath');
      return cleanPath;
    }
    
    // 如果是相对路径，拼接baseUrl
    if (cleanPath.startsWith('/')) {
      final fullUrl = '${ApiHost.baseUrl}$cleanPath';
      print('✅ 相对路径，拼接baseUrl: $fullUrl');
      return fullUrl;
    }
    
    // 如果既不是完整URL也不是以/开头，添加/uploads前缀
    final fullUrl = '${ApiHost.baseUrl}/uploads/$cleanPath';
    print('✅ 文件名，添加/uploads前缀: $fullUrl');
    return fullUrl;
  }

  Future<User?> _fetchUserByUsername(String username) async {
    try {
      final users = await UserService.fetchUsers();
      try {
        return users.firstWhere((user) => user.username == username);
      } catch (e) {
        return null;
      }
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }
}

// 专门处理头像图片加载的组件，支持重试和错误处理
class _AvatarImage extends StatefulWidget {
  final String imageUrl;
  final String originalPath;
  final double width;
  final double height;
  final Widget fallbackWidget;
  final Color backgroundColor;
  final Color textColor;

  const _AvatarImage({
    Key? key,
    required this.imageUrl,
    required this.originalPath,
    required this.width,
    required this.height,
    required this.fallbackWidget,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  State<_AvatarImage> createState() => _AvatarImageState();
}

class _AvatarImageState extends State<_AvatarImage> {
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  @override
  Widget build(BuildContext context) {
    if (_hasError && _retryCount < _maxRetries) {
      // 重试逻辑
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _retryLoad();
      });
    }

    // 如果是资源路径，使用Image.asset
    if (widget.imageUrl.startsWith('assets/')) {
      return Image.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ 用户头像资源加载失败: $error');
          print('❌ 头像资源路径: ${widget.imageUrl}');
          return widget.fallbackWidget;
        },
      );
    }

    // 否则使用Image.network
    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ 用户头像加载失败: $error');
        print('❌ 头像URL: ${widget.imageUrl}');
        print('❌ 原始头像路径: ${widget.originalPath}');
        print('❌ 重试次数: $_retryCount');
        
        // 在第一次失败时启动调试
        if (_retryCount == 0) {
          AvatarDebugger.debugAvatarUrl(widget.originalPath);
        }
        
        if (_retryCount < _maxRetries) {
          // 显示加载指示器，准备重试
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
              ),
            ),
          );
        } else {
          // 达到最大重试次数，显示fallback
          return widget.fallbackWidget;
        }
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // 加载成功，重置错误状态
          _hasError = false;
          _retryCount = 0;
          return child;
        }
        
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
            ),
          ),
        );
      },
    );
  }

  void _retryLoad() {
    if (!mounted) return;
    
    setState(() {
      _retryCount++;
      _hasError = true;
    });
    
    print('🔄 重试加载头像 (${_retryCount}/$_maxRetries): ${widget.imageUrl}');
  }
}