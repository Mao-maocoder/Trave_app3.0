import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../widgets/primary_button.dart';
import '../providers/locale_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<String> interests = [];
  List<String> diets = [];
  String health = '';
  String expect = '';
  String suggestion = '';
  bool submitted = false;

  // 新增字段
  String gender = '';
  String ageGroup = '';
  String monthlyIncome = '';
  String culturalIdentity = '';
  List<String> psychologicalTraits = [];
  String travelFrequency = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> interestOptions = [
    {'zh': '中国美食文化', 'en': 'Chinese Cuisine Culture', 'icon': Icons.restaurant},
    {'zh': '传统民俗体验', 'en': 'Traditional Folk Experience', 'icon': Icons.festival},
    {'zh': '中文语言学习', 'en': 'Chinese Language Learning', 'icon': Icons.translate},
    {'zh': '书法文字艺术', 'en': 'Calligraphy & Writing Art', 'icon': Icons.brush},
    {'zh': '中国音乐文化', 'en': 'Chinese Music Culture', 'icon': Icons.music_note},
    {'zh': '茶文化体验', 'en': 'Tea Culture Experience', 'icon': Icons.local_cafe},
    {'zh': '传统服饰文化', 'en': 'Traditional Clothing Culture', 'icon': Icons.checkroom},
    {'zh': '中秘文化交流', 'en': 'China-Peru Cultural Exchange', 'icon': Icons.public},
    {'zh': '社交娱乐活动', 'en': 'Social Entertainment', 'icon': Icons.games},
    {'zh': '其它', 'en': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> dietOptions = [
    {'zh': '中式传统菜系', 'en': 'Traditional Chinese Cuisine', 'icon': Icons.restaurant_menu},
    {'zh': '川菜（辣味）', 'en': 'Sichuan Cuisine (Spicy)', 'icon': Icons.local_fire_department},
    {'zh': '粤菜（清淡）', 'en': 'Cantonese Cuisine (Light)', 'icon': Icons.rice_bowl},
    {'zh': '中秘融合菜', 'en': 'Chinese-Peruvian Fusion', 'icon': Icons.merge_type},
    {'zh': '素食偏好', 'en': 'Vegetarian Preference', 'icon': Icons.eco},
    {'zh': '海鲜类', 'en': 'Seafood', 'icon': Icons.set_meal},
    {'zh': '有食物过敏', 'en': 'Food Allergies', 'icon': Icons.warning_amber},
    {'zh': '其它', 'en': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> expectOptions = [
    {'zh': '寻根溯源体验', 'en': 'Heritage & Roots Experience', 'icon': Icons.account_balance},
    {'zh': '深度文化挖掘', 'en': 'Deep Cultural Exploration', 'icon': Icons.explore},
            {'zh': '定制化行程', 'en': 'Customized Knight Codebook', 'icon': Icons.tune},
    {'zh': '高品质体验', 'en': 'Premium Experience', 'icon': Icons.star},
    {'zh': '性价比优选', 'en': 'Value for Money', 'icon': Icons.balance},
    {'zh': '社交网络拓展', 'en': 'Social Network Expansion', 'icon': Icons.people},
    {'zh': '身份认同探索', 'en': 'Identity Exploration', 'icon': Icons.psychology},
    {'zh': '其它', 'en': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> genderOptions = [
    {'zh': '男', 'en': 'Male'},
    {'zh': '女', 'en': 'Female'},
    {'zh': '不愿透露', 'en': 'Prefer not to say'},
  ];

  final List<Map<String, dynamic>> ageGroupOptions = [
    {'zh': '18-25岁', 'en': '18-25 years'},
    {'zh': '26-30岁', 'en': '26-30 years'},
    {'zh': '31-35岁', 'en': '31-35 years'},
    {'zh': '36-40岁', 'en': '36-40 years'},
    {'zh': '40岁以上', 'en': '40+ years'},
  ];

  final List<Map<String, dynamic>> incomeOptions = [
    {'zh': '1万索尔以下', 'en': 'Below 10,000 Soles'},
    {'zh': '1-2万索尔', 'en': '10,000-20,000 Soles'},
    {'zh': '2-3万索尔', 'en': '20,000-30,000 Soles'},
    {'zh': '3万索尔以上', 'en': 'Above 30,000 Soles'},
  ];

  final List<Map<String, dynamic>> identityOptions = [
    {'zh': '更认同中国文化', 'en': 'More Chinese Cultural Identity'},
    {'zh': '更认同秘鲁文化', 'en': 'More Peruvian Cultural Identity'},
    {'zh': '秘鲁华人复合身份', 'en': 'Peruvian-Chinese Hybrid Identity'},
    {'zh': '身份认同模糊', 'en': 'Ambiguous Identity'},
  ];

  final List<Map<String, dynamic>> psychologicalOptions = [
    {'zh': '对祖籍国有情感联结', 'en': 'Emotional Connection to Ancestral Country'},
    {'zh': '文化身份认同困惑', 'en': 'Cultural Identity Confusion'},
    {'zh': '职业选择受代际影响', 'en': 'Career Choices Influenced by Generations'},
    {'zh': '适应不确定性强', 'en': 'Strong Adaptability to Uncertainty'},
    {'zh': '容易受父母影响', 'en': 'Easily Influenced by Parents'},
    {'zh': '重视朋友推荐', 'en': 'Value Friend Recommendations'},
  ];

  final List<Map<String, dynamic>> frequencyOptions = [
    {'zh': '每年多次', 'en': 'Multiple times per year'},
    {'zh': '每年一次', 'en': 'Once per year'},
    {'zh': '每2-3年一次', 'en': 'Every 2-3 years'},
    {'zh': '很少旅游', 'en': 'Rarely travel'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadSurvey();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      interests = prefs.getStringList('survey_interests') ?? [];
      diets = prefs.getStringList('survey_diets') ?? [];
      health = prefs.getString('survey_health') ?? '';
      expect = prefs.getString('survey_expect') ?? '';
      suggestion = prefs.getString('survey_suggestion') ?? '';
      submitted = prefs.getBool('survey_submitted') ?? false;

      // 新增字段
      gender = prefs.getString('survey_gender') ?? '';
      ageGroup = prefs.getString('survey_age_group') ?? '';
      monthlyIncome = prefs.getString('survey_monthly_income') ?? '';
      culturalIdentity = prefs.getString('survey_cultural_identity') ?? '';
      psychologicalTraits = prefs.getStringList('survey_psychological_traits') ?? [];
      travelFrequency = prefs.getString('survey_travel_frequency') ?? '';
    });
  }

  Future<void> _saveSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('survey_interests', interests);
    await prefs.setStringList('survey_diets', diets);
    await prefs.setString('survey_health', health);
    await prefs.setString('survey_expect', expect);
    await prefs.setString('survey_suggestion', suggestion);
    await prefs.setBool('survey_submitted', true);

    // 新增字段保存
    await prefs.setString('survey_gender', gender);
    await prefs.setString('survey_age_group', ageGroup);
    await prefs.setString('survey_monthly_income', monthlyIncome);
    await prefs.setString('survey_cultural_identity', culturalIdentity);
    await prefs.setStringList('survey_psychological_traits', psychologicalTraits);
    await prefs.setString('survey_travel_frequency', travelFrequency);

    _animationController.reset();
    setState(() {
      submitted = true;
    });
    _animationController.forward();

    final surveyData = {
      "interests": interests,
      "diets": diets,
      "health": health,
      "expect": expect,
      "suggestion": suggestion,
      "gender": gender,
      "ageGroup": ageGroup,
      "monthlyIncome": monthlyIncome,
      "culturalIdentity": culturalIdentity,
      "psychologicalTraits": psychologicalTraits,
      "travelFrequency": travelFrequency,
    };
    try {
      await http.post(
        Uri.parse('http://localhost:3000/api/survey/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(surveyData),
      );
    } catch (e) {
      // 可选：处理网络异常
    }

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isChinese = localeProvider.locale == AppLocale.zh;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(isChinese ? '提交成功！' : 'Submitted successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: Text(
              isChinese ? '秘鲁华人寻根之旅调研' : 'Peruvian-Chinese Heritage Journey Survey',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            backgroundColor: Colors.white,
            foregroundColor: kPrimaryColor,
            actions: [
              if (submitted)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.refresh, size: 20),
                    ),
                    tooltip: isChinese ? '重新填写' : 'Reset Survey',
                    onPressed: _resetSurvey,
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
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
              ),
            ],
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE3F2FD),
                    Colors.white,
                  ],
                ),
              ),
              child: submitted ? _buildResult(isChinese) : _buildForm(isChinese),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(bool isChinese) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(isChinese),
            const SizedBox(height: 20),
            _buildCard(_buildBasicInfoSection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildInterestsSection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildDietarySection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildIdentitySection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildPsychologicalSection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildHealthSection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildExpectationSection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildTravelFrequencySection(isChinese)),
            const SizedBox(height: 16),
            _buildCard(_buildSuggestionSection(isChinese)),
            const SizedBox(height: 28),
            Center(
              child: PrimaryButton(
                text: isChinese ? '提交' : 'Submit',
                onPressed: _saveSurvey,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(bool isChinese) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '🌟 探寻您的文化根源之旅' : '🌟 Explore Your Cultural Heritage Journey',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese
                ? '作为秘鲁华人，您对祖籍国有着特殊的情感联结。请填写以下问卷，帮助我们深入了解您的文化身份认同、兴趣偏好和旅行期望，为您量身定制高品质的寻根溯源体验。'
                : 'As a Peruvian-Chinese, you have a special emotional connection to your ancestral homeland. Please fill out this survey to help us understand your cultural identity, interests, and travel expectations, so we can create a premium heritage experience tailored just for you.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: child,
      ),
    );
  }

  Widget _buildInterestsSection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '您感兴趣的领域：' : 'Areas of Interest:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: interestOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: interests.contains(optionKey),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    interests.add(optionKey);
                  } else {
                    interests.remove(optionKey);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDietarySection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '饮食偏好：' : 'Dietary Preferences:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: dietOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: diets.contains(optionKey),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    diets.add(optionKey);
                  } else {
                    diets.remove(optionKey);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthSection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '健康状况：' : 'Health Status:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: isChinese ? '请描述您的健康状况' : 'Please describe your health status',
          ),
          onChanged: (value) {
            setState(() {
              health = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExpectationSection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '旅行期望：' : 'Travel Expectations:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: expectOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: expect == optionKey,
              onSelected: (selected) {
                setState(() {
                  expect = selected ? optionKey : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionSection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '建议或意见：' : 'Suggestions or Comments:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: isChinese ? '请输入您的建议或意见' : 'Please enter your suggestions or comments',
          ),
          onChanged: (value) {
            setState(() {
              suggestion = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildResult(bool isChinese) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: kPrimaryColor, size: 48),
            const SizedBox(height: 20),
            Text(
              isChinese ? '感谢您的参与！' : 'Thank you for your participation!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              isChinese ? '我们将根据您的反馈，为您提供更好的服务。' : 'We will use your feedback to provide you with better service.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: isChinese ? '重新填写问卷' : 'Fill Survey Again',
              onPressed: _resetSurvey,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetSurvey() async {
    final prefs = await SharedPreferences.getInstance();

    // 清除所有问卷数据
    await prefs.remove('survey_interests');
    await prefs.remove('survey_diets');
    await prefs.remove('survey_health');
    await prefs.remove('survey_expect');
    await prefs.remove('survey_suggestion');
    await prefs.remove('survey_submitted');
    await prefs.remove('survey_gender');
    await prefs.remove('survey_age_group');
    await prefs.remove('survey_monthly_income');
    await prefs.remove('survey_cultural_identity');
    await prefs.remove('survey_psychological_traits');
    await prefs.remove('survey_travel_frequency');

    // 重置状态
    setState(() {
      interests = [];
      diets = [];
      health = '';
      expect = '';
      suggestion = '';
      submitted = false;
      gender = '';
      ageGroup = '';
      monthlyIncome = '';
      culturalIdentity = '';
      psychologicalTraits = [];
      travelFrequency = '';
    });

    _animationController.reset();
    _animationController.forward();
  }

  // 基本信息部分
  Widget _buildBasicInfoSection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '基本信息：' : 'Basic Information:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // 性别选择
        Text(
          isChinese ? '性别：' : 'Gender:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: genderOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: gender == optionKey,
              onSelected: (selected) {
                setState(() {
                  gender = selected ? optionKey : '';
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 15),

        // 年龄组选择
        Text(
          isChinese ? '年龄组：' : 'Age Group:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: ageGroupOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: ageGroup == optionKey,
              onSelected: (selected) {
                setState(() {
                  ageGroup = selected ? optionKey : '';
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 15),

        // 月收入选择
        Text(
          isChinese ? '月收入：' : 'Monthly Income:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: incomeOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: monthlyIncome == optionKey,
              onSelected: (selected) {
                setState(() {
                  monthlyIncome = selected ? optionKey : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 文化身份认同部分
  Widget _buildIdentitySection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '文化身份认同：' : 'Cultural Identity:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: identityOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: culturalIdentity == optionKey,
              onSelected: (selected) {
                setState(() {
                  culturalIdentity = selected ? optionKey : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 心理特征部分
  Widget _buildPsychologicalSection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '心理特征（可多选）：' : 'Psychological Traits (Multiple Choice):',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: psychologicalOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: psychologicalTraits.contains(optionKey),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    psychologicalTraits.add(optionKey);
                  } else {
                    psychologicalTraits.remove(optionKey);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 旅游频率部分
  Widget _buildTravelFrequencySection(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '旅游频率：' : 'Travel Frequency:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: frequencyOptions.map((option) {
            final optionText = isChinese ? option['zh'] : option['en'];
            final optionKey = option['en'];
            return ChoiceChip(
              label: Text(optionText),
              selected: travelFrequency == optionKey,
              onSelected: (selected) {
                setState(() {
                  travelFrequency = selected ? optionKey : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}