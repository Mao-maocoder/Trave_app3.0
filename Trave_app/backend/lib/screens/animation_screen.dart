import 'package:flutter/material.dart';
import '../constants.dart';
import '../theme.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({Key? key}) : super(key: key);

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentIndex = 0;
  bool _isPlaying = false;

  final List<Map<String, dynamic>> _animations = [
    {
      'title': '故宫全景',
      'subtitle': '紫禁城的宏伟建筑群',
      'description': '通过3D动画展示故宫的整体布局和建筑特色，感受古代皇家建筑的恢宏气势。',
      'duration': '2:30',
      'type': '3D建筑',
    },
    {
      'title': '天坛祈年殿',
      'subtitle': '古代祭天仪式重现',
      'description': '重现古代皇帝祭天的庄严仪式，展现天坛建筑的精美结构和文化内涵。',
      'duration': '3:15',
      'type': '历史重现',
    },
    {
      'title': '中轴线鸟瞰',
      'subtitle': '从空中俯瞰古都',
      'description': '从高空视角展示北京中轴线的完整布局，感受古都规划的精妙之处。',
      'duration': '4:20',
      'type': '航拍视角',
    },
    {
      'title': '胡同生活',
      'subtitle': '老北京的市井风情',
      'description': '展现老北京胡同里的日常生活场景，感受传统与现代的完美融合。',
      'duration': '2:45',
      'type': '生活场景',
    },
    {
      'title': '钟鼓楼',
      'subtitle': '古代报时系统',
      'description': '展示古代钟鼓楼的报时功能，了解古代时间管理的方式。',
      'duration': '1:50',
      'type': '功能展示',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _playAnimation() {
    setState(() {
      _isPlaying = true;
    });
    _controller.forward().then((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  void _nextAnimation() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _animations.length;
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _previousAnimation() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _animations.length) % _animations.length;
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentAnimation = _animations[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('动画展示'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              // TODO: 实现全屏播放
            },
          ),
        ],
      ),
      body: Column(
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
                  Icons.animation_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: kSpaceM),
                const Text(
                  '中轴线动画',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: kFontSizeXxl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kSpaceS),
                const Text(
                  '通过动画感受古都魅力',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: kFontSizeM,
                  ),
                ),
              ],
            ),
          ),
          
          // 动画播放区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(kSpaceL),
              child: Column(
                children: [
                  // 动画预览区域
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: kAccentGradient,
                        borderRadius: BorderRadius.circular(kRadiusXl),
                        boxShadow: kShadowHeavy,
                      ),
                      child: Stack(
                        children: [
                          // 动画内容
                          Center(
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(kRadiusL),
                                    ),
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // 播放状态指示器
                          if (_isPlaying)
                            Positioned(
                              top: kSpaceM,
                              right: kSpaceM,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: kSpaceM,
                                  vertical: kSpaceS,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(kRadiusM),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: kSpaceS),
                                    Text(
                                      '播放中',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: kFontSizeS,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          // 动画信息
                          Positioned(
                            bottom: kSpaceL,
                            left: kSpaceL,
                            right: kSpaceL,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(kSpaceM),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(kRadiusM),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentAnimation['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: kFontSizeL,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: kSpaceS),
                                      Text(
                                        currentAnimation['subtitle'],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: kFontSizeM,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceL),
                  
                  // 控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _previousAnimation,
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 32,
                        color: AppColors.primary,
                      ),
                      GestureDetector(
                        onTap: _playAnimation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: kPrimaryGradient,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: kShadowMedium,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _nextAnimation,
                        icon: const Icon(Icons.skip_next),
                        iconSize: 32,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: kSpaceL),
                  
                  // 动画信息卡片
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(kSpaceL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(kRadiusL),
                        boxShadow: kShadowMedium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentAnimation['title'],
                                style: const TextStyle(
                                  fontSize: kFontSizeXl,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: kSpaceM,
                                  vertical: kSpaceS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(kRadiusM),
                                ),
                                child: Text(
                                  currentAnimation['type'],
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: kFontSizeS,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: kSpaceM),
                          
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: kSpaceS),
                              Text(
                                '时长: ${currentAnimation['duration']}',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: kFontSizeS,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: kSpaceM),
                          
                          Expanded(
                            child: Text(
                              currentAnimation['description'],
                              style: const TextStyle(
                                fontSize: kFontSizeM,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部导航指示器
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: kSpaceM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_animations.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    _fadeController.reset();
                    _slideController.reset();
                    _fadeController.forward();
                    _slideController.forward();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index 
                          ? AppColors.primary 
                          : AppColors.textLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
} 