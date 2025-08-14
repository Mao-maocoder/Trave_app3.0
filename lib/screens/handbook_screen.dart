import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../theme.dart';
import '../providers/locale_provider.dart';

class HandbookScreen extends StatefulWidget {
  const HandbookScreen({Key? key}) : super(key: key);

  @override
  State<HandbookScreen> createState() => _HandbookScreenState();
}

class _HandbookScreenState extends State<HandbookScreen> {
  int _selectedCategory = 0;

  List<String> get _categories {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return isChinese 
        ? ['全部', '交通', '住宿', '美食', '购物', '文化']
        : ['All', 'Transport', 'Accommodation', 'Food', 'Shopping', 'Culture'];
  }

  final List<Map<String, dynamic>> _handbooks = [
    {
      'title': '北京中轴线交通指南',
      'titleEn': 'Beijing Central Axis Transportation Guide',
      'description': '详细介绍中轴线各景点的交通方式和路线规划',
      'descriptionEn': 'Detailed introduction to transportation methods and route planning for various attractions along the Central Axis',
      'category': '交通',
      'categoryEn': 'Transport',
      'icon': Icons.directions,
      'pages': 15,
      'downloads': 1200,
    },
    {
      'title': '故宫游览完全手册',
      'titleEn': 'Complete Forbidden City Tour Handbook',
      'description': '故宫游览路线、注意事项和历史文化解读',
      'descriptionEn': 'Forbidden City tour routes, precautions and historical cultural interpretation',
      'category': '文化',
      'categoryEn': 'Culture',
      'icon': Icons.account_balance,
      'pages': 25,
      'downloads': 2100,
    },
    {
      'title': '北京胡同住宿推荐',
      'titleEn': 'Beijing Hutong Accommodation Recommendations',
      'description': '精选胡同内的特色民宿和酒店推荐',
      'descriptionEn': 'Selected boutique homestays and hotel recommendations in hutongs',
      'category': '住宿',
      'categoryEn': 'Accommodation',
      'icon': Icons.hotel,
      'pages': 12,
      'downloads': 890,
    },
    {
      'title': '中轴线美食地图',
      'titleEn': 'Central Axis Food Map',
      'description': '中轴线沿线特色餐厅和小吃推荐',
      'descriptionEn': 'Specialty restaurants and snack recommendations along the Central Axis',
      'category': '美食',
      'categoryEn': 'Food',
      'icon': Icons.restaurant,
      'pages': 18,
      'downloads': 1560,
    },
    {
      'title': '北京特色购物指南',
      'titleEn': 'Beijing Specialty Shopping Guide',
      'description': '中轴线周边特色商品和购物场所推荐',
      'descriptionEn': 'Specialty products and shopping venues around the Central Axis',
      'category': '购物',
      'categoryEn': 'Shopping',
      'icon': Icons.shopping_bag,
      'pages': 10,
      'downloads': 750,
    },
  ];

  List<Map<String, dynamic>> get _filteredHandbooks {
    if (_selectedCategory == 0) {
      return _handbooks;
    }
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    final category = isChinese ? _categories[_selectedCategory] : _categories[_selectedCategory];
    return _handbooks.where((handbook) {
      final handbookCategory = isChinese ? handbook['category'] : handbook['categoryEn'];
      return handbookCategory == category;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isChinese ? '旅游手册' : 'Travel Handbook', style: const TextStyle(fontFamily: kFontFamilyTitle)),
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
                    color: kAccentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusButton),
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
                    gradient: kPrimaryGradient,
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
                        isChinese ? '中轴线旅游手册' : 'Central Axis Travel Handbook',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: kFontSizeXxl,
                          fontWeight: FontWeight.bold,
                          fontFamily: kFontFamilyTitle,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      Text(
                        isChinese ? '专业的旅游指南和实用信息' : 'Professional travel guides and practical information',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: kFontSizeM,
                          fontFamily: kFontFamilyTitle,
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
                            color: isSelected ? kPrimaryColor : kSurfaceColor,
                            borderRadius: BorderRadius.circular(kRadiusXl),
                            boxShadow: isSelected ? kShadowMedium : kShadowLight,
                          ),
                          child: Center(
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : kTextPrimaryColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: kFontSizeM,
                                fontFamily: kFontFamilyTitle,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // 手册列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(kSpaceM),
                    itemCount: _filteredHandbooks.length,
                    itemBuilder: (context, index) {
                      final handbook = _filteredHandbooks[index];
                      return _buildHandbookCard(handbook, isChinese);
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

  Widget _buildHandbookCard(Map<String, dynamic> handbook, bool isChinese) {
    return Container(
      margin: const EdgeInsets.only(bottom: kSpaceL),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(kRadiusL),
        boxShadow: kShadowMedium,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(kSpaceM),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(kRadiusM),
          ),
          child: Icon(
            handbook['icon'],
            color: kPrimaryColor,
            size: 30,
          ),
        ),
        title: Text(
          isChinese ? handbook['title'] : handbook['titleEn'],
          style: const TextStyle(
            fontSize: kFontSizeL,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kSpaceS),
            Text(
              isChinese ? handbook['description'] : handbook['descriptionEn'],
              style: const TextStyle(
                color: kTextLightColor,
                fontSize: kFontSizeM,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: kSpaceM),
            Row(
              children: [
                Icon(
                  Icons.description,
                  size: 14,
                  color: kTextLightColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    isChinese
                        ? '${handbook['pages']} 页'
                        : '${handbook['pages']} pages',
                    style: const TextStyle(
                      fontSize: kFontSizeS,
                      color: kTextLightColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: kSpaceM),
                Icon(
                  Icons.download,
                  size: 14,
                  color: kPrimaryColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${handbook['downloads']}',
                    style: const TextStyle(
                      fontSize: kFontSizeS,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _downloadHandbook(handbook, isChinese);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusM),
            ),
          ),
          child: Text(isChinese ? '下载' : 'Download'),
        ),
      ),
    );
  }

  void _downloadHandbook(Map<String, dynamic> handbook, bool isChinese) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isChinese 
              ? '正在下载《${handbook['title']}》...'
              : 'Downloading "${handbook['titleEn']}"...',
        ),
        backgroundColor: kPrimaryColor,
      ),
    );
  }
} 