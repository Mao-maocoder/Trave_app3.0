import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/locale_provider.dart';
import '../services/tourist_spot_service.dart';
import '../models/tourist_spot.dart';
import '../widgets/platform_image.dart';
import '../screens/spot_detail_screen.dart';
import '../constants.dart';

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
  
  // DraggableScrollableSheet 控制器
  final DraggableScrollableController _draggableController = DraggableScrollableController();
  
  // 地图样式相关
  int _currentMapStyle = 0; // 当前选中的地图样式索引
  
  // 地图样式配置
  static const List<Map<String, dynamic>> _mapStyles = [
    {
      'name': '卫星地图',
      'nameEn': 'Satellite',
      'url': 'https://webst02.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}',
      'icon': Icons.satellite,
    },
    {
      'name': '混合地图',
      'nameEn': 'Hybrid',
      'url': 'https://webst02.is.autonavi.com/appmaptile?style=8&x={x}&y={y}&z={z}',
      'icon': Icons.layers,
    },
    {
      'name': 'OpenStreetMap',
      'nameEn': 'OpenStreetMap',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      'icon': Icons.public,
    },
  ];
  
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
    _draggableController.dispose();
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

  // 展开景点列表
  void _expandSpotList() {
    try {
      if (_draggableController.isAttached) {
        _draggableController.animateTo(
          0.85,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // 如果控制器未附加，忽略操作
      print('DraggableScrollableController not attached yet');
    }
  }

  // 收起景点列表，显示地图
  void _collapseSpotList() {
    try {
      if (_draggableController.isAttached) {
        _draggableController.animateTo(
          0.12,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // 如果控制器未附加，忽略操作
      print('DraggableScrollableController not attached yet');
    }
  }

  // 显示地图样式选择器
  void _showMapStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMapStyleSelector(),
    );
  }

  // 构建地图样式选择器
  Widget _buildMapStyleSelector() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        return Container(
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(kRadiusCard),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: kQuaternaryColor,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                ),
              ),
              const SizedBox(height: 16),
              
              // 标题
              Text(
                isChinese ? '选择地图样式' : 'Select Map Style',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                  fontFamily: kFontFamilyTitle,
                ),
              ),
              const SizedBox(height: 16),
              
              // 样式选项列表
              ...List.generate(_mapStyles.length, (index) {
                final style = _mapStyles[index];
                final isSelected = index == _currentMapStyle;
                
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor.withOpacity(0.1) : kQuaternaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(kRadiusCard),
                    ),
                    child: Icon(
                      style['icon'],
                      color: isSelected ? kPrimaryColor : kQuaternaryColor,
                    ),
                  ),
                  title: Text(
                    isChinese ? style['name'] : style['nameEn'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? kPrimaryColor : kTextPrimary,
                      fontFamily: kFontFamilyTitle,
                    ),
                  ),
                  trailing: isSelected 
                    ? Icon(Icons.check_circle, color: kPrimaryColor)
                    : null,
                  onTap: () {
                    setState(() {
                      _currentMapStyle = index;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        return Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // 地图区域 - 全屏显示
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildMapArea(isChinese),
                      ),
                    ),
                    
                    // 顶部应用栏 - 浮动在地图上方
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: kCardBackground.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(kRadiusCard),
                            boxShadow: kShadowLight,
                          ),
                          child: Row(
                            children: [
                              Text(
                                isChinese ? '景点地图' : 'Spot Map',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kTextPrimary,
                                  fontFamily: kFontFamilyTitle,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(kRadiusCard),
                                  ),
                                  child: const Icon(Icons.language, size: 20),
                                ),
                                tooltip: isChinese ? '切换到英文' : 'Switch to Chinese',
                                onPressed: localeProvider.toggleLocale,
                              ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(kRadiusCard),
                                  ),
                                  child: Icon(_mapStyles[_currentMapStyle]['icon'], size: 20),
                                ),
                                onPressed: _showMapStyleSelector,
                                tooltip: isChinese ? '切换地图样式' : 'Switch Map Style',
                              ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(kRadiusCard),
                                  ),
                                  child: const Icon(Icons.refresh, size: 20),
                                ),
                                onPressed: _loadSpots,
                                tooltip: isChinese ? '刷新' : 'Refresh',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 可拖拽的景点列表面板
                    DraggableScrollableSheet(
                      controller: _draggableController,
                      initialChildSize: 0.12, // 初始高度更小，主要显示地图
                      minChildSize: 0.12,     // 最小高度
                      maxChildSize: 0.85,     // 最大高度
                      snap: true,             // 启用吸附效果
                      snapSizes: const [0.12, 0.85], // 吸附位置
                      builder: (context, scrollController) {
                        return NotificationListener<DraggableScrollableNotification>(
                          onNotification: (notification) {
                            // 可以在这里监听拖拽状态变化
                            return true;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: kCardBackground,
                              borderRadius: BorderRadius.circular(kRadiusCard),
                              boxShadow: kShadowMedium,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // 顶部信息栏和拖拽指示器
                                Container(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: _buildPanelHeader(isChinese),
                                ),
                                // 景点列表内容
                                Expanded(
                                  child: _buildSpotList(scrollController, isChinese),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPanelHeader(bool isChinese) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: kQuaternaryColor,
              borderRadius: BorderRadius.circular(kRadiusCard),
            ),
          ),
          const SizedBox(height: 12),
          
          // 景点信息概览
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: kPrimaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isChinese ? '发现 ${_spots.length} 个景点' : 'Discover ${_spots.length} spots',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                  fontFamily: kFontFamilyTitle,
                ),
              ),
              const Spacer(),
              
              // 展开/收起按钮
              GestureDetector(
                onTap: () {
                  // 根据当前状态决定展开或收起
                  try {
                    if (_draggableController.isAttached) {
                      if (_draggableController.size < 0.5) {
                        _expandSpotList();
                      } else {
                        _collapseSpotList();
                      }
                    } else {
                      // 如果控制器未附加，默认展开
                      _expandSpotList();
                    }
                  } catch (e) {
                    // 如果出现异常，默认展开
                    _expandSpotList();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(kRadiusCard),
                  ),
                  child: AnimatedBuilder(
                    animation: _draggableController,
                    builder: (context, child) {
                      // 安全地获取控制器状态，避免在未附加时访问
                      double size = 0.0;
                      try {
                        if (_draggableController.isAttached) {
                          size = _draggableController.size;
                        }
                      } catch (e) {
                        // 如果控制器未附加，使用默认值
                        size = 0.12;
                      }
                      
                      final isExpanded = size > 0.5;
                      return Icon(
                        isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: kPrimaryColor,
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          Text(
            isChinese ? '向上滑动查看详细列表' : 'Swipe up to view detailed list',
            style: TextStyle(
              fontSize: 12,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotList(ScrollController scrollController, bool isChinese) {
    if (_spots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: kQuaternaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              isChinese ? '暂无景点数据' : 'No spots available',
              style: TextStyle(
                fontSize: 16,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _spots.length,
      itemBuilder: (context, index) {
        final spot = _spots[index];
        final isSelected = _selectedSpot?.id == spot.id;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? kAccentColor : kCardBackground,
            borderRadius: BorderRadius.circular(kRadiusCard),
            border: Border.all(
              color: isSelected ? kPrimaryColor : kQuaternaryColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: kShadowLight,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusCard),
              child: spot.imageUrl.isNotEmpty
                  ? PlatformImage(
                      imageUrl: spot.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(kRadiusCard),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: kPrimaryColor,
                        size: 32,
                      ),
                    ),
            ),
            title: Text(
              isChinese ? spot.name : spot.nameEn,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? kPrimaryColor : kTextPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  isChinese ? spot.description : spot.descriptionEn,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // 评分星级
                    ...List.generate(5, (i) => Icon(
                          i < spot.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        )),
                    // 评论数
                    if (spot.reviewCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          '(${spot.reviewCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
              color: isSelected ? kPrimaryColor : kQuaternaryColor,
            ),
            onTap: () {
              setState(() {
                _selectedSpot = isSelected ? null : spot;
              });
              // 如果选中了景点，收起列表显示地图
              if (!isSelected) {
                _collapseSpotList();
                // 跳转详情页，传递spot对象
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpotDetailScreen(),
                    settings: RouteSettings(arguments: {
                      'spot': {
                        'name': spot.name,
                        'image': spot.imageUrl,
                        'description': spot.description,
                        'longitude': spot.longitude,
                        'latitude': spot.latitude,
                      }
                    }),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMapArea(bool isChinese) {
    if (_mapError) {
      return Container(
        color: kBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 64, color: kQuaternaryColor),
              const SizedBox(height: 16),
              Text(
                isChinese ? '地图加载失败' : 'Map Loading Failed',
                style: TextStyle(
                  fontSize: 18,
                  color: kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _retryMap,
                icon: const Icon(Icons.refresh),
                label: Text(isChinese ? '重试' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadiusCard),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _beijingCenter,
        initialZoom: 12.0,
        maxZoom: 16.0,
        minZoom: 10.0,
        onTap: (_, __) {
          setState(() {
            _selectedSpot = null;
          });
        },
      ),
      children: [
        // 使用动态地图瓦片，根据当前选择的样式
        TileLayer(
          urlTemplate: _mapStyles[_currentMapStyle]['url'],
          maxZoom: 16,
        ),
        // 景点标记
        MarkerLayer(
          markers: _spots.map((spot) {
            final isSelected = _selectedSpot?.id == spot.id;
            return Marker(
              point: LatLng(spot.latitude, spot.longitude),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSpot = isSelected ? null : spot;
                  });
                  
                  // 点击标记时展开景点列表
                  if (!isSelected) {
                    _expandSpotList();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : kCardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.red : kPrimaryColor,
                      width: 3,
                    ),
                    boxShadow: kShadowMedium,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: isSelected ? Colors.white : kPrimaryColor,
                    size: 28,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}