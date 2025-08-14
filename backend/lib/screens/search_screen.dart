import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tourist_spot.dart';
import '../providers/locale_provider.dart';
import '../services/tourist_spot_service.dart';
import '../widgets/platform_image.dart';
import '../utils/performance_config.dart';
import '../utils/ui_performance.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TouristSpotService _spotService = TouristSpotService();
  
  List<TouristSpot> _searchResults = [];
  List<TouristSpot> _allSpots = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllSpots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSpots() async {
    setState(() {
      _isLoading = true;
    });

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

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _spotService.searchSpots(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isChinese = localeProvider.locale == AppLocale.zh;

    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '搜索景点' : 'Search Spots'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isChinese ? '搜索景点名称、描述或标签...' : 'Search spot names, descriptions, or tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
        ),
      ),
      body: _buildBody(isChinese),
    );
  }

  Widget _buildBody(bool isChinese) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return _buildSuggestions(isChinese);
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults(isChinese);
    }

    return _buildSearchResults(isChinese);
  }

  Widget _buildSuggestions(bool isChinese) {
    // 根据语言定义热门搜索标签
    final List<Map<String, String>> popularTags = [
      {'zh': '故宫', 'en': 'Forbidden City'},
      {'zh': '天坛', 'en': 'Temple of Heaven'},
      {'zh': '历史古迹', 'en': 'Historical Sites'},
      {'zh': '中轴线', 'en': 'Central Axis'},
      {'zh': '颐和园', 'en': 'Summer Palace'},
      {'zh': '长城', 'en': 'Great Wall'},
      {'zh': '文化体验', 'en': 'Cultural Experience'},
      {'zh': '美食', 'en': 'Food'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isChinese ? '热门搜索' : 'Popular Searches',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularTags.map((tag) {
            final tagText = isChinese ? tag['zh']! : tag['en']!;
            return ActionChip(
              label: Text(tagText),
              onPressed: () {
                _searchController.text = tagText;
                _performSearch(tagText);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        Text(
          isChinese ? '所有景点' : 'All Spots',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._allSpots.map((spot) => _buildSpotTile(spot, isChinese)),
      ],
    );
  }

  Widget _buildNoResults(bool isChinese) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isChinese ? '没有找到相关景点' : 'No spots found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '尝试使用不同的关键词' : 'Try using different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isChinese) {
    return PerformantListView(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final spot = _searchResults[index];
        return _buildSpotTile(spot, isChinese);
      },
    );
  }

  Widget _buildSpotTile(TouristSpot spot, bool isChinese) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: OptimizedImage(
              imageUrl: spot.imageUrl,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            isChinese ? spot.name : spot.nameEn,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
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
            const SizedBox(height: 4),
            Text(
              isChinese ? spot.description : spot.descriptionEn,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (spot.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: (isChinese ? spot.tags : spot.tagsEn).take(3).map((tag) => Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/spot_detail',
            arguments: {'spotId': spot.id},
          );
        },
        ),
      ),
    );
  }
} 