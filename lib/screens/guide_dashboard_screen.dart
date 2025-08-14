import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../services/guide_service.dart';
import '../constants.dart';

class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({Key? key}) : super(key: key);

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _surveyStats = {};
  List<Map<String, dynamic>> _boundTourists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final stats = await GuideService.getSurveyStatistics();
      final tourists = await GuideService.getBoundTourists(user!.id);
      
      setState(() {
        _surveyStats = stats;
        _boundTourists = tourists;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '导游管理面板' : 'Guide Dashboard'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 统计卡片
                  _buildStatsCard(isChinese),
                  const SizedBox(height: 24),
                  
                  // 问卷分析图表
                  _buildSurveyCharts(isChinese),
                  const SizedBox(height: 24),
                  
                  // 绑定游客列表
                  _buildTouristsList(isChinese),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard(bool isChinese) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '总览' : 'Overview',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.people,
                  value: _boundTourists.length.toString(),
                  label: isChinese ? '绑定游客' : 'Bound Tourists',
                ),
                _buildStatItem(
                  icon: Icons.assignment,
                  value: _surveyStats['totalSurveys']?.toString() ?? '0',
                  label: isChinese ? '总问卷数' : 'Total Surveys',
                ),
                _buildStatItem(
                  icon: Icons.star,
                  value: _surveyStats['avgRating']?.toStringAsFixed(1) ?? '0',
                  label: isChinese ? '平均评分' : 'Avg Rating',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyCharts(bool isChinese) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '问卷分析' : 'Survey Analysis',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // 饼图：用户偏好
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _generatePieChartSections(),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 柱状图：年龄分布
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('18-24');
                            case 1:
                              return const Text('25-34');
                            case 2:
                              return const Text('35-44');
                            case 3:
                              return const Text('45+');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: _generateBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final preferences = _surveyStats['preferences'] as Map<String, dynamic>? ?? {};
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    
    List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    
    preferences.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: (value as int).toDouble(),
          title: '$key\n$value%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });
    
    return sections;
  }

  List<BarChartGroupData> _generateBarGroups() {
    final ageGroups = _surveyStats['ageGroups'] as Map<String, dynamic>? ?? {};
    List<BarChartGroupData> groups = [];
    
    int index = 0;
    ageGroups.forEach((key, value) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: (value as int).toDouble(),
              color: kPrimaryColor,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    });
    
    return groups;
  }

  Widget _buildTouristsList(bool isChinese) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? '绑定游客' : 'Bound Tourists',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _boundTourists.length,
              itemBuilder: (context, index) {
                final tourist = _boundTourists[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kPrimaryColor,
                    child: Text(
                      tourist['username'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(tourist['username']),
                  subtitle: Text(tourist['email']),
                  trailing: Text(
                    tourist['bindingDate'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
