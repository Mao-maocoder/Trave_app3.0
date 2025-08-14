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
    _tabController = TabController(length: 5, vsync: this);
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
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchPhotoStats() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/photos/stats'));
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
      final surveyResponse = await http.get(Uri.parse('http://localhost:3000/api/survey/stats'));
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
        title: Text(isChinese ? '导游后台管理' : 'Guide Dashboard'),
        backgroundColor: AppColors.primary,
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
                color: AppColors.primary,
                subtitle: isChinese ? '总提交数' : 'Total Submissions',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: isChinese ? '照片总数' : 'Total Photos',
                value: totalPhotos.toString(),
                icon: Icons.photo_library,
                color: AppColors.secondary,
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
                color: Colors.green,
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                      color: Colors.grey[600],
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
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: AppColors.primary),
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
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildActivityItem(
                    icon: Icons.photo_camera,
                    label: isChinese ? '新照片' : 'New Photos',
                    value: '5',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildActivityItem(
                    icon: Icons.star_rate,
                    label: isChinese ? '新评价' : 'New Reviews',
                    value: '3',
                    color: Colors.orange,
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 快速操作
  Widget _buildQuickActions() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.primary),
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
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
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
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: AppColors.primary),
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
                          child: Text('暂无数据', style: TextStyle(color: Colors.grey[600])),
                        );
                      }
                      return Column(
                        children: data.interest.entries.map((e) =>
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
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
                                    color: AppColors.primary,
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
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: AppColors.secondary),
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
                          child: Text('暂无数据', style: TextStyle(color: Colors.grey[600])),
                        );
                      }
                      return Column(
                        children: data.diets.entries.map((e) =>
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
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
                                    color: AppColors.secondary,
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
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo_library, color: AppColors.primary),
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
                              color: Colors.blue,
                              icon: Icons.photo,
                            ),
                          ),
                          Expanded(
                            child: _buildPhotoStatItem(
                              label: '待审核',
                              value: stats['pending'].toString(),
                              color: Colors.orange,
                              icon: Icons.pending,
                            ),
                          ),
                          Expanded(
                            child: _buildPhotoStatItem(
                              label: '已通过',
                              value: stats['approved'].toString(),
                              color: Colors.green,
                              icon: Icons.check_circle,
                            ),
                          ),
                          Expanded(
                            child: _buildPhotoStatItem(
                              label: '已拒绝',
                              value: stats['rejected'].toString(),
                              color: Colors.red,
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
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.secondary),
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
                            color: AppColors.secondary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.place, color: AppColors.secondary, size: 20),
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
                                  color: AppColors.secondary,
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 评价反馈页面
  Widget _buildFeedbackTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 服务评分分布
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('服务评分分布', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<FeedbackStats>(
                    future: feedbackFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
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
                                      color: Colors.grey[300],
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

          // 最新评论
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.comment, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('最新评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            child: Text('暂无评论', style: TextStyle(color: Colors.grey[600])),
                          ),
                        );
                      }
                      return Column(
                        children: data.comments.map((c) =>
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    c.user[0],
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
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
                                                color: index < c.score ? Colors.amber : Colors.grey[300],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        c.content,
                                        style: TextStyle(color: Colors.grey[700]),
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
            Icon(Icons.notifications, color: AppColors.primary),
            SizedBox(width: 8),
            Text('系统通知'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.orange),
              title: Text('有 $pendingPhotos 张照片待审核'),
              subtitle: Text('请及时处理用户上传的照片'),
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Colors.green),
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
        backgroundColor: AppColors.primary,
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
            Icon(Icons.settings, color: AppColors.primary),
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
                          Icon(Icons.people, color: AppColors.primary),
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
                      Icon(Icons.list, color: AppColors.primary),
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
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: user.role == UserRole.guide ? AppColors.primary : AppColors.secondary,
            child: Text(
              user.username[0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  '注册时间: ${user.createdAt.toString().split(' ')[0]}',
                  style: TextStyle(
                    color: Colors.grey[500],
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
                backgroundColor: user.role == UserRole.guide ? AppColors.primary : AppColors.secondary,
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green : Colors.red,
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
}