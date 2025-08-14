import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_edit_screen.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // 顶部大背景图
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background/bg6.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 左上角返回按钮
              if (Navigator.canPop(context))
                Positioned(
                  top: 32,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: kWhite, size: 28),
                    onPressed: () => Navigator.pop(context),
                    tooltip: isChinese ? '返回' : 'Back',
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: 40,
                child: Center(
                  child: Text(
                    isChinese ? '我的' : 'Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: kFontFamilyTitle,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 个人信息卡片
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: kCardBackground,
              borderRadius: BorderRadius.circular(kRadiusCard),
              boxShadow: kShadowMedium,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                      ? ((user.avatar!.startsWith('http') || user.avatar!.startsWith('/uploads/'))
                          ? NetworkImage(
                              user.avatar!.startsWith('http')
                                  ? user.avatar!
                                  : 'https://7f5703ca5937.ngrok-free.app${user.avatar!}',
                            )
                          : AssetImage(user.avatar!)) as ImageProvider
                      : const AssetImage('assets/default_avatar.png'),
                  backgroundColor: kPrimaryLight,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? (isChinese ? '请点击登录' : 'Tap to login'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextPrimary, fontFamily: kFontFamilyTitle),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                                         ElevatedButton.icon(
                       icon: const Icon(Icons.edit, size: 18),
                       label: Text(isChinese ? '编辑资料' : 'Edit Profile'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: kPrimaryColor,
                         foregroundColor: kWhite,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusButton)),
                         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                       ),
                       onPressed: () {
                         print('🔄 编辑资料按钮被点击');
                         // 先显示一个简单的提示来测试按钮是否工作
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('编辑资料按钮被点击！')),
                         );
                         
                         // 使用命名路由导航
                         Future.delayed(const Duration(seconds: 1), () {
                           try {
                             Navigator.pushNamed(context, '/profile-edit');
                             print('✅ 成功导航到编辑资料页面');
                           } catch (e) {
                             print('❌ 导航失败: $e');
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('导航失败: $e')),
                             );
                           }
                         });
                       },
                     ),
                    const SizedBox(width: 16),
                    if (user?.role == UserRole.tourist)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.group, size: 18),
                        label: Text(isChinese ? '绑定导游' : 'Bind Guide'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhite,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusButton)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BindGuideScreen()),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 功能列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite, color: kPrimaryColor),
                  title: Text(isChinese ? '我的收藏' : 'My Favorites', style: const TextStyle(fontFamily: kFontFamilyTitle)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(color: kDividerColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: kPrimaryColor),
                  title: Text(isChinese ? '我的订单' : 'My Orders', style: const TextStyle(fontFamily: kFontFamilyTitle)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(color: kDividerColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.settings, color: kPrimaryColor),
                  title: Text(isChinese ? '账户设置' : 'Account Settings', style: const TextStyle(fontFamily: kFontFamilyTitle)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(color: kDividerColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback, color: kPrimaryColor),
                  title: Text(isChinese ? '反馈' : 'Feedback', style: const TextStyle(fontFamily: kFontFamilyTitle)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/feedback');
                  },
                ),
                const Divider(color: kDividerColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: kErrorColor),
                  title: Text(isChinese ? '退出登录' : 'Logout', style: TextStyle(color: kErrorColor, fontFamily: kFontFamilyTitle)),
                  trailing: const Icon(Icons.chevron_right, color: kErrorColor),
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ],
            ),
          ),
          // 底部版权说明
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: Text(
              isChinese
                  ? '由中轴线文明博物馆开发  |  技术支持'
                  : 'Developed by Central Axis Civilization Museum | Powered by Tech',
              style: const TextStyle(fontSize: 12, color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class BindGuideScreen extends StatefulWidget {
  const BindGuideScreen({Key? key}) : super(key: key);

  @override
  State<BindGuideScreen> createState() => _BindGuideScreenState();
}

class _BindGuideScreenState extends State<BindGuideScreen> {
  String? selectedGuideId;
  bool isLoading = true;
  List<dynamic> availableGuides = [];
  dynamic binding;
  dynamic guideUser;
  bool isChinese = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isChinese = Localizations.localeOf(context).languageCode == 'zh';
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final guides = await UserService.fetchUsers();
    final available = guides.where((u) => u.role == UserRole.guide).toList();
    final b = await UserService.getBindingByTourist(user!.id);
    dynamic gUser;
    if (b != null) {
      gUser = await UserService.getUserById(b.guideId);
    }
    setState(() {
      availableGuides = available;
      binding = b;
      guideUser = gUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    return Scaffold(
      appBar: AppBar(title: Text(isChinese ? '绑定导游' : 'Bind Guide')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: binding != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (guideUser != null) ...[
                          ListTile(
                            leading: CircleAvatar(child: Text(guideUser.username[0])),
                            title: Text('${isChinese ? '导游昵称：' : 'Guide: '}${guideUser.username}'),
                            subtitle: Text('${isChinese ? '邮箱：' : 'Email: '}${guideUser.email}'),
                          ),
                        ],
                        Text(isChinese ? '已绑定导游ID: ' : 'Bound Guide ID: ' + binding.guideId),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await UserService.unbindGuide(user!.id);
                            await _fetchData();
                          },
                          child: Text(isChinese ? '解绑' : 'Unbind'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: selectedGuideId,
                          hint: Text(isChinese ? '请选择导游' : 'Select a guide'),
                          items: availableGuides.map<DropdownMenuItem<String>>((g) => DropdownMenuItem<String>(
                            value: g.id,
                            child: Text(g.username),
                          )).toList(),
                          onChanged: (v) => setState(() => selectedGuideId = v),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: selectedGuideId == null ? null : () async {
                            final success = await UserService.bindGuide(user!.id, selectedGuideId!);
                            if (!success) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(isChinese ? '绑定失败' : 'Bind Failed'),
                                  content: Text(isChinese ? '已存在待审批或已绑定的记录' : 'A pending or approved binding already exists.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(isChinese ? '确定' : 'OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            await _fetchData();
                          },
                          child: Text(isChinese ? '发起绑定' : 'Bind'),
                        ),
                      ],
                    ),
            ),
    );
  }
}