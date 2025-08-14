import 'package:flutter/material.dart';
import '../models/survey_stats.dart';
import '../models/feedback_stats.dart';
import '../services/admin_service.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/performance_config.dart';

class DataVisualizationScreen extends StatefulWidget {
  const DataVisualizationScreen({Key? key}) : super(key: key);

  @override
  State<DataVisualizationScreen> createState() => _DataVisualizationScreenState();
}

class _DataVisualizationScreenState extends State<DataVisualizationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  SurveyStats? _surveyStats;
  FeedbackStats? _feedbackStats;
  bool _isLoading = true;
  String? _error;
  
  // 优化动画控制器数量
  late AnimationController _mainController;
  late AnimationController _barController;
  
  // 动画
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 根据性能模式调整动画控制器
    _mainController = AnimationController(
      duration: PerformanceConfig.mediumAnimation,
      vsync: this,
    );
    _barController = AnimationController(
      duration: PerformanceConfig.longAnimation,
      vsync: this,
    );
    
    // 初始化动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));
    
    _barAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainController.dispose();
    _barController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final surveyStats = await AdminService.fetchSurveyStats();
      final feedbackStats = await AdminService.fetchFeedbackStats();
      
      setState(() {
        _surveyStats = surveyStats;
        _feedbackStats = feedbackStats;
        _isLoading = false;
      });
      
      // 数据加载完成后启动动画
      _startAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAnimations() {
    // 启动主要动画
    _mainController.forward();
    // 延迟启动柱状图动画
    Future.delayed(const Duration(milliseconds: 300), () {
      _barController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '数据可视化' : 'Data Visualization', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 重置动画
              _mainController.reset();
              _barController.reset();
              _loadData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isChinese ? '问卷统计' : 'Survey Stats', iconMargin: EdgeInsets.zero, height: 36, child: Text(isChinese ? '问卷统计' : 'Survey Stats', style: const TextStyle(fontFamily: kFontFamilyTitle))),
            Tab(text: isChinese ? '反馈统计' : 'Feedback Stats', iconMargin: EdgeInsets.zero, height: 36, child: Text(isChinese ? '反馈统计' : 'Feedback Stats', style: const TextStyle(fontFamily: kFontFamilyTitle))),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: kErrorColor),
                      const SizedBox(height: 16),
                      Text('加载失败: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _mainController.reset();
                          _barController.reset();
                          _loadData();
                        },
                        child: Text(isChinese ? '重试' : 'Retry', style: const TextStyle(fontFamily: kFontFamilyTitle)),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSurveyStatsTab(isChinese),
                    _buildFeedbackStatsTab(isChinese),
                  ],
                ),
    );
  }

  Widget _buildSurveyStatsTab(bool isChinese) {
    if (_surveyStats == null) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总体统计卡片
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSummaryCard(isChinese),
          ),
          const SizedBox(height: 24),
          
          // 性别分布饼图
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildGenderPieChart(isChinese),
          ),
          const SizedBox(height: 24),
          
          // 年龄分布柱状图
          AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return _buildAgeGroupBarChart(isChinese);
            },
          ),
          const SizedBox(height: 24),
          
          // 收入分布柱状图
          AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return _buildIncomeBarChart(isChinese);
            },
          ),
          const SizedBox(height: 24),
          
          // 旅行频率柱状图
          AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return _buildTravelFrequencyBarChart(isChinese);
            },
          ),
          const SizedBox(height: 24),
          
          // 兴趣爱好雷达图效果
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildInterestRadarEffect(isChinese),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackStatsTab(bool isChinese) {
    if (_feedbackStats == null) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 评分分布饼图 - 缩放动画
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildRatingPieChart(isChinese),
          ),
          const SizedBox(height: 24),
          
          // 评论列表 - 渐入动画
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCommentsList(isChinese),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isChinese) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '总体统计' : 'Summary',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.people,
                    '${_surveyStats!.total}',
                    isChinese ? '总问卷数' : 'Total Surveys',
                    kPrimaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.favorite,
                    '${_feedbackStats?.comments.length ?? 0}',
                    isChinese ? '总评论数' : 'Total Comments',
                    kSuccessColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.star,
                    '${_calculateAverageRating()}',
                    isChinese ? '平均评分' : 'Avg Rating',
                    kWarningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPieChart(bool isChinese) {
    final genderData = _surveyStats!.gender;
    if (genderData.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '性别分布' : 'Gender Distribution',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // 饼图效果
                  Expanded(
                    flex: 2,
                    child: CustomPaint(
                      size: const Size(150, 150),
                      painter: AnimatedPieChartPainter(
                        genderData, 
                        _surveyStats!.total,
                        _barAnimation.value,
                      ),
                    ),
                  ),
                  // 图例
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: genderData.entries.map((entry) {
                        final percentage = (entry.value / _surveyStats!.total * 100).toStringAsFixed(1);
                        final color = entry.key == '男' || entry.key == 'Male' 
                            ? Colors.blue 
                            : Colors.pink;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key} ($percentage%)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeGroupBarChart(bool isChinese) {
    final ageData = _surveyStats!.ageGroup;
    if (ageData.isEmpty) return const SizedBox.shrink();

    final maxValue = ageData.values.fold(0, (max, value) => value > max ? value : max).toDouble();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '年龄分布' : 'Age Distribution',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: ageData.entries.map((entry) {
                  final fullHeight = (entry.value / maxValue * 120).toDouble();
                  final animatedHeight = fullHeight * _barAnimation.value;
                  final percentage = (entry.value / _surveyStats!.total * 100).toStringAsFixed(1);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(entry.value * _barAnimation.value).round()}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 30,
                          height: animatedHeight,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(fontSize: 8, color: kTextSecondaryColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeBarChart(bool isChinese) {
    final incomeData = _surveyStats!.monthlyIncome;
    if (incomeData.isEmpty) return const SizedBox.shrink();

    final maxValue = incomeData.values.fold(0, (max, value) => value > max ? value : max).toDouble();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '月收入分布' : 'Monthly Income Distribution',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: incomeData.entries.map((entry) {
                  final fullHeight = (entry.value / maxValue * 120).toDouble();
                  final animatedHeight = fullHeight * _barAnimation.value;
                  final percentage = (entry.value / _surveyStats!.total * 100).toStringAsFixed(1);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(entry.value * _barAnimation.value).round()}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 30,
                          height: animatedHeight,
                          decoration: BoxDecoration(
                            color: kSuccessColor,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(fontSize: 8, color: kTextSecondaryColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelFrequencyBarChart(bool isChinese) {
    final frequencyData = _surveyStats!.travelFrequency;
    if (frequencyData.isEmpty) return const SizedBox.shrink();

    final maxValue = frequencyData.values.fold(0, (max, value) => value > max ? value : max).toDouble();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '旅行频率' : 'Travel Frequency',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: frequencyData.entries.map((entry) {
                  final fullHeight = (entry.value / maxValue * 120).toDouble();
                  final animatedHeight = fullHeight * _barAnimation.value;
                  final percentage = (entry.value / _surveyStats!.total * 100).toStringAsFixed(1);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _barAnimation,
                          builder: (context, child) {
                            return Text(
                              '${(entry.value * _barAnimation.value).round()}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 30,
                          height: animatedHeight,
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(fontSize: 8, color: kTextSecondaryColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestRadarEffect(bool isChinese) {
    final interestData = _surveyStats!.interest;
    if (interestData.isEmpty) return const SizedBox.shrink();

    final maxValue = interestData.values.fold(0, (max, value) => value > max ? value : max).toDouble();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '兴趣爱好分布' : 'Interest Distribution',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...interestData.entries.map((entry) {
              final percentage = (entry.value / maxValue * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                        AnimatedBuilder(
                          animation: _barAnimation,
                          builder: (context, child) {
                            return Text('$percentage% (${(entry.value * _barAnimation.value).round()}人)');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _barAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: (entry.value / maxValue) * _barAnimation.value,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                          minHeight: 8,
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingPieChart(bool isChinese) {
    final ratingData = _feedbackStats!.ratings;
    if (ratingData.isEmpty) return const SizedBox.shrink();

    final totalRatings = ratingData.values.fold(0, (sum, count) => sum + count);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '评分分布' : 'Rating Distribution',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // 饼图效果
                  Expanded(
                    flex: 2,
                    child: CustomPaint(
                      size: const Size(150, 150),
                      painter: AnimatedRatingPieChartPainter(
                        ratingData, 
                        totalRatings,
                        _barAnimation.value,
                      ),
                    ),
                  ),
                  // 图例
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ratingData.entries.map((entry) {
                        final percentage = (entry.value / totalRatings * 100).toStringAsFixed(1);
                        final colors = [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.lightGreen,
                          Colors.green,
                        ];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[entry.key - 1],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key}星 ($percentage%)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(bool isChinese) {
    final comments = _feedbackStats!.comments;
    if (comments.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '用户评论' : 'User Comments',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRatingColor(comment.score),
                        child: Text(
                          comment.score.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(comment.user),
                      subtitle: Text(comment.content),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: kTextSecondaryColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _calculateAverageRating() {
    if (_feedbackStats == null || _feedbackStats!.ratings.isEmpty) {
      return '0.0';
    }
    
    double totalRating = 0;
    int totalCount = 0;
    
    _feedbackStats!.ratings.forEach((rating, count) {
      totalRating += rating * count;
      totalCount += count;
    });
    
    return (totalRating / totalCount).toStringAsFixed(1);
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// 动画饼图绘制器
class AnimatedPieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final int total;
  final double animationValue;

  AnimatedPieChartPainter(this.data, this.total, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    double startAngle = 0;
    final colors = [Colors.blue, Colors.pink, Colors.green, Colors.orange, Colors.purple];
    int colorIndex = 0;

    data.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * math.pi * animationValue;
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 动画评分饼图绘制器
class AnimatedRatingPieChartPainter extends CustomPainter {
  final Map<int, int> data;
  final int total;
  final double animationValue;

  AnimatedRatingPieChartPainter(this.data, this.total, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    double startAngle = 0;
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green,
    ];

    data.forEach((rating, count) {
      final sweepAngle = (count / total) * 2 * math.pi * animationValue;
      final paint = Paint()
        ..color = colors[rating - 1]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 