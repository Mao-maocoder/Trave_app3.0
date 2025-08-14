import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../widgets/optimized_image.dart';

class BrowsingHistoryScreen extends StatefulWidget {
  const BrowsingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BrowsingHistoryScreen> createState() => _BrowsingHistoryScreenState();
}

class _BrowsingHistoryScreenState extends State<BrowsingHistoryScreen> {
  final List<Map<String, dynamic>> _browsingHistory = [
    {
      'id': 'gugong',
      'title': '故宫博物院',
      'subtitle': '紫禁城的秘密',
      'image': 'assets/images/spots/故宫.png',
      'visitTime': DateTime.now().subtract(const Duration(hours: 2)),
      'duration': '45分钟',
      'type': 'spot',
    },
    {
      'id': 'tiantan',
      'title': '天坛公园',
      'subtitle': '祈年殿的传说',
      'image': 'assets/images/spots/天坛.png',
      'visitTime': DateTime.now().subtract(const Duration(days: 1)),
      'duration': '30分钟',
      'type': 'spot',
    },
    {
      'id': 'zhonggulou',
      'title': '钟鼓楼',
      'subtitle': '古都时光',
      'image': 'assets/images/spots/钟鼓楼.png',
      'visitTime': DateTime.now().subtract(const Duration(days: 2)),
      'duration': '20分钟',
      'type': 'spot',
    },
    {
      'id': 'exhibition_1',
      'title': '彩画千年',
      'subtitle': '中国官式彩画传承与创新展',
      'image': 'assets/images/spots/故宫.png',
      'visitTime': DateTime.now().subtract(const Duration(days: 3)),
      'duration': '60分钟',
      'type': 'exhibition',
    },
    {
      'id': 'music_1',
      'title': '《中轴》大型民族管弦乐',
      'subtitle': '第一乐章：一城永定',
      'image': 'assets/images/spots/天坛.png',
      'visitTime': DateTime.now().subtract(const Duration(days: 4)),
      'duration': '15分钟',
      'type': 'music',
    },
  ];

  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '浏览历史' : 'Browsing History', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearHistoryDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选器
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('all', isChinese ? '全部' : 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('spot', isChinese ? '景点' : 'Spots'),
                const SizedBox(width: 8),
                _buildFilterChip('exhibition', isChinese ? '展览' : 'Exhibitions'),
                const SizedBox(width: 8),
                _buildFilterChip('music', isChinese ? '音乐' : 'Music'),
              ],
            ),
          ),
          
          // 历史列表
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: kPrimaryColor.withOpacity(0.2),
      checkmarkColor: kPrimaryColor,
      labelStyle: TextStyle(
        color: isSelected ? kPrimaryColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildHistoryList() {
    final filteredHistory = _selectedFilter == 'all' 
        ? _browsingHistory 
        : _browsingHistory.where((item) => item['type'] == _selectedFilter).toList();

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无浏览记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        final item = filteredHistory[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: OptimizedImage(
            imageUrl: item['image'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item['title'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['subtitle'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(item['visitTime']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.timer,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  item['duration'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'delete') {
              _deleteHistoryItem(item);
            } else if (value == 'share') {
              _shareHistoryItem(item);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  const Icon(Icons.share, size: 16),
                  const SizedBox(width: 8),
                  Text(isChinese ? '分享' : 'Share'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    isChinese ? '删除' : 'Delete',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _openHistoryItem(item);
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _showClearHistoryDialog() {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '清除浏览历史' : 'Clear Browsing History'),
        content: Text(isChinese ? '确定要清除所有浏览历史吗？此操作无法撤销。' : 'Are you sure you want to clear all browsing history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(isChinese ? '清除' : 'Clear'),
          ),
        ],
      ),
    );
  }

  void _clearAllHistory() {
    setState(() {
      _browsingHistory.clear();
    });
    
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '浏览历史已清除' : 'Browsing history cleared'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteHistoryItem(Map<String, dynamic> item) {
    setState(() {
      _browsingHistory.removeWhere((element) => element['id'] == item['id']);
    });
    
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '已删除浏览记录' : 'Browsing record deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareHistoryItem(Map<String, dynamic> item) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '分享功能开发中...' : 'Share feature coming soon...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openHistoryItem(Map<String, dynamic> item) {
    // 根据类型导航到相应页面
    switch (item['type']) {
      case 'spot':
        Navigator.pushNamed(context, '/spot-detail', arguments: {'spotId': item['id']});
        break;
      case 'exhibition':
        Navigator.pushNamed(context, '/exhibitions');
        break;
      case 'music':
        Navigator.pushNamed(context, '/music');
        break;
      default:
        break;
    }
  }
} 