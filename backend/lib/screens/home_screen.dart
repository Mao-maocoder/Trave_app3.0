import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../constants.dart';
import '../theme.dart';
import '../utils/performance_config.dart';
import '../widgets/primary_button.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'ai_assistant_screen.dart';
import 'admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isChinese = localeProvider.locale == AppLocale.zh;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 自定义AppBar
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    isChinese ? '北京中轴线' : 'Beijing Central Axis',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_city,
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isChinese ? '中秘文明互鉴' : 'Cultural Exchange',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      localeProvider.locale == AppLocale.zh
                          ? Icons.language
                          : Icons.translate,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      localeProvider.toggleLocale();
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      switch (value) {
                        case 'logout':
                          authProvider.logout();
                          break;
                        case 'feedback':
                          Navigator.pushNamed(context, '/feedback');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'feedback',
                        child: Row(
                          children: [
                            const Icon(Icons.feedback),
                            const SizedBox(width: 8),
                            Text(isChinese ? '意见反馈' : 'Feedback'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout),
                            const SizedBox(width: 8),
                            Text(isChinese ? '退出登录' : 'Logout'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 主要内容
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 欢迎信息
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.accent, AppColors.secondary],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isChinese ? '欢迎回来！' : 'Welcome back!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isChinese 
                                    ? '探索北京中轴线的文化魅力'
                                    : 'Explore the cultural charm of Beijing Central Axis',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 角色区分
                          if (authProvider.isGuide) ...[
                            // 导游：显示管理功能区域
                            Text(
                              isChinese ? '导游管理面板' : 'Guide Management Panel',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 管理功能网格
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                              children: [
                                _buildManagementCard(
                                  context,
                                  icon: Icons.dashboard,
                                  title: isChinese ? '数据统计' : 'Statistics',
                                  subtitle: isChinese ? '查看调查数据' : 'View survey data',
                                  color: AppColors.primary,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AdminDashboardScreen()),
                                  ),
                                ),
                                _buildManagementCard(
                                  context,
                                  icon: Icons.people,
                                  title: isChinese ? '用户管理' : 'User Management',
                                  subtitle: isChinese ? '管理游客账号' : 'Manage tourist accounts',
                                  color: AppColors.secondary,
                                  onTap: () => _showUserManagement(context, isChinese),
                                ),
                                _buildManagementCard(
                                  context,
                                  icon: Icons.content_paste,
                                  title: isChinese ? '内容管理' : 'Content Management',
                                  subtitle: isChinese ? '管理景点信息' : 'Manage spot info',
                                  color: AppColors.accent,
                                  onTap: () => _showContentManagement(context, isChinese),
                                ),
                                _buildManagementCard(
                                  context,
                                  icon: Icons.analytics,
                                  title: isChinese ? '反馈分析' : 'Feedback Analysis',
                                  subtitle: isChinese ? '查看用户反馈' : 'View user feedback',
                                  color: AppColors.success,
                                  onTap: () => _showFeedbackAnalysis(context, isChinese),
                                ),
                                _buildManagementCard(
                                  context,
                                  icon: Icons.photo_library,
                                  title: isChinese ? '照片管理' : 'Photo Management',
                                  subtitle: isChinese ? '管理景点照片' : 'Manage spot photos',
                                  color: AppColors.accent,
                                  onTap: () => _showPhotoManagement(context, isChinese),
                                ),
                                _buildManagementCard(
                                  context,
                                  icon: Icons.settings,
                                  title: isChinese ? '系统设置' : 'System Settings',
                                  subtitle: isChinese ? '应用配置' : 'App configuration',
                                  color: AppColors.warning,
                                  onTap: () => _showSystemSettings(context, isChinese),
                                ),
                                _buildManagementCard(
                                  context,
                                  icon: Icons.report,
                                  title: isChinese ? '生成报告' : 'Generate Report',
                                  subtitle: isChinese ? '导出数据报告' : 'Export data report',
                                  color: AppColors.info,
                                  onTap: () => _showReportGeneration(context, isChinese),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 快速统计卡片
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isChinese ? '今日概览' : 'Today Overview',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatItem(
                                          Icons.person_add,
                                          '12',
                                          isChinese ? '新用户' : 'New Users',
                                          AppColors.primary,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          Icons.quiz,
                                          '8',
                                          isChinese ? '新问卷' : 'New Surveys',
                                          AppColors.success,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildStatItem(
                                          Icons.feedback,
                                          '5',
                                          isChinese ? '新反馈' : 'New Feedback',
                                          AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // 游客：显示原有功能区
                            // 搜索导航条
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () => Navigator.pushNamed(context, '/search'),
                                borderRadius: BorderRadius.circular(25),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: AppColors.textSecondary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isChinese ? '搜索景点、文化、美食...' : 'Search spots, culture, food...',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        isChinese ? '搜索' : 'Search',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 功能模块网格
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                              children: [
                                _buildFeatureCard(
                                  context,
                                  icon: Icons.translate,
                                  title: isChinese ? '翻译助手' : 'Translation',
                                  color: AppColors.primary,
                                  onTap: () => Navigator.pushNamed(context, '/translation'),
                                ),
                                _buildFeatureCard(
                                  context,
                                  icon: Icons.map,
                                  title: isChinese ? '地图导航' : 'Map & Navigation',
                                  color: AppColors.secondary,
                                  onTap: () => Navigator.pushNamed(context, '/map'),
                                ),
                                _buildFeatureCard(
                                  context,
                                  icon: Icons.mic,
                                  title: isChinese ? '语音助手' : 'Voice Assistant',
                                  color: AppColors.accent,
                                  onTap: () => Navigator.pushNamed(context, '/voice'),
                                ),
                                _buildFeatureCard(
                                  context,
                                  icon: Icons.book,
                                  title: isChinese ? '北京中轴线术语库' : 'Beijing Central Axis Terminology Database',
                                  color: AppColors.success,
                                  onTap: () => Navigator.pushNamed(context, '/terminology'),
                                ),
                                _buildFeatureCard(
                                  context,
                                  icon: Icons.book,
                                  title: isChinese ? '文化手册' : 'Handbook',
                                  color: AppColors.warning,
                                  onTap: () => Navigator.pushNamed(context, '/handbook'),
                                ),
                                _buildFeatureCard(
                                  context,
                                  icon: Icons.quiz,
                                  title: isChinese ? '文化调查' : 'Survey',
                                  color: AppColors.info,
                                  onTap: () => Navigator.pushNamed(context, '/survey'),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 快速访问
                            Text(
                              isChinese ? '快速访问' : 'Quick Access',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildQuickAccessCard(
                                    context,
                                    icon: Icons.photo_library,
                                    title: isChinese ? '照片墙' : 'Photo Wall',
                                    color: AppColors.primary,
                                    onTap: () => Navigator.pushNamed(context, '/photo'),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildQuickAccessCard(
                                    context,
                                    icon: Icons.video_library,
                                    title: isChinese ? '视频' : 'Videos',
                                    color: AppColors.secondary,
                                    onTap: () => Navigator.pushNamed(context, '/video'),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildQuickAccessCard(
                                    context,
                                    icon: Icons.animation,
                                    title: isChinese ? '动画' : 'Animation',
                                    color: AppColors.accent,
                                    onTap: () => Navigator.pushNamed(context, '/animation'),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildQuickAccessCard(
                                    context,
                                    icon: Icons.museum,
                                    title: isChinese ? '文化' : 'Culture',
                                    color: AppColors.success,
                                    onTap: () => Navigator.pushNamed(context, '/culture'),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _DraggableAIBall(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 110, // 进一步增加宽度
          constraints: const BoxConstraints(
            minHeight: 80,
            maxHeight: 100,
          ),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserManagement(BuildContext context, bool isChinese) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                  children: [
                    Text(
                      isChinese ? '用户管理' : 'User Management',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<User>>(
                      future: UserService.fetchUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                isChinese ? '加载用户列表失败: ${snapshot.error}' : 'Failed to load users: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }

                        final users = snapshot.data ?? [];
                        if (users.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                isChinese ? '暂无用户数据' : 'No users found',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: users.map((user) => _buildUserCard(
                            user.username,
                            user.email,
                            user.role == UserRole.guide ? (isChinese ? '导游' : 'Guide') : (isChinese ? '游客' : 'Tourist'),
                            isChinese,
                            user: user,
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContentManagement(BuildContext context, bool isChinese) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isChinese ? '内容管理' : 'Content Management',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildContentCard('故宫', 'Forbidden City', isChinese),
              _buildContentCard('天坛', 'Temple of Heaven', isChinese),
              _buildContentCard('前门', 'Qianmen', isChinese),
              _buildContentCard('钟鼓楼', 'Bell and Drum Towers', isChinese),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackAnalysis(BuildContext context, bool isChinese) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  children: [
                    Text(
                      isChinese ? '反馈分析' : 'Feedback Analysis',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFeedbackCard('功能建议', '希望增加更多景点信息', 5, isChinese),
                    _buildFeedbackCard('界面优化', '界面很美观，用户体验很好', 5, isChinese),
                    _buildFeedbackCard('内容建议', '建议增加更多历史文化内容', 4, isChinese),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSystemSettings(BuildContext context, bool isChinese) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isChinese ? '系统设置' : 'System Settings',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(Icons.notifications, isChinese ? '通知设置' : 'Notifications', isChinese),
              _buildSettingItem(Icons.language, isChinese ? '语言设置' : 'Language', isChinese),
              _buildSettingItem(Icons.security, isChinese ? '安全设置' : 'Security', isChinese),
              _buildSettingItem(Icons.backup, isChinese ? '数据备份' : 'Data Backup', isChinese),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportGeneration(BuildContext context, bool isChinese) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        isChinese ? '生成报告' : 'Generate Report',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildReportOption('用户数据报告', 'User Data Report', isChinese),
                      _buildReportOption('调查问卷报告', 'Survey Report', isChinese),
                      _buildReportOption('反馈分析报告', 'Feedback Report', isChinese),
                      _buildReportOption('照片统计报告', 'Photo Report', isChinese),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoManagement(BuildContext context, bool isChinese) {
    Navigator.pushNamed(context, '/photo_management');
  }

  void _showBatchUploadDialog(BuildContext context, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '批量上传照片' : 'Batch Upload Photos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isChinese ? '选择要上传的照片：' : 'Select photos to upload:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: Text(isChinese ? '拍照' : 'Camera'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showUploadProgress(context, isChinese);
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: Text(isChinese ? '相册' : 'Gallery'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showUploadProgress(context, isChinese);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUploadProgress(BuildContext context, bool isChinese) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '上传中...' : 'Uploading...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(isChinese ? '正在上传照片，请稍候...' : 'Uploading photos, please wait...'),
          ],
        ),
      ),
    );
    
    // 模拟上传进度
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? '照片上传成功！' : 'Photos uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  Widget _buildPhotoStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCategoryChip(String label, String labelEn, bool isSelected, bool isChinese) {
    return FilterChip(
      label: Text(isChinese ? label : labelEn),
      selected: isSelected,
      onSelected: (selected) {
        // 处理分类选择
      },
      selectedColor: AppColors.accent.withOpacity(0.2),
      checkmarkColor: AppColors.accent,
    );
  }

  Widget _buildPhotoItem(String title, String author, String date, bool isApproved, bool isChinese) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 照片缩略图
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.photo, color: AppColors.accent),
            ),
            
            const SizedBox(width: 12),
            
            // 照片信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isChinese ? '上传者：$author' : 'Uploader: $author',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            // 状态和操作按钮
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isApproved ? (isChinese ? '已审核' : 'Approved') : (isChinese ? '待审核' : 'Pending'),
                    style: TextStyle(
                      fontSize: 10,
                      color: isApproved ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 16),
                      onPressed: () {
                        // 预览照片
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () {
                        // 编辑照片信息
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () {
                        // 删除照片
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(String username, String email, String role, bool isChinese, {User? user}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: role == '导游' || role == 'Guide' ? AppColors.primary : AppColors.secondary,
          child: Text(
            username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: role == '导游' || role == 'Guide' ? AppColors.primary : AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: user.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isActive ? (isChinese ? '活跃' : 'Active') : (isChinese ? '禁用' : 'Inactive'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (user != null) ...[
              const SizedBox(height: 4),
              Text(
                '${isChinese ? '注册时间' : 'Registered'}: ${user.createdAt.toString().split(' ')[0]}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(String name, String nameEn, bool isChinese) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on, color: AppColors.accent),
        ),
        title: Text(isChinese ? name : nameEn),
        subtitle: Text(isChinese ? '点击编辑景点信息' : 'Tap to edit spot info'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accent),
              onPressed: () {
                _showSpotEditDialog(name, nameEn, isChinese);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                _showDeleteConfirmDialog(name, nameEn, isChinese);
              },
            ),
          ],
        ),
        onTap: () {
          _showSpotEditDialog(name, nameEn, isChinese);
        },
      ),
    );
  }

  Widget _buildFeedbackCard(String category, String content, int rating, bool isChinese) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool isChinese) {
    return ListTile(
      leading: Icon(icon, color: AppColors.warning),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _handleSettingTap(title, isChinese);
      },
    );
  }

  // 处理设置项点击
  void _handleSettingTap(String title, bool isChinese) {
    if (title.contains('通知') || title.contains('Notifications')) {
      _showNotificationSettings(isChinese);
    } else if (title.contains('语言') || title.contains('Language')) {
      _showLanguageSettings(isChinese);
    } else if (title.contains('安全') || title.contains('Security')) {
      _showSecuritySettings(isChinese);
    } else if (title.contains('备份') || title.contains('Backup')) {
      _showDataBackupSettings(isChinese);
    }
  }

  // 通知设置
  void _showNotificationSettings(bool isChinese) {
    bool pushNotifications = true;
    bool emailNotifications = false;
    bool soundEnabled = true;
    bool vibrationEnabled = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      isChinese ? '通知设置' : 'Notification Settings',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 推送通知
                    SwitchListTile(
                      title: Text(isChinese ? '推送通知' : 'Push Notifications'),
                      subtitle: Text(isChinese ? '接收应用推送消息' : 'Receive app push messages'),
                      value: pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          pushNotifications = value;
                        });
                      },
                    ),

                    // 邮件通知
                    SwitchListTile(
                      title: Text(isChinese ? '邮件通知' : 'Email Notifications'),
                      subtitle: Text(isChinese ? '接收邮件提醒' : 'Receive email alerts'),
                      value: emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          emailNotifications = value;
                        });
                      },
                    ),

                    // 声音提醒
                    SwitchListTile(
                      title: Text(isChinese ? '声音提醒' : 'Sound Alerts'),
                      subtitle: Text(isChinese ? '通知时播放声音' : 'Play sound for notifications'),
                      value: soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          soundEnabled = value;
                        });
                      },
                    ),

                    // 震动提醒
                    SwitchListTile(
                      title: Text(isChinese ? '震动提醒' : 'Vibration'),
                      subtitle: Text(isChinese ? '通知时震动' : 'Vibrate for notifications'),
                      value: vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          vibrationEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isChinese ? '通知设置已保存' : 'Notification settings saved'),
                          ),
                        );
                      },
                      child: Text(isChinese ? '保存设置' : 'Save Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 语言设置
  void _showLanguageSettings(bool isChinese) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    String selectedLanguage = isChinese ? 'zh' : 'en';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      isChinese ? '语言设置' : 'Language Settings',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 中文选项
                    RadioListTile<String>(
                      title: const Text('中文'),
                      subtitle: const Text('简体中文'),
                      value: 'zh',
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),

                    // 英文选项
                    RadioListTile<String>(
                      title: const Text('English'),
                      subtitle: const Text('English'),
                      value: 'en',
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // 实际切换语言
                        final newLocale = selectedLanguage == 'zh' ? AppLocale.zh : AppLocale.en;
                        localeProvider.setLocale(newLocale);

                        Navigator.pop(context);

                        // 显示切换成功提示
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              selectedLanguage == 'zh'
                                ? '语言已切换为中文'
                                : 'Language switched to English'
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: Text(isChinese ? '应用设置' : 'Apply Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 安全设置
  void _showSecuritySettings(bool isChinese) {
    bool biometricEnabled = false;
    bool autoLockEnabled = true;
    String lockTimeout = '5';
    bool dataEncryption = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      isChinese ? '安全设置' : 'Security Settings',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 生物识别
                    SwitchListTile(
                      title: Text(isChinese ? '生物识别' : 'Biometric Authentication'),
                      subtitle: Text(isChinese ? '使用指纹或面部识别' : 'Use fingerprint or face recognition'),
                      value: biometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          biometricEnabled = value;
                        });
                      },
                    ),

                    // 自动锁定
                    SwitchListTile(
                      title: Text(isChinese ? '自动锁定' : 'Auto Lock'),
                      subtitle: Text(isChinese ? '应用进入后台时自动锁定' : 'Lock app when in background'),
                      value: autoLockEnabled,
                      onChanged: (value) {
                        setState(() {
                          autoLockEnabled = value;
                        });
                      },
                    ),

                    // 锁定超时
                    ListTile(
                      title: Text(isChinese ? '锁定超时' : 'Lock Timeout'),
                      subtitle: Text(isChinese ? '自动锁定延迟时间' : 'Auto lock delay time'),
                      trailing: DropdownButton<String>(
                        value: lockTimeout,
                        items: [
                          DropdownMenuItem(value: '1', child: Text(isChinese ? '1分钟' : '1 min')),
                          DropdownMenuItem(value: '5', child: Text(isChinese ? '5分钟' : '5 min')),
                          DropdownMenuItem(value: '10', child: Text(isChinese ? '10分钟' : '10 min')),
                          DropdownMenuItem(value: '30', child: Text(isChinese ? '30分钟' : '30 min')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            lockTimeout = value!;
                          });
                        },
                      ),
                    ),

                    // 数据加密
                    SwitchListTile(
                      title: Text(isChinese ? '数据加密' : 'Data Encryption'),
                      subtitle: Text(isChinese ? '加密本地存储数据' : 'Encrypt local stored data'),
                      value: dataEncryption,
                      onChanged: (value) {
                        setState(() {
                          dataEncryption = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),
                    const Divider(),

                    // 修改密码
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppColors.warning),
                      title: Text(isChinese ? '修改密码' : 'Change Password'),
                      subtitle: Text(isChinese ? '更新登录密码' : 'Update login password'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _showChangePasswordDialog(isChinese);
                      },
                    ),

                    // 清除数据
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: AppColors.error),
                      title: Text(isChinese ? '清除所有数据' : 'Clear All Data'),
                      subtitle: Text(isChinese ? '删除所有本地数据' : 'Delete all local data'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _showClearDataDialog(isChinese);
                      },
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isChinese ? '安全设置已保存' : 'Security settings saved'),
                          ),
                        );
                      },
                      child: Text(isChinese ? '保存设置' : 'Save Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 数据备份设置
  void _showDataBackupSettings(bool isChinese) {
    bool autoBackup = true;
    String backupFrequency = 'daily';
    bool cloudBackup = false;
    String lastBackup = '2024-01-15 14:30';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      isChinese ? '数据备份' : 'Data Backup',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 自动备份
                    SwitchListTile(
                      title: Text(isChinese ? '自动备份' : 'Auto Backup'),
                      subtitle: Text(isChinese ? '定期自动备份数据' : 'Automatically backup data regularly'),
                      value: autoBackup,
                      onChanged: (value) {
                        setState(() {
                          autoBackup = value;
                        });
                      },
                    ),

                    // 备份频率
                    ListTile(
                      title: Text(isChinese ? '备份频率' : 'Backup Frequency'),
                      subtitle: Text(isChinese ? '设置备份间隔' : 'Set backup interval'),
                      trailing: DropdownButton<String>(
                        value: backupFrequency,
                        items: [
                          DropdownMenuItem(value: 'daily', child: Text(isChinese ? '每日' : 'Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text(isChinese ? '每周' : 'Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text(isChinese ? '每月' : 'Monthly')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            backupFrequency = value!;
                          });
                        },
                      ),
                    ),

                    // 云端备份
                    SwitchListTile(
                      title: Text(isChinese ? '云端备份' : 'Cloud Backup'),
                      subtitle: Text(isChinese ? '备份到云端存储' : 'Backup to cloud storage'),
                      value: cloudBackup,
                      onChanged: (value) {
                        setState(() {
                          cloudBackup = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),
                    const Divider(),

                    // 最后备份时间
                    ListTile(
                      leading: const Icon(Icons.schedule, color: AppColors.info),
                      title: Text(isChinese ? '最后备份' : 'Last Backup'),
                      subtitle: Text(lastBackup),
                    ),

                    const SizedBox(height: 10),

                    // 立即备份
                    ElevatedButton.icon(
                      onPressed: () {
                        _performBackup(isChinese);
                      },
                      icon: const Icon(Icons.backup),
                      label: Text(isChinese ? '立即备份' : 'Backup Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 恢复数据
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRestoreDialog(isChinese);
                      },
                      icon: const Icon(Icons.restore),
                      label: Text(isChinese ? '恢复数据' : 'Restore Data'),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isChinese ? '备份设置已保存' : 'Backup settings saved'),
                          ),
                        );
                      },
                      child: Text(isChinese ? '保存设置' : 'Save Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 修改密码对话框
  void _showChangePasswordDialog(bool isChinese) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '修改密码' : 'Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isChinese ? '当前密码' : 'Current Password',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isChinese ? '新密码' : 'New Password',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isChinese ? '确认新密码' : 'Confirm New Password',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isChinese ? '密码修改成功' : 'Password changed successfully'),
                ),
              );
            },
            child: Text(isChinese ? '确认' : 'Confirm'),
          ),
        ],
      ),
    );
  }

  // 清除数据确认对话框
  void _showClearDataDialog(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '清除所有数据' : 'Clear All Data'),
        content: Text(
          isChinese
            ? '此操作将删除所有本地数据，包括照片、行程、设置等。此操作不可撤销，确定要继续吗？'
            : 'This will delete all local data including photos, trips, settings, etc. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isChinese ? '所有数据已清除' : 'All data cleared'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(isChinese ? '确认清除' : 'Confirm Clear'),
          ),
        ],
      ),
    );
  }

  // 执行备份
  void _performBackup(bool isChinese) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(isChinese ? '正在备份数据...' : 'Backing up data...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // 关闭加载对话框
      Navigator.pop(context); // 关闭备份设置

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? '数据备份完成' : 'Data backup completed'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  // 恢复数据对话框
  void _showRestoreDialog(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '恢复数据' : 'Restore Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: Text(isChinese ? '从云端恢复' : 'Restore from Cloud'),
              subtitle: Text(isChinese ? '2024-01-15 14:30' : '2024-01-15 14:30'),
              onTap: () {
                Navigator.pop(context);
                _performRestore(isChinese, 'cloud');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: Text(isChinese ? '从本地文件恢复' : 'Restore from Local File'),
              subtitle: Text(isChinese ? '选择备份文件' : 'Select backup file'),
              onTap: () {
                Navigator.pop(context);
                _performRestore(isChinese, 'local');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  // 执行恢复
  void _performRestore(bool isChinese, String source) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(isChinese ? '正在恢复数据...' : 'Restoring data...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChinese
              ? '数据恢复完成，请重启应用'
              : 'Data restore completed, please restart app'
          ),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  // 显示景点编辑对话框
  void _showSpotEditDialog(String name, String nameEn, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '编辑景点信息' : 'Edit Spot Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: isChinese ? '中文名称' : 'Chinese Name',
                hintText: name,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: isChinese ? '英文名称' : 'English Name',
                hintText: nameEn,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isChinese ? '景点信息已更新' : 'Spot info updated'),
                ),
              );
            },
            child: Text(isChinese ? '保存' : 'Save'),
          ),
        ],
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(String name, String nameEn, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '确认删除' : 'Confirm Delete'),
        content: Text(
          isChinese
            ? '确定要删除景点"$name"吗？此操作不可撤销。'
            : 'Are you sure you want to delete "$nameEn"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isChinese ? '景点已删除' : 'Spot deleted'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(isChinese ? '删除' : 'Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String title, String titleEn, bool isChinese) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: AppColors.info),
        ),
        title: Text(isChinese ? title : titleEn),
        subtitle: Text(isChinese ? '点击生成报告' : 'Click to generate report'),
        trailing: const Icon(Icons.download),
        onTap: () {
          _generateReport(title, titleEn, isChinese);
        },
      ),
    );
  }

  // 生成报告
  void _generateReport(String title, String titleEn, bool isChinese) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(isChinese ? '正在生成报告...' : 'Generating report...'),
          ],
        ),
      ),
    );

    // 模拟报告生成过程
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // 关闭加载对话框

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isChinese ? '报告生成完成' : 'Report Generated'),
          content: Text(
            isChinese
              ? '报告"${title}"已生成完成，已保存到下载文件夹。'
              : 'Report "$titleEn" has been generated and saved to downloads folder.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isChinese ? '确定' : 'OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isChinese ? '报告已打开' : 'Report opened'),
                  ),
                );
              },
              child: Text(isChinese ? '打开报告' : 'Open Report'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// 在文件末尾添加可拖动悬浮球组件
class _DraggableAIBall extends StatefulWidget {
  @override
  State<_DraggableAIBall> createState() => _DraggableAIBallState();
}

class _DraggableAIBallState extends State<_DraggableAIBall> {
  Offset position = const Offset(0, 0);
  late double screenWidth;
  late double screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    if (position == Offset.zero) {
      // 初始放在右下角
      position = Offset(screenWidth - 80, screenHeight - 180);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _buildBall(),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            double x = details.offset.dx;
            double y = details.offset.dy;
            // 限制在屏幕范围内
            x = x.clamp(0, screenWidth - 60);
            y = y.clamp(0, screenHeight - 60);
            position = Offset(x, y);
          });
        },
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                insetPadding: const EdgeInsets.all(16),
                backgroundColor: Colors.transparent,
                child: SizedBox(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      child: AIAssistantScreen(),
                    ),
                  ),
                ),
              ),
            );
          },
          child: _buildBall(),
        ),
      ),
    );
  }

  Widget _buildBall() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 30,
      ),
    );
  }
} 