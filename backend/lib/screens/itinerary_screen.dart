import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../services/tourist_spot_service.dart';
import '../models/tourist_spot.dart';
import '../widgets/platform_image.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({Key? key}) : super(key: key);

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with TickerProviderStateMixin {
  final TouristSpotService _spotService = TouristSpotService();
  List<TouristSpot> _allSpots = [];
  List<TouristSpot> _selectedSpots = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadSpots();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSpots() async {
    try {
      final spots = await _spotService.getAllSpots();
      setState(() {
        _allSpots = spots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSpotSelection(TouristSpot spot) {
    setState(() {
      if (_selectedSpots.contains(spot)) {
        _selectedSpots.remove(spot);
      } else {
        _selectedSpots.add(spot);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedSpots.clear();
    });
  }

  void _showItineraryPreview() {
    if (_selectedSpots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh
                ? '请先选择景点'
                : 'Please select spots first',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItineraryPreview(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isChinese = localeProvider.locale == AppLocale.zh;

    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '北京中轴线术语库' : 'Beijing Central Axis Terminology Database'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_selectedSpots.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearSelection,
              tooltip: isChinese ? '清空选择' : 'Clear All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // 选择统计
                  _buildSelectionSummary(isChinese),
                  // 景点选择列表
                  Expanded(
                    child: _buildSpotSelectionList(isChinese),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showItineraryPreview,
        icon: const Icon(Icons.preview),
        label: Text(isChinese ? '预览行程' : 'Preview'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSelectionSummary(bool isChinese) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            color: Colors.blue[700],
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '已选择景点' : 'Selected Spots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  '${_selectedSpots.length} ${isChinese ? '个景点' : 'spots'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedSpots.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedSpots.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpotSelectionList(bool isChinese) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _allSpots.length,
      itemBuilder: (context, index) {
        final spot = _allSpots[index];
        final isSelected = _selectedSpots.contains(spot);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 2,
          color: isSelected ? Colors.blue[50] : Colors.white,
          child: InkWell(
            onTap: () => _toggleSpotSelection(spot),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 选择指示器
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected ? Colors.blue : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // 景点图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: PlatformImage(
                      imageUrl: spot.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 景点信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isChinese ? spot.name : spot.nameEn,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue[700] : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isChinese ? spot.description : spot.descriptionEn,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              spot.rating.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '(${spot.reviewCount})',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 添加/移除图标
                  Icon(
                    isSelected ? Icons.remove_circle : Icons.add_circle,
                    color: isSelected ? Colors.red : Colors.green,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItineraryPreview() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.route, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  isChinese ? '行程预览' : 'Knight Codebook Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 行程内容
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _selectedSpots.length,
              itemBuilder: (context, index) {
                final spot = _selectedSpots[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      isChinese ? spot.name : spot.nameEn,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isChinese ? spot.address : spot.addressEn,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(spot.rating.toString()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 操作按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isChinese ? '继续编辑' : 'Continue Editing'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSaveDialog();
                    },
                    child: Text(isChinese ? '保存行程' : 'Save Knight Codebook'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '保存行程' : 'Save Knight Codebook'),
        content: Text(isChinese ? '行程已保存到本地！' : 'Knight Codebook saved locally!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '确定' : 'OK'),
          ),
        ],
      ),
    );
  }
} 