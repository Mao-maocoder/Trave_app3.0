// lib/services/voice_service_web_stub.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

// Web端语音服务存根实现
class VoiceService {
  static bool _isRecording = false;
  static bool _isPlaying = false;
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// 开始录音（Web端不支持）
  static Future<void> startRecording() async {
    if (kIsWeb) {
      throw Exception('Web端暂不支持录音功能，请使用移动端应用');
    }
  }

  /// 停止录音（Web端不支持）
  static Future<String?> stopRecording() async {
    if (kIsWeb) {
      return null;
    }
    return null;
  }

  /// 检查是否正在录音
  static bool get isRecording => _isRecording;

  /// 语音识别（Web端存根）
  static Future<String> speechToText(String audioFilePath) async {
    throw Exception('Web端暂不支持语音识别功能，请使用移动端应用');
  }

  /// 语音合成（Web端存根）
  static Future<String> textToSpeech(String text, {String lang = 'zh'}) async {
    throw Exception('Web端暂不支持语音合成功能，请使用移动端应用');
  }

  /// 播放音频（Web端支持）
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

  /// 释放资源
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
} 