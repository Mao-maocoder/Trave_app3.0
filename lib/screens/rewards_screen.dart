import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../models/user.dart';
import '../constants.dart';
import '../utils/api_host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../services/nft_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  List<Map<String, dynamic>> _rewards = [];
  List<Map<String, dynamic>> _nftCertificates = [];
  bool _isLoading = true;
  String? _error;
  List<Achievement> _achievements = [];
  bool _isLoadingAchievements = true;
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _qrUrl;

  // 新增：文明探秘奖励定义
  final List<Map<String, dynamic>> _civilizationRewards = [
    {
      'id': 'wood_master_badge',
      'name_zh': '建筑匠师徽章',
      'name_en': 'Architectural Master Badge',
      'description_zh': '精通木石结构，善于发现建筑中的智慧密码',
      'description_en': 'Expert in wood and stone structures, skilled at discovering architectural wisdom codes',
      'icon': Icons.architecture,
      'rarity': 'rare',
      'unlock_condition': '完成故宫太和殿斗拱拼装挑战',
    },
    {
      'id': 'light_poet_badge',
      'name_zh': '光线诗人徽章',
      'name_en': 'Light Poet Badge',
      'description_zh': '对光影变化敏感，能解读时空中的光线密码',
      'description_en': 'Sensitive to light and shadow changes, able to decode light codes in time and space',
      'icon': Icons.wb_sunny,
      'rarity': 'epic',
      'unlock_condition': '完成天坛祈年殿时空密码任务',
    },
    {
      'id': 'food_philosopher_badge',
      'name_zh': '饮食哲学家徽章',
      'name_en': 'Food Philosopher Badge',
      'description_zh': '深谙饮食文化，能从食材中读懂文明故事',
      'description_en': 'Deep understanding of food culture, able to read civilization stories from ingredients',
      'icon': Icons.restaurant,
      'rarity': 'legendary',
      'unlock_condition': '完成四合院中秘主题宴体验',
    },
    {
      'id': 'civilization_explorer_badge',
      'name_zh': '文明探秘使徽章',
      'name_en': 'Civilization Explorer Badge',
      'description_zh': '综合型探秘者，善于发现文明间的对话',
      'description_en': 'Comprehensive explorer, skilled at discovering dialogues between civilizations',
      'icon': Icons.explore,
      'rarity': 'mythic',
      'unlock_condition': '完成所有主线任务',
    },
  ];

  // NFT证书定义
  final List<Map<String, dynamic>> _nftCertificateDefinitions = [
    {
      'id': 'central_axis_master',
      'name_zh': '中轴线探秘大师',
      'name_en': 'Central Axis Exploration Master',
      'description_zh': '完成中轴线全部探秘任务，获得此NFT证书',
      'description_en': 'Complete all Central Axis exploration tasks to earn this NFT certificate',
      'image_url': 'assets/images/nft/central_axis_master.png',
      'rarity': 'legendary',
      'blockchain': 'Polygon',
      'token_id': 'CA001',
    },
    {
      'id': 'civilization_dialogue_expert',
      'name_zh': '文明对话专家',
      'name_en': 'Civilization Dialogue Expert',
      'description_zh': '深度体验中秘文明对话，获得此NFT证书',
      'description_en': 'Deeply experience Chinese-Peruvian civilization dialogue to earn this NFT certificate',
      'image_url': 'assets/images/nft/civilization_dialogue_expert.png',
      'rarity': 'epic',
      'blockchain': 'Polygon',
      'token_id': 'CD001',
    },
    {
      'id': 'ar_experience_collector',
      'name_zh': 'AR体验收集者',
      'name_en': 'AR Experience Collector',
      'description_zh': '完成所有AR互动体验，获得此NFT证书',
      'description_en': 'Complete all AR interactive experiences to earn this NFT certificate',
      'image_url': 'assets/images/nft/ar_experience_collector.png',
      'rarity': 'rare',
      'blockchain': 'Polygon',
      'token_id': 'AR001',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRewards();
    _loadAchievements();
    _loadProducts();
  }

  Future<void> _loadRewards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user == null) {
        throw Exception('用户未登录');
      }

      final response = await http.get(
        Uri.parse('${ApiHost.baseUrl}/api/feedbacks/user/${user.id}/rewards'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _rewards = List<Map<String, dynamic>>.from(data['rewards']);
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? '获取奖励失败');
        }
      } else {
        throw Exception('网络请求失败');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAchievements() async {
    setState(() { _isLoadingAchievements = true; });
    try {
      final data = await AchievementService.fetchAchievements();
      setState(() {
        _achievements = data;
        _isLoadingAchievements = false;
      });
    } catch (e) {
      setState(() { _isLoadingAchievements = false; });
    }
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoadingProducts = true; });
    try {
      final data = await ProductService.fetchProducts();
      setState(() {
        _products = data;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() { _isLoadingProducts = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    // 彻底移除顶部“邮票·北京中轴线介绍”及“你想收集的邮票吗”两大块（包括外层卡片/Container），直接从文创珍藏册购买区块开始。
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '文创链接' : 'Cultural Link', style: const TextStyle(fontFamily: 'STKaiti', fontFamilyFallback: ['KaiTi', 'SimSun', 'serif', 'sans-serif'], fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        foregroundColor: kWhite,
        elevation: 0,
      ),
      body: _buildProductsTab(isChinese, null),
    );
  }

  Widget _buildErrorWidget(bool isChinese) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: kErrorColor),
          SizedBox(height: 16),
          Text(
            isChinese ? '加载失败' : 'Load Failed',
            style: TextStyle(fontSize: 18, color: kErrorColor, fontFamily: kFontFamilyTitle),
          ),
          SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRewards,
            child: Text(isChinese ? '重试' : 'Retry', style: TextStyle(fontFamily: kFontFamilyTitle)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhite,
              padding: EdgeInsets.symmetric(horizontal: kSpaceL, vertical: kSpaceM),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(bool isChinese) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: kCardBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard,
              size: 60,
              color: kGrey400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            isChinese ? '暂无奖励' : 'No Rewards Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextSecondary,
              fontFamily: kFontFamilyTitle,
            ),
          ),
          SizedBox(height: 12),
          Text(
            isChinese 
                ? '提交评价并等待导游批准后，\n您将在这里看到获得的奖励！'
                : 'Submit feedback and wait for guide approval,\nYou will see your rewards here!',
            style: TextStyle(
              fontSize: 16,
              color: kTextHint,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/feedback');
            },
            icon: Icon(Icons.feedback),
            label: Text(isChinese ? '去提交评价' : 'Submit Feedback', style: TextStyle(fontFamily: kFontFamilyTitle)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhite,
              padding: EdgeInsets.symmetric(horizontal: kSpaceL, vertical: kSpaceM),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(kSpaceL),
      itemCount: _rewards.length,
      itemBuilder: (context, index) {
        final reward = _rewards[index];
        return _buildRewardCard(reward, isChinese);
      },
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward, bool isChinese) {
    final createdAt = DateTime.parse(reward['createdAt']);
    final isApproved = reward['status'] == 'approved';
    
    return Card(
      margin: EdgeInsets.only(bottom: kSpaceL),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
      color: kCardBackground,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusCard),
          gradient: isApproved 
              ? kSuccessGradient
              : kWarningGradient,
          boxShadow: kShadowLight,
        ),
        child: Padding(
          padding: EdgeInsets.all(kSpaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(kSpaceS),
                    decoration: BoxDecoration(
                      color: isApproved ? kSuccessColor : kWarningColor,
                      borderRadius: BorderRadius.circular(kRadiusButton),
                    ),
                    child: Icon(
                      isApproved ? Icons.check_circle : Icons.pending,
                      color: kWhite,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: kSpaceS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isApproved 
                              ? (isChinese ? '奖励已发放' : 'Reward Sent')
                              : (isChinese ? '等待处理' : 'Pending'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isApproved ? kSuccessColorDark : kWarningColorDark,
                            fontFamily: kFontFamilyTitle,
                          ),
                        ),
                        Text(
                          '${isChinese ? '获得时间' : 'Received'}: ${createdAt.toString().split('.')[0]}',
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: kSpaceL),
              
              // 评价内容
              Container(
                padding: EdgeInsets.all(kSpaceM),
                decoration: BoxDecoration(
                  color: kWhite.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(kRadiusButton),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.feedback, size: 16, color: kTextSecondary),
                        SizedBox(width: kSpaceS),
                        Text(
                          isChinese ? '您的评价' : 'Your Feedback',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: kSpaceS),
                    Text(
                      reward['feedbackContent'] ?? '',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: kSpaceS),
                    Row(
                      children: List.generate(5, (index) =>
                        Icon(
                          Icons.star,
                          size: 14,
                          color: index < (reward['rating'] ?? 0) ? kWarningColor : kGrey300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (isApproved && reward['reward'] != null && reward['reward'].isNotEmpty) ...[
                SizedBox(height: kSpaceL),
                
                // 奖励内容
                Container(
                  padding: EdgeInsets.all(kSpaceM),
                  decoration: BoxDecoration(
                    color: kSuccessColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusButton),
                    border: Border.all(color: kSuccessColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 16, color: kSuccessColorDark),
                          SizedBox(width: kSpaceS),
                          Text(
                            isChinese ? '获得的奖励' : 'Reward Received',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kSuccessColorDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: kSpaceS),
                      Text(
                        reward['reward'],
                        style: TextStyle(
                          fontSize: 14,
                          color: kSuccessColorDarker,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (reward['message'] != null && reward['message'].isNotEmpty) ...[
                SizedBox(height: kSpaceL),
                
                // 导游回复
                Container(
                  padding: EdgeInsets.all(kSpaceM),
                  decoration: BoxDecoration(
                    color: kInfoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusButton),
                    border: Border.all(color: kInfoColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.message, size: 16, color: kInfoColorDark),
                          SizedBox(width: kSpaceS),
                          Text(
                            isChinese ? '导游回复' : 'Guide Reply',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kInfoColorDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: kSpaceS),
                      Text(
                        reward['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: kInfoColorDarker,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 探秘徽章标签页
  Widget _buildCivilizationBadgesTab(bool isChinese) {
    if (_isLoadingAchievements) {
      return Center(child: CircularProgressIndicator());
    }
    if (_achievements.isEmpty) {
      return Center(child: Text(isChinese ? '暂无成就' : 'No Achievements Yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(kSpaceL),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final badge = _achievements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: kSpaceL),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadiusCard),
              gradient: badge.unlocked
                  ? kPrimaryGradientLight
                  : null,
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(kSpaceL),
                decoration: BoxDecoration(
                  color: badge.unlocked ? kInfoColor : kGrey300,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                ),
                child: Icon(Icons.emoji_events, color: badge.unlocked ? kWhite : kTextSecondary, size: 28),
              ),
              title: Text(
                badge.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: badge.unlocked ? kPrimaryColor : kTextSecondary,
                  fontFamily: kFontFamilyTitle,
                ),
              ),
              subtitle: Text(
                badge.desc,
                style: TextStyle(
                  color: badge.unlocked ? kTextSecondary : kTextHint,
                ),
              ),
              trailing: badge.unlocked
                  ? Icon(Icons.check_circle, color: kSuccessColor)
                  : Icon(Icons.lock, color: kGrey400),
            ),
          ),
        );
      },
    );
  }

  // 修改_buildNftCertificatesTab，顶部插入领取NFT证书按钮
  Widget _buildNftCertificatesTab(bool isChinese) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kSpaceL),
          child: ElevatedButton.icon(
            icon: Icon(Icons.card_giftcard),
            label: Text(isChinese ? '领取NFT证书' : 'Mint NFT Certificate', style: TextStyle(fontFamily: kFontFamilyTitle)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPurple,
              foregroundColor: kWhite,
            ),
            onPressed: user == null ? null : () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text(isChinese ? '领取中...' : 'Minting...'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: kSpaceL),
                      Text(isChinese ? '正在领取NFT证书...' : 'Minting NFT certificate...'),
                    ],
                  ),
                ),
              );
              final url = await NftService.mintNft(user.id);
              Navigator.pop(context);
              if (url != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(isChinese ? 'NFT证书' : 'NFT Certificate'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isChinese ? '恭喜，已领取NFT证书！' : 'Congratulations! NFT certificate minted!'),
                        SizedBox(height: kSpaceL),
                        Image.network(url, height: 120, errorBuilder: (c, e, s) => Icon(Icons.image)),
                        SizedBox(height: kSpaceS),
                        SelectableText(url),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(isChinese ? '关闭' : 'Close'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(kSpaceL),
            itemCount: _nftCertificateDefinitions.length,
            itemBuilder: (context, index) {
              final certificate = _nftCertificateDefinitions[index];
              final isMinted = _checkNftMinted(certificate['id']);
              
              return Card(
                margin: const EdgeInsets.only(bottom: kSpaceL),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    gradient: isMinted 
                        ? kPurpleBlueGradientLight
                        : null,
                  ),
                  child: Column(
                    children: [
                      // NFT图片预览
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusCard)),
                          color: kCardBackground,
                        ),
                        child: isMinted
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusCard)),
                                child: Image.asset(
                                  certificate['image_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: kGrey300,
                                      child: Icon(
                                        Icons.token,
                                        size: 64,
                                        color: kGrey400,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                color: kGrey300,
                                child: Icon(
                                  Icons.token,
                                  size: 64,
                                  color: kGrey400,
                                ),
                              ),
                      ),
                      
                      // NFT信息
                      Padding(
                        padding: const EdgeInsets.all(kSpaceL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isChinese ? certificate['name_zh'] : certificate['name_en'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: kFontFamilyTitle,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: kSpaceS, vertical: kSpaceXS),
                                  decoration: BoxDecoration(
                                    color: _getRarityColor(certificate['rarity']).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(kRadiusCard),
                                  ),
                                  child: Text(
                                    _getRarityText(certificate['rarity'], isChinese),
                                    style: TextStyle(
                                      color: _getRarityColor(certificate['rarity']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpaceS),
                            Text(
                              isChinese ? certificate['description_zh'] : certificate['description_en'],
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: kSpaceL),
                            Row(
                              children: [
                                Icon(Icons.link, size: 16, color: kInfoColorDark),
                                const SizedBox(width: kSpaceS),
                                Text(
                                  certificate['blockchain'],
                                  style: TextStyle(
                                    color: kInfoColorDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Token ID: ${certificate['token_id']}',
                                  style: TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpaceL),
                            if (isMinted)
                              Container(
                                padding: const EdgeInsets.all(kSpaceS),
                                decoration: BoxDecoration(
                                  color: kSuccessColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(kRadiusCard),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: kSuccessColor, size: 16),
                                    const SizedBox(width: kSpaceS),
                                    Text(
                                      isChinese ? '已铸造' : 'Minted',
                                      style: TextStyle(
                                        color: kSuccessColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: () => _mintNftCertificate(certificate['id']),
                                icon: const Icon(Icons.token),
                                label: Text(isChinese ? '铸造NFT' : 'Mint NFT', style: TextStyle(fontFamily: kFontFamilyTitle)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPurple,
                                  foregroundColor: kWhite,
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
          ),
        ),
      ],
    );
  }

  // 检查徽章是否解锁
  bool _checkBadgeUnlocked(String badgeId) {
    // TODO: 从本地存储或服务器检查徽章解锁状态
    // 这里暂时使用模拟数据
    return badgeId == 'wood_master_badge' || badgeId == 'light_poet_badge';
  }

  // 检查NFT是否已铸造
  bool _checkNftMinted(String nftId) {
    // TODO: 从区块链或服务器检查NFT铸造状态
    // 这里暂时使用模拟数据
    return nftId == 'central_axis_master';
  }

  // 铸造NFT证书
  void _mintNftCertificate(String nftId) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '铸造NFT证书' : 'Mint NFT Certificate'),
        content: Text(
          isChinese 
              ? '确定要铸造这个NFT证书吗？铸造后将在区块链上永久记录您的成就。'
              : 'Are you sure you want to mint this NFT certificate? It will permanently record your achievement on the blockchain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performMinting(nftId);
            },
            child: Text(isChinese ? '铸造' : 'Mint', style: TextStyle(fontFamily: kFontFamilyTitle)),
          ),
        ],
      ),
    );
  }

  // 执行铸造
  void _performMinting(String nftId) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    // 显示铸造进度
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '铸造中...' : 'Minting...'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: kSpaceL),
            Text('正在铸造NFT证书...'),
          ],
        ),
      ),
    );

    // 模拟铸造过程
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // 关闭进度对话框
      
      setState(() {
        // 更新NFT状态
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChinese ? 'NFT证书铸造成功！' : 'NFT certificate minted successfully!'),
          backgroundColor: kSuccessColor,
        ),
      );
    });
  }

  // 获取稀有度颜色
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return kGrey;
      case 'rare':
        return kInfoColor;
      case 'epic':
        return kPurple;
      case 'legendary':
        return kWarningColor;
      case 'mythic':
        return kErrorColor;
      default:
        return kGrey;
    }
  }

  // 获取稀有度文本
  String _getRarityText(String rarity, bool isChinese) {
    switch (rarity) {
      case 'common':
        return isChinese ? '普通' : 'Common';
      case 'rare':
        return isChinese ? '稀有' : 'Rare';
      case 'epic':
        return isChinese ? '史诗' : 'Epic';
      case 'legendary':
        return isChinese ? '传说' : 'Legendary';
      case 'mythic':
        return isChinese ? '神话' : 'Mythic';
      default:
        return isChinese ? '普通' : 'Common';
    }
  }

  Widget _buildProductsTab(bool isChinese, User? user) {
    return ListView(
      padding: const EdgeInsets.all(kSpaceL),
      children: [
        // 文创珍藏册购买区块
        Card(
          margin: const EdgeInsets.only(bottom: kSpaceL),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(kSpaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart, color: kSuccessColor, size: 32),
                    SizedBox(width: kSpaceM),
                    Expanded(
                      child: Text(
                        isChinese ? '文创珍藏册购买' : 'Buy Collection Album',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'STKaiti',
                          fontFamilyFallback: ['KaiTi', 'SimSun', 'serif', 'sans-serif'],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kSpaceM),
                // 有赞购买链接单独突出
                Column(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.shopping_bag),
                      label: Text(isChinese ? '有赞购买链接' : 'Youzan Link'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSuccessColor,
                        foregroundColor: kWhite,
                        minimumSize: Size(double.infinity, 48),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () async {
                        const url = 'https://tuicashier.youzan.com/pay/wscgoods_order?alias=1y5awfmx5asutm0';
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                    SizedBox(height: kSpaceS),
                    ElevatedButton.icon(
                      icon: Icon(Icons.storefront),
                      label: Text(isChinese ? '有赞商城' : 'Youzan Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSuccessColor,
                        foregroundColor: kWhite,
                        minimumSize: Size(double.infinity, 48),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () async {
                        const url = 'https://shop102574501.m.youzan.com/v2/showcase/homepage?kdt_id=102382333&scan=3&from=kdt&shopAutoEnter=1';
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ],
                ),
                // 分组小标题
                SizedBox(height: kSpaceL),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFD7B08A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      isChinese ? '文创好物推荐' : 'Cultural & Creative Picks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD7B08A),
                        fontFamily: 'STKaiti',
                        fontFamilyFallback: ['KaiTi', 'SimSun', 'serif', 'sans-serif'],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kSpaceM),
                // 推荐商品按钮
                _buildProductButton(
                  context,
                  isChinese ? '淘宝珍宝推荐' : 'Taobao Treasure',
                  'https://m.tb.cn/h.hRMagm2nlAajLha',
                ),
                SizedBox(height: kSpaceS),
                _buildProductButton(
                  context,
                  isChinese ? '孝端皇后凤冠九龙九凤金属冰箱贴 北京故宫博物院文创纪念品定制' : 'Empress Xiaoduan Crown Dragon Phoenix Metal Fridge Magnet',
                  'https://e.tb.cn/h.hR2A2cpTlhMpaDe?tk=3Zrm41NHUOQ',
                ),
                SizedBox(height: kSpaceS),
                _buildProductButton(
                  context,
                  isChinese ? '先农坛天宫藻井冰箱贴隆福寺金属五层星空北京文创收藏古建筑送礼' : 'Xiannongtan Tiangong Caisson Magnet Beijing Architecture Gift',
                  'https://e.tb.cn/h.hR3ayrpBJuvgSI8?tk=VidZ41NGbDU',
                ),
                SizedBox(height: kSpaceS),
                _buildProductButton(
                  context,
                  isChinese ? '【小版】《世界文化遗产——北京中轴线》特种邮票小版票' : '[Mini Sheet] World Heritage Beijing Central Axis Stamp',
                  'https://e.tb.cn/h.hRW1CuPgWm7LyQZ?tk=S5JJ41nFMRE',
                ),
                SizedBox(height: kSpaceS),
                _buildProductButton(
                  context,
                  isChinese ? '藻井（点击查看详情）' : 'Caisson (View Details)',
                  'https://3.cn/2l6v-n8v',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 新增统一商品按钮构建方法
  Widget _buildProductButton(BuildContext context, String label, String url) {
    return ElevatedButton.icon(
      icon: Icon(Icons.shopping_bag_outlined),
      label: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD7B08A),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 40),
        textStyle: TextStyle(fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      onPressed: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法打开链接')),
          );
        }
      },
    );
  }
} 