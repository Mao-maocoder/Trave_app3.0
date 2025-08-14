import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/avatar_debugger.dart';
import '../widgets/user_avatar.dart';
import '../constants.dart';

class AvatarTestScreen extends StatefulWidget {
  const AvatarTestScreen({Key? key}) : super(key: key);

  @override
  State<AvatarTestScreen> createState() => _AvatarTestScreenState();
}

class _AvatarTestScreenState extends State<AvatarTestScreen> {
  final TextEditingController _avatarPathController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 设置默认测试路径
    _avatarPathController.text = '/uploads/photos/1751787290497-969814838.jpg';
  }

  @override
  void dispose() {
    _avatarPathController.dispose();
    _userIdController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _testAvatarPath() async {
    if (_avatarPathController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入头像路径')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await AvatarDebugger.debugAvatarUrl(_avatarPathController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('调试完成，请查看控制台输出')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('调试失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testUserAvatar() async {
    if (_userIdController.text.trim().isEmpty && _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户ID或用户名')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await AvatarDebugger.debugUserAvatar(
        _userIdController.text.trim(),
        _usernameController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('调试完成，请查看控制台输出')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('调试失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('头像调试工具', style: TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前用户头像测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前用户头像',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: kFontFamilyTitle),
                    ),
                    const SizedBox(height: 8),
                    if (currentUser != null) ...[
                      Text('用户ID: ${currentUser.id}'),
                      Text('用户名: ${currentUser.username}'),
                      Text('头像路径: ${currentUser.avatar ?? '未设置'}'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          UserAvatar(
                            radius: 30,
                            backgroundColor: kPrimaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: currentUser.avatar != null ? _testCurrentUserAvatar : null,
                              child: const Text('调试当前用户头像'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text('未登录'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 头像路径测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '头像路径测试',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: kFontFamilyTitle),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _avatarPathController,
                      decoration: const InputDecoration(
                        labelText: '头像路径',
                        hintText: '例如: /uploads/photos/filename.jpg',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testAvatarPath,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('测试头像路径'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 用户头像测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户头像测试',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: kFontFamilyTitle),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: '用户ID',
                        hintText: '输入用户ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        hintText: '输入用户名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testUserAvatar,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('测试用户头像'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 常见问题说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '常见问题',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('• 头像路径格式不正确'),
                    const Text('• 网络连接问题'),
                    const Text('• 后端服务器未运行'),
                    const Text('• CORS配置问题'),
                    const Text('• 文件不存在或权限问题'),
                    const SizedBox(height: 8),
                    const Text('💡 提示：查看控制台输出获取详细调试信息'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCurrentUserAvatar() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser?.avatar == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      await AvatarDebugger.debugAvatarUrl(currentUser!.avatar!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('调试完成，请查看控制台输出')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('调试失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
} 