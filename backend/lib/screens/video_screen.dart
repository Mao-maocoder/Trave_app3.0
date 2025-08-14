import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../theme.dart';
import '../providers/locale_provider.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  int _selectedCategory = 0;
  String _searchQuery = '';

  List<String> get _categories {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return isChinese 
        ? ['全部', '故宫', '天坛', '胡同', '文化', '风景']
        : ['All', 'Forbidden City', 'Temple of Heaven', 'Hutong', 'Culture', 'Landscape'];
  }

  final List<Map<String, dynamic>> _videos = [
    {
      'title': '故宫深度游',
      'titleEn': 'Forbidden City Deep Tour',
      'description': '带你深入了解故宫的历史文化，感受皇家建筑的宏伟',
      'descriptionEn': 'Take you deep into the history and culture of the Forbidden City, feel the grandeur of royal architecture',
      'author': '文化解说员',
      'authorEn': 'Cultural Guide',
      'views': 12500,
      'likes': 890,
      'duration': '15:30',
      'category': '故宫',
      'categoryEn': 'Forbidden City',
      'thumbnail': 'assets/images/videos/gugong_video.jpg',
      'uploadTime': '3天前',
      'uploadTimeEn': '3 days ago',
    },
    {
      'title': '天坛祈年殿探秘',
      'titleEn': 'Exploring the Hall of Prayer for Good Harvests',
      'description': '揭秘天坛祈年殿的建筑奥秘和祭祀文化',
      'descriptionEn': 'Revealing the architectural mysteries and sacrificial culture of the Hall of Prayer for Good Harvests',
      'author': '古建专家',
      'authorEn': 'Ancient Architecture Expert',
      'views': 8900,
      'likes': 567,
      'duration': '12:45',
      'category': '天坛',
      'categoryEn': 'Temple of Heaven',
      'thumbnail': 'assets/images/videos/tiantan_video.jpg',
      'uploadTime': '1周前',
      'uploadTimeEn': '1 week ago',
    },
    {
      'title': '胡同里的老北京生活',
      'titleEn': 'Old Beijing Life in Hutong',
      'description': '走进胡同，体验最地道的北京生活',
      'descriptionEn': 'Walk into the hutong and experience the most authentic Beijing life',
      'author': '北京生活',
      'authorEn': 'Beijing Life',
      'views': 15600,
      'likes': 1200,
      'duration': '18:20',
      'category': '胡同',
      'categoryEn': 'Hutong',
      'thumbnail': 'assets/images/videos/hutong_video.jpg',
      'uploadTime': '2天前',
      'uploadTimeEn': '2 days ago',
    },
    {
      'title': '中轴线文化解读',
      'titleEn': 'Central Axis Culture Interpretation',
      'description': '专业解读北京中轴线的历史文化内涵',
      'descriptionEn': 'Professional interpretation of the historical and cultural connotations of Beijing Central Axis',
      'author': '文化学者',
      'authorEn': 'Cultural Scholar',
      'views': 21000,
      'likes': 1500,
      'duration': '25:15',
      'category': '文化',
      'categoryEn': 'Culture',
      'thumbnail': 'assets/images/videos/culture_video.jpg',
      'uploadTime': '5天前',
      'uploadTimeEn': '5 days ago',
    },
    {
      'title': '景山公园俯瞰故宫',
      'titleEn': 'Overlooking Forbidden City from Jingshan Park',
      'description': '从景山公园俯瞰故宫全景，感受古都风貌',
      'descriptionEn': 'Overlooking the panoramic view of the Forbidden City from Jingshan Park, feel the ancient capital style',
      'author': '航拍达人',
      'authorEn': 'Aerial Photography Expert',
      'views': 18900,
      'likes': 1100,
      'duration': '8:45',
      'category': '风景',
      'categoryEn': 'Landscape',
      'thumbnail': 'assets/images/videos/landscape_video.jpg',
      'uploadTime': '1天前',
      'uploadTimeEn': '1 day ago',
    },
  ];

  List<Map<String, dynamic>> get _filteredVideos {
    List<Map<String, dynamic>> filtered = _videos;
    
    // 按分类筛选
    if (_selectedCategory > 0) {
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      final category = isChinese ? _categories[_selectedCategory] : _categories[_selectedCategory];
      filtered = filtered.where((video) {
        final videoCategory = isChinese ? video['category'] : video['categoryEn'];
        return videoCategory == category;
      }).toList();
    }
    
    // 按搜索关键词筛选
    if (_searchQuery.isNotEmpty) {
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      filtered = filtered.where((video) {
        final title = isChinese ? video['title'] : video['titleEn'];
        final description = isChinese ? video['description'] : video['descriptionEn'];
        final author = isChinese ? video['author'] : video['authorEn'];
        return title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               author.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isChinese ? '视频中心' : 'Video Center'),
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
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _showSearchDialog();
                },
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
                        Icons.video_library_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: kSpaceM),
                      Text(
                        isChinese ? '中轴线视频中心' : 'Central Axis Video Center',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: kFontSizeXxl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      Text(
                        isChinese ? '探索中轴线的精彩视频' : 'Explore exciting videos of the Central Axis',
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
                
                // 搜索结果提示
                if (_searchQuery.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(kSpaceM),
                    margin: const EdgeInsets.all(kSpaceM),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(kRadiusM),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: kSpaceS),
                        Expanded(
                          child: Text(
                            isChinese 
                                ? '搜索"$_searchQuery"的结果: ${_filteredVideos.length}个视频'
                                : 'Search results for "$_searchQuery": ${_filteredVideos.length} videos',
                            style: const TextStyle(
                              color: AppColors.info,
                              fontSize: kFontSizeS,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: AppColors.info,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 视频列表
                Expanded(
                  child: _filteredVideos.isEmpty
                      ? _buildEmptyState(isChinese)
                      : ListView.builder(
                          padding: const EdgeInsets.all(kSpaceM),
                          itemCount: _filteredVideos.length,
                          itemBuilder: (context, index) {
                            final video = _filteredVideos[index];
                            return _buildVideoCard(video, isChinese);
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

  Widget _buildEmptyState(bool isChinese) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: kSpaceL),
          Text(
            isChinese ? '暂无相关视频' : 'No related videos',
            style: TextStyle(
              fontSize: kFontSizeL,
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpaceM),
          Text(
            isChinese ? '试试其他分类或搜索关键词' : 'Try other categories or search keywords',
            style: TextStyle(
              fontSize: kFontSizeM,
              color: AppColors.textLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, bool isChinese) {
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
          // 视频缩略图
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
                    Icons.play_circle_outline,
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
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(kRadiusS),
                    ),
                    child: Text(
                      video['duration'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: kFontSizeS,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: kSpaceS,
                  left: kSpaceS,
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
                      isChinese ? video['category'] : video['categoryEn'],
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
          
          // 视频信息
          Padding(
            padding: const EdgeInsets.all(kSpaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? video['title'] : video['titleEn'],
                  style: const TextStyle(
                    fontSize: kFontSizeL,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: kSpaceS),
                Text(
                  isChinese ? video['description'] : video['descriptionEn'],
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: kFontSizeM,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: kSpaceM),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (isChinese ? video['author'] : video['authorEn'])[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: kFontSizeS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpaceS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isChinese ? video['author'] : video['authorEn'],
                            style: const TextStyle(
                              fontSize: kFontSizeM,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isChinese ? video['uploadTime'] : video['uploadTimeEn'],
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: kFontSizeS,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${video['views']}',
                              style: const TextStyle(
                                fontSize: kFontSizeS,
                                color: AppColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: kSpaceS),
                          Icon(
                            Icons.favorite,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${video['likes']}',
                              style: const TextStyle(
                                fontSize: kFontSizeS,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  void _showSearchDialog() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '搜索视频' : 'Search Videos'),
        content: TextField(
          decoration: InputDecoration(
            hintText: isChinese ? '输入关键词搜索...' : 'Enter keywords to search...',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(isChinese ? '搜索' : 'Search'),
          ),
        ],
      ),
    );
  }
} 