import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/ui_performance.dart';
import '../services/photo_service.dart';
import '../models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PhotoWallScreen extends StatefulWidget {
  const PhotoWallScreen({Key? key}) : super(key: key);

  @override
  State<PhotoWallScreen> createState() => _PhotoWallScreenState();
}

class _PhotoWallScreenState extends State<PhotoWallScreen> {
  int _selectedCategory = 0;
  String _searchQuery = '';
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<Map<String, dynamic>> _realPhotos = []; // 真实上传的照片

  List<String> get _categories {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return isChinese
        ? ['全部', '故宫', '天坛', '胡同', '建筑', '风景']
        : ['All', 'Forbidden City', 'Temple of Heaven', 'Hutong', 'Architecture', 'Landscape'];
  }

  List<String> get _spotNames {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    return isChinese
        ? ['永定门', '先农坛', '天坛', '前门', '故宫', '什刹海万宁桥', '钟鼓楼']
        : ['Yongdingmen', 'Xiannongtan', 'Temple of Heaven', 'Qianmen', 'Forbidden City', 'Wanning Bridge', 'Bell and Drum Towers'];
  }

  @override
  void initState() {
    super.initState();
    _loadRealPhotos();
  }

  // 加载真实上传的照片
  Future<void> _loadRealPhotos() async {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      // 获取所有已审核照片
      final approvedResult = await PhotoService.getPhotos(status: 'approved');
      final approvedPhotos = (approvedResult['photos'] as List<dynamic>).cast<Map<String, dynamic>>();
      // 获取当前用户上传的所有照片
      List<Map<String, dynamic>> userPhotos = [];
      if (user != null) {
        final userResult = await PhotoService.getPhotos(uploader: user.username, limit: 100);
        userPhotos = (userResult['photos'] as List<dynamic>).cast<Map<String, dynamic>>();
      }
      // 合并并去重
      final allPhotos = [...approvedPhotos];
      for (var up in userPhotos) {
        if (!allPhotos.any((p) => p['id'] == up['id'])) {
          allPhotos.add(up);
        }
      }
      setState(() {
        _realPhotos = allPhotos;
      });
    } catch (e) {
      print('加载照片失败: $e');
    }
  }

  // 检查用户是否可以删除照片
  bool _canDeletePhoto(Map<String, dynamic> photo) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return false;

    // 导游可以删除所有照片
    if (user.role == 'guide') return true;

    // 用户只能删除自己上传的照片
    return photo['uploader'] == user.username;
  }

  // 删除照片
  Future<void> _deletePhoto(Map<String, dynamic> photo) async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '确认删除' : 'Confirm Delete'),
        content: Text(isChinese ? '确定要删除这张照片吗？' : 'Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isChinese ? '删除' : 'Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PhotoService.deletePhoto(photo['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isChinese ? '删除成功' : 'Deleted successfully')),
        );
        _loadRealPhotos(); // 重新加载照片列表
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isChinese ? '删除失败: $e' : 'Delete failed: $e')),
        );
      }
    }
  }

  final List<Map<String, dynamic>> _photos = [
    {
      'title': '故宫太和殿',
      'titleEn': 'Hall of Supreme Harmony',
      'description': '紫禁城的核心建筑，明清两代举行大典的地方',
      'descriptionEn': 'The core building of the Forbidden City, where grand ceremonies were held in Ming and Qing dynasties',
      'author': '摄影师小王',
      'authorEn': 'Photographer Wang',
      'likes': 1250,
      'comments': 89,
      'category': '故宫',
      'categoryEn': 'Forbidden City',
      'image': 'assets/images/photos/gugong1.jpg',
      'uploadTime': '2小时前',
      'uploadTimeEn': '2 hours ago',
      'location': '北京故宫博物院',
      'locationEn': 'Beijing Palace Museum',
    },
    {
      'title': '天坛祈年殿',
      'titleEn': 'Hall of Prayer for Good Harvests',
      'description': '古代皇帝祭天的神圣场所，建筑精美绝伦',
      'descriptionEn': 'A sacred place where ancient emperors worshipped heaven, with exquisite architecture',
      'author': '古建爱好者',
      'authorEn': 'Ancient Architecture Lover',
      'likes': 980,
      'comments': 67,
      'category': '天坛',
      'categoryEn': 'Temple of Heaven',
      'image': 'assets/images/photos/tiantan1.jpg',
      'uploadTime': '5小时前',
      'uploadTimeEn': '5 hours ago',
      'location': '北京天坛公园',
      'locationEn': 'Beijing Temple of Heaven Park',
    },
    {
      'title': '胡同里的老北京',
      'titleEn': 'Old Beijing in Hutong',
      'description': '传统胡同里的生活场景，展现老北京的风情',
      'descriptionEn': 'Life scenes in traditional hutongs, showing the charm of old Beijing',
      'author': '北京文化',
      'authorEn': 'Beijing Culture',
      'likes': 756,
      'comments': 45,
      'category': '胡同',
      'categoryEn': 'Hutong',
      'image': 'assets/images/photos/hutong1.jpg',
      'uploadTime': '1天前',
      'uploadTimeEn': '1 day ago',
      'location': '北京胡同',
      'locationEn': 'Beijing Hutong',
    },
    {
      'title': '钟鼓楼夜景',
      'titleEn': 'Bell and Drum Towers at Night',
      'description': '夜幕下的钟鼓楼，灯火辉煌，古韵悠长',
      'descriptionEn': 'Bell and Drum Towers at night, brilliantly lit with ancient charm',
      'author': '夜景摄影师',
      'authorEn': 'Night Photographer',
      'likes': 1340,
      'comments': 112,
      'category': '建筑',
      'categoryEn': 'Architecture',
      'image': 'assets/images/photos/clock1.jpg',
      'uploadTime': '3天前',
      'uploadTimeEn': '3 days ago',
      'location': '北京钟鼓楼',
      'locationEn': 'Beijing Bell and Drum Towers',
    },
    {
      'title': '景山公园俯瞰',
      'titleEn': 'Overlooking from Jingshan Park',
      'description': '从景山公园俯瞰故宫全景，气势恢宏',
      'descriptionEn': 'Overlooking the panoramic view of the Forbidden City from Jingshan Park, magnificent',
      'author': '航拍达人',
      'authorEn': 'Aerial Photography Expert',
      'likes': 2100,
      'comments': 156,
      'category': '风景',
      'categoryEn': 'Landscape',
      'image': 'assets/images/photos/jingshan1.jpg',
      'uploadTime': '1周前',
      'uploadTimeEn': '1 week ago',
      'location': '北京景山公园',
      'locationEn': 'Beijing Jingshan Park',
    },
    {
      'title': '故宫角楼',
      'titleEn': 'Corner Tower of Forbidden City',
      'description': '故宫角楼的精美建筑细节，展现古代工匠的智慧',
      'descriptionEn': 'Exquisite architectural details of the corner tower, showing the wisdom of ancient craftsmen',
      'author': '建筑摄影师',
      'authorEn': 'Architectural Photographer',
      'likes': 890,
      'comments': 78,
      'category': '故宫',
      'categoryEn': 'Forbidden City',
      'image': 'assets/images/photos/gugong2.jpg',
      'uploadTime': '2天前',
      'uploadTimeEn': '2 days ago',
      'location': '北京故宫博物院',
      'locationEn': 'Beijing Palace Museum',
    },
    {
      'title': '天坛回音壁',
      'titleEn': 'Echo Wall of Temple of Heaven',
      'description': '天坛回音壁的神奇声学效果，古代建筑的智慧结晶',
      'descriptionEn': 'The magical acoustic effect of the Echo Wall, a crystallization of ancient architectural wisdom',
      'author': '声学专家',
      'authorEn': 'Acoustic Expert',
      'likes': 567,
      'comments': 34,
      'category': '天坛',
      'categoryEn': 'Temple of Heaven',
      'image': 'assets/images/photos/tiantan2.jpg',
      'uploadTime': '4天前',
      'uploadTimeEn': '4 days ago',
      'location': '北京天坛公园',
      'locationEn': 'Beijing Temple of Heaven Park',
    },
    {
      'title': '胡同里的四合院',
      'titleEn': 'Siheyuan in Hutong',
      'description': '传统四合院的建筑布局，展现北京民居的特色',
      'descriptionEn': 'Traditional siheyuan layout, showing the characteristics of Beijing residential architecture',
      'author': '古建研究者',
      'authorEn': 'Ancient Architecture Researcher',
      'likes': 678,
      'comments': 52,
      'category': '胡同',
      'categoryEn': 'Hutong',
      'image': 'assets/images/photos/hutong2.jpg',
      'uploadTime': '1周前',
      'uploadTimeEn': '1 week ago',
      'location': '北京胡同',
      'locationEn': 'Beijing Hutong',
    },
  ];

  List<Map<String, dynamic>> get _filteredPhotos {
    // 合并示例照片和真实上传的照片
    List<Map<String, dynamic>> allPhotos = [..._photos];

    // 添加真实上传的照片，转换格式以匹配示例照片的结构
    for (var realPhoto in _realPhotos) {
      allPhotos.add({
        'title': realPhoto['title'] ?? realPhoto['originalName'] ?? '无标题',
        'titleEn': realPhoto['title'] ?? realPhoto['originalName'] ?? 'No Title',
        'description': realPhoto['description'] ?? '',
        'descriptionEn': realPhoto['description'] ?? '',
        'author': realPhoto['uploader'] ?? '匿名用户',
        'authorEn': realPhoto['uploader'] ?? 'Anonymous',
        'category': realPhoto['spotName'] ?? '其他',
        'categoryEn': realPhoto['spotName'] ?? 'Other',
        'likes': 0,
        'comments': 0,
        'location': realPhoto['spotName'] ?? '未知位置',
        'locationEn': realPhoto['spotName'] ?? 'Unknown Location',
        'isRealPhoto': true, // 标记为真实照片
        'id': realPhoto['id'], // 保存原始ID用于删除
        'uploader': realPhoto['uploader'], // 保存上传者信息
        'userRole': realPhoto['userRole'], // 保存用户角色
        'path': realPhoto['path'], // 保存图片路径
      });
    }

    List<Map<String, dynamic>> filtered = allPhotos;

    // 按分类筛选
    if (_selectedCategory > 0) {
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      final category = isChinese ? _categories[_selectedCategory] : _categories[_selectedCategory];
      filtered = filtered.where((photo) {
        final photoCategory = isChinese ? photo['category'] : photo['categoryEn'];
        return photoCategory == category;
      }).toList();
    }

    // 按搜索关键词筛选
    if (_searchQuery.isNotEmpty) {
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      filtered = filtered.where((photo) {
        final title = isChinese ? photo['title'] : photo['titleEn'];
        final description = isChinese ? photo['description'] : photo['descriptionEn'];
        final author = isChinese ? photo['author'] : photo['authorEn'];
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
            title: Text(isChinese ? '照片墙' : 'Photo Wall'),
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
              IconButton(
                icon: const Icon(Icons.add_a_photo),
                onPressed: () {
                  _showUploadDialog();
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
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: kSpaceM),
                      Text(
                        isChinese ? '中轴线照片墙' : 'Central Axis Photo Wall',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: kFontSizeXxl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      Text(
                        isChinese ? '分享你的中轴线记忆' : 'Share your Central Axis memories',
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
                                ? '搜索"$_searchQuery"的结果: ${_filteredPhotos.length}张照片'
                                : 'Search results for "$_searchQuery": ${_filteredPhotos.length} photos',
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
                
                // 照片网格
                Expanded(
                  child: _filteredPhotos.isEmpty
                      ? _buildEmptyState(isChinese)
                      : PerformantGridView(
                          padding: const EdgeInsets.all(kSpaceM),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7, // 调整宽高比，给更多垂直空间
                            crossAxisSpacing: kSpaceS, // 减小间距
                            mainAxisSpacing: kSpaceS,
                          ),
                          itemCount: _filteredPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = _filteredPhotos[index];
                            return _buildPhotoCard(photo, isChinese);
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
            Icons.photo_library_outlined,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: kSpaceL),
          Text(
            isChinese ? '暂无相关照片' : 'No related photos',
            style: TextStyle(
              fontSize: kFontSizeL,
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpaceM),
          Text(
            isChinese ? '试试其他分类或上传你的照片' : 'Try other categories or upload your photos',
            style: TextStyle(
              fontSize: kFontSizeM,
              color: AppColors.textLight.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: kSpaceL),
          ElevatedButton.icon(
            onPressed: () {
              _showUploadDialog();
            },
            icon: const Icon(Icons.add_a_photo),
            label: Text(isChinese ? '上传照片' : 'Upload Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo, bool isChinese) {
    return GestureDetector(
      onTap: () {
        _showPhotoDetail(photo, isChinese);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(kRadiusL),
          boxShadow: kShadowMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 照片
            Container(
              width: double.infinity,
              height: 100, // 减小固定高度
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
                      Icons.photo,
                      size: 40, // 减小图标尺寸
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Positioned(
                    top: kSpaceS,
                    right: kSpaceS,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(kRadiusS),
                      ),
                      child: Text(
                        isChinese ? photo['category'] : photo['categoryEn'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10, // 减小字体
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // 删除按钮（只对真实照片且有权限的用户显示）
                  if (photo['isRealPhoto'] == true && _canDeletePhoto(photo))
                    Positioned(
                      top: kSpaceS,
                      left: kSpaceS,
                      child: GestureDetector(
                        onTap: () => _deletePhoto(photo),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(kRadiusS),
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 照片信息 - 使用Expanded确保占用剩余空间
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8), // 减小内边距
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      isChinese ? photo['title'] : photo['titleEn'],
                      style: const TextStyle(
                        fontSize: 12, // 减小字体
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 作者
                    Text(
                      isChinese ? photo['author'] : photo['authorEn'],
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 10, // 减小字体
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(), // 使用Spacer推送统计信息到底部
                    // 统计信息
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 12, // 减小图标
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${photo['likes']}',
                            style: const TextStyle(
                              fontSize: 10, // 减小字体
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.comment,
                          size: 12, // 减小图标
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${photo['comments']}',
                            style: const TextStyle(
                              fontSize: 10, // 减小字体
                              color: AppColors.textLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  void _showPhotoDetail(Map<String, dynamic> photo, bool isChinese) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kRadiusXl),
              topRight: Radius.circular(kRadiusXl),
            ),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: kSpaceM),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(kSpaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 照片
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kRadiusL),
                          gradient: kAccentGradient,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.photo,
                                size: 64,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Positioned(
                              top: kSpaceM,
                              right: kSpaceM,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: kSpaceM,
                                  vertical: kSpaceS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(kRadiusM),
                                ),
                                child: Text(
                                  isChinese ? photo['category'] : photo['categoryEn'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: kFontSizeM,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: kSpaceL),
                      
                      // 照片标题
                      Text(
                        isChinese ? photo['title'] : photo['titleEn'],
                        style: const TextStyle(
                          fontSize: kFontSizeXl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: kSpaceS),
                      
                      Text(
                        isChinese ? photo['description'] : photo['descriptionEn'],
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: kFontSizeL,
                        ),
                      ),
                      
                      const SizedBox(height: kSpaceL),
                      
                      // 作者信息
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              (isChinese ? photo['author'] : photo['authorEn'])[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: kSpaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isChinese ? photo['author'] : photo['authorEn'],
                                  style: const TextStyle(
                                    fontSize: kFontSizeM,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  isChinese ? photo['uploadTime'] : photo['uploadTimeEn'],
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: kFontSizeS,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: 实现关注功能
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(kRadiusM),
                              ),
                            ),
                            child: Text(isChinese ? '关注' : 'Follow'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: kSpaceL),
                      
                      // 位置信息
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: kSpaceS),
                          Text(
                            isChinese ? photo['location'] : photo['locationEn'],
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: kFontSizeM,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: kSpaceL),
                      
                      // 统计信息
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: kSpaceS),
                          Text(
                            isChinese 
                                ? '${photo['likes']} 点赞'
                                : '${photo['likes']} likes',
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: kFontSizeM,
                            ),
                          ),
                          const SizedBox(width: kSpaceL),
                          Icon(
                            Icons.comment,
                            size: 20,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: kSpaceS),
                          Text(
                            isChinese 
                                ? '${photo['comments']} 评论'
                                : '${photo['comments']} comments',
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: kFontSizeM,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: kSpaceXxl),
                      
                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: 实现点赞功能
                              },
                              icon: const Icon(Icons.favorite),
                              label: Text(isChinese ? '点赞' : 'Like'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusM),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: kSpaceL),
                              ),
                            ),
                          ),
                          const SizedBox(width: kSpaceM),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: 实现评论功能
                              },
                              icon: const Icon(Icons.comment),
                              label: Text(isChinese ? '评论' : 'Comment'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusM),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: kSpaceL),
                              ),
                            ),
                          ),
                          const SizedBox(width: kSpaceM),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: 实现分享功能
                              },
                              icon: const Icon(Icons.share),
                              label: Text(isChinese ? '分享' : 'Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusM),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: kSpaceL),
                              ),
                            ),
                          ),
                        ],
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

  void _showSearchDialog() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '搜索照片' : 'Search Photos'),
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

  void _showUploadDialog() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '上传照片' : 'Upload Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: kSpaceM),
            Text(
              isChinese ? '选择照片来源' : 'Select photo source',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: kFontSizeM,
              ),
            ),
            const SizedBox(height: kSpaceL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 拍照按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImageFromCamera();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: Text(isChinese ? '拍照' : 'Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: kSpaceM),
                // 相册按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: Text(isChinese ? '相册' : 'Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  // 从摄像头拍照
  Future<void> _pickImageFromCamera() async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    // Web环境下跳过权限检查
    if (!kIsWeb) {
      try {
        // 检查摄像头权限
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isChinese ? '需要摄像头权限才能拍照' : 'Camera permission is required to take photos'),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: isChinese ? '设置' : 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      } catch (e) {
        // 权限检查失败，继续尝试拍照
        print('Permission check failed: $e');
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // 在Web环境下，需要读取文件字节并创建PlatformFile
        final bytes = await image.readAsBytes();
        final platformFile = PlatformFile(
          name: image.name,
          size: bytes.length,
          bytes: bytes,
        );
        _showUploadDetailsDialog([platformFile]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? '拍照失败: $e' : 'Camera failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 从相册选择照片
  Future<void> _pickImageFromGallery() async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    // Web环境下跳过权限检查
    if (!kIsWeb) {
      try {
        // 检查存储权限
        PermissionStatus storageStatus;
        if (Platform.isAndroid) {
          // Android 使用存储权限
          storageStatus = await Permission.storage.request();
        } else {
          // iOS 使用相册权限
          storageStatus = await Permission.photos.request();
        }

        if (storageStatus != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isChinese ? '需要存储权限才能访问相册' : 'Storage permission is required to access gallery'),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: isChinese ? '设置' : 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      } catch (e) {
        // 权限检查失败，继续尝试选择照片
        print('Permission check failed: $e');
      }
    }

    try {
      // 显示选择对话框：单张还是多张
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isChinese ? '选择模式' : 'Selection Mode'),
          content: Text(isChinese ? '您想选择单张照片还是多张照片？' : 'Do you want to select single or multiple photos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'single'),
              child: Text(isChinese ? '单张' : 'Single'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'multiple'),
              child: Text(isChinese ? '多张' : 'Multiple'),
            ),
          ],
        ),
      );

      if (result == 'single') {
        await _pickSingleImage();
      } else if (result == 'multiple') {
        await _pickMultipleImages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? '选择照片失败: $e' : 'Gallery selection failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 选择单张照片
  Future<void> _pickSingleImage() async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // 在Web环境下，需要读取文件字节并创建PlatformFile
        final bytes = await image.readAsBytes();
        final platformFile = PlatformFile(
          name: image.name,
          size: bytes.length,
          bytes: bytes,
        );
        _showUploadDetailsDialog([platformFile]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? '选择照片失败: $e' : 'Photo selection failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 选择多张照片
  Future<void> _pickMultipleImages() async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );

      if (result != null && result.files.isNotEmpty) {
        _showUploadDetailsDialog(result.files);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? '选择多张照片失败: $e' : 'Multiple selection failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 显示上传详情对话框
  void _showUploadDetailsDialog(List<PlatformFile> files) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    showDialog(
      context: context,
      builder: (context) => _UploadDetailsDialog(
        files: files,
        spotNames: _spotNames,
        isChinese: isChinese,
        onUploadComplete: () {
          // 上传完成后的回调
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isChinese ? '照片上传成功！' : 'Photos uploaded successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          // 重新加载照片列表
          _loadRealPhotos();
        },
      ),
    );
  }
}

// 上传详情对话框组件
class _UploadDetailsDialog extends StatefulWidget {
  final List<PlatformFile> files;
  final List<String> spotNames;
  final bool isChinese;
  final VoidCallback onUploadComplete;

  const _UploadDetailsDialog({
    required this.files,
    required this.spotNames,
    required this.isChinese,
    required this.onUploadComplete,
  });

  @override
  State<_UploadDetailsDialog> createState() => _UploadDetailsDialogState();
}

class _UploadDetailsDialogState extends State<_UploadDetailsDialog> {
  String? selectedSpot;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isUploading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isChinese ? '上传照片详情' : 'Upload Photo Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isChinese
                ? '选择了 ${widget.files.length} 张照片'
                : 'Selected ${widget.files.length} photo(s)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kSpaceM),

            // 景点选择
            DropdownButtonFormField<String>(
              value: selectedSpot,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '选择景点 *' : 'Select Spot *',
                border: const OutlineInputBorder(),
              ),
              items: widget.spotNames.map((spot) => DropdownMenuItem(
                value: spot,
                child: Text(spot),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSpot = value;
                });
              },
            ),
            const SizedBox(height: kSpaceM),

            // 标题输入
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '标题（可选）' : 'Title (Optional)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: kSpaceM),

            // 描述输入
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '描述（可选）' : 'Description (Optional)',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUploading ? null : () => Navigator.pop(context),
          child: Text(widget.isChinese ? '取消' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: isUploading || selectedSpot == null
              ? null
              : _uploadPhotos,
          child: isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isChinese ? '上传' : 'Upload'),
        ),
      ],
    );
  }

  Future<void> _uploadPhotos() async {
    if (selectedSpot == null) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isChinese ? '请先登录' : 'Please login first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      await PhotoService.uploadPhotosFromBytes(
        files: widget.files,
        spotName: selectedSpot!,
        user: user,
        title: titleController.text.isNotEmpty ? titleController.text : null,
        description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
      );

      widget.onUploadComplete();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isChinese ? '上传失败: $e' : 'Upload failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }
}