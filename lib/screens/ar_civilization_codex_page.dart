import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'; // Added for AssetImage

class ARCivilizationCodexPage extends StatefulWidget {
  const ARCivilizationCodexPage({Key? key}) : super(key: key);

  @override
  State<ARCivilizationCodexPage> createState() => _ARCivilizationCodexPageState();
}

class _ARCivilizationCodexPageState extends State<ARCivilizationCodexPage> {
  int _selectedCategory = 0;

  final List<String> _categories = ['中轴线', '天坛', '故宫', '万宁桥', '四合院', '美食'];

  final List<Map<String, dynamic>> _digitalResources = [
    // 中轴线数字资源
    {
      'category': '中轴线',
      'title': '北京中轴线官网',
      'title_es': 'Sitio Oficial del Eje Central de Pekín',
      'description': '官方权威的中轴线信息平台',
      'description_es': 'Plataforma oficial de información del Eje Central de Pekín',
      'url': 'https://bjaxiscloud.com.cn/',
      'type': 'website',
    },
    {
      'category': '中轴线',
      'title': '3D沉浸中轴：全景穿越京城脊梁',
      'title_es': '3D Inmersivo: Cruza la columna vertebral de Pekín',
      'description': '全景体验北京中轴线的壮美',
      'description_es': 'Experiencia panorámica de la majestuosidad del Eje Central de Pekín',
      'url': 'https://tv.sohu.com/v/dXMvMzI2NTU5MjQ2LzU2MTc1MjI2NS5zaHRtbA.html',
      'type': 'video',
    },
    {
      'category': '中轴线',
      'title': '一条"线"也能成功申遗？不愧是中国！',
      'title_es': '¿Una "línea" puede ser Patrimonio Mundial? ¡Solo en China!',
      'description': '深度解析北京中轴线的申遗价值',
      'description_es': 'Análisis profundo del valor patrimonial del Eje Central de Pekín',
      'url': 'https://www.bilibili.com/video/BV1mE421w7Vg/',
      'type': 'video',
    },
    {
      'category': '中轴线',
      'title': '什么是北京中轴线？',
      'title_es': '¿Qué es el Eje Central de Pekín?',
      'description': '科普北京中轴线的基本概念',
      'description_es': 'Conceptos básicos sobre el Eje Central de Pekín',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=3006775711214015004',
      'type': 'video',
    },
    {
      'category': '中轴线',
      'title': '3D全景动画"转动"北京中轴线',
      'title_es': 'Animación 3D: "Gira" el Eje Central de Pekín',
      'description': '3D动画展示中轴线的立体结构',
      'description_es': 'Animación 3D que muestra la estructura tridimensional del Eje Central',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=17771482181489522250',
      'type': 'video',
    },
    {
      'category': '中轴线',
      'title': '【申遗宣传】什么是北京中轴线（英语国际版）',
      'title_es': 'Promoción de Patrimonio: ¿Qué es el Eje Central de Pekín? (Versión internacional)',
      'description': '面向国际的申遗宣传片',
      'description_es': 'Video promocional internacional sobre el Eje Central',
      'url': 'https://www.bilibili.com/video/BV1B4CbYFEjy/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
      'type': 'video',
    },
    {
      'category': '中轴线',
      'title': 'AI短片：北京中轴线',
      'title_es': 'Corto AI: Eje Central de Pekín',
      'description': 'AI技术制作的北京中轴线短片',
      'description_es': 'Corto sobre el Eje Central realizado con tecnología de IA',
      'url': 'https://www.bilibili.com/video/BV1W8DZYKECr/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
      'type': 'video',
    },

    // 天坛数字资源
    {
      'category': '天坛',
      'title': '北京天坛官网',
      'title_es': 'Sitio Oficial del Templo del Cielo de Pekín',
      'description': '天坛公园官方网站',
      'description_es': 'Sitio web oficial del Parque del Templo del Cielo de Pekín',
      'url': 'http://www.tiantanpark.com/',
      'type': 'website',
    },
    {
      'category': '天坛',
      'title': '天坛导览全图',
      'title_es': 'Mapa panorámico del Templo del Cielo',
      'description': '天坛公园官方导览全图',
      'description_es': 'Mapa panorámico oficial del Parque del Templo del Cielo',
      'url': 'http://www.tiantanpark.com/contents/4/4107.html',
      'type': 'website',
    },
    {
      'category': '天坛',
      'title': '《天坛祈年殿拆解动画》',
      'title_es': 'Animación de Desmontaje del Templo del Cielo de Pekín',
      'description': '3D动画展示祈年殿的建筑结构',
      'description_es': 'Animación 3D que muestra la estructura del Templo del Cielo',
      'url': 'https://www.bilibili.com/video/BV1zCA6e2Eer?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c&spm_id_from=333.788.player.player_end_recommend_autoplay',
      'type': 'video',
    },
    {
      'category': '天坛',
      'title': '《3D全景看天坛如何"祭天"》',
      'title_es': '3D Panorámico: ¿Cómo "Ofrenda al Cielo" en el Templo del Cielo?',
      'description': '3D全景体验古代祭天仪式',
      'description_es': 'Experiencia panorámica 3D de la ceremonia de "Ofrenda al Cielo" antigua',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=3303483145355424623',
      'type': 'video',
    },
    {
      'category': '天坛',
      'title': '《秘鲁古老的印加都城库斯科》',
      'title_es': 'Ciudad Antigua de Cuzco, Perú',
      'description': '对比中秘文明的古代都城',
      'description_es': 'Comparación de ciudades antiguas entre la civilización china y la inca',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=18272300209720379346',
      'type': 'video',
    },

    // 故宫数字资源
    {
      'category': '故宫',
      'title': '故宫博物院官网',
      'title_es': 'Sitio Oficial del Museo del Palacio de la Ciudad Prohibida',
      'description': '故宫博物院官方网站',
      'description_es': 'Sitio web oficial del Museo del Palacio de la Ciudad Prohibida',
      'url': 'https://www.dpm.org.cn/explode/others/248017.html',
      'type': 'website',
    },
    {
      'category': '故宫',
      'title': '故宫博物院数字文物库',
      'title_es': 'Biblioteca Digital de Arte del Museo del Palacio de la Ciudad Prohibida',
      'description': '故宫文物数字化展示平台',
      'description_es': 'Plataforma de exhibición digital de arte del Museo del Palacio de la Ciudad Prohibida',
      'url': 'https://digicol.dpm.org.cn/',
      'type': 'website',
    },
    {
      'category': '故宫',
      'title': '琉璃烧制技艺"琉"光溢彩',
      'title_es': 'Técnica de Horno de Vidrio "Líu" Brillante',
      'description': '展示传统琉璃制作工艺',
      'description_es': 'Exposición de la técnica tradicional de horno de vidrio',
      'url': 'https://tv.cctv.com/2025/05/25/VIDECTEQ4CQMfr2X4wd59cXU250525.shtml',
      'type': 'video',
    },
    {
      'category': '故宫',
      'title': '琉璃烧制技艺',
      'title_es': 'Técnica de Horno de Vidrio',
      'description': '详细介绍琉璃制作技术',
      'description_es': 'Descripción detallada de la técnica de horno de vidrio',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=10052820836157398587',
      'type': 'video',
    },
    {
      'category': '故宫',
      'title': '"高温烧胎，低温烧釉"',
      'title_es': 'Sinterización de Cerámica: "Calentamiento de Alto Horno, Enfriamiento de Bajo Horno"',
      'description': '传统陶瓷烧制工艺解析',
      'description_es': 'Análisis de la técnica de sinterización de cerámica tradicional',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=13919565296214666623',
      'type': 'video',
    },
    {
      'category': '故宫',
      'title': '【太和殿屋顶真的"鹰不落"吗？】',
      'title_es': '¿El Techo del Taihe Palace realmente "No se posa el águila"?',
      'description': '揭秘太和殿建筑的神秘传说',
      'description_es': 'Desvelar el misterio de la construcción del Templo Taihe',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=13121734262817927664',
      'type': 'video',
    },

    // 万宁桥数字资源
    {
      'category': '万宁桥',
      'title': '万宁桥与镇水兽的神秘传说',
      'title_es': 'Mito y Leyenda del Puente Wanning y el Dragón de Agua',
      'description': '探索万宁桥的历史传说',
      'description_es': 'Exploración de la leyenda y el misterio del Puente Wanning',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=11813824572621971519',
      'type': 'video',
    },
    {
      'category': '万宁桥',
      'title': '镇水神兽与万宁桥的历史传说',
      'title_es': 'Leyenda y Misterio del Dragón de Agua y el Puente Wanning',
      'description': '深入了解镇水神兽的文化内涵',
      'description_es': 'Entendimiento profundo de la cultura del Dragón de Agua y el Puente Wanning',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=13498141590081766778',
      'type': 'video',
    },
    {
      'category': '万宁桥',
      'title': '舞蹈《镇水神兽》',
      'title_es': 'Baile del Dragón de Agua',
      'description': '以舞蹈形式展现镇水神兽文化',
      'description_es': 'Baile que representa la cultura del Dragón de Agua',
      'url': 'https://haokan.baidu.com/v?pd=wisenatural&vid=13782222974100361441',
      'type': 'video',
    },
    {
      'category': '万宁桥',
      'title': '700多年万宁桥',
      'title_es': 'Puente Wanning de 700 Años',
      'description': '万宁桥700多年的历史变迁',
      'description_es': 'Cambios históricos de 700 años del Puente Wanning',
      'url': 'https://www.bilibili.com/video/BV1iK4y1c7z9/?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c',
      'type': 'video',
    },

    // 北京四合院数字资源
    {
      'category': '四合院',
      'title': '北京四合院_百度百科',
      'title_es': 'Siheyuan de Pekín - Wikipedia',
      'description': '四合院的基本介绍和知识',
      'description_es': 'Introducción básica y conocimientos sobre el Siheyuan',
      'url': 'https://baike.baidu.com/item/%E5%8C%97%E4%BA%AC%E5%9B%9B%E5%92%8C%E9%99%A2/7642492?fr=aladdin',
      'type': 'website',
    },
    {
      'category': '四合院',
      'title': '北京四九城与数字"四"的文化魅力',
      'title_es': 'Magia Cultural de "Cuatro" en Pekín',
      'description': '探索北京四九城的文化内涵',
      'description_es': 'Exploración de la cultura y el significado de "Cuatro" en Pekín',
      'url': 'https://baijiahao.baidu.com/s?id=1828844473890325240&wfr=spider&for=pc',
      'type': 'article',
    },
    {
      'category': '四合院',
      'title': '带你了解老北京四合院',
      'title_es': 'Conócelo todo sobre el Siheyuan de Viejo Pekín',
      'description': '深入了解老北京四合院文化',
      'description_es': 'Entendimiento profundo de la cultura del Siheyuan de Viejo Pekín',
      'url': 'https://baijiahao.baidu.com/s?id=1810000542630382698&wfr=spider&for=pc',
      'type': 'article',
    },
    {
      'category': '四合院',
      'title': '北京四合院 01',
      'title_es': 'Siheyuan de Pekín 01',
      'description': '四合院系列视频第一部分',
      'description_es': 'Primera parte de la serie de videos del Siheyuan',
      'url': 'https://www.bilibili.com/video/BV1eA411Y7qH?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c&p=15&spm_id_from=333.788.videopod.episodes',
      'type': 'video',
    },
    {
      'category': '四合院',
      'title': '北京四合院 02',
      'title_es': 'Siheyuan de Pekín 02',
      'description': '四合院系列视频第二部分',
      'description_es': 'Segunda parte de la serie de videos del Siheyuan',
      'url': 'https://www.bilibili.com/video/BV1eA411Y7qH?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c&spm_id_from=333.788.videopod.episodes&p=16',
      'type': 'video',
    },
    {
      'category': '四合院',
      'title': '北京四合院 03',
      'title_es': 'Siheyuan de Pekín 03',
      'description': '四合院系列视频第三部分',
      'description_es': 'Tercera parte de la serie de videos del Siheyuan',
      'url': 'https://www.bilibili.com/video/BV1eA411Y7qH?vd_source=3410c0f2b19cd75c4eccc1f1102e2f8c&spm_id_from=333.788.videopod.episodes&p=17',
      'type': 'video',
    },

    // 北京中轴线美食数字资源
    {
      'category': '美食',
      'title': '北京中轴线美食地图',
      'title_es': 'Mapa de Gastronomía del Eje Central de Pekín',
      'description': '中轴线沿线美食分布地图',
      'description_es': 'Mapa de distribución de gastronomía a lo largo del Eje Central',
      'url': 'https://baijiahao.baidu.com/s?id=1808625793899732379&wfr=spider&for=pc',
      'type': 'article',
    },
    {
      'category': '美食',
      'title': '北京中轴线上的老字号餐厅！',
      'title_es': '¡Restaurantes de Renombre Antiguo en el Eje Central de Pekín!',
      'description': '中轴线沿线知名老字号餐厅介绍',
      'description_es': 'Introducción a restaurantes de renombre antiguo a lo largo del Eje Central',
      'url': 'https://www.visitbeijing.com.cn/article/4IsMRSStBuX',
      'type': 'article',
    },
    {
      'category': '美食',
      'title': '45家北京中轴线老字号餐厅分布',
      'title_es': 'Distribución de 45 Restaurantes de Renombre Antiguo en el Eje Central',
      'description': '详细的中轴线老字号餐厅分布信息',
      'description_es': 'Información detallada sobre la distribución de restaurantes de renombre antiguo en el Eje Central',
      'url': 'https://mp.weixin.qq.com/s?__biz=MzA3ODYwMjczMA==&mid=2665766771&idx=1&sn=02e00713ecfba50520c77cb63554ef61&chksm=85ad17f8953a96ea45562d3752649ba0974a676cdd1bc74bc481f93954edce8140107f21370f&scene=27',
      'type': 'article',
    },
    {
      'category': '美食',
      'title': '话说丨菜单上的北京中轴线',
      'title_es': 'Hablando sobre el Eje Central en el Menú',
      'description': '从菜单角度了解中轴线美食文化',
      'description_es': 'Entendimiento de la cultura gastronómica del Eje Central desde el menú',
      'url': 'https://baijiahao.baidu.com/s?id=1792300063860180708&wfr=spider&for=pc',
      'type': 'article',
    },
  ];

