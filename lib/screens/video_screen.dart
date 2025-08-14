import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../theme.dart';
import '../providers/locale_provider.dart';
import 'dart:html' as html;
// import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '戏楼' : 'Theater'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, size: 20),
            tooltip: isChinese ? '切换到英文' : 'Switch to Chinese',
            onPressed: () {
              Provider.of<LocaleProvider>(context, listen: false).toggleLocale();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildVideoCard(
            context,
            isChinese ? 'AI春晚非遗大作《中轴线》' : 'AI Spring Festival Gala: Central Axis',
            'Bilibili',
            'https://www.bilibili.com/video/BV1j8Fue5Erw/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
          ),
          _buildVideoCard(
            context,
            isChinese ? '单弦《诗情画意赞中轴》' : 'Danxian: Ode to the Central Axis',
            'Bilibili',
            'https://www.bilibili.com/video/BV1NS42197G2/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
          ),
          _buildVideoCard(
            context,
            isChinese ? '北京中轴龙脉之钟' : 'Beijing Central Axis Dragon Vein Bell',
            'Bilibili',
            'https://www.bilibili.com/video/BV1FiDUY3EoB/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
          ),
          _buildVideoCard(
            context,
            isChinese ? '《登场了！北京中轴线》' : 'Here Comes! Beijing Central Axis',
            '百度好看',
            'https://haokan.baidu.com/v?pd=wisenatural&vid=6763549125120068849',
          ),
          _buildVideoCard(
            context,
            isChinese ? '《北京中轴线》' : 'Beijing Central Axis',
            'Bilibili',
            'https://www.bilibili.com/video/BV1Jw4m1Y7EU/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
          ),
          _buildVideoCard(
            context,
            isChinese ? '曲艺联唱《北京中轴线》' : 'Quyi Medley: Beijing Central Axis',
            'CCTV',
            'https://caiyi.cctv.com/2025/01/29/VIDEHnm6F08FYa7tQxb5fV4V250129.shtml',
          ),
          _buildVideoCard(
            context,
            isChinese ? '舞蹈《镇水神兽》' : 'Dance: Water Guardian Beast',
            '百度好看',
            'https://haokan.baidu.com/v?pd=wisenatural&vid=13782222974100361441',
          ),
          _buildVideoCard(
            context,
            isChinese ? '中轴线情书' : 'Central Axis Love Letter',
            'Bilibili',
            'https://www.bilibili.com/video/BV1F5DoYtERo/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
          ),
        ],
      ),
    );
  }
}

Widget _buildVideoCard(BuildContext context, String title, String platform, String url) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ListTile(
      leading: const Icon(Icons.ondemand_video, color: Colors.blueAccent),
      title: Text(title),
      subtitle: Text(platform),
      trailing: const Icon(Icons.open_in_new),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开链接')),
          );
        }
      },
    ),
  );
} 