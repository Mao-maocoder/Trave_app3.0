import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/music_service.dart';
import '../constants.dart';

class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  final List<Map<String, String>> chapters = [
    {'title': '第一乐章', 'name': '一城永定'},
    {'title': '第二乐章', 'name': '坛根儿情'},
    {'title': '第三乐章', 'name': '正阳雨燕'},
    {'title': '第四乐章', 'name': '天安九州'},
    {'title': '第五乐章', 'name': '紫禁三和'},
    {'title': '第六乐章', 'name': '景山万春'},
    {'title': '第七乐章', 'name': '水润万宁'},
    {'title': '第八乐章', 'name': '钟鼓合鸣'},
    {'title': '第九乐章', 'name': '国之中轴'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    _fadeController.forward();
    _slideController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxContentWidth = 500;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return kTitleGradient.createShader(bounds);
                },
                child: const Text(
                  '《中轴》大型民族管弦乐专题',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontFamily: kFontFamilyTitle,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // 动态背景渐变
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
            ),
          ),
          
          // 浮动音符装饰
          _buildFloatingNotes(),
          
          // 主要内容
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildMainContent(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF3E5F5),
                Color(0xFFE1BEE7),
                Color(0xFFEDE7F6),
                Color(0xFFE8EAF6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.7, 1.0],
              transform: GradientRotation(_waveAnimation.value * 0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingNotes() {
    return Stack(
      children: List.generate(8, (index) {
        return AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            double offset = _waveAnimation.value + (index * 0.3);
            return Positioned(
              left: 50 + (index * 60) + (math.sin(offset) * 30),
              top: 100 + (index * 80) + (math.cos(offset * 0.8) * 20),
              child: Transform.rotate(
                angle: offset * 0.5,
                child: Opacity(
                  opacity: 0.05 + (math.sin(offset) * 0.03),
                  child: Icon(
                    index % 3 == 0 ? Icons.music_note : 
                    index % 3 == 1 ? Icons.music_note_outlined : 
                    Icons.audiotrack,
                    size: 40 + (index % 3) * 20,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80), // 为AppBar留出空间
        _buildHeroImage(),
        const SizedBox(height: 32),
        _buildSubtitle(),
        const SizedBox(height: 24),
        _buildDescription(),
        const SizedBox(height: 32),
        _buildChaptersList(),
        const SizedBox(height: 40),
        _buildFooter(),
        const SizedBox(height: 40), // 底部留白
      ],
    );
  }

  Widget _buildHeroImage() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 400,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadiusXl),
              gradient: kAccentGradient,
              boxShadow: kShadowLarge,
            ),
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 80,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return kSubtitleGradient.createShader(bounds);
          },
          child: const Text(
            'Central Axis National Orchestra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.5,
              fontFamily: kFontFamilyTitle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(kSpaceL),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '《中轴》大型民族管弦乐以北京中轴线为灵感，融合多民族音乐元素，展现中华文明的历史底蕴与现代风采。全曲共九个乐章，带领观众穿越古今，感受中轴线的文化魅力。',
        style: TextStyle(
          fontSize: 16, 
          color: kTextSecondary, 
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildChaptersList() {
    return Column(
      children: chapters.asMap().entries.map((entry) {
        int idx = entry.key;
        var chapter = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (idx * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 50),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, 
                          vertical: 8
                        ),
                        leading: Container(
                          width: 16,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple[400]!,
                                Colors.purple[200]!,
                                Colors.deepPurple[100]!,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          chapter['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                        subtitle: Text(
                          chapter['name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.play_circle_filled,
                          color: Colors.deepPurple[300],
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Container(
              height: 3,
              width: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple[300]!,
                    Colors.purple[200]!,
                    Colors.deepPurple[100]!,
                  ],
                  stops: [
                    0.0,
                    0.5 + (math.sin(_waveAnimation.value) * 0.3),
                    1.0,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          '北京中轴线·民族音乐文化',
          style: TextStyle(
            color: Colors.deepPurple[400],
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}