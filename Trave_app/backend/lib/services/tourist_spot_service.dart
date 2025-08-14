import '../models/tourist_spot.dart';

class TouristSpotService {
  // 使用真实素材的景点数据
  static final List<TouristSpot> _spots = [
    TouristSpot(
      id: '1',
      name: '永定门',
      nameEn: 'Yongdingmen',
      description: '永定门是北京中轴线的南起点，始建于明嘉靖年间，2004年按原貌复建。这座巍峨的城楼曾是明清北京外城最重要的门户，如今与永定门公园共同构成中轴线上的重要景观，向北可遥望天坛，向南则连接着南苑的广阔绿意。作为北京城市历史的见证，永定门以其庄重的姿态展现着古都的恢弘气度。',
      descriptionEn: 'Yongdingmen is the southern starting point of Beijing\'s central axis, originally built during the Ming Jiajing period and reconstructed in 2004 according to its original appearance. This majestic gate tower was once the most important portal of Beijing\'s outer city during the Ming and Qing dynasties. Today, together with Yongdingmen Park, it forms an important landscape on the central axis, with views of the Temple of Heaven to the north and the vast greenery of Nanyuan to the south. As a witness to Beijing\'s urban history, Yongdingmen displays the grandeur of the ancient capital with its solemn posture.',
      imageUrl: 'assets/images/spots/永定门.png',
      latitude: 39.8673,
      longitude: 116.3974,
      address: '北京市东城区永定门桥北',
      addressEn: 'North of Yongdingmen Bridge, Dongcheng District, Beijing',
      tags: ['历史古迹', '城门', '中轴线起点', '世界遗产'],
      tagsEn: ['Historical Site', 'City Gate', 'Central Axis Start', 'World Heritage'],
      rating: 4.5,
      reviewCount: 128,
      category: '历史古迹',
    ),
    TouristSpot(
      id: '2',
      name: '先农坛',
      nameEn: 'Xiannongtan',
      description: '先农坛是北京中轴线上的重要皇家祭祀建筑群，始建于明永乐十八年（1420年），与天坛东西对称，是明清两代皇帝祭祀先农神、举行亲耕典礼的场所，现为北京古代建筑博物馆。先农坛承载着中国古代农耕文明与祭祀文化，2001年列入全国重点文物保护单位，并作为"北京中轴线"组成部分申报世界文化遗产。',
      descriptionEn: 'Xiannongtan is an important royal sacrificial architectural complex on Beijing\'s central axis, built in 1420 during the Ming Yongle period, symmetrically positioned with the Temple of Heaven. It was where emperors of the Ming and Qing dynasties worshipped the God of Agriculture and held ploughing ceremonies. Now it serves as the Beijing Ancient Architecture Museum. Xiannongtan carries China\'s ancient agricultural civilization and sacrificial culture, listed as a national key cultural relic protection unit in 2001 and nominated as part of "Beijing Central Axis" for World Heritage status.',
      imageUrl: 'assets/images/spots/先农坛.png',
      latitude: 39.8756,
      longitude: 116.3974,
      address: '北京市西城区永定门内大街西侧、东经路21号',
      addressEn: '21 Dongjing Road, West of Yongdingmen Inner Street, Xicheng District, Beijing',
      tags: ['历史古迹', '祭祀', '中轴线', '博物馆'],
      tagsEn: ['Historical Site', 'Sacrifice', 'Central Axis', 'Museum'],
      rating: 4.3,
      reviewCount: 95,
      category: '历史古迹',
    ),
    TouristSpot(
      id: '3',
      name: '天坛',
      nameEn: 'Temple of Heaven',
      description: '天坛是北京著名的世界文化遗产，始建于明永乐十八年（1420年），是明清两代皇帝祭天、祈谷的皇家祭祀场所。其核心建筑祈年殿为三重檐圆形大殿，采用榫卯结构，无梁无钉，象征"天人合一"。圜丘坛是冬至祭天之地，以"九"为设计核心，体现"天圆地方"的宇宙观。回音壁和丹陛桥等建筑巧妙运用声学与空间设计，展现古代智慧。天坛占地273公顷，比故宫大两倍，庄严肃穆，1998年被列入《世界遗产名录》。',
      descriptionEn: 'The Temple of Heaven is a famous World Cultural Heritage site in Beijing, built in 1420 during the Ming Yongle period, serving as the royal sacrificial venue where emperors of the Ming and Qing dynasties worshipped heaven and prayed for good harvests. Its core building, the Hall of Prayer for Good Harvests, is a triple-eaved circular hall using mortise and tenon structure without beams or nails, symbolizing the unity of heaven and man. The Circular Mound Altar is where winter solstice sacrifices were held, designed around the number "nine" to reflect the cosmic view of "round heaven and square earth". Buildings like the Echo Wall and Danbi Bridge cleverly utilize acoustics and spatial design, showcasing ancient wisdom. Covering 273 hectares, twice the size of the Forbidden City, it is solemn and majestic, listed in the World Heritage List in 1998.',
      imageUrl: 'assets/images/spots/天坛.png',
      latitude: 39.8822,
      longitude: 116.3974,
      address: '北京市东城区天坛内东里7号',
      addressEn: '7 Tiantan Nei Dongli, Dongcheng District, Beijing',
      tags: ['历史古迹', '祭祀', '世界遗产', '祈年殿', '回音壁'],
      tagsEn: ['Historical Site', 'Sacrifice', 'World Heritage', 'Hall of Prayer', 'Echo Wall'],
      rating: 4.8,
      reviewCount: 256,
      category: '历史古迹',
    ),
    TouristSpot(
      id: '4',
      name: '前门',
      nameEn: 'Qianmen',
      description: '前门大街是北京著名的历史文化商业街区，位于天安门广场南侧，自元代以来就是繁华的商业中心。这里汇聚了众多中华老字号，如同仁堂、瑞蚨祥、全聚德、都一处等，展现了老北京的市井风情与商业传统。游客可以漫步青石板路，欣赏复古铛铛车，品尝京味小吃，感受传统与现代交融的独特氛围。此外，前门周边还有三里河公园的江南水乡景致、正阳门箭楼的历史遗迹，以及热闹的夜市和文创体验，是探索北京文化的重要一站。',
      descriptionEn: 'Qianmen Street is a famous historical and cultural commercial district in Beijing, located south of Tiananmen Square, serving as a prosperous commercial center since the Yuan Dynasty. It gathers numerous time-honored Chinese brands such as Tongrentang, Ruifuxiang, Quanjude, and Duyichu, showcasing old Beijing\'s folk customs and commercial traditions. Visitors can stroll on the bluestone roads, admire retro trolley cars, taste Beijing-style snacks, and experience the unique atmosphere where tradition meets modernity. Additionally, the surrounding area features the Jiangnan water town scenery of Sanlihe Park, the historical relic of Zhengyangmen Arrow Tower, as well as bustling night markets and cultural creative experiences, making it an important stop for exploring Beijing culture.',
      imageUrl: 'assets/images/spots/前门.png',
      latitude: 39.8994,
      longitude: 116.3974,
      address: '北京市东城区前门大街甲2号',
      addressEn: 'A2 Qianmen Street, Dongcheng District, Beijing',
      tags: ['历史古迹', '商业街', '老字号', '文化街区'],
      tagsEn: ['Historical Site', 'Shopping Street', 'Time-honored Brands', 'Cultural District'],
      rating: 4.2,
      reviewCount: 189,
      category: '历史古迹',
    ),
    TouristSpot(
      id: '5',
      name: '故宫',
      nameEn: 'Forbidden City',
      description: '故宫，又称紫禁城，是中国明清两代的皇家宫殿，位于北京中轴线的中心，是世界上现存规模最大、保存最完整的木质结构古建筑群之一。始建于明永乐四年（1406年），历时14年建成，占地72万平方米，拥有大小宫殿70多座，房屋9000余间。故宫以其宏伟的建筑、丰富的文物收藏和深厚的历史文化底蕴，被誉为世界五大宫之首，1987年被联合国教科文组织列为世界文化遗产。',
      descriptionEn: 'The Forbidden City, also known as the Purple Forbidden City, was the imperial palace of the Ming and Qing dynasties, located at the center of Beijing\'s central axis. It is one of the largest and most complete ancient wooden architectural complexes in the world. Construction began in 1406 during the Ming Yongle period and took 14 years to complete, covering 720,000 square meters with over 70 palaces and 9,000 rooms. With its magnificent architecture, rich cultural relics collection, and profound historical and cultural heritage, it is known as the first among the world\'s five great palaces and was listed as a World Cultural Heritage site by UNESCO in 1987.',
      imageUrl: 'assets/images/spots/故宫.png',
      latitude: 39.9163,
      longitude: 116.3974,
      address: '北京市东城区景山前街4号',
      addressEn: '4 Jingshan Front Street, Dongcheng District, Beijing',
      tags: ['历史古迹', '宫殿', '世界遗产', '紫禁城', '太和殿'],
      tagsEn: ['Historical Site', 'Palace', 'World Heritage', 'Forbidden City', 'Hall of Supreme Harmony'],
      rating: 4.9,
      reviewCount: 512,
      category: '历史古迹',
    ),
    TouristSpot(
      id: '6',
      name: '什刹海万宁桥',
      nameEn: 'Shichahai Wannian Bridge',
      description: '万宁桥（俗称后门桥）是北京中轴线上最古老的石桥之一，始建于元代至元二十二年（1285年），至今已有700多年历史。它位于什刹海前海东岸，地安门外大街，是元大都城市规划的重要基点，也是京杭大运河进入北京城的关键闸口。这座单孔汉白玉石拱桥曾是元代漕运枢纽，桥闸一体，南方来的粮船经此进入积水潭码头，使这里成为元大都最繁华的商贸中心。桥两侧现存元代镇水兽蚣蝮，雕刻精美，兼具测量水位的功能。如今，万宁桥仍承担交通功能，周边垂柳拂岸、酒吧林立，古典与现代交融，是感受北京历史与市井风情的绝佳地点。2014年，它随大运河列入世界文化遗产名录。',
      descriptionEn: 'Wannian Bridge (commonly known as Hounian Bridge) is one of the oldest stone bridges on Beijing\'s central axis, built in 1285 during the Yuan Dynasty, with over 700 years of history. Located on the east bank of Shichahai Front Lake, on Di\'anmen Outer Street, it was an important base point in the Yuan capital\'s urban planning and a key sluice gate for the Grand Canal entering Beijing. This single-arch white marble stone bridge was once a transportation hub during the Yuan Dynasty, integrating bridge and sluice, with grain ships from the south entering Jishuitan Wharf through here, making it the most prosperous commercial center of the Yuan capital. The bridge sides still preserve Yuan Dynasty water-controlling beasts (Bixi), exquisitely carved and serving the dual function of measuring water levels. Today, Wannian Bridge still serves transportation functions, with weeping willows along the banks and bars lining the area, blending classical and modern elements, making it an excellent place to experience Beijing\'s history and folk customs. In 2014, it was listed in the World Cultural Heritage List along with the Grand Canal.',
      imageUrl: 'assets/images/spots/什刹海万宁桥.png',
      latitude: 39.9333,
      longitude: 116.3974,
      address: '北京市西城区什刹海街道前海南沿与地安门外大街交汇处火神庙东南角',
      addressEn: 'Southeast corner of Huoshen Temple, intersection of Shichahai Front South Bank and Di\'anmen Outer Street, Shichahai Street, Xicheng District, Beijing',
      tags: ['历史古迹', '桥梁', '什刹海', '世界遗产', '元代'],
      tagsEn: ['Historical Site', 'Bridge', 'Shichahai', 'World Heritage', 'Yuan Dynasty'],
      rating: 4.1,
      reviewCount: 76,
      category: '历史古迹',
    ),
    TouristSpot(
      id: '7',
      name: '钟鼓楼',
      nameEn: 'Bell & Drum Towers',
      description: '北京钟鼓楼坐落于中轴线北端，是元、明、清三代的皇家报时中心，由南侧的鼓楼和北侧的钟楼组成。鼓楼红墙灰瓦，内设仿制更鼓，整点可观赏击鼓表演；钟楼灰墙绿瓦，悬挂重达63吨的"古钟之王"，钟声曾响彻全城。两楼之间广场充满市井烟火气，登楼可俯瞰中轴线与胡同风貌，是感受老北京历史与现代生活交融的绝佳地点。',
      descriptionEn: 'Beijing Bell and Drum Towers are located at the northern end of the central axis, serving as the royal time-keeping center during the Yuan, Ming, and Qing dynasties, consisting of the Drum Tower to the south and the Bell Tower to the north. The Drum Tower has red walls and gray tiles, housing replica drums with drum-beating performances on the hour; the Bell Tower has gray walls and green tiles, hanging the "King of Ancient Bells" weighing 63 tons, whose bell sounds once echoed throughout the city. The square between the two towers is full of folk atmosphere, and climbing the towers offers panoramic views of the central axis and hutong landscape, making it an excellent place to experience the blend of old Beijing history and modern life.',
      imageUrl: 'assets/images/spots/钟鼓楼.png',
      latitude: 39.9417,
      longitude: 116.3974,
      address: '北京市东城区钟楼湾临字9号',
      addressEn: '9 Zhonglouwan Linzi, Dongcheng District, Beijing',
      tags: ['历史古迹', '钟楼', '鼓楼', '报时', '胡同'],
      tagsEn: ['Historical Site', 'Bell Tower', 'Drum Tower', 'Time-keeping', 'Hutong'],
      rating: 4.4,
      reviewCount: 143,
      category: '历史古迹',
    ),
  ];

