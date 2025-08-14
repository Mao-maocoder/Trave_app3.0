import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../widgets/primary_button.dart';
import '../providers/locale_provider.dart';
import 'dart:convert';
import '../utils/api_host.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class SurveyScreen extends StatefulWidget {
  final bool asDialog;
  final VoidCallback? onSurveySubmitted;
  const SurveyScreen({Key? key, this.asDialog = false, this.onSurveySubmitted}) : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool submitted = false;

  // 问卷答案字段
  String q1City = ''; // 来自秘鲁哪个城市
  String q1OtherCity = ''; // 其他城市
  String q2VisitCount = ''; // 第几次访问中国
  List<String> q3VisitedCities = []; // 去过哪些中国城市
  String q3OtherCities = ''; // 其他城市
  String q4AxisKnowledge = ''; // 对中轴线了解程度
  String q5DynastyClothing = ''; // 对朝代服饰了解
  String q6FavoriteDynasty = ''; // 最喜欢哪个朝代服饰
  String q7PhotoImportance = ''; // 拍照重要性
  String q8PhotoSkill = ''; // 拍照水平
  String q9VideoSkill = ''; // 视频剪辑能力
  List<String> q10InteractionReasons = []; // 与当地居民互动原因
  List<String> q11ExpectedExperiences = []; // 最期待体验
  String q12ChineseFoodKnowledge = ''; // 来北京前对中餐了解程度
  List<String> q13TastePreferences = []; // 偏好口味
  String q14DietaryRestrictions = ''; // 饮食禁忌
  String q14OtherRestrictions = ''; // 其他禁忌
  String q15AccommodationPriority = ''; // 住宿最重要因素
  String q16MostWantedFood = ''; // 最想吃什么中餐
  List<String> q17SnackTypes = []; // 最想尝试的北京小吃类型
  List<String> q18DailyTea = []; // 日常在秘鲁喝什么茶
  List<String> q19DesiredDrinks = []; // 来中国后最希望喝什么饮料
  String q20Utensils = ''; // 希望用餐时使用什么餐具
  String q21GameHabits = ''; // 平时有玩游戏的习惯吗
  String q22BlackMythAwareness = ''; // 听说过或玩过黑神话悟空吗
  List<String> q23Souvenirs = []; // 最想带走的中轴线文化伴手礼
  List<String> q24SharingPlatforms = []; // 旅行中用什么形式进行分享
  String q25ChineseLanguage = ''; // 语言能力
  String q26PoetryInterest = ''; // 是否愿意尝试了解中国的诗歌艺术
  String q27CulturalPerformances = ''; // 是否喜欢看当地的文化表演
  String q28SmartphoneSkills = ''; // 是否熟练使用智能手机
  String q29SpecialNeeds = ''; // 是否有特殊健康状况或需求
  String q29SpecialNeedsDetails = ''; // 特殊需求详情
  List<String> q30ShoppingPreferences = []; // 购物偏好

  // 角色定义
  final List<Map<String, String>> roles = [
    {
      'key': 'taste_walker',
      'name_zh': '味觉行者',
      'name_es': 'Viajero del Sabor',
      'desc_zh': '热爱美食、喜欢探索各地风味的你，是最懂生活的旅行家。',
      'desc_es': 'Amante de la gastronomía y explorador de sabores locales, eres el viajero que mejor entiende la vida.',
      'img': 'assets/images/profile/character1.jpg',
    },
    {
      'key': 'time_traveler',
      'name_zh': '时空旅者',
      'name_es': 'Viajero del Tiempo',
      'desc_zh': '对历史文化充满兴趣，喜欢穿越古今的你，是时空的见证者。',
      'desc_es': 'Apasionado por la historia y la cultura, eres el testigo del tiempo.',
      'img': 'assets/images/profile/character2.png',
    },
    {
      'key': 'hutong_poet',
      'name_zh': '胡同诗人',
      'name_es': 'Poeta de Hutong',
      'desc_zh': '喜欢与人交流、热爱文化艺术的你，是最具文艺气息的旅人。',
      'desc_es': 'Amante de la comunicación y el arte, eres el viajero más artístico.',
      'img': 'assets/images/profile/character3.png',
    },
    {
      'key': 'fashion_maker',
      'name_zh': '时空装造师',
      'name_es': 'Diseñador del Tiempo',
      'desc_zh': '喜欢汉服、装扮、拍照的你，是最会玩造型的达人。',
      'desc_es': 'Te encanta el Hanfu, el disfraz y la fotografía, eres el mejor en el estilo.',
      'img': 'assets/images/profile/character4.png',
    },
  ];

  // 分配身份
  String assignRole() {
    if (q13TastePreferences.isNotEmpty || q16MostWantedFood.isNotEmpty) {
      return 'taste_walker';
    } else if (q4AxisKnowledge == 'deep' || q5DynastyClothing == 'very') {
      return 'time_traveler';
    } else if (q24SharingPlatforms.isNotEmpty || q26PoetryInterest == 'very_willing') {
      return 'hutong_poet';
    } else if (q6FavoriteDynasty != '' || q8PhotoSkill == 'excellent') {
      return 'fashion_maker';
    }
    return 'taste_walker'; // 默认
  }

  // 问题1选项：秘鲁城市
  final List<Map<String, dynamic>> q1CityOptions = [
    {'key': 'lima', 'text_zh': '利马', 'text_es': 'Lima'},
    {'key': 'cusco', 'text_zh': '库斯科', 'text_es': 'Cusco'},
    {'key': 'arequipa', 'text_zh': '阿雷基帕', 'text_es': 'Arequipa'},
    {'key': 'trujillo', 'text_zh': '特鲁希略', 'text_es': 'Trujillo'},
    {'key': 'other', 'text_zh': '其他', 'text_es': 'Otro'},
  ];

  // 问题2选项：访问次数
  final List<Map<String, dynamic>> q2VisitCountOptions = [
    {'key': 'first', 'text_zh': '首次', 'text_es': 'Primera vez'},
    {'key': '2-3', 'text_zh': '2-3次', 'text_es': '2-3 veces'},
    {'key': '4+', 'text_zh': '4次以上', 'text_es': 'Más de 4 veces'},
  ];

  // 问题3选项：中国城市（多选）
  final List<Map<String, dynamic>> q3CityOptions = [
    {'key': 'shanghai', 'text_zh': '上海', 'text_es': 'Shanghái'},
    {'key': 'nanjing', 'text_zh': '南京', 'text_es': 'Nankín'},
    {'key': 'suzhou', 'text_zh': '苏州', 'text_es': 'Suzhou'},
    {'key': 'hangzhou', 'text_zh': '杭州', 'text_es': 'Hangzhou'},
    {'key': 'shenzhen', 'text_zh': '深圳', 'text_es': 'Shenzhen'},
    {'key': 'guangzhou', 'text_zh': '广州', 'text_es': 'Cantón'},
    {'key': 'hongkong', 'text_zh': '香港', 'text_es': 'Hong Kong'},
    {'key': 'taiwan', 'text_zh': '台湾', 'text_es': 'Taiwán'},
    {'key': 'beijing', 'text_zh': '北京', 'text_es': 'Pekín'},
    {'key': 'other', 'text_zh': '其它', 'text_es': 'Otro'},
  ];

  // 问题4选项：中轴线了解程度
  final List<Map<String, dynamic>> q4KnowledgeOptions = [
    {'key': 'none', 'text_zh': '完全不了解', 'text_es': 'No conozco nada'},
    {'key': 'heard', 'text_zh': '略有耳闻', 'text_es': 'He oído hablar'},
    {'key': 'researched', 'text_zh': '做过攻略', 'text_es': 'He investigado'},
    {'key': 'deep', 'text_zh': '深度研究', 'text_es': 'He investigado a fondo'},
  ];

  // 问题5选项：朝代服饰了解
  final List<Map<String, dynamic>> q5ClothingOptions = [
    {'key': 'very', 'text_zh': '很了解', 'text_es': 'Muy familiarizado'},
    {'key': 'general', 'text_zh': '一般了解', 'text_es': 'Algo familiarizado'},
    {'key': 'little', 'text_zh': '一点了解', 'text_es': 'Un poco familiarizado'},
    {'key': 'none', 'text_zh': '完全不了解', 'text_es': 'Nada familiarizado'},
  ];

  // 问题6选项：最喜欢朝代
  final List<Map<String, dynamic>> q6DynastyOptions = [
    {'key': 'tang', 'text_zh': '唐代', 'text_es': 'Dinastía Tang'},
    {'key': 'yuan', 'text_zh': '元代', 'text_es': 'Dinastía Yuan'},
    {'key': 'ming', 'text_zh': '明代', 'text_es': 'Dinastía Ming'},
    {'key': 'qing', 'text_zh': '清代', 'text_es': 'Dinastía Qing'},
    {'key': 'not_interested', 'text_zh': '不感兴趣', 'text_es': 'No me interesa'},
  ];

  // 问题7选项：拍照重要性
  final List<Map<String, dynamic>> q7PhotoOptions = [
    {'key': 'very_important', 'text_zh': '非常重要', 'text_es': 'Muy importante'},
    {'key': 'important', 'text_zh': '比较重要', 'text_es': 'Bastante importante'},
    {'key': 'optional', 'text_zh': '可有可无', 'text_es': 'No es necesario'},
    {'key': 'not_like', 'text_zh': '我不喜欢拍照', 'text_es': 'No me gusta tomar fotos'},
  ];

  // 问题8选项：拍照水平
  final List<Map<String, dynamic>> q8SkillOptions = [
    {'key': 'excellent', 'text_zh': '非常好', 'text_es': 'Excelente'},
    {'key': 'good', 'text_zh': '比较擅长', 'text_es': 'Bueno'},
    {'key': 'basic', 'text_zh': '会一点', 'text_es': 'Básico'},
    {'key': 'poor', 'text_zh': '不擅长', 'text_es': 'No soy bueno'},
  ];

  // 问题9选项：视频剪辑能力
  final List<Map<String, dynamic>> q9VideoOptions = [
    {'key': 'yes', 'text_zh': '会', 'text_es': 'Sí'},
    {'key': 'no', 'text_zh': '不会', 'text_es': 'No'},
    {'key': 'a_little', 'text_zh': '会一点', 'text_es': 'Un poco'},
  ];

  // 问题10选项：互动原因（多选）
  final List<Map<String, dynamic>> q10InteractionOptions = [
    {'key': 'culture', 'text_zh': '了解当地文化和生活方式', 'text_es': 'Conocer la cultura y el estilo de vida local'},
    {'key': 'friends', 'text_zh': '结交新朋友', 'text_es': 'Hacer nuevos amigos'},
    {'key': 'experience', 'text_zh': '体验真实的当地生活', 'text_es': 'Experimentar la vida local auténtica'},
    {'key': 'fun', 'text_zh': '增加旅行乐趣', 'text_es': 'Aumentar la diversión del viaje'},
  ];

  // 问题11选项：最期待体验（多选）
  final List<Map<String, dynamic>> q11ExperienceOptions = [
    {'key': 'bell_drum', 'text_zh': '看晨钟暮鼓仪式，在钟鼓楼亲自敲响', 'text_es': 'Ver la ceremonia de campana y tambor, tocar personalmente en la Torre del Tambor'},
    {'key': 'hanfu_photo', 'text_zh': '穿着汉服拍摄中国风大片', 'text_es': 'Tomar fotos con Hanfu'},
    {'key': 'street_explore', 'text_zh': '走街串巷感受当时民风民情', 'text_es': 'Explorar callejones y sentir la vida local'},
    {'key': 'food_feast', 'text_zh': '品尝中国美食饕餮盛宴', 'text_es': 'Disfrutar de un festín de comida china'},
    {'key': 'boat_ride', 'text_zh': '荡舟在什刹海', 'text_es': 'Pasear en barco por Shichahai'},
  ];

  // 问题12选项：中餐了解程度
  final List<Map<String, dynamic>> q12FoodKnowledgeOptions = [
    {'key': 'never', 'text_zh': '完全没吃过', 'text_es': 'Nunca he comido comida china'},
    {'key': 'eaten_but_unknown', 'text_zh': '吃过但不了解', 'text_es': 'He comido pero no conozco mucho'},
    {'key': 'familiar_classic', 'text_zh': '熟悉经典菜品（如面条、饺子、烤鸭、火锅）', 'text_es': 'Familiarizado con platos clásicos (fideos, jiaozi, pato laqueado, hotpot)'},
    {'key': 'eight_cuisines', 'text_zh': '中国有八大菜系都吃过', 'text_es': 'He probado las ocho cocinas principales de China'},
  ];

  // 问题13选项：偏好口味（多选）
  final List<Map<String, dynamic>> q13TasteOptions = [
    {'key': 'sour', 'text_zh': '酸', 'text_es': 'Ácido'},
    {'key': 'sweet', 'text_zh': '甜', 'text_es': 'Dulce'},
    {'key': 'bitter', 'text_zh': '苦', 'text_es': 'Amargo'},
    {'key': 'spicy', 'text_zh': '辣', 'text_es': 'Picante'},
    {'key': 'salty', 'text_zh': '咸', 'text_es': 'Salado'},
    {'key': 'umami', 'text_zh': '鲜', 'text_es': 'Umami'},
    {'key': 'oily', 'text_zh': '油腻', 'text_es': 'Aceitoso'},
    {'key': 'light', 'text_zh': '清淡', 'text_es': 'Ligero'},
  ];

  // 问题14选项：饮食禁忌
  final List<Map<String, dynamic>> q14RestrictionOptions = [
    {'key': 'none', 'text_zh': '无', 'text_es': 'Ninguna'},
    {'key': 'vegetarian', 'text_zh': '素食', 'text_es': 'Vegetariano'},
    {'key': 'seafood_allergy', 'text_zh': '海鲜过敏', 'text_es': 'Alergia a mariscos'},
    {'key': 'nut_allergy', 'text_zh': '坚果过敏', 'text_es': 'Alergia a nueces'},
    {'key': 'pork_restriction', 'text_zh': '猪肉禁忌', 'text_es': 'Restricción de cerdo'},
    {'key': 'other', 'text_zh': '其他', 'text_es': 'Otro'},
  ];

  // 问题15选项：住宿最重要因素
  final List<Map<String, dynamic>> q15AccommodationOptions = [
    {'key': 'location', 'text_zh': '地理位置', 'text_es': 'Ubicación'},
    {'key': 'hotel_age', 'text_zh': '酒店的新旧程度', 'text_es': 'Antigüedad del hotel'},
    {'key': 'breakfast', 'text_zh': '早餐丰富度', 'text_es': 'Desayuno abundante'},
    {'key': 'hotel_features', 'text_zh': '酒店特色', 'text_es': 'Características del hotel'},
    {'key': 'brand_awareness', 'text_zh': '酒店品牌知名度', 'text_es': 'Reconocimiento de marca'},
    {'key': 'room_size', 'text_zh': '房间大小', 'text_es': 'Tamaño de la habitación'},
  ];

  // 问题16选项：最想吃什么中餐
  final List<Map<String, dynamic>> q16FoodOptions = [
    {'key': 'roast_duck', 'text_zh': '烤鸭', 'text_es': 'Pato laqueado'},
    {'key': 'lobster', 'text_zh': '龙虾', 'text_es': 'Langosta'},
    {'key': 'douzhi', 'text_zh': '豆汁', 'text_es': 'Dòuzhī (bebida de judía fermentada)'},
    {'key': 'jiaoqian', 'text_zh': '焦圈', 'text_es': 'Jiaoquan'},
    {'key': 'youtiao', 'text_zh': '油条', 'text_es': 'Youtiao'},
    {'key': 'doujiang', 'text_zh': '豆浆', 'text_es': 'Leche de soja'},
    {'key': 'grilled_meat', 'text_zh': '炙子烤肉', 'text_es': 'Carne asada estilo Beijing'},
    {'key': 'dumpling', 'text_zh': '饺子', 'text_es': 'Jiaozi'},
  ];

  // 问题17选项：小吃类型（多选）
  final List<Map<String, dynamic>> q17SnackOptions = [
    {'key': 'salty', 'text_zh': '咸味（如卤煮、炒肝）', 'text_es': 'Salado (como Lǔzhǔ, hígado salteado)'},
    {'key': 'sweet', 'text_zh': '甜味（如驴打滚、豌豆黄）', 'text_es': 'Dulce (como "burro rodante", guisante amarillo)'},
    {'key': 'sour', 'text_zh': '酸味（如豆汁儿）', 'text_es': 'Ácido (como dòuzhī)'},
    {'key': 'spicy', 'text_zh': '辣味（如火锅）', 'text_es': 'Picante (como hotpot)'},
    {'key': 'crispy', 'text_zh': '酥脆类（如焦圈）', 'text_es': 'Crujiente (como jiāoquān)'},
    {'key': 'soup', 'text_zh': '汤类（如面茶）', 'text_es': 'Sopa (como miànchá)'},
  ];

  // 问题18选项：日常茶饮（多选）
  final List<Map<String, dynamic>> q18TeaOptions = [
    {'key': 'coca_tea', 'text_zh': '古柯茶（Coca Tea）', 'text_es': 'Té de coca'},
    {'key': 'muna_tea', 'text_zh': '穆纳茶（Muña Tea）', 'text_es': 'Té de muña'},
    {'key': 'manzanilla_tea', 'text_zh': '洋甘菊茶（Manzanilla Tea）', 'text_es': 'Té de manzanilla'},
    {'key': 'anis_tea', 'text_zh': '茴香茶（Anis Tea）', 'text_es': 'Té de anís'},
  ];

  // 问题19选项：希望喝的饮料（多选）
  final List<Map<String, dynamic>> q19DrinkOptions = [
    {'key': 'coffee', 'text_zh': '咖啡', 'text_es': 'Café'},
    {'key': 'black_tea', 'text_zh': '红茶', 'text_es': 'Té negro'},
    {'key': 'jasmine_tea', 'text_zh': '茉莉花茶', 'text_es': 'Té de jazmín'},
    {'key': 'green_tea', 'text_zh': '绿茶', 'text_es': 'Té verde'},
    {'key': 'pu_er_tea', 'text_zh': '普洱茶', 'text_es': 'Té Pu-erh'},
    {'key': 'milk_tea', 'text_zh': '奶茶', 'text_es': 'Té con leche'},
    {'key': 'mineral_water', 'text_zh': '矿泉水', 'text_es': 'Agua mineral'},
    {'key': 'sparkling_water', 'text_zh': '气泡水', 'text_es': 'Agua con gas'},
    {'key': 'cola', 'text_zh': '可乐', 'text_es': 'Cola'},
  ];

  // 问题20选项：餐具使用
  final List<Map<String, dynamic>> q20UtensilOptions = [
    {'key': 'western', 'text_zh': '西式餐具刀叉', 'text_es': 'Cubiertos occidentales'},
    {'key': 'chinese', 'text_zh': '中式餐具筷子', 'text_es': 'Palillos chinos'},
    {'key': 'both', 'text_zh': '西式中式餐具都需要', 'text_es': 'Ambos, cubiertos y palillos'},
  ];

  // 问题21选项：游戏习惯
  final List<Map<String, dynamic>> q21GameOptions = [
    {'key': 'often', 'text_zh': '经常玩', 'text_es': 'Juego a menudo'},
    {'key': 'sometimes', 'text_zh': '偶尔玩', 'text_es': 'A veces juego'},
    {'key': 'never', 'text_zh': '从来不玩', 'text_es': 'Nunca juego'},
  ];

  // 问题22选项：黑神话悟空了解
  final List<Map<String, dynamic>> q22BlackMythOptions = [
    {'key': 'know', 'text_zh': '知道', 'text_es': 'Lo conozco'},
    {'key': 'dont_know', 'text_zh': '不知道', 'text_es': 'No lo conozco'},
    {'key': 'played', 'text_zh': '玩过', 'text_es': 'He jugado'},
    {'key': 'not_played', 'text_zh': '没玩过', 'text_es': 'No he jugado'},
  ];

  // 问题23选项：伴手礼（多选）
  final List<Map<String, dynamic>> q23SouvenirOptions = [
    {'key': 'building_blocks', 'text_zh': '中轴线建筑积木', 'text_es': 'Bloques de edificios del eje central'},
    {'key': 'opera_masks', 'text_zh': '京剧脸谱彩绘', 'text_es': 'Máscaras de ópera de Pekín'},
    {'key': 'creative_products', 'text_zh': '文创产品如冰箱贴', 'text_es': 'Productos creativos (como imanes)'},
    {'key': 'chinese_clothing', 'text_zh': '中国服饰', 'text_es': 'Ropa tradicional china'},
    {'key': 'cloisonne', 'text_zh': '景泰蓝', 'text_es': 'Cloisonné'},
  ];

  // 问题24选项：分享平台（多选）
  final List<Map<String, dynamic>> q24PlatformOptions = [
    {'key': 'tiktok', 'text_zh': 'TikTok', 'text_es': 'TikTok'},
    {'key': 'facebook', 'text_zh': 'Facebook', 'text_es': 'Facebook'},
    {'key': 'youtube', 'text_zh': 'YouTube', 'text_es': 'YouTube'},
    {'key': 'whatsapp', 'text_zh': 'WhatsApp', 'text_es': 'WhatsApp'},
    {'key': 'instagram', 'text_zh': 'Instagram', 'text_es': 'Instagram'},
    {'key': 'x', 'text_zh': 'X', 'text_es': 'X'},
  ];

  // 问题25选项：中文语言能力
  final List<Map<String, dynamic>> q25LanguageOptions = [
    {'key': 'fluent', 'text_zh': '非常流利', 'text_es': 'Muy fluido'},
    {'key': 'basic_communication', 'text_zh': '基本交流', 'text_es': 'Comunicación básica'},
    {'key': 'simple_words', 'text_zh': '只会简单词汇', 'text_es': 'Solo palabras simples'},
    {'key': 'none', 'text_zh': '完全不会', 'text_es': 'No sé nada'},
  ];

  // 问题26选项：诗歌艺术兴趣
  final List<Map<String, dynamic>> q26PoetryOptions = [
    {'key': 'very_willing', 'text_zh': '非常愿意学习', 'text_es': 'Muy dispuesto a aprender'},
    {'key': 'acceptable', 'text_zh': '可以接受', 'text_es': 'Aceptable'},
    {'key': 'unwilling', 'text_zh': '不愿意', 'text_es': 'No quiero'},
  ];

  // 问题27选项：文化表演喜好
  final List<Map<String, dynamic>> q27PerformanceOptions = [
    {'key': 'very_like', 'text_zh': '非常喜欢', 'text_es': 'Me gusta mucho'},
    {'key': 'like', 'text_zh': '比较喜欢', 'text_es': 'Me gusta'},
    {'key': 'optional', 'text_zh': '可有可无', 'text_es': 'Me es indiferente'},
    {'key': 'dont_like', 'text_zh': '不喜欢', 'text_es': 'No me gusta'},
  ];

  // 问题28选项：智能手机使用能力
  final List<Map<String, dynamic>> q28SmartphoneOptions = [
    {'key': 'very_skilled', 'text_zh': '非常熟练', 'text_es': 'Muy hábil'},
    {'key': 'skilled', 'text_zh': '比较熟练', 'text_es': 'Bastante hábil'},
    {'key': 'average', 'text_zh': '一般', 'text_es': 'Promedio'},
    {'key': 'not_skilled', 'text_zh': '不太熟练', 'text_es': 'No muy hábil'},
    {'key': 'cant_use', 'text_zh': '完全不会', 'text_es': 'No sé usar'},
  ];

  // 问题29选项：特殊需求
  final List<Map<String, dynamic>> q29SpecialNeedsOptions = [
    {'key': 'yes', 'text_zh': '有，请说明', 'text_es': 'Sí, por favor especifique'},
    {'key': 'no', 'text_zh': '无', 'text_es': 'No'},
  ];

  // 问题30选项：购物偏好（多选）
  final List<Map<String, dynamic>> q30ShoppingOptions = [
    {'key': 'traditional_crafts', 'text_zh': '传统手工艺品', 'text_es': 'Artesanía tradicional'},
    {'key': 'specialty_food', 'text_zh': '特色食品', 'text_es': 'Comida típica'},
    {'key': 'souvenirs_creative', 'text_zh': '纪念品与文创产品', 'text_es': 'Souvenirs y productos creativos'},
    {'key': 'modern_fashion', 'text_zh': '现代时尚商品', 'text_es': 'Moda moderna'},
  ];

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
    _animationController.forward();
    
    // 检查用户是否真的完成过问卷
    _checkSurveyStatus();
  }

  // 检查问卷状态
  Future<void> _checkSurveyStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      // 如果用户已经完成问卷，直接显示结果
      if (authProvider.currentUser!.hasCompletedSurvey) {
        await _loadSurvey();
      }
      // 如果用户未完成问卷，不加载本地数据，显示空白问卷
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      q1City = prefs.getString('survey_q1_city') ?? '';
      q1OtherCity = prefs.getString('survey_q1_other_city') ?? '';
      q2VisitCount = prefs.getString('survey_q2_visit_count') ?? '';
      q3VisitedCities = prefs.getStringList('survey_q3_visited_cities') ?? [];
      q3OtherCities = prefs.getString('survey_q3_other_cities') ?? '';
      q4AxisKnowledge = prefs.getString('survey_q4_axis_knowledge') ?? '';
      q5DynastyClothing = prefs.getString('survey_q5_dynasty_clothing') ?? '';
      q6FavoriteDynasty = prefs.getString('survey_q6_favorite_dynasty') ?? '';
      q7PhotoImportance = prefs.getString('survey_q7_photo_importance') ?? '';
      q8PhotoSkill = prefs.getString('survey_q8_photo_skill') ?? '';
      q9VideoSkill = prefs.getString('survey_q9_video_skill') ?? '';
      q10InteractionReasons = prefs.getStringList('survey_q10_interaction_reasons') ?? [];
      q11ExpectedExperiences = prefs.getStringList('survey_q11_expected_experiences') ?? [];
      q12ChineseFoodKnowledge = prefs.getString('survey_q12_chinese_food_knowledge') ?? '';
      q13TastePreferences = prefs.getStringList('survey_q13_taste_preferences') ?? [];
      q14DietaryRestrictions = prefs.getString('survey_q14_dietary_restrictions') ?? '';
      q14OtherRestrictions = prefs.getString('survey_q14_other_restrictions') ?? '';
      q15AccommodationPriority = prefs.getString('survey_q15_accommodation_priority') ?? '';
      q16MostWantedFood = prefs.getString('survey_q16_most_wanted_food') ?? '';
      q17SnackTypes = prefs.getStringList('survey_q17_snack_types') ?? [];
      q18DailyTea = prefs.getStringList('survey_q18_daily_tea') ?? [];
      q19DesiredDrinks = prefs.getStringList('survey_q19_desired_drinks') ?? [];
      q20Utensils = prefs.getString('survey_q20_utensils') ?? '';
      q21GameHabits = prefs.getString('survey_q21_game_habits') ?? '';
      q22BlackMythAwareness = prefs.getString('survey_q22_black_myth_awareness') ?? '';
      q23Souvenirs = prefs.getStringList('survey_q23_souvenirs') ?? [];
      q24SharingPlatforms = prefs.getStringList('survey_q24_sharing_platforms') ?? [];
      q25ChineseLanguage = prefs.getString('survey_q25_chinese_language') ?? '';
      q26PoetryInterest = prefs.getString('survey_q26_poetry_interest') ?? '';
      q27CulturalPerformances = prefs.getString('survey_q27_cultural_performances') ?? '';
      q28SmartphoneSkills = prefs.getString('survey_q28_smartphone_skills') ?? '';
      q29SpecialNeeds = prefs.getString('survey_q29_special_needs') ?? '';
      q29SpecialNeedsDetails = prefs.getString('survey_q29_special_needs_details') ?? '';
      q30ShoppingPreferences = prefs.getStringList('survey_q30_shopping_preferences') ?? [];
      submitted = prefs.getBool('survey_submitted') ?? false;
    });
  }

  Future<void> _saveSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('survey_q1_city', q1City);
    await prefs.setString('survey_q1_other_city', q1OtherCity);
    await prefs.setString('survey_q2_visit_count', q2VisitCount);
    await prefs.setStringList('survey_q3_visited_cities', q3VisitedCities);
    await prefs.setString('survey_q3_other_cities', q3OtherCities);
    await prefs.setString('survey_q4_axis_knowledge', q4AxisKnowledge);
    await prefs.setString('survey_q5_dynasty_clothing', q5DynastyClothing);
    await prefs.setString('survey_q6_favorite_dynasty', q6FavoriteDynasty);
    await prefs.setString('survey_q7_photo_importance', q7PhotoImportance);
    await prefs.setString('survey_q8_photo_skill', q8PhotoSkill);
    await prefs.setString('survey_q9_video_skill', q9VideoSkill);
    await prefs.setStringList('survey_q10_interaction_reasons', q10InteractionReasons);
    await prefs.setStringList('survey_q11_expected_experiences', q11ExpectedExperiences);
    await prefs.setString('survey_q12_chinese_food_knowledge', q12ChineseFoodKnowledge);
    await prefs.setStringList('survey_q13_taste_preferences', q13TastePreferences);
    await prefs.setString('survey_q14_dietary_restrictions', q14DietaryRestrictions);
    await prefs.setString('survey_q14_other_restrictions', q14OtherRestrictions);
    await prefs.setString('survey_q15_accommodation_priority', q15AccommodationPriority);
    await prefs.setString('survey_q16_most_wanted_food', q16MostWantedFood);
    await prefs.setStringList('survey_q17_snack_types', q17SnackTypes);
    await prefs.setStringList('survey_q18_daily_tea', q18DailyTea);
    await prefs.setStringList('survey_q19_desired_drinks', q19DesiredDrinks);
    await prefs.setString('survey_q20_utensils', q20Utensils);
    await prefs.setString('survey_q21_game_habits', q21GameHabits);
    await prefs.setString('survey_q22_black_myth_awareness', q22BlackMythAwareness);
    await prefs.setStringList('survey_q23_souvenirs', q23Souvenirs);
    await prefs.setStringList('survey_q24_sharing_platforms', q24SharingPlatforms);
    await prefs.setString('survey_q25_chinese_language', q25ChineseLanguage);
    await prefs.setString('survey_q26_poetry_interest', q26PoetryInterest);
    await prefs.setString('survey_q27_cultural_performances', q27CulturalPerformances);
    await prefs.setString('survey_q28_smartphone_skills', q28SmartphoneSkills);
    await prefs.setString('survey_q29_special_needs', q29SpecialNeeds);
    await prefs.setString('survey_q29_special_needs_details', q29SpecialNeedsDetails);
    await prefs.setStringList('survey_q30_shopping_preferences', q30ShoppingPreferences);
    await prefs.setBool('survey_submitted', true);

    setState(() {
      submitted = true;
    });
    
    // 更新用户的问卷完成状态
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        // 更新本地用户状态
        final updatedUser = authProvider.currentUser!.copyWith(hasCompletedSurvey: true);
        authProvider.updateUser(updatedUser);
      }
    } catch (e) {
      print('更新用户状态失败: $e');
    }
    
    // 显示形象生成页面
    if (mounted) {
      _showProfileGenerationDialog();
    }

    // 提交到服务器
    final surveyData = {
      "userId": Provider.of<AuthProvider>(context, listen: false).currentUser?.id,
      "q1_city": q1City,
      "q1_other_city": q1OtherCity,
      "q2_visit_count": q2VisitCount,
      "q3_visited_cities": q3VisitedCities,
      "q3_other_cities": q3OtherCities,
      "q4_axis_knowledge": q4AxisKnowledge,
      "q5_dynasty_clothing": q5DynastyClothing,
      "q6_favorite_dynasty": q6FavoriteDynasty,
      "q7_photo_importance": q7PhotoImportance,
      "q8_photo_skill": q8PhotoSkill,
      "q9_video_skill": q9VideoSkill,
      "q10_interaction_reasons": q10InteractionReasons,
      "q11_expected_experiences": q11ExpectedExperiences,
      "q12_chinese_food_knowledge": q12ChineseFoodKnowledge,
      "q13_taste_preferences": q13TastePreferences,
      "q14_dietary_restrictions": q14DietaryRestrictions,
      "q14_other_restrictions": q14OtherRestrictions,
      "q15_accommodation_priority": q15AccommodationPriority,
      "q16_most_wanted_food": q16MostWantedFood,
      "q17_snack_types": q17SnackTypes,
      "q18_daily_tea": q18DailyTea,
      "q19_desired_drinks": q19DesiredDrinks,
      "q20_utensils": q20Utensils,
      "q21_game_habits": q21GameHabits,
      "q22_black_myth_awareness": q22BlackMythAwareness,
      "q23_souvenirs": q23Souvenirs,
      "q24_sharing_platforms": q24SharingPlatforms,
      "q25_chinese_language": q25ChineseLanguage,
      "q26_poetry_interest": q26PoetryInterest,
      "q27_cultural_performances": q27CulturalPerformances,
      "q28_smartphone_skills": q28SmartphoneSkills,
      "q29_special_needs": q29SpecialNeeds,
      "q29_special_needs_details": q29SpecialNeedsDetails,
      "q30_shopping_preferences": q30ShoppingPreferences,
    };

    try {
      await AuthService.authorizedRequest(
        Uri.parse(getApiBaseUrl(path: '/api/survey/submit')),
        method: 'POST',
        body: json.encode(surveyData),
      );
    } catch (e) {
      // 处理网络异常
    }
  }

  // 显示形象生成对话框
  void _showProfileGenerationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: kPrimaryColor),
            SizedBox(width: 8),
            Text('生成专属形象'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('正在根据您的问卷答案生成专属探秘身份...'),
            const SizedBox(height: 16),
            _buildProfilePreview(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );

    // 3秒后自动关闭并跳转
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  // 构建形象预览
  Widget _buildProfilePreview() {
    // 根据问卷答案生成形象
    String profileType = _generateProfileType();
    String profileName = _generateProfileName();
    String profileDescription = _generateProfileDescription();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: kPrimaryColor,
            child: Icon(
              _getProfileIcon(profileType),
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profileName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profileDescription,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 根据问卷答案生成形象类型
  String _generateProfileType() {
    if (q4AxisKnowledge == 'expert') return 'scholar';
    if (q7PhotoImportance == 'very_important') return 'photographer';
    if (q6FavoriteDynasty == 'ming') return 'historian';
    if (q12ChineseFoodKnowledge == 'expert') return 'foodie';
    return 'explorer';
  }

  // 生成形象名称
  String _generateProfileName() {
    switch (_generateProfileType()) {
      case 'scholar':
        return '中轴学者';
      case 'photographer':
        return '光影记录者';
      case 'historian':
        return '历史探索者';
      case 'foodie':
        return '美食鉴赏家';
      default:
        return '文化探秘者';
    }
  }

  // 生成形象描述
  String _generateProfileDescription() {
    switch (_generateProfileType()) {
      case 'scholar':
        return '您对中轴线文化有深入研究，将带领大家探索建筑背后的历史奥秘';
      case 'photographer':
        return '您善于捕捉美的瞬间，将用镜头记录中轴线的每一个精彩时刻';
      case 'historian':
        return '您对历史充满热情，将为大家讲述中轴线上的历史故事';
      case 'foodie':
        return '您对美食有独特见解，将带领大家品味中轴线周边的特色美食';
      default:
        return '您充满好奇心，将和大家一起探索中轴线的文化魅力';
    }
  }

  // 获取形象图标
  IconData _getProfileIcon(String profileType) {
    switch (profileType) {
      case 'scholar':
        return Icons.school;
      case 'photographer':
        return Icons.camera_alt;
      case 'historian':
        return Icons.history_edu;
      case 'foodie':
        return Icons.restaurant;
      default:
        return Icons.explore;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isChinese = localeProvider.locale == AppLocale.zh;
        return widget.asDialog
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        kBackgroundColor,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: submitted ? _buildResult(isChinese) : _buildForm(isChinese),
                ),
              )
            : Scaffold(
                backgroundColor: kBackgroundColor,
                appBar: AppBar(
                  title: const Text(
                    '北京中轴线秘鲁游客深度体验调查问卷',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: kTextPrimary, fontFamily: kFontFamilyTitle),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: kTextPrimary,
                  actions: [
                    if (submitted)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(kRadiusButton),
                            ),
                            child: const Icon(Icons.refresh, size: 20),
                          ),
                          tooltip: '重新填写',
                          onPressed: _resetSurvey,
                        ),
                      ),
                  ],
                ),
                body: submitted ? _buildResult(isChinese) : _buildForm(isChinese),
              );
      },
    );
  }

  Widget _buildForm(bool isChinese) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(isChinese),
            const SizedBox(height: 20),
            _buildCard(_buildQuestion1()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion2()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion3()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion4()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion5()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion6()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion7()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion8()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion9()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion10()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion11()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion12()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion13()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion14()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion15()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion16()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion17()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion18()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion19()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion20()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion21()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion22()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion23()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion24()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion25()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion26()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion27()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion28()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion29()),
            const SizedBox(height: 16),
            _buildCard(_buildQuestion30()),
            const SizedBox(height: 28),
            Center(
              child: PrimaryButton(
                text: '提交问卷',
                onPressed: _saveSurvey,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(bool isChinese) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.quiz, size: 48, color: kPrimaryColor),
          const SizedBox(height: 12),
          const Text(
            '北京中轴线秘鲁游客深度体验调查问卷',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '通过这份问卷，我们将为您分配专属的探秘身份，让您深度体验中轴线景点与秘鲁文明的对话。',
            style: TextStyle(
              fontSize: 14,
              color: kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // 问题1：您来自秘鲁哪个城市？
  Widget _buildQuestion1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '1. 您来自秘鲁哪个城市？（单选）' : '1. ¿De qué ciudad de Perú viene? (única opción)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q1CityOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q1City == option['key'],
              onSelected: (selected) {
                setState(() {
                  q1City = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
        if (q1City == 'other') ...[
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: isChinese ? '请填写城市' : 'Por favor, escriba la ciudad',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                q1OtherCity = value;
              });
            },
          ),
        ],
      ],
    );
  }

  // 问题2：这是您第几次访问中国
  Widget _buildQuestion2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '2. 这是您第几次访问中国（单选）' : '2. ¿Cuántas veces ha visitado China? (única opción)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q2VisitCountOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q2VisitCount == option['key'],
              onSelected: (selected) {
                setState(() {
                  q2VisitCount = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题3：您还去过中国那些城市？
  Widget _buildQuestion3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isChinese ? '3. 您还去过中国哪些城市？（多选）' : '3. ¿Qué otras ciudades de China ha visitado? (múltiple opción)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q3CityOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q3VisitedCities.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q3VisitedCities.add(option['key']);
                  } else {
                    q3VisitedCities.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (q3VisitedCities.contains('other')) ...[
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: isChinese ? '请填写城市' : 'Por favor, escriba la ciudad',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                q3OtherCities = value;
              });
            },
          ),
        ],
      ],
    );
  }

  // 问题4：您对北京中轴线的了解程度？
  Widget _buildQuestion4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. 您对北京中轴线的了解程度？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q4KnowledgeOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q4AxisKnowledge == option['key'],
              onSelected: (selected) {
                setState(() {
                  q4AxisKnowledge = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题5：您对中国不同朝代的服饰有了解吗？
  Widget _buildQuestion5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. 您对中国不同朝代的服饰有了解吗？',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q5ClothingOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q5DynastyClothing == option['key'],
              onSelected: (selected) {
                setState(() {
                  q5DynastyClothing = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题6：您最喜欢哪个朝代的服饰？
  Widget _buildQuestion6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6. 您最喜欢哪个朝代的服饰？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q6DynastyOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q6FavoriteDynasty == option['key'],
              onSelected: (selected) {
                setState(() {
                  q6FavoriteDynasty = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题7：您觉得拍照是一件重要的事情吗？
  Widget _buildQuestion7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7. 您觉得拍照是一件重要的事情吗？',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q7PhotoOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q7PhotoImportance == option['key'],
              onSelected: (selected) {
                setState(() {
                  q7PhotoImportance = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题8：您的拍照水平如何？
  Widget _buildQuestion8() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '8. 您的拍照水平如何？',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q8SkillOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q8PhotoSkill == option['key'],
              onSelected: (selected) {
                setState(() {
                  q8PhotoSkill = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题9：您的视频剪辑能力如何？
  Widget _buildQuestion9() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '9. 您的视频剪辑能力如何？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q9VideoOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q9VideoSkill == option['key'],
              onSelected: (selected) {
                setState(() {
                  q9VideoSkill = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题10：如果您希望与当地居民互动，主要原因是？
  Widget _buildQuestion10() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '10. 如果您希望与当地居民互动，主要原因是？（可多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q10InteractionOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q10InteractionReasons.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q10InteractionReasons.add(option['key']);
                  } else {
                    q10InteractionReasons.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题11：您最期待在秘鲁体验什么？
  Widget _buildQuestion11() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '11. 您最期待在秘鲁体验什么？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q11ExperienceOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q11ExpectedExperiences.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q11ExpectedExperiences.add(option['key']);
                  } else {
                    q11ExpectedExperiences.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题12：来北京前对中餐了解程度？
  Widget _buildQuestion12() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '12. 来北京前对中餐了解程度？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q12FoodKnowledgeOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q12ChineseFoodKnowledge == option['key'],
              onSelected: (selected) {
                setState(() {
                  q12ChineseFoodKnowledge = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题13：您的口味偏好？
  Widget _buildQuestion13() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '13. 您的口味偏好？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q13TasteOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q13TastePreferences.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q13TastePreferences.add(option['key']);
                  } else {
                    q13TastePreferences.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题14：您的饮食禁忌？
  Widget _buildQuestion14() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '14. 您的饮食禁忌？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q14RestrictionOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q14DietaryRestrictions == option['key'],
              onSelected: (selected) {
                setState(() {
                  q14DietaryRestrictions = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
        if (q14DietaryRestrictions == 'other') ...[
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: '请填写其他禁忌',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                q14OtherRestrictions = value;
              });
            },
          ),
        ],
      ],
    );
  }

  // 问题15：住宿最重要因素？
  Widget _buildQuestion15() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '15. 住宿最重要因素？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q15AccommodationOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q15AccommodationPriority == option['key'],
              onSelected: (selected) {
                setState(() {
                  q15AccommodationPriority = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题16：最想吃什么中餐？
  Widget _buildQuestion16() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '16. 最想吃什么中餐？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q16FoodOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q16MostWantedFood == option['key'],
              onSelected: (selected) {
                setState(() {
                  q16MostWantedFood = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题17：最想尝试的北京小吃类型？
  Widget _buildQuestion17() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '17. 最想尝试的北京小吃类型？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q17SnackOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q17SnackTypes.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q17SnackTypes.add(option['key']);
                  } else {
                    q17SnackTypes.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题18：日常在秘鲁喝什么茶？
  Widget _buildQuestion18() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '18. 日常在秘鲁喝什么茶？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q18TeaOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q18DailyTea.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q18DailyTea.add(option['key']);
                  } else {
                    q18DailyTea.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题19：来中国后最希望喝什么饮料？
  Widget _buildQuestion19() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '19. 来中国后最希望喝什么饮料？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q19DrinkOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q19DesiredDrinks.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q19DesiredDrinks.add(option['key']);
                  } else {
                    q19DesiredDrinks.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题20：希望用餐时使用什么餐具？
  Widget _buildQuestion20() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '20. 希望用餐时使用什么餐具？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q20UtensilOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q20Utensils == option['key'],
              onSelected: (selected) {
                setState(() {
                  q20Utensils = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题21：平时有玩游戏的习惯吗？
  Widget _buildQuestion21() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '21. 平时有玩游戏的习惯吗？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q21GameOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q21GameHabits == option['key'],
              onSelected: (selected) {
                setState(() {
                  q21GameHabits = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题22：听说过或玩过黑神话悟空吗？
  Widget _buildQuestion22() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '22. 听说过或玩过黑神话悟空吗？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q22BlackMythOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q22BlackMythAwareness == option['key'],
              onSelected: (selected) {
                setState(() {
                  q22BlackMythAwareness = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题23：最想带走的中轴线文化伴手礼？
  Widget _buildQuestion23() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '23. 最想带走的中轴线文化伴手礼？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q23SouvenirOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q23Souvenirs.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q23Souvenirs.add(option['key']);
                  } else {
                    q23Souvenirs.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题24：旅行中用什么形式进行分享？
  Widget _buildQuestion24() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '24. 旅行中用什么形式进行分享？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q24PlatformOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q24SharingPlatforms.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q24SharingPlatforms.add(option['key']);
                  } else {
                    q24SharingPlatforms.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题25：您的语言能力？
  Widget _buildQuestion25() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '25. 您的语言能力？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q25LanguageOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q25ChineseLanguage == option['key'],
              onSelected: (selected) {
                setState(() {
                  q25ChineseLanguage = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题26：是否愿意尝试了解中国的诗歌艺术？
  Widget _buildQuestion26() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '26. 是否愿意尝试了解中国的诗歌艺术？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q26PoetryOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q26PoetryInterest == option['key'],
              onSelected: (selected) {
                setState(() {
                  q26PoetryInterest = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题27：是否喜欢看当地的文化表演？
  Widget _buildQuestion27() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '27. 是否喜欢看当地的文化表演？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q27PerformanceOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q27CulturalPerformances == option['key'],
              onSelected: (selected) {
                setState(() {
                  q27CulturalPerformances = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题28：是否熟练使用智能手机？
  Widget _buildQuestion28() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '28. 是否熟练使用智能手机？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q28SmartphoneOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q28SmartphoneSkills == option['key'],
              onSelected: (selected) {
                setState(() {
                  q28SmartphoneSkills = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 问题29：是否有特殊健康状况或需求？
  Widget _buildQuestion29() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '29. 是否有特殊健康状况或需求？（单选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q29SpecialNeedsOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q29SpecialNeeds == option['key'],
              onSelected: (selected) {
                setState(() {
                  q29SpecialNeeds = selected ? option['key'] : '';
                });
              },
            );
          }).toList(),
        ),
        if (q29SpecialNeeds == 'yes') ...[
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: '请说明特殊需求详情',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                q29SpecialNeedsDetails = value;
              });
            },
          ),
        ],
      ],
    );
  }

  // 问题30：您的购物偏好？
  Widget _buildQuestion30() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '30. 您的购物偏好？（多选）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q30ShoppingOptions.map((option) {
            return ChoiceChip(
              label: Text((isChinese ? option['text_zh'] : option['text_es']) ?? ''),
              selected: q30ShoppingPreferences.contains(option['key']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    q30ShoppingPreferences.add(option['key']);
                  } else {
                    q30ShoppingPreferences.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResult(bool isChinese) {
    final role = roles.firstWhere((r) => r['key'] == assignRole(), orElse: () => roles[0]);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Image.asset(role['img']!, height: 120),
          const SizedBox(height: 16),
          Text(
            '恭喜你成为：${isChinese ? role['name_zh']! : role['name_es']!}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? role['desc_zh']! : role['desc_es']!,
            style: const TextStyle(fontSize: 16, color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            '感谢您的参与！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '问卷已提交成功，我们将根据您的回答为您分配专属的探秘身份。',
            style: TextStyle(fontSize: 16, color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: '重新填写问卷',
            onPressed: _resetSurvey,
          ),
        ],
      ),
    );
  }

  Future<void> _resetSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    setState(() {
      q1City = '';
      q1OtherCity = '';
      q2VisitCount = '';
      q3VisitedCities = [];
      q3OtherCities = '';
      q4AxisKnowledge = '';
      q5DynastyClothing = '';
      q6FavoriteDynasty = '';
      q7PhotoImportance = '';
      q8PhotoSkill = '';
      q9VideoSkill = '';
      q10InteractionReasons = [];
      q11ExpectedExperiences = [];
      q12ChineseFoodKnowledge = '';
      q13TastePreferences = [];
      q14DietaryRestrictions = '';
      q14OtherRestrictions = '';
      q15AccommodationPriority = '';
      q16MostWantedFood = '';
      q17SnackTypes = [];
      q18DailyTea = [];
      q19DesiredDrinks = [];
      q20Utensils = '';
      q21GameHabits = '';
      q22BlackMythAwareness = '';
      q23Souvenirs = [];
      q24SharingPlatforms = [];
      q25ChineseLanguage = '';
      q26PoetryInterest = '';
      q27CulturalPerformances = '';
      q28SmartphoneSkills = '';
      q29SpecialNeeds = '';
      q29SpecialNeedsDetails = '';
      q30ShoppingPreferences = [];
      submitted = false;
    });

    _animationController.reset();
    _animationController.forward();
  }

  bool get isChinese {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale == AppLocale.zh;
  }
}