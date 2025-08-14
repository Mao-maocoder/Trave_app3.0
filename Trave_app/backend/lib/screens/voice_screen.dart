import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../services/voice_service.dart';
import '../widgets/optimized_card.dart';
import 'package:flutter/foundation.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({Key? key}) : super(key: key);

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _responseText = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  // 常用语音命令
  final List<Map<String, String>> _voiceCommands = [
    {
      'zh': '导航到故宫',
      'en': 'Navigate to Forbidden City',
      'category': 'navigation'
    },
    {
      'zh': '查询天坛开放时间',
      'en': 'Check Temple of Heaven opening hours',
      'category': 'info'
    },
    {
      'zh': '播放北京介绍',
      'en': 'Play Beijing introduction',
      'category': 'audio'
    },
    {
      'zh': '拍照',
      'en': 'Take a photo',
      'category': 'camera'
    },
    {
      'zh': '翻译这句话',
      'en': 'Translate this sentence',
      'category': 'translation'
    },
    {
      'zh': '查看天气预报',
      'en': 'Check weather forecast',
      'category': 'weather'
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    VoiceService.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    try {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _responseText = '';
      });

      _pulseController.repeat(reverse: true);
      _waveController.repeat();

      await VoiceService.startRecording();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在听您说话...'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('启动语音识别失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    try {
      final audioPath = await VoiceService.stopRecording();
      
      if (audioPath != null && mounted) {
        setState(() {
          _isListening = false;
          _isProcessing = true;
        });

        _pulseController.stop();
        _waveController.stop();

        // 语音识别
        final recognizedText = await VoiceService.speechToText(audioPath);
        
        if (mounted) {
          setState(() {
            _recognizedText = recognizedText;
            _isProcessing = false;
          });

          // 处理语音命令
          await _processVoiceCommand(recognizedText);
        }
      } else if (mounted) {
        setState(() {
          _isListening = false;
        });
        _pulseController.stop();
        _waveController.stop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
        _pulseController.stop();
        _waveController.stop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('语音识别失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processVoiceCommand(String command) async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    // 简单的命令处理逻辑
    String response = '';
    
    if (command.toLowerCase().contains('导航') || command.toLowerCase().contains('navigate')) {
      response = isChinese ? '正在为您导航...' : 'Navigating for you...';
    } else if (command.toLowerCase().contains('时间') || command.toLowerCase().contains('time')) {
      response = isChinese ? '故宫开放时间：8:30-17:00' : 'Forbidden City opening hours: 8:30-17:00';
    } else if (command.toLowerCase().contains('拍照') || command.toLowerCase().contains('photo')) {
      response = isChinese ? '正在打开相机...' : 'Opening camera...';
    } else if (command.toLowerCase().contains('翻译') || command.toLowerCase().contains('translate')) {
      response = isChinese ? '正在启动翻译功能...' : 'Starting translation feature...';
    } else if (command.toLowerCase().contains('天气') || command.toLowerCase().contains('weather')) {
      response = isChinese ? '今天北京天气晴朗，温度20-25度' : 'Today Beijing is sunny, temperature 20-25°C';
    } else {
      response = isChinese ? '我理解您说的：$command，正在处理您的请求...' : 'I understand: $command, processing your request...';
    }

    setState(() {
      _responseText = response;
    });

    // 语音播报回复
    try {
      final lang = isChinese ? 'zh' : 'en';
      final audioPath = await VoiceService.textToSpeech(response, lang: lang);
      await VoiceService.playAudio(audioPath);
    } catch (e) {
      // 语音播报失败不影响主要功能
    }
  }

  void _useVoiceCommand(String command) {
    _recognizedText = command;
    _processVoiceCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isChinese ? '语音助手' : 'Voice Assistant'),
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
                        Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: kSpaceM),
                      Text(
                        isChinese ? '智能语音助手' : 'Smart Voice Assistant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: kFontSizeXxl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      Text(
                        isChinese ? '用语音控制您的旅行体验' : 'Control your travel experience with voice',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: kFontSizeM,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 语音交互区域
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(kSpaceL),
                    child: Column(
                      children: [
                        // 语音按钮
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: GestureDetector(
                              onTap: _isListening ? _stopListening : _startListening,
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _isListening ? _pulseAnimation.value : 1.0,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: _isListening ? AppColors.primary : AppColors.surface,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: _isListening ? 20 : 10,
                                            spreadRadius: _isListening ? 5 : 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isListening ? Icons.stop : Icons.mic,
                                        size: 48,
                                        color: _isListening ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        // 状态指示
                        if (_isListening)
                          AnimatedBuilder(
                            animation: _waveAnimation,
                            builder: (context, child) {
                              return Container(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    final delay = index * 0.1;
                                    final animationValue = (_waveAnimation.value + delay) % 1.0;
                                    final height = 20 + (animationValue * 30);
                                    
                                    return Container(
                                      width: 4,
                                      height: height,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                        
                        // 识别结果
                        if (_recognizedText.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(kSpaceM),
                            margin: const EdgeInsets.only(top: kSpaceL),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(kRadiusM),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.hearing,
                                      color: AppColors.info,
                                      size: 20,
                                    ),
                                    const SizedBox(width: kSpaceS),
                                    Text(
                                      isChinese ? '识别结果' : 'Recognized',
                                      style: const TextStyle(
                                        color: AppColors.info,
                                        fontSize: kFontSizeS,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: kSpaceS),
                                Text(
                                  _recognizedText,
                                  style: const TextStyle(
                                    fontSize: kFontSizeM,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // 助手回复
                        if (_responseText.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(kSpaceM),
                            margin: const EdgeInsets.only(top: kSpaceM),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(kRadiusM),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.smart_toy,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                    const SizedBox(width: kSpaceS),
                                    Text(
                                      isChinese ? '助手回复' : 'Assistant Response',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: kFontSizeS,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: kSpaceS),
                                Text(
                                  _responseText,
                                  style: const TextStyle(
                                    fontSize: kFontSizeM,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // 加载指示器
                        if (_isProcessing)
                          Container(
                            margin: const EdgeInsets.only(top: kSpaceL),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: kSpaceS),
                                Text(
                                  isChinese ? '正在处理...' : 'Processing...',
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: kFontSizeM,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // 常用命令
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(kSpaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '常用语音命令' : 'Common Voice Commands',
                        style: const TextStyle(
                          fontSize: kFontSizeL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _voiceCommands.length,
                          itemBuilder: (context, index) {
                            final command = _voiceCommands[index];
                            final displayText = isChinese ? command['zh']! : command['en']!;
                            return Container(
                              margin: const EdgeInsets.only(right: kSpaceM),
                              child: OptimizedChip(
                                label: displayText,
                                onPressed: () => _useVoiceCommand(displayText),
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                textColor: AppColors.primary,
                                fontSize: 11,
                              ),
                            );
                          },
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
    );
  }
} 