  // 获取所有景点
  Future<List<TouristSpot>> getAllSpots() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));
    return _spots;
  }

  // 根据ID获取景点
  Future<TouristSpot?> getSpotById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _spots.firstWhere((spot) => spot.id == id);
    } catch (e) {
      return null;
    }
  }

  // 根据类别获取景点
  Future<List<TouristSpot>> getSpotsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _spots.where((spot) => spot.category == category).toList();
  }

  // 搜索景点
  Future<List<TouristSpot>> searchSpots(String query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final lowercaseQuery = query.toLowerCase();
    return _spots.where((spot) =>
        spot.name.toLowerCase().contains(lowercaseQuery) ||
        spot.nameEn.toLowerCase().contains(lowercaseQuery) ||
        spot.description.toLowerCase().contains(lowercaseQuery) ||
        spot.descriptionEn.toLowerCase().contains(lowercaseQuery) ||
        spot.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // 获取热门景点
  Future<List<TouristSpot>> getPopularSpots({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final sortedSpots = List<TouristSpot>.from(_spots);
    sortedSpots.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedSpots.take(limit).toList();
  }

  // 获取收藏的景点
  Future<List<TouristSpot>> getFavoriteSpots() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _spots.where((spot) => spot.isFavorite).toList();
  }

  // 切换收藏状态
  Future<void> toggleFavorite(String spotId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _spots.indexWhere((spot) => spot.id == spotId);
    if (index != -1) {
      _spots[index] = _spots[index].copyWith(isFavorite: !_spots[index].isFavorite);
    }
  }

  // 获取景点详细信息（包含亮点推荐）
  Map<String, dynamic> getSpotDetails(String spotId) {
    final details = {
      '1': { // 永定门
        'highlights': [
          '中轴线南起点标志',
          '2004年按原貌复建',
          '永定门公园景观',
          '古都历史见证'
        ],
        'tips': [
          '建议从南向北游览中轴线',
          '可结合天坛公园一起游览',
          '春秋两季景色最佳'
        ],
        'videos': [
          'https://www.bilibili.com/video/BV1Lc4UeQEus/'
        ]
      },
      '2': { // 先农坛
        'highlights': [
          '北京古代建筑博物馆',
          '与天坛东西对称布局',
          '农耕文明祭祀文化',
          '全国重点文物保护单位'
        ],
        'tips': [
          '现为博物馆，需购票参观',
          '了解古代建筑技术',
          '感受农耕文化传统'
        ],
        'videos': [
          'https://www.zhihu.com/zvideo/1859493474065313792'
        ]
      },
      '3': { // 天坛
        'highlights': [
          '祈年殿三重檐圆形大殿',
          '回音壁神奇声学效果',
          '圜丘坛"九"字设计',
          '世界文化遗产'
        ],
        'tips': [
          '建议早晨或傍晚游览',
          '可体验古代祭天仪式',
          '注意回音壁的声学效果',
          '四季皆宜，冬季雪景尤美'
        ],
        'videos': [
          'https://www.zhihu.com/zvideo/1859493474065313792'
        ]
      },
      '4': { // 前门
        'highlights': [
          '中华老字号聚集地',
          '青石板路复古铛铛车',
          '京味小吃文化',
          '三里河公园江南景致'
        ],
        'tips': [
          '品尝全聚德烤鸭',
          '体验复古铛铛车',
          '购买老字号商品',
          '夜晚体验夜市文化'
        ],
        'videos': [
          'https://tv.cctv.com/2024/09/05/VIDEq6HQqjvl15ccDhVAKc3K240905.shtml'
        ]
      },
      '5': { // 故宫
        'highlights': [
          '太和殿皇帝大典场所',
          '乾清宫皇帝寝宫',
          '珍宝馆皇家珍宝',
          '钟表馆西洋钟表'
        ],
        'tips': [
          '提前在官网预约门票',
          '建议游览时间3-4小时',
          '从午门进入，神武门出',
          '注意携带身份证',
          '冬季雪景尤为惊艳'
        ],
        'videos': [
          'https://haokan.baidu.com/v?pd=wisenatural&vid=2525826453559110143',
          'https://haokan.baidu.com/v?pd=wisenatural&vid=10924486027455321627'
        ]
      },
      '6': { // 什刹海万宁桥
        'highlights': [
          '元代石桥700年历史',
          '京杭大运河关键闸口',
          '元代镇水兽蚣蝮',
          '古典与现代交融'
        ],
        'tips': [
          '了解元代漕运历史',
          '欣赏什刹海风光',
          '体验酒吧文化',
          '感受古今交融'
        ],
        'videos': [
          'https://v.youku.com/v_show/id_XNjQ2NzU0NTE0NA==.html'
        ]
      },
      '7': { // 钟鼓楼
        'highlights': [
          '元代报时中心',
          '63吨古钟之王',
          '整点击鼓表演',
          '俯瞰中轴线全景'
        ],
        'tips': [
          '整点观看击鼓表演',
          '登楼俯瞰胡同风貌',
          '体验老北京生活',
          '感受历史与现代'
        ],
        'videos': [
          'https://baijiahao.baidu.com/s?id=1814121377120264335'
        ]
      }
    };
    
    return details[spotId] ?? {};
  }
} 