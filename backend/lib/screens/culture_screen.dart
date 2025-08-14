import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../widgets/optimized_card.dart';

class CultureScreen extends StatefulWidget {
  const CultureScreen({Key? key}) : super(key: key);

  @override
  State<CultureScreen> createState() => _CultureScreenState();
}

class _CultureScreenState extends State<CultureScreen> {
  int _selectedCategory = 0;

  List<String> get _categories {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return isChinese 
        ? ['全部', '历史', '建筑', '艺术', '民俗', '节日']
        : ['All', 'History', 'Architecture', 'Art', 'Folk', 'Festivals'];
  }

  final List<Map<String, dynamic>> _cultureItems = [
    {
      'title': '中轴线的历史渊源',
      'titleEn': 'Historical Origins of the Central Axis',
      'description': '追溯北京中轴线的历史发展，了解古都规划的精妙之处',
      'descriptionEn': 'Tracing the historical development of Beijing Central Axis, understanding the ingenuity of ancient capital planning',
      'category': '历史',
      'categoryEn': 'History',
      'icon': Icons.history_edu,
      'image': 'assets/images/culture/history.jpg',
      'readTime': '8分钟',
      'readTimeEn': '8 min',
    },
    {
      'title': '故宫建筑艺术',
      'titleEn': 'Forbidden City Architectural Art',
      'description': '探索故宫建筑的精美设计和深厚文化内涵',
      'descriptionEn': 'Exploring the exquisite design and profound cultural connotations of Forbidden City architecture',
      'category': '建筑',
      'categoryEn': 'Architecture',
      'icon': Icons.architecture,
      'image': 'assets/images/culture/architecture.jpg',
      'readTime': '12分钟',
      'readTimeEn': '12 min',
    },
    {
      'title': '天坛祭祀文化',
      'titleEn': 'Temple of Heaven Sacrificial Culture',
      'description': '了解古代皇帝祭天的仪式和文化意义',
      'descriptionEn': 'Understanding the rituals and cultural significance of ancient emperors worshipping heaven',
      'category': '历史',
      'categoryEn': 'History',
      'icon': Icons.temple_buddhist,
      'image': 'assets/images/culture/sacrifice.jpg',
      'readTime': '10分钟',
      'readTimeEn': '10 min',
    },
    {
      'title': '北京胡同文化',
      'titleEn': 'Beijing Hutong Culture',
      'description': '探索胡同里的老北京生活和文化传统',
      'descriptionEn': 'Exploring old Beijing life and cultural traditions in hutongs',
      'category': '民俗',
      'categoryEn': 'Folk',
      'icon': Icons.home,
      'image': 'assets/images/culture/hutong.jpg',
      'readTime': '15分钟',
      'readTimeEn': '15 min',
    },
    {
      'title': '传统节日习俗',
      'titleEn': 'Traditional Festival Customs',
      'description': '了解北京传统节日的庆祝方式和民俗活动',
      'descriptionEn': 'Understanding the celebration methods and folk activities of Beijing traditional festivals',
      'category': '节日',
      'categoryEn': 'Festivals',
      'icon': Icons.celebration,
      'image': 'assets/images/culture/festival.jpg',
      'readTime': '6分钟',
      'readTimeEn': '6 min',
    },
    {
      'title': '古代建筑工艺',
      'titleEn': 'Ancient Architectural Craftsmanship',
      'description': '揭秘古代建筑的精湛工艺和技术智慧',
      'descriptionEn': 'Revealing the exquisite craftsmanship and technical wisdom of ancient architecture',
      'category': '建筑',
      'categoryEn': 'Architecture',
      'icon': Icons.construction,
      'image': 'assets/images/culture/craft.jpg',
      'readTime': '14分钟',
      'readTimeEn': '14 min',
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 0) {
      return _cultureItems;
    }
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    final category = isChinese ? _categories[_selectedCategory] : _categories[_selectedCategory];
    return _cultureItems.where((item) {
      final itemCategory = isChinese ? item['category'] : item['categoryEn'];
      return itemCategory == category;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isChinese ? '文化探索' : 'Cultural Exploration'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.language, size: 20),
                ),
                tooltip: isChinese ? '切换到英文' : 'Switch to Chinese',
                onPressed: localeProvider.toggleLocale,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 头部介绍
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(kSpaceL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(kRadiusXl),
                      bottomRight: Radius.circular(kRadiusXl),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: kSpaceM),
                      Text(
                        isChinese ? '中轴线文化探索' : 'Central Axis Cultural Exploration',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: kFontSizeXxl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      Text(
                        isChinese ? '深入了解古都文化的精髓' : 'Deep understanding of the essence of ancient capital culture',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: kFontSizeM,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 分类标签
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: kSpaceM),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategory == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: kSpaceM, top: kSpaceL),
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpaceL,
                            vertical: kSpaceM,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(kRadiusXl),
                            boxShadow: isSelected ? kShadowMedium : kShadowLight,
                          ),
                          child: Center(
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: kFontSizeM,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // 文化内容列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(kSpaceM),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildCultureCard(item, isChinese);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCultureCard(Map<String, dynamic> item, bool isChinese) {
    return Container(
      margin: const EdgeInsets.only(bottom: kSpaceL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRadiusL),
        boxShadow: kShadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(kRadiusL),
                topRight: Radius.circular(kRadiusL),
              ),
              gradient: kAccentGradient,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    item['icon'],
                    size: 64,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Positioned(
                  top: kSpaceS,
                  right: kSpaceS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpaceS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(kRadiusS),
                    ),
                    child: Text(
                      isChinese ? item['category'] : item['categoryEn'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: kFontSizeS,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: kSpaceS,
                  left: kSpaceS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpaceS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(kRadiusS),
                    ),
                    child: Text(
                      isChinese ? item['readTime'] : item['readTimeEn'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: kFontSizeS,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(kSpaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? item['title'] : item['titleEn'],
                  style: const TextStyle(
                    fontSize: kFontSizeL,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: kSpaceS),
                Text(
                  isChinese ? item['description'] : item['descriptionEn'],
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: kFontSizeM,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: kSpaceM),
                OptimizedButtonRow(
                  spacing: kSpaceS,
                  buttons: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _readArticle(item, isChinese);
                      },
                      icon: const Icon(Icons.article, size: 14),
                      label: OptimizedText(
                        isChinese ? '阅读全文' : 'Read Full',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusM),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _shareArticle(item, isChinese);
                      },
                      icon: const Icon(Icons.share, size: 14),
                      label: OptimizedText(
                        isChinese ? '分享' : 'Share',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusM),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _readArticle(Map<String, dynamic> item, bool isChinese) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isChinese 
              ? '正在加载《${item['title']}》...'
              : 'Loading "${item['titleEn']}"...',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _shareArticle(Map<String, dynamic> item, bool isChinese) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isChinese 
              ? '分享《${item['title']}》'
              : 'Share "${item['titleEn']}"',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
} 