  List<Map<String, dynamic>> get _filteredResources {
    final locale = Localizations.localeOf(context).languageCode;
    final isSpanish = locale == 'es';
    final List<String> categoriesZh = ['中轴线', '天坛', '故宫', '万宁桥', '四合院', '美食'];
    final List<String> categoriesEs = ['Eje Central', 'Templo del Cielo', 'Ciudad Prohibida', 'Puente Wanning', 'Siheyuan', 'Gastronomía'];
    final List<String> categories = isSpanish ? categoriesEs : categoriesZh;

    if (_selectedCategory == 0) {
      return _digitalResources;
    }
    final category = isSpanish ? categoriesEs[_selectedCategory] : categoriesZh[_selectedCategory];
    return _digitalResources.where((resource) => (isSpanish ? resource['category_es'] : resource['category']) == category).toList();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开链接: $url')),
        );
      }
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'website':
        return Icons.language;
      case 'video':
        return Icons.play_circle_outline;
      case 'article':
        return Icons.article;
      default:
        return Icons.link;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'website':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'article':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isSpanish = locale == 'es';
    final isChinese = locale == 'zh';
    final List<String> categoriesZh = ['中轴线', '天坛', '故宫', '万宁桥', '四合院', '美食'];
    final List<String> categoriesEs = ['Eje Central', 'Templo del Cielo', 'Ciudad Prohibida', 'Puente Wanning', 'Siheyuan', 'Gastronomía'];
    final List<String> categories = isSpanish ? categoriesEs : categoriesZh;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('数字文明秘典'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(categories.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(categories[i], style: TextStyle(fontWeight: FontWeight.bold)),
                      selected: _selectedCategory == i,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = i;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // 资源列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (categories[_selectedCategory] == '万宁桥')
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            insetPadding: EdgeInsets.all(16),
                            child: AspectRatio(
                              aspectRatio: 16/9,
                              child: VideoPlayerWidget(assetPath: 'assets/images/dab2602bb3b518f25b11c16725d56280.mp4'),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.play_circle_fill, color: Colors.red, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '万宁桥本地珍贵视频',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '本地珍藏：万宁桥相关珍贵影像',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '本地视频',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.open_in_new,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // 其余资源卡片
                ..._filteredResources.map((resource) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _launchURL(resource['url']),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getTypeColor(resource['type']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getTypeIcon(resource['type']),
                              color: _getTypeColor(resource['type']),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSpanish ? resource['title_es'] ?? resource['title'] : resource['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isSpanish ? resource['description_es'] ?? resource['description'] : resource['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(resource['type']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        resource['type'] == 'website' ? '网站' : 
                                        resource['type'] == 'video' ? '视频' : '文章',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getTypeColor(resource['type']),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.open_in_new,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 

class VideoPlayerWidget extends StatefulWidget {
  final String assetPath;
  const VideoPlayerWidget({Key? key, required this.assetPath}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
} 