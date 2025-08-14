import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';

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
      '功能建议',
      '界面优化',
      '内容建议',
      '性能问题',
      '其他'
    ] : [
      'Feature Suggestion',
      'UI Optimization',
      'Content Suggestion',
      'Performance Issue',
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
      // 模拟提交反馈
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final isChinese = localeProvider.locale == AppLocale.zh;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '反馈提交成功！感谢您的宝贵意见' : 'Feedback submitted successfully! Thank you for your valuable feedback'),
            backgroundColor: AppColors.success,
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
    } catch (e) {
      if (mounted) {
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final isChinese = localeProvider.locale == AppLocale.zh;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '提交失败，请稍后重试' : 'Submission failed, please try again later'),
            backgroundColor: AppColors.error,
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
            title: Text(isChinese ? '意见反馈' : 'Feedback'),
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
                          isChinese ? '您的反馈很重要' : 'Your feedback is important',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: kFontSizeXl,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: kSpaceS),
                        Text(
                          isChinese ? '帮助我们改进应用，提供更好的用户体验' : 'Help us improve the application and provide a better user experience',
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
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                    isChinese ? '应用评分' : 'App Rating',
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
                  
                  // 反馈类别
                  Text(
                    isChinese ? '反馈类别' : 'Feedback Category',
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
                        hintText: isChinese ? '选择反馈类别' : 'Select feedback category',
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
                  
                  // 反馈内容
                  Text(
                    isChinese ? '反馈内容' : 'Feedback Content',
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
                        hintText: isChinese ? '请详细描述您的建议或遇到的问题...' : 'Please describe your suggestions or issues in detail...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(kSpaceM),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isChinese ? '请输入反馈内容' : 'Please enter feedback content';
                        }
                        if (value.trim().length < 10) {
                          return isChinese ? '反馈内容至少需要10个字符' : 'Feedback content must be at least 10 characters';
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
                              isChinese ? '提交反馈' : 'Submit Feedback',
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
                            isChinese ? '我们会在3个工作日内回复您的反馈，感谢您的支持！' : 'We will reply to your feedback within 3 business days. Thank you for your support!',
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