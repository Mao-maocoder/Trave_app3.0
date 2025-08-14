import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../constants.dart';

class VoiceService {
  static const String _baiduApiKey = BaiduVoiceConfig.apiKey;
  static const String _baiduSecretKey = BaiduVoiceConfig.secretKey;
  
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
    if (kIsWeb) throw Exception('Web端暂不支持录音功能');
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

  /// 语音识别（百度语音识别API）
  static Future<String> speechToText(String audioFilePath) async {
    try {
      // 读取音频文件
      final audioFile = File(audioFilePath);
      final audioBytes = await audioFile.readAsBytes();
      
      // 获取百度访问令牌
      final token = await _getBaiduToken();
      
      // 调用百度语音识别API
      final url = Uri.parse(
        'https://vop.baidu.com/server_api?cuid=${BaiduVoiceConfig.appId}&token=$token'
      );
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'audio/pcm;rate=16000',
        },
        body: audioBytes,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] != null && data['result'].isNotEmpty) {
          return data['result'][0];
        } else {
          throw Exception('语音识别失败: ${data['err_msg'] ?? '未知错误'}');
        }
      } else {
        throw Exception('语音识别请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('语音识别错误: $e');
      throw Exception('语音识别服务暂时不可用，请稍后重试');
    }
  }

  /// 语音合成（百度语音合成API）
  static Future<String> textToSpeech(String text, {String lang = 'zh'}) async {
    try {
      // 获取百度访问令牌
      final token = await _getBaiduToken();
      
      // 调用百度语音合成API
      final url = Uri.parse(
        'https://tsn.baidu.com/text2audio?tok=$token&cuid=${BaiduVoiceConfig.appId}&ctp=1&lan=$lang&spd=5&pit=5&vol=5&per=0&tex=${Uri.encodeComponent(text)}'
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // 保存音频文件
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/speech_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(response.bodyBytes);
        return audioFile.path;
      } else {
        throw Exception('语音合成请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('语音合成错误: $e');
      throw Exception('语音合成服务暂时不可用，请稍后重试');
    }
  }

  /// 播放音频
  static Future<void> playAudio(String audioFilePath) async {
    try {
      _isPlaying = true;
      await _audioPlayer.play(DeviceFileSource(audioFilePath));
    } catch (e) {
      print('播放音频错误: $e');
      throw Exception('音频播放失败');
    } finally {
      _isPlaying = false;
    }
  }

  /// 停止播放
  static Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  /// 检查是否正在播放
  static bool get isPlaying => _isPlaying;

  /// 获取百度访问令牌
  static Future<String> _getBaiduToken() async {
    try {
      final url = Uri.parse(
        'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=$_baiduApiKey&client_secret=$_baiduSecretKey'
      );
      
      final response = await http.post(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        throw Exception('获取百度访问令牌失败');
      }
    } catch (e) {
      print('获取百度令牌错误: $e');
      throw Exception('无法获取语音服务授权');
    }
  }

  /// 释放资源
  static Future<void> dispose() async {
    if (_audioRecorder != null) {
      await _audioRecorder!.dispose();
    }
    await _audioPlayer.dispose();
  }
} 