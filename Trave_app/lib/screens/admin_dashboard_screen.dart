import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/admin_service.dart';
import '../services/user_service.dart';
import '../models/survey_stats.dart';
import '../models/feedback_stats.dart';
import '../models/user.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../utils/api_host.dart';
import '../widgets/user_avatar.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late Future<SurveyStats> surveyFuture;
  late Future<FeedbackStats> feedbackFuture;
  late Future<Map<String, dynamic>> photoStatsFuture;
  late Future<UserStats> userStatsFuture;
  late TabController _tabController;
  Timer? _refreshTimer;

  // 统计数据
  int totalSubmissions = 0;
  int totalPhotos = 0;
  int pendingPhotos = 0;
  double averageRating = 0.0;
  int totalUsers = 0;
  int recentUsers = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAllData();

    // 每30秒自动刷新数据
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadAllData() {
    setState(() {
      surveyFuture = AdminService.fetchSurveyStats();
      feedbackFuture = AdminService.fetchFeedbackStats();
      photoStatsFuture = _fetchPhotoStats();
      userStatsFuture = UserService.fetchUserStats();
    });
    _updateSummaryStats();
  }

  void _refreshData() {
    if (mounted) {
      _loadAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('数据已刷新'),
          duration: Duration(seconds: 1),
          backgroundColor: kPrimaryColor,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchPhotoStats() async {
    try {
      final response = await http.get(Uri.parse(getApiBaseUrl(path: '/api/photos/stats')));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('获取照片统计失败: $e');
    }
    return {'success': false};
  }

  Future<void> _updateSummaryStats() async {
    try {
      // 获取问卷提交总数
      final surveyResponse = await http.get(Uri.parse(getApiBaseUrl(path: '/api/survey/stats')));
      if (surveyResponse.statusCode == 200) {
        final surveyData = json.decode(surveyResponse.body);
        int total = 0;
        surveyData['interest']?.values?.forEach((count) => total += count as int);
        setState(() {
          totalSubmissions = total;
        });
      }

      // 获取照片统计
      final photoStats = await _fetchPhotoStats();
      if (photoStats['success'] == true) {
        setState(() {
          totalPhotos = photoStats['stats']['total'] ?? 0;
          pendingPhotos = photoStats['stats']['pending'] ?? 0;
        });
      }

      // 计算平均评分
      final feedbackData = await AdminService.fetchFeedbackStats();
      double totalScore = 0;
      int totalRatings = 0;
      feedbackData.ratings.forEach((rating, count) {
        totalScore += rating * count;
        totalRatings += count;
      });
      setState(() {
        averageRating = totalRatings > 0 ? totalScore / totalRatings : 0.0;
      });

      // 获取用户统计
      final userStats = await UserService.fetchUserStats();
      setState(() {
        totalUsers = userStats.total;
        recentUsers = userStats.recentRegistrations;
      });
    } catch (e) {
      print('更新统计数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;

    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '导游后台管理' : 'Guide Dashboard', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '刷新数据',
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
            tooltip: '通知',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: isChinese ? '概览' : 'Overview'),
            Tab(icon: Icon(Icons.poll), text: isChinese ? '问卷' : 'Surveys'),
            Tab(icon: Icon(Icons.photo_library), text: isChinese ? '照片' : 'Photos'),
            Tab(icon: Icon(Icons.star), text: isChinese ? '评价' : 'Reviews'),
            Tab(icon: Icon(Icons.people), text: isChinese ? '用户' : 'Users'),
            Tab(icon: Icon(Icons.lock_reset), text: isChinese ? '重置请求' : 'Reset Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSurveyTab(),
          _buildPhotoTab(),
          _buildFeedbackTab(),
          _buildUserTab(),
          _buildResetRequestsTab(),
        ],
      ),
    );
  }

  // 概览页面
  Widget _buildOverviewTab() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 关键指标卡片
          _buildMetricsCards(),
          SizedBox(height: 20),

          // 今日活动概览
          _buildTodayActivity(),
          SizedBox(height: 20),

          // 快速操作
          _buildQuickActions(),
        ],
      ),
    );
  }

  // 关键指标卡片
  Widget _buildMetricsCards() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: isChinese ? '问卷提交' : 'Survey Submissions',
                value: totalSubmissions.toString(),
                icon: Icons.assignment,
                color: kPrimaryColor,
                subtitle: isChinese ? '总提交数' : 'Total Submissions',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: isChinese ? '照片总数' : 'Total Photos',
                value: totalPhotos.toString(),
                icon: Icons.photo_library,
                color: kSecondaryColor,
                subtitle: isChinese ? '待审核: $pendingPhotos' : 'Pending: $pendingPhotos',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: isChinese ? '平均评分' : 'Average Rating',
                value: averageRating.toStringAsFixed(1),
                icon: Icons.star,
                color: Colors.amber,
                subtitle: isChinese ? '服务质量' : 'Service Quality',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: isChinese ? '注册用户' : 'Registered Users',
                value: totalUsers.toString(),
                icon: Icons.people,
                color: kSuccessColor,
                subtitle: isChinese ? '新增: $recentUsers' : 'New: $recentUsers',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
      color: kCardBackground,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusCard),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: kShadowLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 今日活动概览
  Widget _buildTodayActivity() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
      color: kCardBackground,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: kPrimaryColor),
                SizedBox(width: 8),
                Text(
                  isChinese ? '今日活动概览' : 'Today\'s Activity Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActivityItem(
                    icon: Icons.assignment_turned_in,
                    label: isChinese ? '新问卷' : 'New Surveys',
                    value: '2',
                    color: kSuccessColor,
                  ),
                ),
                Expanded(
                  child: _buildActivityItem(
                    icon: Icons.photo_camera,
                    label: isChinese ? '新照片' : 'New Photos',
                    value: '5',
                    color: kInfoColor,
                  ),
                ),
                Expanded(
                  child: _buildActivityItem(
                    icon: Icons.star_rate,
                    label: isChinese ? '新评价' : 'New Reviews',
                    value: '3',
                    color: kWarningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }

  // 快速操作
  Widget _buildQuickActions() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
      color: kCardBackground,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: kPrimaryColor),
                SizedBox(width: 8),
                Text(
                  isChinese ? '快速操作' : 'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.photo_library,
                    label: isChinese ? '审核照片' : 'Review Photos',
                    onTap: () => _tabController.animateTo(2),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.download,
                    label: isChinese ? '导出数据' : 'Export Data',
                    onTap: () => _exportData(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.settings,
                    label: isChinese ? '系统设置' : 'System Settings',
                    onTap: () => _showSettings(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: kBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryColor, size: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 问卷统计页面
  Widget _buildSurveyTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 兴趣分布
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
            color: kCardBackground,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: kPrimaryColor),
                      SizedBox(width: 8),
                      Text('兴趣分布', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<SurveyStats>(
                    future: surveyFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      if (data.interest.isEmpty) {
                        return Center(
                          child: Text('暂无数据', style: TextStyle(color: kTextSecondary)),
                        );
                      }
                      return Column(
                        children: data.interest.entries.map((e) =>
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.interests, color: Colors.white, size: 16),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${e.value}人',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 饮食偏好分布
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
            color: kCardBackground,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: kSecondaryColor),
                      SizedBox(width: 8),
                      Text('饮食偏好', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<SurveyStats>(
                    future: surveyFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      if (data.diets.isEmpty) {
                        return Center(
                          child: Text('暂无数据', style: TextStyle(color: kTextSecondary)),
                        );
                      }
                      return Column(
                        children: data.diets.entries.map((e) =>
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kSecondaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kSecondaryColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: kSecondaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.restaurant_menu, color: Colors.white, size: 16),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kSecondaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${e.value}人',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 照片管理页面
  Widget _buildPhotoTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 照片统计卡片
          FutureBuilder<Map<String, dynamic>>(
            future: photoStatsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!['success'] != true) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('照片统计加载中...')),
                  ),
                );
              }

              final stats = snapshot.data!['stats'];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
                color: kCardBackground,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo_library, color: kPrimaryColor),
                          SizedBox(width: 8),
                          Text('照片统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPhotoStatItem(
                              label: '总数',
                              value: stats['total'].toString(),
                              color: kInfoColor,
                              icon: Icons.photo,
                            ),
                          ),
                          Expanded(
                            child: _buildPhotoStatItem(
                              label: '待审核',
                              value: stats['pending'].toString(),
                              color: kWarningColor,
                              icon: Icons.pending,
                            ),
                          ),
                          Expanded(
                            child: _buildPhotoStatItem(
                              label: '已通过',
                              value: stats['approved'].toString(),
                              color: kSuccessColor,
                              icon: Icons.check_circle,
                            ),
                          ),
                          Expanded(
                            child: _buildPhotoStatItem(
                              label: '已拒绝',
                              value: stats['rejected'].toString(),
                              color: kDangerColor,
                              icon: Icons.cancel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // 按景点统计
          FutureBuilder<Map<String, dynamic>>(
            future: photoStatsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!['success'] != true) {
                return SizedBox.shrink();
              }

              final bySpot = snapshot.data!['stats']['bySpot'] as Map<String, dynamic>;
              if (bySpot.isEmpty) return SizedBox.shrink();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
                color: kCardBackground,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: kSecondaryColor),
                          SizedBox(width: 8),
                          Text('按景点统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      ...bySpot.entries.map((e) =>
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kSecondaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kSecondaryColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.place, color: kSecondaryColor, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kSecondaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${e.value}张',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }

  // 评价反馈页面
  Widget _buildFeedbackTab() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 评价管理标题
          Row(
            children: [
              Icon(Icons.feedback, color: kPrimaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                isChinese ? '评价管理' : 'Feedback Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),

          // 服务评分分布
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
            color: kCardBackground,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(isChinese ? '服务评分分布' : 'Service Rating Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<FeedbackStats>(
                    future: feedbackFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      
                      if (data.ratings.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(isChinese ? '暂无评分数据' : 'No rating data', style: TextStyle(color: kTextSecondary)),
                          ),
                        );
                      }
                      
                      final total = data.ratings.values.reduce((a, b) => a + b);

                      return Column(
                        children: data.ratings.entries.map((e) =>
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  child: Row(
                                    children: [
                                      Text('${e.key}'),
                                      Icon(Icons.star, color: Colors.amber, size: 16),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: kBorderColor,
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: e.value / total,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  width: 40,
                                  child: Text(
                                    '${e.value}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 待处理评价列表
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
            color: kCardBackground,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending_actions, color: kWarningColor),
                      SizedBox(width: 8),
                      Text(isChinese ? '待处理评价' : 'Pending Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchPendingFeedbacks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            isChinese ? '加载失败' : 'Load failed',
                            style: TextStyle(color: kDangerColor),
                          ),
                        );
                      }

                      final feedbacks = snapshot.data!;
                      
                      if (feedbacks.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              isChinese ? '暂无待处理评价' : 'No pending feedback',
                              style: TextStyle(color: kTextSecondary),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: feedbacks.map((feedback) => _buildFeedbackCard(feedback, isChinese)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 最新评论
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
            color: kCardBackground,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.comment, color: kPrimaryColor),
                      SizedBox(width: 8),
                      Text(isChinese ? '最新评论' : 'Latest Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<FeedbackStats>(
                    future: feedbackFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      if (data.comments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(isChinese ? '暂无评论' : 'No comments', style: TextStyle(color: kTextSecondary)),
                          ),
                        );
                      }
                      return Column(
                        children: data.comments.map((c) =>
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kBorderColor),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 用户头像 - 支持网络图片
                                UserAvatar(
                                  username: c.user,
                                  radius: 16,
                                  backgroundColor: kPrimaryColor,
                                  textColor: Colors.white,
                                  fontSize: 12,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            c.user,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          Row(
                                            children: List.generate(5, (index) =>
                                              Icon(
                                                Icons.star,
                                                size: 14,
                                                color: index < c.score ? Colors.amber : kTextSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        c.content,
                                        style: TextStyle(color: kTextPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示通知
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: kPrimaryColor),
            SizedBox(width: 8),
            Text('系统通知'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: kWarningColor),
              title: Text('有 $pendingPhotos 张照片待审核'),
              subtitle: Text('请及时处理用户上传的照片'),
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: kSuccessColor),
              title: Text('今日新增 2 份问卷'),
              subtitle: Text('用户参与度良好'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('知道了'),
          ),
        ],
      ),
    );
  }

  // 导出数据
  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('数据导出功能开发中...'),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  // 显示设置
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: kPrimaryColor),
            SizedBox(width: 8),
            Text('系统设置'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('自动刷新'),
              subtitle: Text('每30秒自动更新数据'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('推送通知'),
              subtitle: Text('接收重要事件通知'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 用户管理页面
  Widget _buildUserTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 用户统计卡片
          FutureBuilder<UserStats>(
            future: userStatsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('加载用户统计失败: ${snapshot.error}'),
                  ),
                );
              }

              final stats = snapshot.data!;
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, color: kPrimaryColor),
                          SizedBox(width: 8),
                          Text(
                            '用户统计',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUserStatItem('总用户数', stats.total.toString(), Icons.group),
                          ),
                          Expanded(
                            child: _buildUserStatItem('活跃用户', stats.active.toString(), Icons.person),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUserStatItem('游客', stats.tourists.toString(), Icons.tour),
                          ),
                          Expanded(
                            child: _buildUserStatItem('导游', stats.guides.toString(), Icons.badge),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildUserStatItem('近期注册', stats.recentRegistrations.toString(), Icons.new_releases),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // 用户列表
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.list, color: kPrimaryColor),
                      SizedBox(width: 8),
                      Text(
                        '用户列表',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<List<User>>(
                    future: UserService.fetchUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('加载用户列表失败: ${snapshot.error}');
                      }

                      final users = snapshot.data!;
                      if (users.isEmpty) {
                        return Text('暂无用户数据');
                      }

                      return Column(
                        children: users.map((user) => _buildUserListItem(user)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryColor, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          UserAvatar(
            username: user.username,
            radius: 25,
            backgroundColor: user.role == UserRole.guide ? kPrimaryColor : kSecondaryColor,
            textColor: Colors.white,
            fontSize: 16,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '注册时间: ${user.createdAt.toString().split(' ')[0]}',
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Chip(
                label: Text(
                  user.role == UserRole.guide ? '导游' : '游客',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: user.role == UserRole.guide ? kPrimaryColor : kSecondaryColor,
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: user.isActive ? kSuccessColor : kDangerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? '活跃' : '禁用',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 重置请求标签页
  Widget _buildResetRequestsTab() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchResetRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: kDangerColor),
                  SizedBox(height: 16),
                  Text(
                    isChinese ? '加载重置请求失败' : 'Failed to load reset requests',
                    style: TextStyle(fontSize: 18, color: kDangerColor),
                  ),
                  SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: kSuccessColor),
                  SizedBox(height: 16),
                  Text(
                    isChinese ? '暂无重置请求' : 'No reset requests',
                    style: TextStyle(fontSize: 18, color: kSuccessColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    isChinese ? '所有用户都能正常登录' : 'All users can login normally',
                    style: TextStyle(color: kTextSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildResetRequestCard(request, isChinese);
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchResetRequests() async {
    try {
      final response = await http.get(
        Uri.parse(getApiBaseUrl(path: '/api/auth/reset-requests')),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['requests']);
        }
      }
      return [];
    } catch (e) {
      print('获取重置请求失败: $e');
      return [];
    }
  }

  Future<User?> _fetchUserByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse(getApiBaseUrl(path: '/api/users')),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final users = List<Map<String, dynamic>>.from(data['users']);
          final userData = users.firstWhere(
            (user) => user['email'] == email,
            orElse: () => <String, dynamic>{},
          );
          
          if (userData.isNotEmpty) {
            return User.fromJson(userData);
          }
        }
      }
      return null;
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }

  Future<User?> _fetchUserByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse(getApiBaseUrl(path: '/api/users')),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final users = List<Map<String, dynamic>>.from(data['users']);
          final userData = users.firstWhere(
            (user) => user['username'] == username,
            orElse: () => <String, dynamic>{},
          );
          
          if (userData.isNotEmpty) {
            return User.fromJson(userData);
          }
        }
      }
      return null;
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }



  Future<List<Map<String, dynamic>>> _fetchPendingFeedbacks() async {
    try {
      final response = await http.get(
        Uri.parse(getApiBaseUrl(path: '/api/feedback/list?status=pending')),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['feedbacks']);
        }
      }
      return [];
    } catch (e) {
      print('获取待处理评价失败: $e');
      return [];
    }
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback, bool isChinese) {
    final submittedAt = DateTime.parse(feedback['submittedAt']);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 用户头像 - 支持网络图片
                UserAvatar(
                  username: feedback['username'],
                  radius: 20,
                  backgroundColor: kPrimaryColor,
                  textColor: Colors.white,
                  fontSize: 14,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback['username'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${isChinese ? '提交时间' : 'Submitted'}: ${submittedAt.toString().split('.')[0]}',
                        style: TextStyle(color: kTextSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) =>
                    Icon(
                      Icons.star,
                      size: 16,
                      color: index < feedback['rating'] ? Colors.amber : kTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              feedback['content'],
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showProcessFeedbackDialog(feedback, isChinese),
                    icon: Icon(Icons.check),
                    label: Text(isChinese ? '处理评价' : 'Process'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectFeedback(feedback['id'], isChinese),
                    icon: Icon(Icons.close),
                    label: Text(isChinese ? '拒绝' : 'Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kDangerColor,
                      side: BorderSide(color: kDangerColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProcessFeedbackDialog(Map<String, dynamic> feedback, bool isChinese) {
    final rewardController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kBackgroundColor,
                        kInfoColor.withOpacity(0.08),
                      ],
                    ),
                    boxShadow: kShadowLight,
                  ),
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusCard),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(kRadiusCard),
                          ),
                          child: Icon(
                            Icons.card_giftcard,
                            color: kPrimaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isChinese ? '🎁 奖励设置' : '🎁 Reward Settings',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 用户信息卡片
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kInfoColor.withOpacity(0.08), kPurpleColor.withOpacity(0.08)],
                              ),
                              borderRadius: BorderRadius.circular(kRadiusCard),
                              border: Border.all(color: kInfoColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                // 用户头像 - 支持网络图片
                                UserAvatar(
                                  username: feedback['username'],
                                  radius: 20,
                                  backgroundColor: kPrimaryColor,
                                  textColor: Colors.white,
                                  fontSize: 14,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        feedback['username'],
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          ...List.generate(5, (index) =>
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: index < feedback['rating'] ? Colors.amber : kTextSecondary,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '${feedback['rating']}/5',
                                            style: TextStyle(color: kTextSecondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          
                          // 奖励输入框
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kRadiusCard),
                              boxShadow: kShadowLight,
                            ),
                            child: TextField(
                              controller: rewardController,
                              decoration: InputDecoration(
                                labelText: isChinese ? '🎁 奖励内容' : '🎁 Reward Content',
                                hintText: isChinese ? '例如：免费门票、优惠券、纪念品等' : 'e.g. Free ticket, discount coupon, souvenir',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kRadiusCard),
                                  borderSide: BorderSide(color: kInfoColor.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kRadiusCard),
                                  borderSide: BorderSide(color: kPrimaryColor, width: 2),
                                ),
                                filled: true,
                                fillColor: kBackgroundColor,
                                prefixIcon: Icon(Icons.card_giftcard, color: kPrimaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // 消息输入框
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kRadiusCard),
                              boxShadow: kShadowLight,
                            ),
                            child: TextField(
                              controller: messageController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: isChinese ? '💬 回复消息' : '💬 Reply Message',
                                hintText: isChinese ? '给用户的感谢或鼓励话语' : 'Thank you message or encouragement',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kRadiusCard),
                                  borderSide: BorderSide(color: kSuccessColor.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(kRadiusCard),
                                  borderSide: BorderSide(color: kSuccessColor, width: 2),
                                ),
                                filled: true,
                                fillColor: kBackgroundColor,
                                prefixIcon: Icon(Icons.message, color: kSuccessColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Container(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(kRadiusCard),
                                  ),
                                  side: BorderSide(color: kTextSecondary),
                                ),
                                child: Text(
                                  isChinese ? '取消' : 'Cancel',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await Future.delayed(Duration(milliseconds: 200));
                                  try {
                                    await _processFeedback(
                                      feedback['id'],
                                      'approve',
                                      rewardController.text.trim(),
                                      messageController.text.trim(),
                                      isChinese,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: kDangerColor,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(kRadiusCard),
                                  ),
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      isChinese ? '批准奖励' : 'Approve',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _processFeedback(String feedbackId, String action, String reward, String message, bool isChinese) async {
    try {
      final response = await http.post(
        Uri.parse(getApiBaseUrl(path: '/api/feedback/$feedbackId/process')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': action,
          'reward': reward.isNotEmpty ? reward : null,
          'message': message.isNotEmpty ? message : null,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        // 显示炫酷的成功动画
        if (action == 'approve' && reward.isNotEmpty) {
          _showSuccessAnimation(isChinese);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: kSuccessColor,
            ),
          );
        }
        // 刷新数据
        setState(() {});
      } else {
        throw Exception(data['message'] ?? '处理失败');
      }
    } catch (e) {
      throw Exception('处理评价失败: $e');
    }
  }

  void _showSuccessAnimation(bool isChinese) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                color: kBackgroundColor.withOpacity(0.3),
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kSuccessColor.withOpacity(0.4),
                          kSuccessColor.withOpacity(0.6),
                          kSuccessColor.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: kShadowMedium,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 外圈动画
                        TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, ringValue, child) {
                            return Transform.scale(
                              scale: 1.0 + (0.2 * ringValue),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity((0.8 - ringValue).clamp(0.0, 1.0)),
                                    width: 3,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // 内圈动画
                        TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, innerValue, child) {
                            return Transform.scale(
                              scale: innerValue,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 50,
                                  color: kSuccessColor.withOpacity(0.6),
                                ),
                              ),
                            );
                          },
                        ),
                        // 文字动画
                        Positioned(
                          bottom: -70,
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, textValue, child) {
                              return Opacity(
                                opacity: textValue.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(0, 15 * (1 - textValue)),
                                  child: Text(
                                    isChinese ? '🎉 奖励已发放！' : '🎉 Reward Sent!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          onEnd: () {
            // 动画结束后自动关闭
            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(isChinese ? '奖励发放成功！' : 'Reward sent successfully!'),
                    ],
                  ),
                  backgroundColor: kSuccessColor,
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadiusCard),
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  Future<void> _rejectFeedback(String feedbackId, bool isChinese) async {
    try {
      await _processFeedback(feedbackId, 'reject', '', '', isChinese);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: kDangerColor,
        ),
      );
    }
  }

  Widget _buildResetRequestCard(Map<String, dynamic> request, bool isChinese) {
    final createdAt = DateTime.parse(request['createdAt']);
    final expiresAt = DateTime.parse(request['expiresAt']);
    final isExpired = DateTime.now().isAfter(expiresAt);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isExpired ? Icons.schedule : Icons.lock_reset,
                  color: isExpired ? kWarningColor : kPrimaryColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isChinese ? '重置请求' : 'Reset Request',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isExpired)
                  Chip(
                    label: Text(
                      isChinese ? '已过期' : 'Expired',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: kWarningColor,
                  ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                // 用户头像
                FutureBuilder<User?>(
                  future: _fetchUserByEmail(request['email']),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return UserAvatar(
                        username: snapshot.data!.username,
                        radius: 20,
                        backgroundColor: kPrimaryColor,
                        textColor: Colors.white,
                        fontSize: 14,
                      );
                    }
                    return UserAvatar(
                      radius: 20,
                      backgroundColor: kPrimaryColor,
                      textColor: Colors.white,
                      fontSize: 14,
                    );
                  },
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<User?>(
                        future: _fetchUserByEmail(request['email']),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Text(
                              '用户: ${snapshot.data!.username}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            );
                          }
                          return Text(
                            '${isChinese ? '邮箱' : 'Email'}: ${request['email']}',
                            style: TextStyle(fontSize: 16),
                          );
                        },
                      ),
                      Text(
                        '${isChinese ? '邮箱' : 'Email'}: ${request['email']}',
                        style: TextStyle(fontSize: 14, color: kTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${isChinese ? '请求时间' : 'Request Time'}: ${createdAt.toString().split('.')[0]}',
              style: TextStyle(color: kTextSecondary),
            ),
            SizedBox(height: 8),
            Text(
              '${isChinese ? '过期时间' : 'Expires At'}: ${expiresAt.toString().split('.')[0]}',
              style: TextStyle(color: kTextSecondary),
            ),
            SizedBox(height: 16),
            if (!isExpired) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showProcessResetDialog(request, isChinese),
                      icon: Icon(Icons.check),
                      label: Text(isChinese ? '处理请求' : 'Process'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectResetRequest(request['id'], isChinese),
                      icon: Icon(Icons.close),
                      label: Text(isChinese ? '拒绝' : 'Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kDangerColor,
                        side: BorderSide(color: kDangerColor),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                isChinese ? '此请求已过期，无法处理' : 'This request has expired and cannot be processed',
                style: TextStyle(color: kWarningColor, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showProcessResetDialog(Map<String, dynamic> request, bool isChinese) {
    final newUsernameController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool _obscurePassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isChinese ? '处理重置请求' : 'Process Reset Request'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isChinese ? '为用户设置新的账户信息：' : 'Set new account info for user:'}',
                      style: TextStyle(color: kTextSecondary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${isChinese ? '邮箱' : 'Email'}: ${request['email']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: newUsernameController,
                      decoration: InputDecoration(
                        labelText: isChinese ? '新用户名' : 'New Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: newPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: isChinese ? '新密码' : 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isChinese ? '取消' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newUsernameController.text.isEmpty || newPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isChinese ? '请填写完整信息' : 'Please fill in all fields'),
                          backgroundColor: kDangerColor,
                        ),
                      );
                      return;
                    }

                    try {
                      await _processResetRequest(
                        request['id'],
                        newUsernameController.text.trim(),
                        newPasswordController.text,
                        'approve',
                        isChinese,
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: kDangerColor,
                        ),
                      );
                    }
                  },
                  child: Text(isChinese ? '确认重置' : 'Confirm Reset'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processResetRequest(String requestId, String newUsername, String newPassword, String action, bool isChinese) async {
    try {
      final response = await http.post(
        Uri.parse(getApiBaseUrl(path: '/api/auth/process-reset')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
          'newUsername': newUsername,
          'newPassword': newPassword,
          'action': action,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: kSuccessColor,
          ),
        );
        // 刷新数据
        setState(() {});
      } else {
        throw Exception(data['message'] ?? '处理失败');
      }
    } catch (e) {
      throw Exception('处理重置请求失败: $e');
    }
  }

  Future<void> _rejectResetRequest(String requestId, bool isChinese) async {
    try {
      await _processResetRequest(requestId, '', '', 'reject', isChinese);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: kDangerColor,
        ),
      );
    }
  }
}