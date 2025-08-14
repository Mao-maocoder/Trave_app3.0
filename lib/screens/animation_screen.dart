import 'package:flutter/material.dart';
import '../constants.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({Key? key}) : super(key: key);

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '致美斋饭庄' : 'ZhiMeiZhai Restaurant'),
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
              // 这里假设有LocaleProvider，若无请替换为你的多语言切换逻辑
              // Provider.of<LocaleProvider>(context, listen: false).toggleLocale();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        children: [
          Text(
            isChinese ? '地址：西城区广内大街169号翔达国际酒店3层' : 'Address: 3rd Floor, Xiangda International Hotel, 169 Guangnei Street, Xicheng District',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            isChinese ? '电话：010-63523960' : 'Tel: 010-63523960',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final url = 'http://dpurl.cn/mxzws3Dz';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              'http://dpurl.cn/mxzws3Dz',
              style: const TextStyle(fontSize: 18, color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 32),
          // 展示二维码图片（已保存为assets/images/zhimeizhai.png）
          Image.asset('assets/images/zhimeizhai.png', fit: BoxFit.contain),
        ],
      ),
    );
  }
} 