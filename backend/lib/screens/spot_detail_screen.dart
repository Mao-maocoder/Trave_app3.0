import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import '../models/tourist_spot.dart';
import '../providers/locale_provider.dart';
import '../services/tourist_spot_service.dart';
import '../services/amap_service.dart';
import '../widgets/platform_image.dart';

class SpotDetailScreen extends StatefulWidget {
  final String spotId;
  
  const SpotDetailScreen({Key? key, required this.spotId}) : super(key: key);

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  TouristSpot? _spot;
  bool _isLoading = true;
  bool _isFavorite = false;
  Map<String, dynamic> _spotDetails = {};
  final TouristSpotService _spotService = TouristSpotService();

  @override
  void initState() {
    super.initState();
    _loadSpotDetails();
  }

  Future<void> _loadSpotDetails() async {
    try {
      final spot = await _spotService.getSpotById(widget.spotId);
      final details = _spotService.getSpotDetails(widget.spotId);
      setState(() {
        _spot = spot;
        _spotDetails = details;
        _isFavorite = spot?.isFavorite ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_spot == null) return;
    
    await _spotService.toggleFavorite(_spot!.id);
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh
                ? (_isFavorite ? '已添加到收藏' : '已取消收藏')
                : (_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          ),
          backgroundColor: _isFavorite ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _openNavigation() async {
    if (_spot == null) return;

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isChinese = localeProvider.locale == AppLocale.zh;

    // 构建导航URL
    final destination = '${_spot!.latitude},${_spot!.longitude}';
    final spotName = isChinese ? _spot!.name : _spot!.nameEn;
    
    // 尝试打开高德地图
    final amapUrl = 'amapuri://route/plan/?dlat=${_spot!.latitude}&dlon=${_spot!.longitude}&dname=$spotName&dev=0&t=0';
    
    try {
      final uri = Uri.parse(amapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // 如果高德地图不可用，使用网页版
        final webUrl = 'https://uri.amap.com/navigation?to=${_spot!.longitude},${_spot!.latitude},$spotName&mode=car&policy=1&src=mypage&coordinate=gaode&callnative=0';
        final webUri = Uri.parse(webUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('无法打开导航');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '无法打开导航应用' : 'Cannot open navigation app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openMap() async {
    if (_spot == null) return;

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isChinese = localeProvider.locale == AppLocale.zh;

    // 构建地图URL
    final spotName = isChinese ? _spot!.name : _spot!.nameEn;
    final mapUrl = 'https://uri.amap.com/marker?position=${_spot!.longitude},${_spot!.latitude}&name=$spotName&src=mypage&coordinate=gaode&callnative=0';
    
    try {
      final uri = Uri.parse(mapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('无法打开地图');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '无法打开地图应用' : 'Cannot open map app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareSpot() async {
    if (_spot == null) return;

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isChinese = localeProvider.locale == AppLocale.zh;

    final spotName = isChinese ? _spot!.name : _spot!.nameEn;
    final description = isChinese ? _spot!.description : _spot!.descriptionEn;
    final shareText = '$spotName\n$description\n\n${isChinese ? '查看详情' : 'View details'}: https://uri.amap.com/marker?position=${_spot!.longitude},${_spot!.latitude}&name=$spotName';

    try {
      final uri = Uri.parse('mailto:?subject=$spotName&body=$shareText');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // 如果邮件应用不可用，显示分享对话框
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(isChinese ? '分享景点' : 'Share Spot'),
              content: SelectableText(shareText),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isChinese ? '关闭' : 'Close'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '分享失败' : 'Share failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openVideo(String videoUrl) async {
    try {
      final uri = Uri.parse(videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('无法打开视频');
      }
    } catch (e) {
      if (mounted) {
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final isChinese = localeProvider.locale == AppLocale.zh;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChinese ? '无法打开视频链接' : 'Cannot open video link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isChinese = localeProvider.locale == AppLocale.zh;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isChinese ? '景点详情' : 'Spot Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_spot == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isChinese ? '景点详情' : 'Spot Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                isChinese ? '景点不存在' : 'Spot not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 图片头部
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isChinese ? _spot!.name : _spot!.nameEn,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PlatformImage(
                    imageUrl: _spot!.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 64),
                    ),
                  ),
                  // 渐变遮罩
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),

          // 内容
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 评分和评论数
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _spot!.rating.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_spot!.reviewCount} ${isChinese ? '条评论' : 'reviews'})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 描述
                  Text(
                    isChinese ? '景点介绍' : 'Description',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isChinese ? _spot!.description : _spot!.descriptionEn,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // 亮点推荐
                  if (_spotDetails['highlights'] != null) ...[
                    _buildHighlightsSection(context, isChinese),
                    const SizedBox(height: 24),
                  ],

                  // 小贴士
                  if (_spotDetails['tips'] != null) ...[
                    _buildTipsSection(context, isChinese),
                    const SizedBox(height: 24),
                  ],

                  // 地址
                  _buildInfoSection(
                    context,
                    icon: Icons.location_on,
                    title: isChinese ? '地址' : 'Address',
                    content: isChinese ? _spot!.address : _spot!.addressEn,
                  ),

                  // 标签
                  if (_spot!.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      isChinese ? '标签' : 'Tags',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (isChinese ? _spot!.tags : _spot!.tagsEn).map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      )).toList(),
                    ),
                  ],

                  // 视频链接
                  if (_spotDetails['videos'] != null && 
                      _spotDetails['videos'] is List && 
                      (_spotDetails['videos'] as List).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      isChinese ? '相关视频' : 'Related Videos',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_spotDetails['videos'] as List).map((videoUrl) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.play_circle_outline, color: Theme.of(context).primaryColor),
                        title: Text(isChinese ? '观看介绍视频' : 'Watch Introduction Video'),
                        subtitle: Text(videoUrl.toString()),
                        onTap: () => _openVideo(videoUrl.toString()),
                      ),
                    )).toList(),
                  ],

                  // 操作按钮
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openNavigation,
                          icon: const Icon(Icons.navigation),
                          label: Text(isChinese ? '导航' : 'Navigate'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openMap,
                          icon: const Icon(Icons.map),
                          label: Text(isChinese ? '地图' : 'Map'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 分享按钮
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _shareSpot,
                      icon: const Icon(Icons.share),
                      label: Text(isChinese ? '分享' : 'Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(BuildContext context, bool isChinese) {
    final highlights = _spotDetails['highlights'];
    if (highlights == null || highlights is! List || highlights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '亮点推荐' : 'Highlights',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...highlights.map((highlight) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  highlight.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context, bool isChinese) {
    final tips = _spotDetails['tips'];
    if (tips == null || tips is! List || tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '小贴士' : 'Tips',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
} 