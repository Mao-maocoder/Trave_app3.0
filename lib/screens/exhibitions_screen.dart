import 'package:flutter/material.dart';
import '../constants.dart';
import '../theme.dart';

class ExhibitionsScreen extends StatefulWidget {
  const ExhibitionsScreen({Key? key}) : super(key: key);

  @override
  State<ExhibitionsScreen> createState() => _ExhibitionsScreenState();
}

class _ExhibitionsScreenState extends State<ExhibitionsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  final List<Map<String, dynamic>> _currentExhibitions = [
    {
      'title': '彩画千年',
      'subtitle': '中国官式彩画传承与创新展',
      'subtitleEn': 'A Thousand Year Legacy of Caihua',
      'image': 'assets/images/spots/gugong.png',
      'startDate': '2025-05-27',
      'endDate': '2025-08-26',
      'daysLeft': 28,
      'status': 'current',
    },
    {
      'title': '玉出昆冈',
      'subtitle': '清代这爱和用玉文化兴贸',
      'subtitleEn': 'Jade from Kunlun',
      'image': 'assets/images/spots/tiantan.png',
      'startDate': '2025-01-07',
      'endDate': '2026-01-04',
      'daysLeft': 158,
      'status': 'current',
    },
    {
      'title': '腾跃古今',
      'subtitle': '马文化特展',
      'subtitleEn': 'Leaping Through Time',
      'image': 'assets/images/spots/zhonggulou.png',
      'startDate': '2025-06-03',
      'endDate': '2026-03-31',
      'daysLeft': 244,
      'status': 'current',
    },
    {
      'title': '吉光片羽',
      'subtitle': '常设展',
      'subtitleEn': 'Glimpses of Glory',
      'image': 'assets/images/spots/qianmen.png',
      'startDate': '2020-01-01',
      'endDate': '2025-12-31',
      'daysLeft': 365,
      'status': 'permanent',
    },
  ];

  final List<Map<String, dynamic>> _pastExhibitions = [
    {
      'title': '中轴文化展',
      'subtitle': '北京中轴线历史文化展',
      'subtitleEn': 'Central Axis Culture Exhibition',
      'image': 'assets/images/spots/yongdingmen.png',
      'startDate': '2024-01-01',
      'endDate': '2024-12-31',
      'status': 'past',
    },
    {
      'title': '古都风貌',
      'subtitle': '北京古都风貌展',
      'subtitleEn': 'Ancient Capital Scenery',
      'image': 'assets/images/spots/shichahai_wanningqiao.png',
      'startDate': '2023-06-01',
      'endDate': '2023-12-31',
      'status': 'past',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCurrentExhibitions {
    if (_searchQuery.isEmpty) return _currentExhibitions;
    return _currentExhibitions.where((exhibition) {
      return exhibition['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             exhibition['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredPastExhibitions {
    if (_searchQuery.isEmpty) return _pastExhibitions;
    return _pastExhibitions.where((exhibition) {
      return exhibition['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             exhibition['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('展览列表', style: TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '请输入要搜索的展览',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // 标签页
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: kPrimaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: kPrimaryColor,
              tabs: const [
                Tab(text: '正在展览'),
                Tab(text: '历年展览'),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExhibitionsGrid(_filteredCurrentExhibitions),
                _buildExhibitionsGrid(_filteredPastExhibitions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExhibitionsGrid(List<Map<String, dynamic>> exhibitions) {
    if (exhibitions.isEmpty) {
      return const Center(
        child: Text('暂无展览', style: TextStyle(fontSize: 16, color: kTextSecondary)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: exhibitions.length,
      itemBuilder: (context, index) {
        final exhibition = exhibitions[index];
        return _buildExhibitionCard(exhibition);
      },
    );
  }

  Widget _buildExhibitionCard(Map<String, dynamic> exhibition) {
    return GestureDetector(
      onTap: () {
        // 点击展览卡片，可以显示详情或导航到详情页
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(exhibition['title']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('副标题: ${exhibition['subtitle']}'),
                const SizedBox(height: 8),
                Text('时间: ${exhibition['startDate']} ~ ${exhibition['endDate']}'),
                if (exhibition['daysLeft'] != null)
                  Text('剩余天数: ${exhibition['daysLeft']}天'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 展览图片
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.asset(
                      exhibition['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: kPrimaryColor.withOpacity(0.3),
                          child: const Icon(Icons.image, color: Colors.white),
                        );
                      },
                    ),
                    // 状态标签
                    if (exhibition['daysLeft'] != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '距离结束 ${exhibition['daysLeft']}天',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 展览信息
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibition['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exhibition['subtitle'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exhibition['startDate']} ~ ${exhibition['endDate']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
