import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../constants.dart';
import '../widgets/user_avatar.dart';
import '../providers/locale_provider.dart';
import '../utils/api_host.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _contactController = TextEditingController();
  
  int _rating = 5;
  String _selectedCategory = '功能建议';
  bool _isSubmitting = false;

  List<String> _getCategories(bool isChinese) {
    return isChinese ? [
      '服务体验',
      '行程安排',
      '文化体验',
      '导游专业度',
      '景点选择',
      '其他'
    ] : [
      'Service Experience',
              'Knight Codebook Arrangement',
      'Cultural Experience',
      'Guide Professionalism',
      'Attraction Selection',
      'Other'
    ];
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user == null) {
        throw Exception('用户未登录');
      }

      final response = await http.post(
        Uri.parse('${getApiBaseUrl(path: '/api/feedback/submit')}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.id,
          'username': user.username,
          'rating': _rating,
          'content': _feedbackController.text.trim(),
          'category': _selectedCategory,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
          final isChinese = localeProvider.locale == AppLocale.zh;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isChinese ? '评价提交成功！感谢您的宝贵意见' : 'Feedback submitted successfully! Thank you for your valuable feedback'),
              backgroundColor: kSuccessColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadiusM),
              ),
            ),
          );

          // 清空表单
          _feedbackController.clear();
          _contactController.clear();
          setState(() {
            _rating = 5;
            final categories = _getCategories(isChinese);
            _selectedCategory = categories[0];
          });
        }
      } else {
        throw Exception(data['message'] ?? '提交失败');
      }
    } catch (e) {
      if (mounted) {
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final isChinese = localeProvider.locale == AppLocale.zh;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '提交失败：${e.toString()}' : 'Submission failed: ${e.toString()}'),
            backgroundColor: kErrorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusM),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _updateCategoryForLanguage(bool isChinese) {
    final categories = _getCategories(isChinese);
    final currentIndex = isChinese ?
      ['Feature Suggestion', 'UI Optimization', 'Content Suggestion', 'Performance Issue', 'Other'].indexOf(_selectedCategory) :
      ['功能建议', '界面优化', '内容建议', '性能问题', '其他'].indexOf(_selectedCategory);

    if (currentIndex >= 0 && currentIndex < categories.length) {
      _selectedCategory = categories[currentIndex];
    } else {
      _selectedCategory = categories[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;

        // 确保选中的类别与当前语言匹配
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final categories = _getCategories(isChinese);
          if (!categories.contains(_selectedCategory)) {
            setState(() {
              _updateCategoryForLanguage(isChinese);
            });
          }
        });
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isChinese ? '意见反馈' : 'Feedback', style: const TextStyle(fontFamily: kFontFamilyTitle)),
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
                    color: kAccentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusButton),
                  ),
                  child: const Icon(Icons.language, size: 20),
                ),
                tooltip: isChinese ? '切换到英文' : 'Switch to Chinese',
                onPressed: localeProvider.toggleLocale,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(kSpaceM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 欢迎信息
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(kSpaceL),
                    decoration: BoxDecoration(
                      gradient: kPrimaryGradient,
                      borderRadius: BorderRadius.circular(kRadiusL),
                      boxShadow: kShadowMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.feedback_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: kSpaceM),
                        Text(
                          isChinese ? '您的评价很重要' : 'Your feedback is important',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: kFontSizeXl,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: kSpaceS),
                        Text(
                          isChinese ? '帮助我们改进服务质量，为更多游客提供更好的旅行体验' : 'Help us improve our service quality and provide better travel experiences for more tourists',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: kFontSizeM,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceXl),
                  
                  // 用户信息
                  if (user != null) ...[
                    Container(
                      padding: const EdgeInsets.all(kSpaceM),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(kRadiusM),
                        boxShadow: kShadowLight,
                      ),
                      child: Row(
                        children: [
                          UserAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                            fontSize: 16,
                          ),
                          const SizedBox(width: kSpaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username.isNotEmpty ? user.username : '用户',
                                  style: const TextStyle(
                                    fontSize: kFontSizeL,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.email.isNotEmpty ? user.email : (isChinese ? '未设置邮箱' : 'No email set'),
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: kFontSizeS,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpaceL),
                  ],
                  
                  // 评分
                  Text(
                    isChinese ? '服务评分' : 'Service Rating',
                    style: const TextStyle(
                      fontSize: kFontSizeL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSpaceS),
                  Container(
                    padding: const EdgeInsets.all(kSpaceM),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(kRadiusM),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              isChinese ? '评分标准' : 'Rating Standards',
                              style: TextStyle(
                                fontSize: kFontSizeS,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpaceS),
                        Text(
                          isChinese 
                              ? '5星：非常满意，超出预期\n4星：满意，符合预期\n3星：一般，基本满意\n2星：不满意，需要改进\n1星：非常不满意'
                              : '5★: Very satisfied, exceeded expectations\n4★: Satisfied, met expectations\n3★: Average, basically satisfied\n2★: Dissatisfied, needs improvement\n1★: Very dissatisfied',
                          style: TextStyle(
                            fontSize: kFontSizeS,
                            color: Colors.blue.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kSpaceM),
                  Container(
                    padding: const EdgeInsets.all(kSpaceM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(kRadiusM),
                      boxShadow: kShadowLight,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: index < _rating ? Colors.amber : AppColors.textLight,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceL),
                  
                  // 评价类别
                  Text(
                    isChinese ? '评价类别' : 'Feedback Category',
                    style: const TextStyle(
                      fontSize: kFontSizeL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSpaceM),
                  Container(
                    padding: const EdgeInsets.all(kSpaceM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(kRadiusM),
                      boxShadow: kShadowLight,
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: isChinese ? '选择评价类别' : 'Select feedback category',
                      ),
                      items: _getCategories(isChinese).map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceL),
                  
                  // 评价内容
                  Text(
                    isChinese ? '评价内容' : 'Feedback Content',
                    style: const TextStyle(
                      fontSize: kFontSizeL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSpaceM),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(kRadiusM),
                      boxShadow: kShadowLight,
                    ),
                    child: TextFormField(
                      controller: _feedbackController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: isChinese ? '请详细描述您的旅行体验，包括导游服务、景点安排、文化体验等方面...' : 'Please describe your travel experience in detail, including guide service, attraction arrangements, cultural experience, etc...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(kSpaceM),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isChinese ? '请输入评价内容' : 'Please enter feedback content';
                        }
                        if (value.trim().length < 10) {
                          return isChinese ? '评价内容至少需要10个字符' : 'Feedback content must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceL),
                  
                  // 联系方式（可选）
                  Text(
                    isChinese ? '联系方式（可选）' : 'Contact Information (Optional)',
                    style: const TextStyle(
                      fontSize: kFontSizeL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSpaceM),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(kRadiusM),
                      boxShadow: kShadowLight,
                    ),
                    child: TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        hintText: isChinese ? '邮箱或手机号（用于回复反馈）' : 'Email or phone number (for feedback reply)',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(kSpaceM),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceXxl),
                  
                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusM),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: kSpaceM),
                                Text(isChinese ? '提交中...' : 'Submitting...'),
                              ],
                            )
                          : Text(
                              isChinese ? '提交评价' : 'Submit Feedback',
                              style: const TextStyle(
                                fontSize: kFontSizeL,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: kSpaceL),
                  
                  // 提示信息
                  Container(
                    padding: const EdgeInsets.all(kSpaceM),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(kRadiusM),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: kSpaceS),
                        Expanded(
                          child: Text(
                            isChinese ? '我们会在24小时内处理您的评价，优秀评价将获得奖励！' : 'We will process your feedback within 24 hours. Excellent feedback will receive rewards!',
                            style: const TextStyle(
                              color: AppColors.info,
                              fontSize: kFontSizeS,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 