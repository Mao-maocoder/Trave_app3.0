import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants.dart';
import '../utils/api_host.dart';

// 新增：头像资源列表
const List<String> kDefaultAvatarAssets = [
  'assets/images/profile/character1.jpg',
  'assets/images/profile/character2.png',
  'assets/images/profile/character3.png',
  'assets/images/profile/character4.png',
  'assets/images/profile/character5.png',
  'assets/images/profile/character6.png',
  'assets/images/profile/character7.png',
  'assets/images/profile/character8.png',
];

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  String? _avatarUrl;
  File? _avatarFile;
  Uint8List? _avatarBytes; // 用于Web平台
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nicknameController = TextEditingController(text: user?.username ?? '');
    _avatarUrl = user?.avatar;
    
    print('🔄 个人资料编辑页面初始化');
    print('📤 用户ID: ${user?.id}');
    print('📤 当前昵称: ${user?.username}');
    print('📤 当前头像URL: ${user?.avatar}');
    print('📤 设置的头像URL: $_avatarUrl');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      // 显示选择头像方式的底部菜单
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('拍摄照片'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.style),
              title: const Text('使用默认头像'),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        ),
      );

      if (source == null) {
        // 用户选择使用默认头像
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('选择默认头像'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: kDefaultAvatarAssets.map((asset) => GestureDetector(
                    onTap: () => Navigator.pop(context, asset),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(asset),
                      radius: 32,
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        );

        if (selected != null) {
          setState(() {
            _avatarUrl = selected;
            _avatarFile = null;
            _avatarBytes = null;
          });
        }
        return;
      }

      // 用户选择拍照或从相册选择
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked != null) {
        setState(() => _isLoading = true);
        try {
          String? url;
          if (kIsWeb) {
            final bytes = await picked.readAsBytes();
            setState(() { _avatarBytes = bytes; });
            url = await _uploadAvatarBytes(bytes, picked.name);
          } else {
            setState(() { _avatarFile = File(picked.path); });
            url = await _uploadAvatar(_avatarFile!);
          }
          
          if (url != null) {
            setState(() { 
              _avatarUrl = url;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('头像上传成功'))
            );
          } else {
            throw Exception('头像上传失败');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('头像上传失败: ${e.toString()}')),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('选择头像时发生错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('选择头像失败，请重试')),
      );
    }
  }

  Future<String?> _uploadAvatar(File file) async {
    // 移动端上传头像
    final request = await UserService.uploadAvatar(file);
    return request;
  }

  Future<String?> _uploadAvatarBytes(Uint8List bytes, String filename) async {
    // Web端上传头像
    final request = await UserService.uploadAvatarBytes(bytes, filename);
    return request;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      print('🔄 开始保存用户资料...');
      print('📤 用户ID: ${user!.id}');
      print('📤 新昵称: ${_nicknameController.text.trim()}');
      print('📤 新头像URL: $_avatarUrl');
      
      final success = await UserService.updateProfile(
        user.id,
        username: _nicknameController.text.trim(),
        avatarUrl: _avatarUrl,
      );
      
      if (success) {
        print('✅ 后端更新成功，开始更新本地用户信息...');
        // 刷新全局用户信息
        final updatedUser = user.copyWith(
          username: _nicknameController.text.trim(),
          avatar: _avatarUrl,
        );
        await authProvider.updateUser(updatedUser);
        print('✅ 本地用户信息更新成功');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('资料更新成功')),
        );
        // 返回并传递更新成功的标志
        Navigator.of(context).pop(true);
      } else {
        print('❌ 后端更新失败');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('资料更新失败')),
        );
      }
    } catch (e) {
      print('❌ 保存资料时发生错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('编辑个人信息', style: TextStyle(fontFamily: kFontFamilyTitle))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : _pickAvatar,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.2),
                          width: 4,
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ClipOval(
                              child: _avatarFile != null || _avatarBytes != null
                                  ? kIsWeb && _avatarBytes != null
                                      ? Image.memory(
                                          _avatarBytes!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          _avatarFile!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                  : _avatarUrl != null && _avatarUrl!.isNotEmpty
                                      ? _avatarUrl!.startsWith('assets/')
                                          ? Image.asset(
                                              _avatarUrl!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('❌ 个人资料页面资源头像加载失败: $error');
                                                return const Icon(Icons.person, size: 48, color: Colors.grey);
                                              },
                                            )
                                          : Image.network(
                                              _avatarUrl!.startsWith('http')
                                                  ? _avatarUrl!
                                                  : '${ApiHost.baseUrl}$_avatarUrl',
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('❌ 个人资料页面头像加载失败: $error');
                                                return const Icon(Icons.person, size: 48, color: Colors.grey);
                                              },
                                            )
                                      : const Icon(Icons.person, size: 48, color: Colors.grey),
                            ),
                    ),
                  ),
                  if (!_isLoading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '昵称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? '昵称不能为空' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                  ),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}