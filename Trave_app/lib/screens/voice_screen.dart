import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../widgets/user_avatar.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../services/voice_service.dart';
import '../utils/api_host.dart';
import '../widgets/optimized_card.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

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

  // Web端语音识别
  dynamic _speechRecognition;
  bool _isWebSpeechSupported = false;

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

    // 初始化Web端语音识别
    if (kIsWeb) {
      _initWebSpeechRecognition();
    }
  }

  void _initWebSpeechRecognition() {
    try {
      // 检查浏览器是否支持语音识别
      if (kIsWeb) {
        final flutterWebSpeech = js.context['flutterWebSpeech'];
        _isWebSpeechSupported = flutterWebSpeech != null;
        if (_isWebSpeechSupported) {
          _speechRecognition = flutterWebSpeech['SpeechRecognition'];
        }
      } else {
        _isWebSpeechSupported = false;
      }
    } catch (e) {
      print('Web Speech API initialization error: $e');
      _isWebSpeechSupported = false;
    }
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

      if (kIsWeb) {
        // Web端使用浏览器原生语音识别
        if (_isWebSpeechSupported) {
          await _startWebSpeechRecognition();
        } else {
          throw Exception('您的浏览器不支持语音识别功能');
        }
      } else {
        // 移动端使用原生录音
        await VoiceService.startRecording();
      }
      
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
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  Future<void> _startWebSpeechRecognition() async {
    try {
      // 使用更简单的方法，避免Promise转换问题
      final result = js.context.callMethod('eval', ['''
        (function() {
          return new Promise((resolve, reject) => {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            if (!SpeechRecognition) {
              reject('Speech Recognition not supported');
              return;
            }
            
            const recognition = new SpeechRecognition();
            recognition.continuous = false;
            recognition.interimResults = false;
            recognition.lang = 'zh-CN';
            
            recognition.onstart = () => {
              console.log('Web Speech Recognition started');
            };
            
            recognition.onresult = (event) => {
              console.log('Web Speech Recognition result received');
              const results = event.results;
              if (results && results.length > 0) {
                const transcript = results[0][0].transcript;
                console.log('Recognized text:', transcript);
                resolve(transcript);
              } else {
                reject('No results');
              }
            };
            
            recognition.onerror = (event) => {
              console.log('Web Speech Recognition error:', event.error);
              reject(event.error);
            };
            
            recognition.onend = () => {
              console.log('Web Speech Recognition ended');
            };
            
            recognition.start();
          });
        })();
      ''']);
      
      // 使用setTimeout等待结果，避免Promise转换问题
      String? transcript;
      bool hasResult = false;
      
      // 设置全局回调
      js.context['handleSpeechResult'] = js.allowInterop((text) {
        transcript = text;
        hasResult = true;
      });
      
      js.context['handleSpeechError'] = js.allowInterop((error) {
        hasResult = true;
        throw Exception(error);
      });
      
      // 修改JS代码，使用回调而不是Promise
      js.context.callMethod('eval', ['''
        (function() {
          const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
          if (!SpeechRecognition) {
            window.handleSpeechError('Speech Recognition not supported');
            return;
          }
          
          const recognition = new SpeechRecognition();
          recognition.continuous = false;
          recognition.interimResults = false;
          recognition.lang = 'zh-CN';
          
          recognition.onstart = () => {
            console.log('Web Speech Recognition started');
          };
          
          recognition.onresult = (event) => {
            console.log('Web Speech Recognition result received');
            const results = event.results;
            if (results && results.length > 0) {
              const transcript = results[0][0].transcript;
              console.log('Recognized text:', transcript);
              window.handleSpeechResult(transcript);
            } else {
              window.handleSpeechError('No results');
            }
          };
          
          recognition.onerror = (event) => {
            console.log('Web Speech Recognition error:', event.error);
            window.handleSpeechError(event.error);
          };
          
          recognition.onend = () => {
            console.log('Web Speech Recognition ended');
          };
          
          recognition.start();
        })();
      ''']);
      
      // 等待结果
      int timeout = 0;
      while (!hasResult && timeout < 100) {
        await Future.delayed(const Duration(milliseconds: 100));
        timeout++;
      }
      
      if (transcript != null) {
        print('Received transcript: $transcript');
        if (mounted) {
          setState(() {
            _recognizedText = transcript!;
            _isListening = false;
          });
          _pulseController.stop();
          _waveController.stop();
          
          // 处理语音命令
          await _processVoiceCommand(transcript!);
        }
      } else {
        throw Exception('语音识别超时');
      }
      
    } catch (e) {
      print('Web Speech Recognition error: $e');
      // 如果Web Speech API失败，回退到文本输入
      await _showTextInputDialog();
    }
  }

  Future<void> _showTextInputDialog() async {
    if (mounted) {
      final TextEditingController textController = TextEditingController();
      
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('语音输入'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('由于浏览器限制，请手动输入您要说的话：'),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: '请输入您的问题或命令...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    Navigator.of(context).pop(value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(textController.text);
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          _recognizedText = result;
          _isListening = false;
        });
        _pulseController.stop();
        _waveController.stop();

        // 处理语音命令
        await _processVoiceCommand(result);
      } else {
        setState(() {
          _isListening = false;
        });
        _pulseController.stop();
        _waveController.stop();
      }
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    try {
      if (kIsWeb) {
        // Web端停止语音识别
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
        _pulseController.stop();
        _waveController.stop();
      } else {
        // 移动端停止录音
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
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  Future<void> _processVoiceCommand(String command) async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    setState(() {
      _isProcessing = true;
      _responseText = isChinese ? '正在思考中...' : 'Thinking...';
    });

    try {
      // 调用AI助手API来生成智能回复
      final response = await _callAIAssistant(command);
      
      setState(() {
        _responseText = response;
        _isProcessing = false;
      });

      // 语音合成回复
      try {
        print('开始语音合成...');
        final audioUrl = await VoiceService.textToSpeech(response);
        print('语音合成完成，开始播放: $audioUrl');
        
        // 显示播放状态
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isChinese ? '正在播放语音回复...' : 'Playing audio response...'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        
        // 移动端音频播放调试
        if (!kIsWeb) {
          print('🔄 移动端音频播放调试信息:');
          print('- 音频URL: $audioUrl');
          print('- 完整URL: ${audioUrl.startsWith('http') ? audioUrl : '${getApiBase()}$audioUrl'}');
          print('- 平台: ${Platform.operatingSystem}');
        }
        
        await VoiceService.playAudio(audioUrl);
        print('语音播放完成');
        
        // 播放完成提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isChinese ? '语音播放完成' : 'Audio playback completed'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        print('语音合成或播放失败: $e');
        // 如果语音合成失败，至少显示文本回复
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isChinese ? '语音播放失败，但已显示文字回复' : 'Audio playback failed, but text response is shown'),
              duration: const Duration(seconds: 3),
              backgroundColor: kWarningColor,
            ),
          );
        }
      }
    } catch (e) {
      print('AI助手调用失败: $e');
      setState(() {
        _isProcessing = false;
        _responseText = isChinese ? '抱歉，我现在无法回答您的问题，请稍后重试。' : 'Sorry, I cannot answer your question right now, please try again later.';
      });
    }
  }

  Future<String> _callAIAssistant(String message) async {
    try {
      final requestBody = {
        'message': message,
      };
      
      print('📤 发送请求数据: ${jsonEncode(requestBody)}');
      
      final response = await AuthService.authorizedRequest(
        Uri.parse('${getApiBaseUrl()}/ai/chat'),
        method: 'POST',
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['response'] != null) {
          return data['response'];
        } else {
          throw Exception(data['message'] ?? 'AI回复解析失败');
        }
      } else {
        throw Exception('AI助手请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('AI助手调用错误: $e');
      // 如果AI调用失败，返回一个基本的回复
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      return isChinese ? '我理解您说的：$message，这是一个很好的问题。不过我现在无法提供详细的回答，建议您稍后重试或查看应用中的相关信息。' : 'I understand what you said: $message, that\'s a great question. However, I cannot provide a detailed answer right now. Please try again later or check the relevant information in the app.';
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
            title: const Text('语音助手', style: TextStyle(fontFamily: kFontFamilyTitle)),
            backgroundColor: kPrimaryColor,
            foregroundColor: kWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // 用户头像
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;
                  final avatarUrl = user?.avatar;
                  final fullAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty 
                      ? '${getApiBase()}${avatarUrl}' 
                      : null;
                  
                  // 调试信息
                  if (fullAvatarUrl != null) {
                    print('🖼️ 语音助手头像URL: $fullAvatarUrl');
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: UserAvatar(
                      radius: 16,
                      backgroundColor: kWhite.withOpacity(0.2),
                      textColor: kWhite,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              // 语言切换按钮
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(kRadiusL),
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
                        color: kWhite,
                        size: 32,
                      ),
                      const SizedBox(height: kSpaceM),
                      Text(
                        isChinese ? '智能语音助手' : 'Smart Voice Assistant',
                        style: const TextStyle(
                          color: kWhite,
                          fontSize: kFontSizeXxl,
                          fontWeight: FontWeight.bold,
                          fontFamily: kFontFamilyTitle,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      Text(
                        isChinese ? '用语音控制您的旅行体验' : 'Control your travel experience with voice',
                        style: const TextStyle(
                          color: kWhite70,
                          fontSize: kFontSizeM,
                          fontFamily: kFontFamilyTitle,
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
                        // 语音按钮区域
                        Expanded(
                          flex: 2,
                          child: Stack(
                            children: [
                              // 主要语音按钮
                              Center(
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
                                            color: _isListening ? kPrimaryColor : kSurfaceColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: kPrimaryColor.withOpacity(0.3),
                                                blurRadius: _isListening ? 20 : 10,
                                                spreadRadius: _isListening ? 5 : 2,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _isListening ? Icons.stop : Icons.mic,
                                            size: 48,
                                            color: _isListening ? kWhite : kPrimaryColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              // 测试语音输出按钮 - 右上角
                              Positioned(
                                top: 16,
                                right: 16,
                                child: ElevatedButton.icon(
                                  onPressed: _isProcessing ? null : () async {
                                    try {
                                      setState(() {
                                        _isProcessing = true;
                                      });
                                      
                                      final testText = isChinese ? '这是一个语音输出测试' : 'This is a voice output test';
                                      
                                      // 直接使用浏览器原生语音合成
                                      if (kIsWeb) {
                                        await _speakText(testText, isChinese ? 'zh' : 'en');
                                      } else {
                                        final audioUrl = await VoiceService.textToSpeech(testText);
                                        await VoiceService.playAudio(audioUrl);
                                      }
                                      
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(isChinese ? '测试语音播放完成' : 'Test audio completed'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('测试失败: $e'),
                                            backgroundColor: kErrorColor,
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.volume_up, size: 16),
                                  label: Text(isChinese ? '测试' : 'Test'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kSuccessColor,
                                    foregroundColor: kWhite,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(kRadiusS),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 使用说明
                        if (_recognizedText.isEmpty && _responseText.isEmpty && !_isListening)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: kSpaceM),
                            padding: const EdgeInsets.all(kSpaceM),
                            decoration: BoxDecoration(
                              color: kInfoColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(kRadiusM),
                              border: Border.all(
                                color: kInfoColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.mic,
                                  color: kInfoColor,
                                  size: 32,
                                ),
                                const SizedBox(height: kSpaceS),
                                Text(
                                  isChinese ? '点击麦克风开始对话' : 'Tap microphone to start conversation',
                                  style: const TextStyle(
                                    color: kInfoColor,
                                    fontSize: kFontSizeM,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: kFontFamilyTitle,
                                  ),
                                ),
                                const SizedBox(height: kSpaceS),
                                Text(
                                  isChinese ? '说出您的问题，AI会自动回复并播放语音' : 'Ask your question, AI will reply and play audio automatically',
                                  style: const TextStyle(
                                    color: kTextSecondaryColor,
                                    fontSize: kFontSizeS,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                        
                        // 对话内容区域 - 使用Expanded确保不会挤压按钮
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: kSpaceL),
                            child: Column(
                              children: [
                                // 识别结果
                                if (_recognizedText.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(kSpaceM),
                                    margin: const EdgeInsets.only(bottom: kSpaceM),
                                    decoration: BoxDecoration(
                                      color: kInfoColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(kRadiusM),
                                      border: Border.all(
                                        color: kInfoColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.hearing,
                                              color: kInfoColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: kSpaceS),
                                            Text(
                                              isChinese ? '识别结果' : 'Recognized',
                                              style: const TextStyle(
                                                color: kInfoColor,
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
                                            color: kTextPrimaryColor,
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
                                    margin: const EdgeInsets.only(bottom: kSpaceM),
                                    decoration: BoxDecoration(
                                      color: kSuccessColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(kRadiusM),
                                      border: Border.all(
                                        color: kSuccessColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.smart_toy,
                                              color: kSuccessColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: kSpaceS),
                                            Text(
                                              isChinese ? '助手回复' : 'Assistant Response',
                                              style: const TextStyle(
                                                color: kSuccessColor,
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
                                            color: kTextPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                // 加载指示器
                                if (_isProcessing)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: kSpaceM),
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
                                            color: kTextSecondaryColor,
                                            fontSize: kFontSizeS,
                                          ),
                                        ),
                                      ],
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
                          fontFamily: kFontFamilyTitle,
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
                                backgroundColor: kPrimaryColor.withOpacity(0.1),
                                textColor: kPrimaryColor,
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

  /// 简单的浏览器语音合成方法
  Future<void> _speakText(String text, String lang) async {
    try {
      print('开始浏览器语音合成: $text');
      
      final result = js.context.callMethod('eval', ['''
        (function() {
          return new Promise((resolve, reject) => {
            if (!window.speechSynthesis) {
              reject('Speech Synthesis not supported');
              return;
            }
            
            const utterance = new SpeechSynthesisUtterance('$text');
            utterance.lang = '$lang';
            utterance.rate = 0.9;
            utterance.pitch = 1.0;
            utterance.volume = 1.0;
            
            utterance.onstart = () => {
              console.log('Speech Synthesis started');
            };
            
            utterance.onend = () => {
              console.log('Speech Synthesis ended');
              resolve('success');
            };
            
            utterance.onerror = (event) => {
              console.log('Speech Synthesis error:', event.error);
              reject(event.error);
            };
            
            window.speechSynthesis.speak(utterance);
          });
        })();
      ''']);
      
      print('浏览器语音合成完成');
      
    } catch (e) {
      print('浏览器语音合成错误: $e');
      throw Exception('浏览器语音合成失败: $e');
    }
  }
}