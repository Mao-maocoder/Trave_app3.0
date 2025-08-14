import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/locale_provider.dart';
import '../services/tourist_spot_service.dart';
import '../models/tourist_spot.dart';
import '../widgets/platform_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final TouristSpotService _spotService = TouristSpotService();
  List<TouristSpot> _spots = [];
  bool _isLoading = true;
  TouristSpot? _selectedSpot;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _mapError = false;
  
  // 北京中轴线中心坐标
  static const LatLng _beijingCenter = LatLng(39.9042, 116.4074);

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
        _spots = spots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _retryMap() {
    setState(() {
      _mapError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isChinese ? '景点地图' : 'Spot Map'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
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
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSpots,
                tooltip: isChinese ? '刷新' : 'Refresh',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // 地图区域
                      Expanded(
                        flex: 2,
                        child: _buildMapArea(isChinese),
                      ),
                      // 景点列表
                      Expanded(
                        flex: 1,
                        child: _buildSpotList(isChinese),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMapArea(bool isChinese) {
    if (_mapError) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[100],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                isChinese ? '地图加载失败' : 'Map Loading Failed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _retryMap,
                child: Text(isChinese ? '重试' : 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            center: _beijingCenter,
            zoom: 12.0,
            onTap: (_, __) {
              setState(() {
                _selectedSpot = null;
              });
            },
          ),
          children: [
            // 使用OpenStreetMap瓦片
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.travel_app',
              maxZoom: 18,
            ),
            // 景点标记
            MarkerLayer(
              markers: _spots.map((spot) {
                final isSelected = _selectedSpot?.id == spot.id;
                return Marker(
                  point: LatLng(spot.latitude, spot.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpot = isSelected ? null : spot;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.blue,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.white : Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotList(bool isChinese) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isChinese ? '景点列表' : 'Spot List',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _spots.length,
              itemBuilder: (context, index) {
                final spot = _spots[index];
                final isSelected = _selectedSpot?.id == spot.id;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      isChinese ? spot.name : spot.nameEn,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      isChinese ? spot.description : spot.descriptionEn,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedSpot = isSelected ? null : spot;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 