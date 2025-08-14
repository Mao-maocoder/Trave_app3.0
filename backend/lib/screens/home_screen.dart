import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../constants.dart';
import '../models/user.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'dart:math' as math;
import '../widgets/optimized_image.dart';
import '../utils/image_preloader.dart';

// 叶子动画类
class LeafAnimation {
  final int id;
  final double startX;
  final Duration delay;
  final Duration duration;
  
  LeafAnimation({
    required this.id,
    required this.startX,
    required this.delay,
    required this.duration,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _currentBannerIndex = 0;
  late PageController _bannerController;
  late PageController _exhibitionPageController;
  late AnimationController _leafAnimationController;
  late List<LeafAnimation> _leaves;
  int _currentExhibitionPage = 0;
  
  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _exhibitionPageController = PageController();
    _leafAnimationController = AnimationController(
      duration: const Duration(seconds: 8), // 增加动画周期
      vsync: this,
    );
    _initializeLeaves();
    _startAutoPlay();
    _startLeafAnimation();
    _preloadImages();
  }

  void _preloadImages() {
    // 预加载轮播图图片
    final bannerImages = _banners.map((banner) => banner['image'] as String).toList();
    ImagePreloader.preloadImages(bannerImages);
    
    // 预加载展览图片
    final exhibitionImages = [
      'assets/images/spots/gugong.png',
      'assets/images/spots/tiantan.png',
      'assets/images/spots/zhonggulou.png',
      'assets/images/spots/qianmen.png',
      'assets/images/spots/yongdingmen.png',
      'assets/images/spots/xiannongtan.png',
      'assets/images/spots/shichahai_wanningqiao.png',
    ];
    ImagePreloader.preloadImages(exhibitionImages);
  }

  void _initializeLeaves() {
    _leaves = List.generate(6, (index) => LeafAnimation(
      id: index,
      startX: math.Random().nextDouble() * 250 + 75,
      delay: Duration(milliseconds: index * 800), // 增加延迟间隔
      duration: Duration(seconds: 4 + math.Random().nextInt(3)), // 增加下落时间
    ));
  }

  void _startLeafAnimation() {
    _leafAnimationController.repeat();
  }

  // 轮播图数据
  final List<Map<String, dynamic>> _banners = [
    {
      'title': '中轴奇遇',
      'subtitle': '探索北京中轴线的文化魅力',
      'image': 'assets/images/spots/gugong.png',
      'tag': '文化体验',
    },
    {
      'title': '天坛祈年殿',
      'subtitle': '感受古代皇家祭祀文化',
      'image': 'assets/images/spots/tiantan.png',
      'tag': '历史古迹',
    },
    {
      'title': '钟鼓楼',
      'subtitle': '聆听古都的时光回响',
      'image': 'assets/images/spots/zhonggulou.png',
      'tag': '文化地标',
    },
    {
      'title': '前门大街',
      'subtitle': '体验老北京风情',
      'image': 'assets/images/spots/qianmen.png',
      'tag': '民俗文化',
    },
    {
      'title': '永定门',
      'subtitle': '中轴线的南起点',
      'image': 'assets/images/spots/yongdingmen.png',
      'tag': '历史地标',
    },
  ];

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (_currentBannerIndex < _banners.length - 1) {
          _currentBannerIndex++;
        } else {
          _currentBannerIndex = 0;
        }
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _exhibitionPageController.dispose();
    _leafAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authProvider.currentUser?.username ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    authProvider.currentUser?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (authProvider.currentUser?.isGuide == true)
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: Text(
                  localeProvider.locale == AppLocale.zh ? '导游管理面板' : 'Guide Dashboard',
                ),
                onTap: () {
                  Navigator.pop(context); // 关闭抽屉
                  Navigator.pushNamed(context, '/guide_dashboard');
                },
              ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                localeProvider.locale == AppLocale.zh ? '设置' : 'Settings',
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('中轴奇遇', style: TextStyle(color: kPrimaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kTextSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '推荐',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '游中轴',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: '看景点',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildMapContent();
      case 2:
        return _buildSpotsContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 轮播图区域
          _buildBannerSection(),
          
          // 今日信息卡片
          _buildTodayInfoSection(),
          
          // 功能图标网格
          _buildFeatureGrid(),
          
          // 中轴展览
          _buildExhibitionsSection(),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          // 轮播图
          PageView.builder(
            controller: _bannerController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // 背景图片
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.asset(
                          banner['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: kPrimaryColor.withOpacity(0.3),
                              child: const Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      // 渐变遮罩
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // 内容
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                banner['tag'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xE6FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 轮播指示器
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x80000000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentBannerIndex + 1}/${_banners.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none, // 允许子元素超出边界
          children: [
            // 叶子动画效果
            ..._leaves.map((leaf) => _buildLeafAnimation(leaf)),
            // 背景装饰图片 - 让房子更完整显示
            Positioned(
              top: -15, // 稍微露出房顶
              right: 0,
              child: Image.asset(
                'assets/images/background/icon_bg.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: kPrimaryColor,
                      size: 45,
                    ),
                  );
                },
              ),
            ),
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 今日开放标题
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '今日开放',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 实时时间显示 - 简洁无框设计
                  StreamBuilder<DateTime>(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      final now = snapshot.data ?? DateTime.now();
                      return Text(
                        '${now.month}月${now.day}日',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 两个功能卡片
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          title: '路线规划',
                          subtitle: '提前了解行程安排',
                          icon: Icons.route,
                          color: Colors.red,
                          onTap: () => Navigator.pushNamed(context, '/itinerary'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          title: '地图导览',
                          subtitle: '智能路线推荐',
                          icon: Icons.map,
                          color: kPrimaryColor,
                          onTap: () => Navigator.pushNamed(context, '/map'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 叶子动画组件
  Widget _buildLeafAnimation(LeafAnimation leaf) {
    return AnimatedBuilder(
      animation: _leafAnimationController,
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _leafAnimationController,
          curve: Interval(
            (leaf.delay.inMilliseconds / 8000).clamp(0.0, 1.0),
            ((leaf.delay.inMilliseconds + leaf.duration.inMilliseconds) / 8000).clamp(0.0, 1.0),
            curve: Curves.easeInOut,
          ),
        ));

        final progress = animation.value;
        final y = progress * 150; // 减少下落距离
        final opacity = progress < 0.3 ? progress * 3.33 : (progress > 0.7 ? (1 - progress) * 3.33 : 1.0); // 优化渐变效果
        final rotation = progress * 180; // 减少旋转角度
        final sway = math.sin(progress * math.pi * 2) * 10; // 添加摇摆效果

        // 只在上半部分显示叶子，不遮挡下面的卡片
        if (y > 80) return const SizedBox.shrink();

        return Positioned(
          left: leaf.startX + sway, // 添加摇摆
          top: y - 15, // 从框外开始
          child: Transform.rotate(
            angle: rotation * math.pi / 180,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 16,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green[600]!.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 叶脉
                    Positioned(
                      left: 8,
                      top: 2,
                      child: Container(
                        width: 1,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green[800]!.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // 叶脉分支
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        width: 4,
                        height: 1,
                        decoration: BoxDecoration(
                          color: Colors.green[800]!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      top: 10,
                      child: Container(
                        width: 3,
                        height: 1,
                        decoration: BoxDecoration(
                          color: Colors.green[800]!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      top: 14,
                      child: Container(
                        width: 2,
                        height: 1,
                        decoration: BoxDecoration(
                          color: Colors.green[800]!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.music_note, 'title': '《中轴》音乐', 'route': '/music'},
      {'icon': Icons.translate, 'title': '智能翻译', 'route': '/translation'},
      {'icon': Icons.photo_library, 'title': '照片墙', 'route': '/photo'},
      {'icon': Icons.smart_toy, 'title': 'AI助手', 'route': '/ai_assistant'},
      {'icon': Icons.mic, 'title': '语音导览', 'route': '/voice'},
      {'icon': Icons.museum, 'title': '戏楼', 'route': '/culture'},
      {'icon': Icons.feedback, 'title': '意见反馈', 'route': '/feedback'},
      {'icon': Icons.card_giftcard, 'title': '积分奖励', 'route': '/rewards'},
              {'icon': Icons.book, 'title': '北京中轴线术语库', 'route': '/terminology'},
      {'icon': Icons.map, 'title': '数字中轴', 'route': '/digital-axis', 'url': 'https://bjaxiscloud.com.cn/'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '功能服务',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return GestureDetector(
                onTap: () async {
                  // 如果有URL，打开外部链接
                  if (feature['url'] != null) {
                    final url = feature['url'] as String;
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('无法打开链接')),
                      );
                    }
                  } else {
                    // 否则进行内部导航
                    Navigator.pushNamed(context, feature['route'] as String);
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: kPrimaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExhibitionsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '中轴展览',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/exhibitions');
                },
                child: const Text('全部 >'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 添加滚动提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.swipe_left, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '左右滑动查看更多展览',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // 页码指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentExhibitionPage + 1} / 7',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _exhibitionPageController,
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              onPageChanged: (index) {
                setState(() {
                  _currentExhibitionPage = index;
                });
              },
              itemBuilder: (context, index) {
                final exhibitions = [
                  {'title': '故宫博物院', 'subtitle': '紫禁城的秘密', 'image': 'assets/images/spots/gugong.png'},
                  {'title': '天坛公园', 'subtitle': '祈年殿的传说', 'image': 'assets/images/spots/tiantan.png'},
                  {'title': '钟鼓楼', 'subtitle': '古都时光', 'image': 'assets/images/spots/zhonggulou.png'},
                  {'title': '前门大街', 'subtitle': '老北京风情', 'image': 'assets/images/spots/qianmen.png'},
                  {'title': '永定门', 'subtitle': '中轴南起点', 'image': 'assets/images/spots/yongdingmen.png'},
                  {'title': '先农坛', 'subtitle': '古代祭祀文化', 'image': 'assets/images/spots/xiannongtan.png'},
                  {'title': '什刹海', 'subtitle': '古都水乡', 'image': 'assets/images/spots/shichahai_wanningqiao.png'},
                ];
                final exhibition = exhibitions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildExhibitionCard(exhibition['title']!, exhibition['subtitle']!, exhibition['image']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExhibitionCard(String title, String subtitle, String image) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: kPrimaryColor.withOpacity(0.3),
                      child: const Icon(Icons.image, color: Colors.white),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // 添加一个透明的点击区域
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // 根据标题导航到对应的景点详情页面
                      switch (title) {
                        case '故宫博物院':
                          Navigator.pushNamed(context, '/spot_detail', arguments: {'spotId': 'gugong'});
                          break;
                        case '天坛公园':
                          Navigator.pushNamed(context, '/spot_detail', arguments: {'spotId': 'tiantan'});
                          break;
                        case '钟鼓楼':
                          Navigator.pushNamed(context, '/spot_detail', arguments: {'spotId': 'zhonggulou'});
                          break;
                        case '前门大街':
                          Navigator.pushNamed(context, '/spot_detail', arguments: {'spotId': 'qianmen'});
                          break;
                        case '永定门':
                          Navigator.pushNamed(context, '/spot_detail', arguments: {'spotId': 'yongdingmen'});
                          break;
                        case '先农坛':
                          Navigator.pushNamed(context, '/spot_detail', arguments: {'spotId': 'xiannongtan'});
                          break;
                        case '什刹海':
                          Navigator.pushNamed(context, '/spot_detail', arguments: {'spotId': 'shichahai'});
                          break;
                        default:
                          Navigator.pushNamed(context, '/search');
                      }
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    return const MapScreen();
  }

  Widget _buildSpotsContent() {
    return const SearchScreen();
  }

  Widget _buildProfileContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Column(
      children: [
        // 顶部装饰背景区域
        Container(
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background/bg6.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // 装饰性背景图案
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // 用户信息
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 28,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? '用户',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user?.role == UserRole.guide ? '导游' : '游客',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 主要内容区域
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 用户功能区域
                  _buildProfileSection(
                    title: '我的服务',
                    items: [
                      {
                        'icon': Icons.favorite,
                        'title': '收藏景点',
                        'subtitle': '查看您收藏的景点',
                        'onTap': () => Navigator.pushNamed(context, '/favorites'),
                      },
                      {
                        'icon': Icons.history,
                        'title': '浏览历史',
                        'subtitle': '查看您的浏览记录',
                        'onTap': () => Navigator.pushNamed(context, '/browsing-history'),
                      },
                      {
                        'icon': Icons.edit,
                        'title': '编辑资料',
                        'subtitle': '修改个人信息',
                        'onTap': () => Navigator.pushNamed(context, '/profile-edit'),
                      },
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 系统功能区域
                  _buildProfileSection(
                    title: '系统设置',
                    items: [
                      {
                        'icon': Icons.settings,
                        'title': '设置',
                        'subtitle': '应用设置与偏好',
                        'onTap': () => Navigator.pushNamed(context, '/settings'),
                      },
                      {
                        'icon': Icons.help_outline,
                        'title': '帮助',
                        'subtitle': '使用帮助与反馈',
                        'onTap': () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('使用帮助'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('中轴奇遇使用指南：'),
                                  SizedBox(height: 8),
                                  Text('• 首页：浏览景点和功能'),
                                  Text('• 地图：查看景点位置'),
                                  Text('• 搜索：查找特定景点'),
                                  Text('• 行程：规划您的旅程'),
                                  Text('• 我的：管理个人信息'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('知道了'),
                                ),
                              ],
                            ),
                          );
                        },
                      },
                      {
                        'icon': Icons.info_outline,
                        'title': '关于',
                        'subtitle': '应用信息与版本',
                        'onTap': () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('关于中轴奇遇'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('版本：1.0.0'),
                                  SizedBox(height: 8),
                                  Text('中轴奇遇是一款专为北京中轴线文化旅游设计的应用。'),
                                  SizedBox(height: 8),
                                  Text('功能特色：'),
                                  Text('• 景点介绍与导航'),
                                  Text('• 智能AI助手'),
                                  Text('• 多语言翻译'),
                                  Text('• 北京中轴线术语库'),
                                  Text('• 文化体验'),
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
                      },
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 底部信息
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '由中轴奇遇团队开发',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '北京中轴线文化旅游应用',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection({required String title, required List<Map<String, dynamic>> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  GestureDetector(
                    onTap: item['onTap'] as VoidCallback?,
                    child: Container(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: Colors.grey[200],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 
