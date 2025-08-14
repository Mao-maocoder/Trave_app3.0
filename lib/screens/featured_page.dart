import 'package:flutter/material.dart';
import '../widgets/optimized_card.dart';
import 'xk_codebook_detail_page.dart';
import 'ar_civilization_codex_page.dart';

class FeaturedPage extends StatelessWidget {
  const FeaturedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    final List<_FeaturedItem> items = [
      _FeaturedItem(
        title: isChinese ? '数字文明秘典' : 'Digital Civilization Codex',
        description: isChinese ? '沉浸式体验文明历史，探索中轴线文化瑰宝' : 'Immersive experience of civilization history, explore the cultural treasures of the central axis',
        image: 'assets/images/background/card1.jpg',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ARCivilizationCodexPage()));
        },
      ),
      _FeaturedItem(
        title: isChinese ? '北京中轴线术语库' : 'Beijing Central Axis Terminology Database',
        description: isChinese ? '点击显示中西双语词条' : 'Click to display Chinese-Spanish bilingual entries',
        image: 'assets/images/background/card2.jpg',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => XKCodebookDetailPage()));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '精彩推荐' : 'Featured',
          style: const TextStyle(
            fontFamily: 'SimSun',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, i) {
          final item = items[i];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  item.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.18),
                ),
              ),
              Positioned(
                left: 24,
                top: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SimSun',
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                      onPressed: item.onTap,
                      child: Text(isChinese ? '点击查看' : 'View', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FeaturedItem {
  final String title;
  final String description;
  final String image;
  final VoidCallback onTap;
  _FeaturedItem({required this.title, required this.description, required this.image, required this.onTap});
} 