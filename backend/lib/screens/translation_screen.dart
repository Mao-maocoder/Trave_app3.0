import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../utils/api_host.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  String _fromLanguage = 'zh';
  String _toLanguage = 'en';

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final input = _inputController.text;
    if (input.isEmpty) return;

    setState(() {
      _outputController.text = '翻译中...';
    });

    try {
      final url = Uri.parse('${getApiBaseUrl()}/api/translate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': input,
          'from': _fromLanguage,
          'to': _toLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _outputController.text = data['translation'] ?? '翻译失败';
          });
        } else {
          setState(() {
            _outputController.text = '翻译失败: ${data['message'] ?? '未知错误'}';
          });
        }
      } else {
        setState(() {
          _outputController.text = '翻译服务暂时不可用';
        });
      }
    } catch (e) {
      setState(() {
        _outputController.text = '翻译失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('智能翻译'),
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 语言选择
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromLanguage,
                    decoration: const InputDecoration(
                      labelText: '源语言',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'zh', child: Text('中文')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _fromLanguage = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = _fromLanguage;
                      _fromLanguage = _toLanguage;
                      _toLanguage = temp;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toLanguage,
                    decoration: const InputDecoration(
                      labelText: '目标语言',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'zh', child: Text('中文')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _toLanguage = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 输入区域
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '请输入要翻译的文本',
                border: OutlineInputBorder(),
                hintText: '在这里输入您要翻译的内容...',
              ),
            ),
            const SizedBox(height: 16),
            
            // 翻译按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _translate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('翻译'),
              ),
            ),
            const SizedBox(height: 24),
            
            // 输出区域
            TextField(
              controller: _outputController,
              maxLines: 4,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '翻译结果',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 