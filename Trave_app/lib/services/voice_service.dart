import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/api_host.dart';
import 'dart:js' as js;
import 'auth_service.dart';

class VoiceService {
  static AudioRecorder? _audioRecorder;
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static bool _isRecording = false;
  static bool _isPlaying = false;

  /// 初始化录音器
  static Future<void> _initRecorder() async {
    if (_audioRecorder == null && !kIsWeb) {
      _audioRecorder = AudioRecorder();
    }
  }

  /// 开始录音
  static Future<void> startRecording() async {
    if (kIsWeb) {
      // Web端使用浏览器原生录音API
      throw Exception('Web端暂不支持录音功能，请使用移动端应用');
    }
    
    await _initRecorder();
    
    if (_audioRecorder != null && await _audioRecorder!.hasPermission()) {
      // 获取临时目录路径
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      _isRecording = true;
    } else {
      throw Exception('没有录音权限');
    }
  }

  /// 停止录音并返回音频文件路径
  static Future<String?> stopRecording() async {
    if (kIsWeb) return null;
    
    if (_isRecording && _audioRecorder != null) {
      final path = await _audioRecorder!.stop();
      _isRecording = false;
      return path;
    }
    return null;
  }

  /// 检查是否正在录音
  static bool get isRecording => _isRecording;

