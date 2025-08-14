import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../services/guide_service.dart';
import '../constants.dart';

class BindGuideScreen extends StatefulWidget {
  const BindGuideScreen({Key? key}) : super(key: key);

  @override
  State<BindGuideScreen> createState() => _BindGuideScreenState();
}

class _BindGuideScreenState extends State<BindGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guideIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _guideIdController.dispose();
    super.dispose();
  }

  Future<void> _sendBindingRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      
      // 获取导游信息验证
      final guideInfo = await GuideService.getGuideInfo(_guideIdController.text);
      
      // 发送绑定请求
      final success = await GuideService.handleBindingRequest(
        _guideIdController.text, 
        true
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isChinese ? '绑定请求已发送' : 'Binding request sent')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isChinese ? '绑定请求失败' : 'Failed to send binding request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '绑定导游' : 'Bind Guide'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 导游ID输入框
              TextFormField(
                controller: _guideIdController,
                decoration: InputDecoration(
                  labelText: isChinese ? '导游ID' : 'Guide ID',
                  hintText: isChinese ? '请输入导游ID' : 'Enter guide ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isChinese ? '请输入导游ID' : 'Please enter guide ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendBindingRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isChinese ? '发送绑定请求' : 'Send Binding Request',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
