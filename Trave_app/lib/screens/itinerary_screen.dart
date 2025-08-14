import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../services/tourist_spot_service.dart';
import '../services/itinerary_service.dart';
import '../models/tourist_spot.dart';
import '../models/itinerary_item.dart';
import '../models/user.dart';
import '../widgets/platform_image.dart';
import '../constants.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({Key? key}) : super(key: key);

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with TickerProviderStateMixin {
  final TouristSpotService _spotService = TouristSpotService();
  List<TouristSpot> _allSpots = [];
  List<ItineraryItem> _itineraryItems = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // 多天行程功能
  int _selectedDate = 0;
  Map<String, List<ItineraryItem>> _multiDayItinerary = {};
  bool _isGuideMode = false; // 是否为导游模式
  bool _showCallNotification = true; // 添加通知显示状态
  
  // 默认时间设置
  DateTime _currentDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);

  // 新增：任务系统
  List<Map<String, dynamic>> _mainTasks = [];
  List<Map<String, dynamic>> _sideTasks = [];
  Map<String, bool> _completedTasks = {};

  // 主线任务定义
  final List<Map<String, dynamic>> _mainTaskDefinitions = [
    {
      'id': 'yongdingmen',
      'name_zh': '太平鼓迎宾·对称美学的共鸣',
      'name_en': 'Peace Drum Welcome·Symmetrical Aesthetics Resonance',
      'spot_name': '永定门',
      'description_zh': '解锁京西太平鼓AR舞蹈教学',
      'description_en': 'Unlock Jingxi Peace Drum AR Dance Tutorial',
      'reward': '太平鼓徽章',
      'icon': Icons.music_note,
    },
    {
      'id': 'tiantan',
      'name_zh': '祈年殿的时空密码',
      'name_en': 'Qinian Hall\'s Time-Space Code',
      'spot_name': '天坛',
      'description_zh': '对比中国农历与印加结绳记事',
      'description_en': 'Compare Chinese Lunar Calendar with Inca Quipu',
      'reward': '时空密码徽章',
      'icon': Icons.access_time,
    },
    {
      'id': 'gugong',
      'name_zh': '太和殿斗拱拼装挑战',
      'name_en': 'Taihe Hall Bracket Assembly Challenge',
      'spot_name': '故宫',
      'description_zh': 'AR模拟榫卯结构，对比马丘比丘石墙',
      'description_en': 'AR Mortise-Tenon Simulation, Compare with Machu Picchu',
      'reward': '木石匠心徽章',
      'icon': Icons.architecture,
    },
    {
      'id': 'wanningqiao',
      'name_zh': '镇水兽AR治水模拟',
      'name_en': 'Water Guardian AR Water Control Simulation',
      'spot_name': '万宁桥',
      'description_zh': '还原元代水利智慧',
      'description_en': 'Restore Yuan Dynasty Water Control Wisdom',
      'reward': '水利智慧徽章',
      'icon': Icons.water,
    },
    {
      'id': 'qianmen',
      'name_zh': '前门大街的市井风情',
      'name_en': 'Qianmen Street Folk Customs',
      'spot_name': '前门',
      'description_zh': '体验老北京商业文化',
      'description_en': 'Experience Old Beijing Commercial Culture',
      'reward': '市井风情徽章',
      'icon': Icons.store,
    },
    {
      'id': 'zhongzhou',
      'name_zh': '中轴音乐厅的文化交响',
      'name_en': 'Central Axis Concert Hall Cultural Symphony',
      'spot_name': '中轴音乐厅',
      'description_zh': '感受中秘音乐文化的融合',
      'description_en': 'Experience Chinese-Peruvian Music Fusion',
      'reward': '音乐文化徽章',
      'icon': Icons.music_note,
    },
    {
      'id': 'gulou',
      'name_zh': '钟鼓楼的时空回响',
      'name_en': 'Bell and Drum Tower Time Echo',
      'spot_name': '钟鼓楼',
      'description_zh': '聆听古代报时系统的智慧',
      'description_en': 'Listen to Ancient Time-Telling Wisdom',
      'reward': '时空回响徽章',
      'icon': Icons.schedule,
    },
  ];

  // 支线任务定义
  final List<Map<String, dynamic>> _sideTaskDefinitions = [
    {
      'id': 'peru_symbols',
      'name_zh': '寻找中轴线上的秘鲁符号',
      'name_en': 'Find Peruvian Symbols on Central Axis',
      'description_zh': '寻找四合院宴中的藜麦菜品、琉璃瓦当兽头等秘鲁元素',
      'description_en': 'Find quinoa dishes, glazed tile beasts and other Peruvian elements',
      'reward': '文明符号徽章',
      'icon': Icons.search,
    },
    {
      'id': 'civilization_dialogue',
      'name_zh': '文明对话打卡',
      'name_en': 'Civilization Dialogue Check-in',
      'description_zh': '在7大景点完成文明对比拍照',
      'description_en': 'Complete civilization comparison photos at 7 major spots',
      'reward': '文明对话徽章',
      'icon': Icons.camera_alt,
    },
    {
      'id': 'ar_experience',
      'name_zh': 'AR体验收集',
      'name_en': 'AR Experience Collection',
      'description_zh': '完成所有AR互动体验',
      'description_en': 'Complete all AR interactive experiences',
      'reward': 'AR体验徽章',
      'icon': Icons.view_in_ar,
    },
  ];

  // 新增：中轴奇遇行程路线数据 - 按日期分类
  final Map<int, List<Map<String, String>>> _multiDayAxisAdventureTimeline = {
    0: [ // 第一天 - 中秘文化交流：一天行程
      {
        'scene': '故宫',
        'culture': '中秘文化交流：天工开物 故宫&马丘比丘',
        'activity': '上午：利用APP，展示故宫布局\n导游拼接榫卯结构，对比马丘比丘石墙',
      },
      {
        'scene': '万宁桥',
        'culture': '中秘文化交流：河清海晏 万宁桥&纳斯卡水渠',
        'activity': '下午：利用APP，展示万宁桥\n镇水兽AR治水模拟，对比纳斯卡水渠',
      },
      {
        'scene': '钟鼓楼',
        'culture': '中秘文化交流：时间之声 钟鼓楼&印加日晷',
        'activity': '下午：体验古代报时系统\n对比中国与印加文明的时间观念',
      },
      {
        'scene': '东来顺',
        'culture': '中秘文化交流：佳肴美馔 中国秘鲁美食对比',
        'activity': '晚上：品尝东来顺铜锅涮肉\n对比秘鲁传统烤肉技术',
      },
    ],
  };

  // 保留原有的固定数据作为备用
  final List<Map<String, String>> axisAdventureTimeline = [
    {
      'scene': '天坛',
      'culture': '一重互鉴：天人合一 祈年殿&太阳神庙',
      'activity': '利用APP，展示天坛布局\n非遗展示京西太平鼓迎宾',
    },
    {
      'scene': '故宫',
      'culture': '二重互鉴：天工开物 故宫&马丘比丘',
      'activity': '利用APP，展示故宫布局\n导游拼接榫卯',
    },
    {
      'scene': '故宫',
      'culture': '旅游拍摄',
      'activity': '清朝宫廷风沉浸式拍摄',
    },
    {
      'scene': '万宁桥',
      'culture': '三重互鉴：河清海晏 万宁桥&纳斯卡水渠',
      'activity': '利用APP，展示万宁桥\n镇水兽AR治水模拟',
    },
    {
      'scene': '京韵四合晚宴',
      'culture': '四重互鉴：佳肴美馔 中国秘鲁主题宴会设计',
      'activity': '利用APP，展示四合院\n京韵四合-八道定制菜',
    },
    {
      'scene': '旅游文创产品',
      'culture': '北京中轴线文化延伸',
      'activity': '北京中轴线邮票、六龙三凤冰箱贴、天宫藻井冰箱贴京文创等伴手礼',
    },
  ];

  // 导游行程管理
  List<Map<String, dynamic>> _guideItineraries = [];
  bool _isCreatingItinerary = false;
  Map<String, dynamic>? _editingItinerary;
  
  // 行程模板
  final List<Map<String, dynamic>> _itineraryTemplates = [
    {
      'id': 'template_1',
      'name': '经典中轴线一日游',
      'description': '游览北京中轴线核心景点，体验传统文化',
      'spots': ['永定门', '天坛', '前门', '故宫', '钟鼓楼'],
      'duration': '1天',
      'difficulty': '简单',
    },
    {
      'id': 'template_2', 
      'name': '深度文化体验两日游',
      'description': '深入了解中轴线文化，包含AR体验和互动环节',
      'spots': ['永定门', '天坛', '先农坛', '前门', '故宫', '什刹海', '钟鼓楼'],
      'duration': '2天',
      'difficulty': '中等',
    },
    {
      'id': 'template_3',
      'name': '摄影主题一日游',
      'description': '专为摄影爱好者设计的路线，最佳拍摄时间和角度',
      'spots': ['天坛', '故宫', '什刹海', '钟鼓楼'],
      'duration': '1天',
      'difficulty': '简单',
    },
  ];

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
    _checkGuideMode();
    _loadSpots();
    _initializeSampleItinerary(); // 添加示例行程
    _animationController.forward();
  }

  // 检查是否为导游模式
  void _checkGuideMode() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      setState(() {
        _isGuideMode = authProvider.currentUser!.role == UserRole.guide;
      });
      print('🔍 用户角色检测: ${authProvider.currentUser!.role}');
      print('🔍 是否为导游模式: $_isGuideMode');
    }
  }

  // 初始化示例行程
  void _initializeSampleItinerary() {
    if (!_isGuideMode) {
      // 为游客添加示例行程
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      _multiDayItinerary[todayKey] = [
        ItineraryItem(
          spot: TouristSpot(
            id: 'tiantan',
            name: '天坛公园',
            nameEn: 'Temple of Heaven',
            description: '游览祈年殿、回音壁，感受古代祭祀文化',
            descriptionEn: 'Visit the Hall of Prayer for Good Harvests and Echo Wall to experience ancient sacrificial culture',
            imageUrl: 'assets/images/spots/天坛.png',
            latitude: 39.8822,
            longitude: 116.4066,
            address: '北京市东城区天坛东路1号',
            addressEn: '1 Tiantan East Road, Dongcheng District, Beijing',
            tags: ['历史', '文化', '祭祀'],
            tagsEn: ['History', 'Culture', 'Sacrifice'],
            category: 'historical',
          ),
          startTime: DateTime.now().copyWith(hour: 9, minute: 0),
          durationMinutes: 180,
          notes: '游览祈年殿、回音壁，感受古代祭祀文化',
        ),
        ItineraryItem(
          spot: TouristSpot(
            id: 'qianmen',
            name: '前门大街',
            nameEn: 'Qianmen Street',
            description: '体验老北京风情，品尝特色小吃',
            descriptionEn: 'Experience old Beijing charm and taste local snacks',
            imageUrl: 'assets/images/spots/前门.png',
            latitude: 39.8994,
            longitude: 116.3974,
            address: '北京市东城区前门大街',
            addressEn: 'Qianmen Street, Dongcheng District, Beijing',
            tags: ['美食', '文化', '商业'],
            tagsEn: ['Food', 'Culture', 'Commerce'],
            category: 'cultural',
          ),
          startTime: DateTime.now().copyWith(hour: 14, minute: 0),
          durationMinutes: 180,
          notes: '体验老北京风情，品尝特色小吃',
        ),
        ItineraryItem(
          spot: TouristSpot(
            id: 'yongdingmen',
            name: '永定门',
            nameEn: 'Yongdingmen',
            description: '中轴线南起点，感受古都城门文化',
            descriptionEn: 'Southern starting point of the central axis, experience ancient city gate culture',
            imageUrl: 'assets/images/spots/永定门.png',
            latitude: 39.8667,
            longitude: 116.4000,
            address: '北京市东城区永定门内大街',
            addressEn: 'Yongdingmen Inner Street, Dongcheng District, Beijing',
            tags: ['历史', '城门', '文化'],
            tagsEn: ['History', 'City Gate', 'Culture'],
            category: 'historical',
          ),
          startTime: DateTime.now().copyWith(hour: 17, minute: 0),
          durationMinutes: 120,
          notes: '中轴线南起点，感受古都城门文化',
        ),
      ];

      // 添加中秘文化交流一天行程
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowKey = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      
      _multiDayItinerary[tomorrowKey] = [
        ItineraryItem(
          spot: TouristSpot(
            id: 'gugong',
            name: '故宫博物院',
            nameEn: 'Forbidden City',
            description: '参观太和殿、中和殿、保和殿，体验皇家建筑之美',
            descriptionEn: 'Visit the Hall of Supreme Harmony, Hall of Central Harmony, and Hall of Preserving Harmony to experience the beauty of royal architecture',
            imageUrl: 'assets/images/spots/故宫.png',
            latitude: 39.9163,
            longitude: 116.3972,
            address: '北京市东城区景山前街4号',
            addressEn: '4 Jingshan Front Street, Dongcheng District, Beijing',
            tags: ['历史', '文化', '建筑'],
            tagsEn: ['History', 'Culture', 'Architecture'],
            category: 'historical',
          ),
          startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 9, minute: 0),
          durationMinutes: 240,
          notes: '中秘文化交流：参观太和殿、中和殿、保和殿，体验皇家建筑之美',
        ),
        ItineraryItem(
          spot: TouristSpot(
            id: 'wanningqiao',
            name: '万宁桥',
            nameEn: 'Wanning Bridge',
            description: '游览万宁桥，体验古都水乡风情',
            descriptionEn: 'Visit Wanning Bridge to experience the water town charm of the ancient capital',
            imageUrl: 'assets/images/spots/什刹海万宁桥.png',
            latitude: 39.9396,
            longitude: 116.3917,
            address: '北京市西城区什刹海',
            addressEn: 'Shichahai, Xicheng District, Beijing',
            tags: ['水乡', '文化', '休闲'],
            tagsEn: ['Water Town', 'Culture', 'Leisure'],
            category: 'cultural',
          ),
          startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 14, minute: 0),
          durationMinutes: 120,
          notes: '中秘文化交流：游览万宁桥，体验古都水乡风情',
        ),
        ItineraryItem(
          spot: TouristSpot(
            id: 'zhonggulou',
            name: '钟鼓楼',
            nameEn: 'Bell and Drum Towers',
            description: '登上钟鼓楼，俯瞰古都风貌',
            descriptionEn: 'Climb the Bell and Drum Towers to overlook the ancient capital',
            imageUrl: 'assets/images/spots/钟鼓楼.png',
            latitude: 39.9396,
            longitude: 116.3917,
            address: '北京市东城区钟楼湾胡同',
            addressEn: 'Zhonglouwan Hutong, Dongcheng District, Beijing',
            tags: ['历史', '建筑', '观景'],
            tagsEn: ['History', 'Architecture', 'View'],
            category: 'historical',
          ),
          startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 16, minute: 0),
          durationMinutes: 120,
          notes: '中秘文化交流：登上钟鼓楼，俯瞰古都风貌',
        ),
        ItineraryItem(
          spot: TouristSpot(
            id: 'donglaishun',
            name: '东来顺铜锅涮肉',
            nameEn: 'Donglaishun Hot Pot',
            description: '品尝北京传统铜锅涮肉',
            descriptionEn: 'Taste traditional Beijing hot pot',
            imageUrl: 'assets/images/spots/天坛.png', // 使用天坛图片作为临时图片
            latitude: 39.9244,
            longitude: 116.3917,
            address: '北京市东城区王府井大街198号',
            addressEn: '198 Wangfujing Street, Dongcheng District, Beijing',
            tags: ['美食', '传统', '文化'],
            tagsEn: ['Food', 'Traditional', 'Culture'],
            category: 'cultural',
          ),
          startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 19, minute: 0),
          durationMinutes: 120,
          notes: '中秘文化交流：品尝北京传统铜锅涮肉',
        ),
      ];
    }
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
      });
      
      // 加载用户行程
      await _loadUserItinerary();
      
      // 初始化任务系统
      _initializeTasks();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 初始化任务系统
  void _initializeTasks() {
    _mainTasks = List.from(_mainTaskDefinitions);
    _sideTasks = List.from(_sideTaskDefinitions);
    
    // 从本地存储加载任务完成状态
    _loadTaskProgress();
  }

  // 加载任务进度
  void _loadTaskProgress() {
    // TODO: 从SharedPreferences加载任务完成状态
    // 这里暂时使用模拟数据
    _completedTasks = {
      'yongdingmen': false,
      'tiantan': false,
      'gugong': false,
      'wanningqiao': false,
      'qianmen': false,
      'zhongzhou': false,
      'gulou': false,
      'peru_symbols': false,
      'civilization_dialogue': false,
      'ar_experience': false,
    };
  }

  // 完成任务
  void _completeTask(String taskId) {
    setState(() {
      _completedTasks[taskId] = true;
    });
    
    // 保存任务进度
    _saveTaskProgress();
    
    // 显示完成提示
    _showTaskCompletionDialog(taskId);
  }

  // 保存任务进度
  void _saveTaskProgress() {
    // TODO: 保存到SharedPreferences
  }

  // 显示任务完成对话框
  void _showTaskCompletionDialog(String taskId) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    // 找到对应的任务
    Map<String, dynamic>? task;
    if (_mainTasks.any((t) => t['id'] == taskId)) {
      task = _mainTasks.firstWhere((t) => t['id'] == taskId);
    } else if (_sideTasks.any((t) => t['id'] == taskId)) {
      task = _sideTasks.firstWhere((t) => t['id'] == taskId);
    }
    
    if (task == null) return;
    final t = task;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isChinese ? '任务完成！' : 'Task Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isChinese ? (t['name_zh'] as String? ?? '') : (t['name_en'] as String? ?? ''),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isChinese ? '获得奖励：${t['reward'] as String? ?? ''}' : 'Reward: ${t['reward'] as String? ?? ''}',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '确定' : 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserItinerary() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.currentUser != null) {
        final userId = authProvider.currentUser!.id;
        final items = await ItineraryService.getUserItinerary(userId);
        setState(() {
          _itineraryItems = items;
        });
        print('✅ 加载用户行程成功，共 ${items.length} 项');
      }
    } catch (e) {
      print('❌ 加载用户行程失败: $e');
    }
  }

  Future<void> _autoSaveToCloud(bool isChinese) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.currentUser != null) {
        final userId = authProvider.currentUser!.id;
        final success = await ItineraryService.saveUserItinerary(userId, _itineraryItems);
        if (success) {
          print('✅ 自动保存到云端成功');
        } else {
          print('❌ 自动保存到云端失败');
        }
      }
    } catch (e) {
      print('❌ 自动保存到云端出错: $e');
    }
  }

  void _addSpotToItinerary(TouristSpot spot) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddSpotDialog(spot, '', isChinese),
    );
  }

  Widget _buildAddSpotDialog(TouristSpot spot, String currentDateKey, bool isChinese) {
    TimeOfDay selectedTime = _startTime;
    int durationMinutes = 120; // 默认2小时
    final notesController = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                Icon(Icons.add_location, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isChinese ? '添加景点到行程' : 'Add Spot to Knight Codebook',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // 景点信息
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? spot.name : spot.nameEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isChinese ? spot.address : spot.addressEn,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 时间选择
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '开始时间' : 'Start Time',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 游玩时长选择
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '游玩时长' : 'Duration',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: durationMinutes.toDouble(),
                              min: 30,
                              max: 480, // 8小时
                              divisions: 15,
                              label: '${durationMinutes ~/ 60}小时${durationMinutes % 60}分钟',
                              onChanged: (value) {
                                setState(() {
                                  durationMinutes = value.round();
                                });
                              },
                            ),
                          ),
                          Text(
                            '${durationMinutes ~/ 60}小时${durationMinutes % 60}分钟',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 备注
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '备注' : 'Notes',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: isChinese ? '添加备注（可选）' : 'Add notes (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 操作按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isChinese ? '取消' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final startDateTime = DateTime(
                        _currentDate.year,
                        _currentDate.month,
                        _currentDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      
                      final newItem = ItineraryItem(
                        spot: spot,
                        startTime: startDateTime,
                        durationMinutes: durationMinutes,
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      );
                      
                                             setState(() {
                         _itineraryItems.add(newItem);
                         // 按时间排序
                         _itineraryItems.sort((a, b) => a.startTime.compareTo(b.startTime));
                       });
                       
                       Navigator.pop(context);
                       
                       // 自动保存到云端
                       _autoSaveToCloud(isChinese);
                       
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text(
                             isChinese ? '已添加到行程' : 'Added to Knight Codebook',
                           ),
                           backgroundColor: Colors.green,
                         ),
                       );
                    },
                    child: Text(isChinese ? '添加' : 'Add'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    setState(() {
      _itineraryItems.removeAt(index);
    });
    
    // 自动保存到云端
    _autoSaveToCloud(isChinese);
  }

  void _editItem(int index) {
    final item = _itineraryItems[index];
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditItemDialog(item, index, isChinese),
    );
  }

  Widget _buildEditItemDialog(ItineraryItem item, int index, bool isChinese) {
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(item.startTime);
    int durationMinutes = item.durationMinutes;
    final notesController = TextEditingController(text: item.notes ?? '');

    return StatefulBuilder(
      builder: (context, dialogSetState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                  color: Colors.orange[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isChinese ? '编辑行程项' : 'Edit Knight Codebook Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // 景点信息
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: PlatformImage(
                        imageUrl: item.spot.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isChinese ? item.spot.name : item.spot.nameEn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isChinese ? item.spot.address : item.spot.addressEn,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 时间选择
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '开始时间' : 'Start Time',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          dialogSetState(() {
                            selectedTime = time;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 游玩时长选择
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '游玩时长' : 'Duration',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: durationMinutes.toDouble(),
                              min: 30,
                              max: 480,
                              divisions: 15,
                              label: '${durationMinutes ~/ 60}小时${durationMinutes % 60}分钟',
                              onChanged: (value) {
                                dialogSetState(() {
                                  durationMinutes = value.round();
                                });
                              },
                            ),
                          ),
                          Text(
                            '${durationMinutes ~/ 60}小时${durationMinutes % 60}分钟',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 备注
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '备注' : 'Notes',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: isChinese ? '添加备注（可选）' : 'Add notes (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // 操作按钮
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(isChinese ? '取消' : 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final startDateTime = DateTime(
                            _currentDate.year,
                            _currentDate.month,
                            _currentDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          
                          final updatedItem = ItineraryItem(
                            spot: item.spot,
                            startTime: startDateTime,
                            durationMinutes: durationMinutes,
                            notes: notesController.text.isNotEmpty ? notesController.text : null,
                          );
                          
                          // 使用主屏幕的 setState 更新数据
                          setState(() {
                            _itineraryItems[index] = updatedItem;
                            // 按时间排序
                            _itineraryItems.sort((a, b) => a.startTime.compareTo(b.startTime));
                          });
                          
                          Navigator.pop(context);
                          
                          // 自动保存到云端
                          _autoSaveToCloud(isChinese);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isChinese ? '已更新行程' : 'Itinerary updated',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Text(isChinese ? '更新' : 'Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    // 根据用户角色显示不同界面
    if (_isGuideMode) {
      return _buildGuideDashboard(isChinese);
    } else {
      return _buildTouristItinerary(isChinese);
    }
  }

  // 导游后台管理界面
  Widget _buildGuideDashboard(bool isChinese) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '导游后台管理' : 'Guide Dashboard'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // 退出登录按钮
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(isChinese),
            tooltip: isChinese ? '退出登录' : 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计概览
            _buildStatisticsOverview(isChinese),
            const SizedBox(height: 20),
            
            // 功能模块
            _buildFunctionModules(isChinese),
            const SizedBox(height: 20),
            
            // 实时通知
            _buildRealTimeNotifications(isChinese),
          ],
        ),
      ),
    );
  }

  // 统计概览
  Widget _buildStatisticsOverview(bool isChinese) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                isChinese ? '数据统计概览' : 'Statistics Overview',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: isChinese ? '绑定游客' : 'Bound Tourists',
                  value: '12',
                  color: Colors.blue[100]!,
                  textColor: Colors.blue[800]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment,
                  title: isChinese ? '调查问卷' : 'Surveys',
                  value: '156',
                  color: Colors.green[100]!,
                  textColor: Colors.green[800]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.photo_camera,
                  title: isChinese ? '待审核照片' : 'Pending Photos',
                  value: '8',
                  color: Colors.orange[100]!,
                  textColor: Colors.orange[800]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.rate_review,
                  title: isChinese ? '待审核评价' : 'Pending Reviews',
                  value: '5',
                  color: Colors.purple[100]!,
                  textColor: Colors.purple[800]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 统计卡片
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 功能模块
  Widget _buildFunctionModules(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '功能管理' : 'Function Management',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildFunctionCard(
              icon: Icons.assignment,
              title: isChinese ? '问卷统计' : 'Survey Stats',
              subtitle: isChinese ? '查看问卷数据' : 'View survey data',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/admin-dashboard'),
            ),
            _buildFunctionCard(
              icon: Icons.people,
              title: isChinese ? '游客管理' : 'Tourist Management',
              subtitle: isChinese ? '管理绑定游客' : 'Manage bound tourists',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/tourist-management'),
            ),
            _buildFunctionCard(
              icon: Icons.photo_camera,
              title: isChinese ? '媒体审核' : 'Media Review',
              subtitle: isChinese ? '审核照片视频' : 'Review photos & videos',
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/media-review'),
            ),
            _buildFunctionCard(
              icon: Icons.rate_review,
              title: isChinese ? '评价管理' : 'Review Management',
              subtitle: isChinese ? '管理用户评价' : 'Manage user reviews',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/review-management'),
            ),
            _buildFunctionCard(
              icon: Icons.route,
              title: isChinese ? '行程发布' : 'Itinerary Publishing',
              subtitle: isChinese ? '创建发布行程' : 'Create & publish itineraries',
              color: Colors.red,
              onTap: () => _showItineraryPublishingDialog(isChinese),
            ),
            _buildFunctionCard(
              icon: Icons.view_list,
              title: isChinese ? '行程模板' : 'Itinerary Templates',
              subtitle: isChinese ? '管理行程模板' : 'Manage templates',
              color: Colors.teal,
              onTap: () => _showItineraryTemplatesDialog(isChinese),
            ),
          ],
        ),
      ],
    );
  }

  // 功能卡片
  Widget _buildFunctionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 实时通知
  Widget _buildRealTimeNotifications(bool isChinese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_active, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              isChinese ? '实时通知' : 'Real-time Notifications',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_showCallNotification) // 条件显示通知
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phone, color: Colors.red, size: 20),
              ),
              title: Text(
                isChinese ? '游客呼叫' : 'Tourist Call',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isChinese ? '游客正在呼叫导游...' : 'Tourist is calling guide...',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.phone, color: Colors.green),
                    onPressed: () => _answerCall(isChinese),
                  ),
                  IconButton(
                    icon: Icon(Icons.call_end, color: Colors.red),
                    onPressed: () => _rejectCall(isChinese),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // 游客行程界面
  Widget _buildTouristItinerary(bool isChinese) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '行程单' : 'Itinerary'),
        centerTitle: true,
        actions: [
          // 一键呼叫导游按钮
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _callGuide(isChinese),
            tooltip: isChinese ? '呼叫导游' : 'Call Guide',
          ),
        ],
      ),
      body: Column(
        children: [
          // 日期选择器
          _buildDateSelector(isChinese),
          // 多天行程内容
          Expanded(
            child: _buildMultiDayContent(isChinese),
          ),
        ],
      ),
    );
  }

  // 日期选择器
  Widget _buildDateSelector(bool isChinese) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                isChinese ? '选择日期' : 'Select Date',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_isGuideMode)
                Text(
                  isChinese ? '导游模式' : 'Guide Mode',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 日期选择器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = _selectedDate == index;
                final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final hasItinerary = _multiDayItinerary.containsKey(dateKey);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: hasItinerary
                          ? Border.all(color: AppColors.success, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getDayOfWeek(date, isChinese),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        if (hasItinerary)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 获取星期几
  String _getDayOfWeek(DateTime date, bool isChinese) {
    final days = isChinese 
        ? ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // 多天行程内容
  Widget _buildMultiDayContent(bool isChinese) {
    final date = DateTime.now().add(Duration(days: _selectedDate));
    final currentDateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final currentDayItinerary = _multiDayItinerary[currentDateKey] ?? [];
    
    if (currentDayItinerary.isEmpty) {
      return _buildEmptyDayContent(isChinese);
    } else {
      return _buildAxisAdventureTimeline();
    }
  }

  // 空日期内容
  Widget _buildEmptyDayContent(bool isChinese) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isChinese ? '这一天还没有行程安排' : 'No itinerary for this day',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '点击下方按钮添加景点' : 'Tap the button below to add spots',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSpotDialog(isChinese),
            icon: const Icon(Icons.add),
            label: Text(isChinese ? '添加景点' : 'Add Spots'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 显示添加景点对话框
  void _showAddSpotDialog(bool isChinese) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSpotSelectionDialog(isChinese),
    );
  }

  // 景点选择对话框
  Widget _buildSpotSelectionDialog(bool isChinese) {
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.add_location, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isChinese ? '选择景点添加到行程' : 'Select Spots for Itinerary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 景点列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allSpots.length,
              itemBuilder: (context, index) {
                final spot = _allSpots[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: PlatformImage(
                        imageUrl: spot.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
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
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: () {
                        Navigator.pop(context);
                        _addSpotToSelectedDate(spot, isChinese);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 添加景点到选定日期
  void _addSpotToSelectedDate(TouristSpot spot, bool isChinese) {
    final date = DateTime.now().add(Duration(days: _selectedDate));
    final currentDateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddSpotDialog(spot, currentDateKey, isChinese),
    );
  }

  // 显示发布对话框（导游模式）
  void _showPublishDialog(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.publish, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isChinese ? '发布行程' : 'Publish Itinerary'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isChinese 
                  ? '确定要发布这个多天行程给绑定的游客吗？'
                  : 'Are you sure you want to publish this multi-day itinerary to your bound tourists?',
            ),
            const SizedBox(height: 16),
            Text(
              isChinese 
                  ? '发布后游客将收到行程通知'
                  : 'Tourists will receive itinerary notifications after publishing',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现发布逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isChinese ? '行程发布成功！' : 'Itinerary published successfully!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isChinese ? '发布' : 'Publish'),
          ),
        ],
      ),
    );
  }



  // 显示调查问卷统计
  void _showSurveyStatistics(bool isChinese) {
    Navigator.pushNamed(context, '/admin-dashboard');
  }

  // 显示游客管理
  void _showTouristManagement(bool isChinese) {
    Navigator.pushNamed(context, '/tourist-management');
  }

  // 显示媒体审核
  void _showMediaReview(bool isChinese) {
    Navigator.pushNamed(context, '/media-review');
  }

  // 显示评价管理
  void _showReviewManagement(bool isChinese) {
    Navigator.pushNamed(context, '/review-management');
  }

  // 接听电话
  void _answerCall(bool isChinese) {
    setState(() {
      _showCallNotification = false; // 隐藏通知
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isChinese ? '已接听游客呼叫' : 'Tourist call answered',
        ),
        backgroundColor: Colors.green,
      ),
    );
    
    // TODO: 实现实际的通话逻辑
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: Colors.green),
            const SizedBox(width: 8),
            Text(isChinese ? '通话中' : 'Call in Progress'),
          ],
        ),
        content: Text(isChinese ? '正在与游客通话...' : 'Talking with tourist...'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isChinese ? '挂断' : 'End Call'),
          ),
        ],
      ),
    );
  }

  // 拒绝电话
  void _rejectCall(bool isChinese) {
    setState(() {
      _showCallNotification = false; // 隐藏通知
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isChinese ? '已拒绝游客呼叫' : 'Tourist call rejected',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 游客呼叫导游
  void _callGuide(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isChinese ? '呼叫导游' : 'Call Guide'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isChinese ? '确定要呼叫导游吗？' : 'Are you sure you want to call the guide?'),
            const SizedBox(height: 16),
            Text(
              isChinese ? '导游将收到通知并可以接听您的电话' : 'The guide will receive a notification and can answer your call',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initiateCall(isChinese);
            },
            child: Text(isChinese ? '呼叫' : 'Call'),
          ),
        ],
      ),
    );
  }

  // 发起呼叫
  void _initiateCall(bool isChinese) {
    // TODO: 实现实际的呼叫逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isChinese ? '正在呼叫导游...' : 'Calling guide...',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildItinerarySummary(bool isChinese) {
    if (_itineraryItems.isEmpty) {
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
                    isChinese ? '选择景点' : 'Select Spots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    isChinese ? '点击景点添加到行程' : 'Tap spots to add to itinerary',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final totalDuration = _itineraryItems.fold<int>(
      0, (sum, item) => sum + item.durationMinutes);
    final startTime = _itineraryItems.first.startTime;
    final endTime = _itineraryItems.last.endTime;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.blue[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.green[700],
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '行程概览' : 'Itinerary Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      '${_itineraryItems.length} ${isChinese ? '个景点' : 'spots'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${totalDuration ~/ 60}小时${totalDuration % 60}分钟',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '开始时间' : 'Start',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isChinese ? '结束时间' : 'End',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpotSelectionList(bool isChinese) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            isChinese ? '选择景点添加到行程' : 'Select spots to add to itinerary',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _allSpots.length,
            itemBuilder: (context, index) {
              final spot = _allSpots[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: InkWell(
                  onTap: () => _addSpotToItinerary(spot),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                        // 添加图标
                        Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryList(bool isChinese) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _itineraryItems.length,
      itemBuilder: (context, index) {
        final item = _itineraryItems[index];
        final isLast = index == _itineraryItems.length - 1;

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 时间信息
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.formattedStartTime,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '-',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.formattedEndTime,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.formattedDuration,
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 景点信息
                    Row(
                      children: [
                        // 序号
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 景点图片
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PlatformImage(
                            imageUrl: item.spot.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 景点详情
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChinese ? item.spot.name : item.spot.nameEn,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isChinese ? item.spot.address : item.spot.addressEn,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (item.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '📝 ${item.notes}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // 操作按钮
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editItem(index),
                              tooltip: isChinese ? '编辑' : 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _removeItem(index),
                              tooltip: isChinese ? '删除' : 'Delete',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 连接线（除了最后一个）
            if (!isLast)
              Container(
                height: 20,
                width: 2,
                color: Colors.grey[300],
                margin: const EdgeInsets.only(left: 31),
              ),
          ],
        );
      },
    );
  }

  void _showItineraryPreview() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItineraryPreview(isChinese),
    );
  }

  Widget _buildItineraryPreview(bool isChinese) {
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
                  isChinese ? '行程预览' : 'Itinerary Preview',
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
              itemCount: _itineraryItems.length,
              itemBuilder: (context, index) {
                final item = _itineraryItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 时间信息
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${item.formattedStartTime} - ${item.formattedEndTime}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.formattedDuration,
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 景点信息
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isChinese ? item.spot.name : item.spot.nameEn,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    isChinese ? item.spot.address : item.spot.addressEn,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  if (item.notes != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '📝 ${item.notes}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(item.spot.rating.toString()),
                              ],
                            ),
                          ],
                        ),
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
                      _showSaveDialog(isChinese);
                    },
                    child: Text(isChinese ? '保存行程' : 'Save Itinerary'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(bool isChinese) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isChinese ? '保存失败' : 'Save Failed'),
          content: Text(isChinese ? '请先登录后再保存行程' : 'Please login first to save itinerary'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isChinese ? '确定' : 'OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 显示保存进度
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '保存中...' : 'Saving...'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在保存到云端...'),
          ],
        ),
      ),
    );

    try {
      final userId = authProvider.currentUser!.id;
      final success = await ItineraryService.saveUserItinerary(userId, _itineraryItems);
      
      Navigator.pop(context); // 关闭进度对话框
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isChinese ? '保存结果' : 'Save Result'),
          content: Text(
            success 
              ? (isChinese ? '行程已保存到云端！' : 'Itinerary saved to cloud!')
              : (isChinese ? '保存失败，请重试' : 'Save failed, please try again')
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isChinese ? '确定' : 'OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // 关闭进度对话框
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isChinese ? '保存失败' : 'Save Failed'),
          content: Text(isChinese ? '保存过程中出现错误' : 'Error occurred while saving'),
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

  // 主线任务标签页
  Widget _buildMainTasksTab(bool isChinese) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mainTasks.length,
      itemBuilder: (context, index) {
        final task = _mainTasks[index];
        final isCompleted = _completedTasks[task['id']] ?? false;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task['icon'],
                color: isCompleted ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            title: Text(
              isChinese ? task['name_zh'] : task['name_en'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? task['description_zh'] : task['description_en'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isChinese ? '奖励：${task['reward']}' : 'Reward: ${task['reward']}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: isCompleted
                ? Icon(Icons.check_circle, color: AppColors.success)
                : IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _completeTask(task['id']),
                    tooltip: isChinese ? '开始任务' : 'Start Task',
                  ),
            onTap: () => _showTaskDetails(task, isChinese),
          ),
        );
      },
    );
  }

  // 支线任务标签页
  Widget _buildSideTasksTab(bool isChinese) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sideTasks.length,
      itemBuilder: (context, index) {
        final task = _sideTasks[index];
        final isCompleted = _completedTasks[task['id']] ?? false;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task['icon'],
                color: isCompleted ? Colors.white : AppColors.warning,
                size: 24,
              ),
            ),
            title: Text(
              isChinese ? task['name_zh'] : task['name_en'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? task['description_zh'] : task['description_en'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isChinese ? '奖励：${task['reward']}' : 'Reward: ${task['reward']}',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: isCompleted
                ? Icon(Icons.check_circle, color: AppColors.success)
                : IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _completeTask(task['id']),
                    tooltip: isChinese ? '开始任务' : 'Start Task',
                  ),
            onTap: () => _showTaskDetails(task, isChinese),
          ),
        );
      },
    );
  }

  // 显示任务详情
  void _showTaskDetails(Map<String, dynamic> task, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(task['icon'], color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isChinese ? task['name_zh'] : task['name_en'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? task['description_zh'] : task['description_en'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isChinese ? '奖励：${task['reward']}' : 'Reward: ${task['reward']}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '关闭' : 'Close'),
          ),
          if (!(_completedTasks[task['id']] ?? false))
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completeTask(task['id']);
              },
              child: Text(isChinese ? '完成任务' : 'Complete Task'),
            ),
        ],
      ),
    );
  }

  Widget _buildAxisAdventureTimeline() {
    // 根据选择的日期获取对应的行程数据
    final currentTimeline = _multiDayAxisAdventureTimeline[_selectedDate] ?? axisAdventureTimeline;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B4513),
                  Color(0xFFD2691E),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '中轴奇遇行程路线 - 第${_selectedDate + 1}天',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '探索中轴线文化瑰宝，体验文明互鉴之旅',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 时间轴内容
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: currentTimeline.length,
            itemBuilder: (context, index) {
              final item = currentTimeline[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间轴节点
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF8B4513),
                                Color(0xFFD2691E),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        if (index != currentTimeline.length - 1)
                          Container(
                            width: 3,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF8B4513),
                                  Color(0xFFD2691E).withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 内容卡片
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24.0, top: 2.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFF8F9FA),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 场景标题
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF8B4513).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Color(0xFF8B4513),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item['scene'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // 文化互鉴
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF8B4513).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF8B4513).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.public,
                                        color: Color(0xFF8B4513),
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '文化互鉴',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8B4513),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    item['culture'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2C3E50),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            // 活动内容
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFD2691E).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFD2691E).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline,
                                        color: Color(0xFFD2691E),
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '活动内容',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD2691E),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    (item['activity'] ?? '').replaceAll('\\n', '\n'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF34495E),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 退出登录
  void _logout(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(isChinese ? '退出登录' : 'Logout'),
          ],
        ),
        content: Text(isChinese ? '确定要退出登录吗？' : 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // 执行退出登录
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              // 跳转到登录页面
              Navigator.of(context).pushReplacementNamed('/');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isChinese ? '退出' : 'Logout'),
          ),
        ],
      ),
    );
  }

  // 显示行程发布对话框
  void _showItineraryPublishingDialog(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.route, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isChinese ? '行程发布' : 'Itinerary Publishing'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isChinese ? '选择操作：' : 'Select action:'),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.add, color: Colors.green),
              title: Text(isChinese ? '创建新行程' : 'Create New Itinerary'),
              subtitle: Text(isChinese ? '从头开始创建行程' : 'Create itinerary from scratch'),
              onTap: () {
                Navigator.pop(context);
                _showCreateItineraryDialog(isChinese);
              },
            ),
            ListTile(
              leading: Icon(Icons.view_list, color: Colors.blue),
              title: Text(isChinese ? '使用模板' : 'Use Template'),
              subtitle: Text(isChinese ? '基于模板创建行程' : 'Create from template'),
              onTap: () {
                Navigator.pop(context);
                _showTemplateSelectionDialog(isChinese);
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.orange),
              title: Text(isChinese ? '管理已发布行程' : 'Manage Published'),
              subtitle: Text(isChinese ? '查看和编辑已发布的行程' : 'View and edit published'),
              onTap: () {
                Navigator.pop(context);
                _showPublishedItinerariesDialog(isChinese);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  // 显示行程模板对话框
  void _showItineraryTemplatesDialog(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.view_list, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isChinese ? '行程模板管理' : 'Itinerary Templates'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._itineraryTemplates.map((template) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      template['name'].substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(template['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template['description']),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(template['duration']),
                            backgroundColor: Colors.blue[100],
                            labelStyle: TextStyle(color: Colors.blue[800], fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(template['difficulty']),
                            backgroundColor: Colors.green[100],
                            labelStyle: TextStyle(color: Colors.green[800], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pop(context);
                        _showEditTemplateDialog(template, isChinese);
                      } else if (value == 'delete') {
                        Navigator.pop(context);
                        _showDeleteTemplateDialog(template, isChinese);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            const SizedBox(width: 8),
                            Text(isChinese ? '编辑' : 'Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(isChinese ? '删除' : 'Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateTemplateDialog(isChinese);
                },
                icon: Icon(Icons.add),
                label: Text(isChinese ? '创建新模板' : 'Create New Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
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

  // 显示创建行程对话框
  void _showCreateItineraryDialog(bool isChinese) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    List<String> selectedSpots = [];
    int selectedDays = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(isChinese ? '创建新行程' : 'Create New Itinerary'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isChinese ? '行程名称' : 'Itinerary Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isChinese ? '行程描述' : 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(isChinese ? '天数：' : 'Days: '),
                    Expanded(
                      child: Slider(
                        value: selectedDays.toDouble(),
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: selectedDays.toString(),
                        onChanged: (value) {
                          setState(() {
                            selectedDays = value.round();
                          });
                        },
                      ),
                    ),
                    Text(selectedDays.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                Text(isChinese ? '选择景点：' : 'Select Spots:'),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _allSpots.length,
                    itemBuilder: (context, index) {
                      final spot = _allSpots[index];
                      final isSelected = selectedSpots.contains(spot.name);
                      return CheckboxListTile(
                        title: Text(isChinese ? spot.name : spot.nameEn),
                        subtitle: Text(isChinese ? spot.address : spot.addressEn),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedSpots.add(spot.name);
                            } else {
                              selectedSpots.remove(spot.name);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isChinese ? '取消' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedSpots.isNotEmpty) {
                  _createItinerary(
                    nameController.text,
                    descriptionController.text,
                    selectedSpots,
                    selectedDays,
                    isChinese,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(isChinese ? '创建' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  // 创建行程
  void _createItinerary(String name, String description, List<String> spots, int days, bool isChinese) {
    final newItinerary = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'description': description,
      'spots': spots,
      'days': days,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'draft',
      'published_to': [],
    };

    setState(() {
      _guideItineraries.add(newItinerary);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '行程创建成功' : 'Itinerary created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 显示已发布行程对话框
  void _showPublishedItinerariesDialog(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.list, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isChinese ? '已发布行程' : 'Published Itineraries'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_guideItineraries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isChinese ? '暂无已发布的行程' : 'No published itineraries',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ..._guideItineraries.map((itinerary) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        itinerary['name'].substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(itinerary['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itinerary['description']),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text('${itinerary['days']}天'),
                              backgroundColor: Colors.blue[100],
                              labelStyle: TextStyle(color: Colors.blue[800], fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(itinerary['status'] == 'published' ? '已发布' : '草稿'),
                              backgroundColor: itinerary['status'] == 'published' ? Colors.green[100] : Colors.orange[100],
                              labelStyle: TextStyle(
                                color: itinerary['status'] == 'published' ? Colors.green[800] : Colors.orange[800],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pop(context);
                          _showEditItineraryDialog(itinerary, isChinese);
                        } else if (value == 'publish') {
                          Navigator.pop(context);
                          _showPublishItineraryDialog(itinerary, isChinese);
                        } else if (value == 'delete') {
                          Navigator.pop(context);
                          _showDeleteItineraryDialog(itinerary, isChinese);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              const SizedBox(width: 8),
                              Text(isChinese ? '编辑' : 'Edit'),
                            ],
                          ),
                        ),
                        if (itinerary['status'] != 'published')
                          PopupMenuItem(
                            value: 'publish',
                            child: Row(
                              children: [
                                Icon(Icons.publish, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(isChinese ? '发布' : 'Publish', style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(isChinese ? '删除' : 'Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
            ],
          ),
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

  // 显示发布行程对话框
  void _showPublishItineraryDialog(Map<String, dynamic> itinerary, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.publish, color: Colors.green),
            const SizedBox(width: 8),
            Text(isChinese ? '发布行程' : 'Publish Itinerary'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isChinese ? '确定要发布以下行程吗？' : 'Are you sure you want to publish this itinerary?'),
            const SizedBox(height: 16),
            Text(
              itinerary['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(itinerary['description']),
            const SizedBox(height: 16),
            Text(isChinese ? '发布后，绑定的游客将收到通知。' : 'After publishing, bound tourists will be notified.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _publishItinerary(itinerary, isChinese);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(isChinese ? '发布' : 'Publish'),
          ),
        ],
      ),
    );
  }

  // 发布行程
  void _publishItinerary(Map<String, dynamic> itinerary, bool isChinese) {
    setState(() {
      itinerary['status'] = 'published';
      itinerary['published_at'] = DateTime.now().toIso8601String();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '行程发布成功' : 'Itinerary published successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 显示删除行程对话框
  void _showDeleteItineraryDialog(Map<String, dynamic> itinerary, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(isChinese ? '删除行程' : 'Delete Itinerary'),
          ],
        ),
        content: Text(
          isChinese 
            ? '确定要删除行程"${itinerary['name']}"吗？此操作不可撤销。'
            : 'Are you sure you want to delete itinerary "${itinerary['name']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _guideItineraries.removeWhere((item) => item['id'] == itinerary['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isChinese ? '行程已删除' : 'Itinerary deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isChinese ? '删除' : 'Delete'),
          ),
        ],
      ),
    );
  }

  // 显示模板选择对话框
  void _showTemplateSelectionDialog(bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.view_list, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isChinese ? '选择模板' : 'Select Template'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._itineraryTemplates.map((template) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      template['name'].substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(template['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template['description']),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(template['duration']),
                            backgroundColor: Colors.blue[100],
                            labelStyle: TextStyle(color: Colors.blue[800], fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(template['difficulty']),
                            backgroundColor: Colors.green[100],
                            labelStyle: TextStyle(color: Colors.green[800], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _createItineraryFromTemplate(template, isChinese);
                  },
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  // 从模板创建行程
  void _createItineraryFromTemplate(Map<String, dynamic> template, bool isChinese) {
    final newItinerary = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': '${template['name']} - ${DateTime.now().toString().substring(0, 10)}',
      'description': template['description'],
      'spots': List<String>.from(template['spots']),
      'days': template['duration'] == '1天' ? 1 : 2,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'draft',
      'published_to': [],
      'template_id': template['id'],
    };

    setState(() {
      _guideItineraries.add(newItinerary);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '从模板创建行程成功' : 'Itinerary created from template successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 显示创建模板对话框
  void _showCreateTemplateDialog(bool isChinese) {
    // 实现创建模板的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '模板创建功能开发中...' : 'Template creation feature under development...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // 显示编辑模板对话框
  void _showEditTemplateDialog(Map<String, dynamic> template, bool isChinese) {
    // 实现编辑模板的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '模板编辑功能开发中...' : 'Template editing feature under development...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // 显示删除模板对话框
  void _showDeleteTemplateDialog(Map<String, dynamic> template, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(isChinese ? '删除模板' : 'Delete Template'),
          ],
        ),
        content: Text(
          isChinese 
            ? '确定要删除模板"${template['name']}"吗？'
            : 'Are you sure you want to delete template "${template['name']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isChinese ? '模板删除功能开发中...' : 'Template deletion feature under development...'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isChinese ? '删除' : 'Delete'),
          ),
        ],
      ),
    );
  }

  // 显示编辑行程对话框
  void _showEditItineraryDialog(Map<String, dynamic> itinerary, bool isChinese) {
    // 实现编辑行程的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '行程编辑功能开发中...' : 'Itinerary editing feature under development...'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}