  /// 语音识别（通过后端API）
  static Future<String> speechToText(String audioFilePath) async {
    try {
      // 读取音频文件
      final audioFile = File(audioFilePath);
      final audioBytes = await audioFile.readAsBytes();
      
      // 创建multipart请求
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${getApiBaseUrl()}/voice/speech-to-text'),
      );
      
      // 添加音频文件
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'recording.m4a',
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['text'] != null) {
          return data['text'];
        } else {
          throw Exception('语音识别失败: ${data['message'] ?? '未知错误'}');
        }
      } else {
        throw Exception('语音识别请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('语音识别错误: $e');
      throw Exception('语音识别服务暂时不可用，请稍后重试');
    }
  }

  /// 语音合成（优先使用浏览器原生，回退到后端API）
  static Future<String> textToSpeech(String text, {String lang = 'zh'}) async {
    try {
      print('开始语音合成，文本: $text');
      
      // 优先使用浏览器原生语音合成（更稳定）
      if (kIsWeb) {
        try {
          await _textToSpeechWeb(text, lang);
          // 返回一个虚拟URL，表示使用浏览器原生合成
          return 'browser-native-tts';
        } catch (e) {
          print('浏览器语音合成失败，尝试后端API: $e');
        }
      }
      
      // 如果浏览器不支持或失败，使用后端API
      try {
        final response = await AuthService.authorizedRequest(
          Uri.parse('${getApiBaseUrl()}/voice/text-to-speech'),
          method: 'POST',
          body: jsonEncode({
            'text': text,
            'lang': lang,
          }),
        );

        print('语音合成API响应状态: ${response.statusCode}');
        print('语音合成API响应内容: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['audioUrl'] != null) {
            // 返回完整的音频URL，避免重复/api
            String audioUrl = data['audioUrl'];
            if (audioUrl.startsWith('/api/')) {
              audioUrl = '${getApiBase()}$audioUrl';
            } else {
              audioUrl = '${getApiBaseUrl()}$audioUrl';
            }
            print('生成的音频URL: $audioUrl');
            return audioUrl;
          } else {
            throw Exception('语音合成失败: ${data['message'] ?? '未知错误'}');
          }
        } else {
          throw Exception('语音合成请求失败: ${response.statusCode}');
        }
      } catch (e) {
        print('后端语音合成也失败: $e');
        throw Exception('所有语音合成方式都失败');
      }
    } catch (e) {
      print('语音合成错误: $e');
      throw Exception('语音合成服务暂时不可用，请稍后重试');
    }
  }

  /// Web端浏览器原生语音合成
  static Future<void> _textToSpeechWeb(String text, String lang) async {
    try {
      print('使用浏览器原生语音合成: $text');
      
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
              console.log('Web Speech Synthesis started');
            };
            
            utterance.onend = () => {
              console.log('Web Speech Synthesis ended');
              resolve('success');
            };
            
            utterance.onerror = (event) => {
              console.log('Web Speech Synthesis error:', event.error);
              reject(event.error);
            };
            
            window.speechSynthesis.speak(utterance);
          });
        })();
      ''']);
      
      // 等待语音合成完成
      await Future.delayed(const Duration(seconds: 2));
      print('浏览器语音合成完成');
      
    } catch (e) {
      print('浏览器语音合成错误: $e');
      throw Exception('浏览器语音合成失败: $e');
    }
  }

  /// 播放音频
  static Future<void> playAudio(String audioUrl) async {
    try {
      print('开始播放音频: $audioUrl');
      _isPlaying = true;
      
      if (kIsWeb) {
        if (audioUrl == 'browser-native-tts') {
          // 浏览器原生语音合成，不需要额外播放
          print('浏览器原生语音合成，无需额外播放');
        } else {
          // Web端使用HTML5 Audio API
          await _playAudioWeb(audioUrl);
        }
      } else {
        // 移动端使用AudioPlayer，添加更多错误处理和重试机制
        try {
          // 确保URL是完整的
          String fullUrl = audioUrl;
          if (!audioUrl.startsWith('http')) {
            // 如果是相对路径，添加基础URL
            fullUrl = '${getApiBase()}$audioUrl';
          }
          print('移动端播放完整URL: $fullUrl');
          
          // 设置播放源
          await _audioPlayer.play(UrlSource(fullUrl));
          
          // 等待播放开始
          await Future.delayed(const Duration(milliseconds: 500));
          
          // 检查播放状态
          final state = _audioPlayer.state;
          print('音频播放状态: $state');
          
          if (state == PlayerState.stopped) {
            throw Exception('音频播放失败：播放器状态异常');
          }
          
        } catch (e) {
          print('移动端音频播放失败，尝试备用方案: $e');
          
          // 备用方案：尝试不同的播放方式
          try {
            await _audioPlayer.stop(); // 先停止
            await Future.delayed(const Duration(milliseconds: 100));
            
            // 重新尝试播放
            String fullUrl = audioUrl.startsWith('http') ? audioUrl : '${getApiBase()}$audioUrl';
            await _audioPlayer.play(UrlSource(fullUrl));
            
          } catch (e2) {
            print('备用播放方案也失败: $e2');
            throw Exception('移动端音频播放失败: $e2');
          }
        }
      }
      
      print('音频播放成功');
    } catch (e) {
      print('播放音频错误: $e');
      throw Exception('音频播放失败: $e');
    } finally {
      _isPlaying = false;
    }
  }

  /// Web端音频播放
  static Future<void> _playAudioWeb(String audioUrl) async {
    try {
      print('Web端开始播放音频: $audioUrl');
      
      // 使用JavaScript直接播放音频，避免Dart-HTML互操作问题
      final result = js.context.callMethod('eval', ['''
        (function() {
          return new Promise((resolve, reject) => {
            const audio = new Audio('$audioUrl');
            audio.autoplay = true;
            audio.controls = false;
            
            audio.addEventListener('loadeddata', () => {
              console.log('Web端音频加载完成');
            });
            
            audio.addEventListener('canplay', () => {
              console.log('Web端音频可以播放');
            });
            
            audio.addEventListener('play', () => {
              console.log('Web端音频开始播放');
            });
            
            audio.addEventListener('ended', () => {
              console.log('Web端音频播放完成');
              resolve('success');
            });
            
            audio.addEventListener('error', (e) => {
              console.log('Web端音频播放错误:', e);
              reject('音频播放失败');
            });
            
            // 设置超时
            setTimeout(() => {
              if (audio.readyState >= 2) { // HAVE_CURRENT_DATA
                console.log('Web端音频播放超时，但已加载');
                resolve('timeout');
              } else {
                reject('音频加载超时');
              }
            }, 10000);
          });
        })();
      ''']);
      
      print('Web端音频播放完成');
      
    } catch (e) {
      print('Web端音频播放错误: $e');
      throw Exception('Web端音频播放失败: $e');
    }
  }

  /// 停止播放
  static Future<void> stopAudio() async {
    if (kIsWeb) {
      // Web端停止播放
      try {
        // 使用JavaScript停止所有音频
        js.context.callMethod('eval', ['''
          (function() {
            const audioElements = document.querySelectorAll('audio');
            audioElements.forEach(audio => audio.pause());
          })();
        ''']);
      } catch (e) {
        print('Web端停止播放错误: $e');
      }
    } else {
      // 移动端停止播放
      await _audioPlayer.stop();
    }
    _isPlaying = false;
  }

  /// 检查是否正在播放
  static bool get isPlaying => _isPlaying;

  /// 释放资源
  static Future<void> dispose() async {
    if (_audioRecorder != null) {
      await _audioRecorder!.dispose();
    }
    await _audioPlayer.dispose();
  }
} 