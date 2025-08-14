import 'package:flutter/material.dart';

class XKCodebookDetailPage extends StatelessWidget {
  const XKCodebookDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]);
    TextStyle subtitleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepOrange);
    TextStyle zhStyle = TextStyle(fontSize: 15, color: Colors.black87, height: 1.5);
    TextStyle esStyle = TextStyle(fontSize: 15, color: Colors.blueGrey[700], fontStyle: FontStyle.italic, height: 1.5);

    return Scaffold(
      appBar: AppBar(
        title: Text(Localizations.localeOf(context).languageCode == 'es' ? 'Base de Datos de Terminología del Eje Central de Beijing' : '北京中轴线术语库'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('《北京中轴线颂》中西双语注解', style: titleStyle),
          SizedBox(height: 16),
          _buildVerse('1. 永定门，位居南，东西陪伴有两坛', '永定门为北京中轴线南端起点，始建于明嘉靖年间。其东西两侧分列先农坛（西）与天坛（东），体现"左祖右社"的都城规划理念。', 'Puerta Yongding, punto de inicio en el sur del Eje Central de Beijing, construida durante la dinastía Ming (Jiajing). A sus lados se encuentran el Templo Xiannong (oeste) y el Templo del Cielo (este), reflejando el diseño urbano de "templo ancestral a la izquierda, altar de la tierra a la derecha".', subtitleStyle, zhStyle, esStyle),
          _buildVerse('2. 西侧神坛祭先农，东侧祀天又祈年', '先农坛为明清帝王祭祀农神场所，内设观耕台；天坛祈年殿以蓝瓦鎏金顶象征天象，是古代"天人沟通"的核心空间。', 'El Templo Xiannong (oeste) era donde los emperadores de Ming y Qing sacrificaban al dios de la agricultura, con plataforma de observación. El Salón Qinian del Templo del Cielo (este) simboliza la comunicación celestial mediante su cúpula dorada y azulejos azules.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('3. 正阳门前箭楼立，正阳门后人头攒', '正阳门箭楼为明清城防体系代表，现存城楼与箭楼构成"国门"形象；其北侧广场为明清时期商贾云集之地。', 'La Torre de Flechas de Zhengyangmen, parte del sistema defensivo Ming-Qing, forma la "Puerta Nacional" con su torre. La plaza norte era un centro comercial en la época Ming-Qing.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('4. 瞻仰领袖毛主席，纪念堂内永长眠', '毛主席纪念堂位于天安门广场，1977年建成，汉白玉栏杆环绕，体现现代中国对开国领袖的集体记忆。', 'El Mausoleo del Presidente Mao en la Plaza de Tian\'anmen, construido en 1977, con barandillas de mármol blanco, encarna la memoria colectiva del líder fundador de China moderna.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('5. 人民英雄纪念碑，勿忘先烈记心田', '1958年落成的花岗岩纪念碑，高37.94米，碑身浮雕展现虎门销烟至解放战争历史，碑文由毛泽东起草、周恩来题写。', 'El Monumento a los Héroes del Pueblo (1958) de granito, de 37.94m de altura, presenta bajorrelieves desde la Guerra del Opio hasta la Liberación. El texto fue redactado por Mao Zedong y escrito por Zhou Enlai.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('6. 天安门前有广场，城市中心八方连', '天安门广场占地44万平方米，南北长880米，东西宽500米，为全球最大城市广场，连接故宫、国家博物馆等核心建筑。', 'La Plaza de Tian\'anmen (440,000㎡) es la plaza urbana más grande del mundo, con 880m de norte a sur y 500m de este a oeste. Conecta la Ciudad Prohibida, el Museo Nacional y otros edificios clave.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('7. 天安门，圣火燃，开国大典声回旋', '1949年10月1日，毛泽东在此宣布中华人民共和国成立，城楼悬挂的国徽重达1.7吨，直径3米，象征新生政权的合法性。', 'El 1 de octubre de 1949, Mao Zedong proclamó la fundación de la República Popular China aquí. El escudo nacional colgado (1.7t, 3m de diámetro) simboliza la legitimidad del nuevo régimen.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('8. 太庙社稷拥左右，紫禁城内有坤乾', '太庙（今劳动人民文化宫）与社稷坛（今中山公园）分列紫禁城东西，体现"前朝后寝"的礼制；紫禁城现存8700间房屋，为明清24帝居所。', 'El Templo Ancestral (actual Palacio Cultural de los Trabajadores) y el Altar de la Tierra (actual Parque Zhongshan) flanquean la Ciudad Prohibida, siguiendo el ritual "corte frontal, dormitorios traseros". La Ciudad Prohibida cuenta con 8,700 habitaciones, residencia de 24 emperadores Ming-Qing.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('9. 登上景山万春亭，万宁古桥依稀见', '景山万春亭海拔88.7米，为北京城内最高点，可俯瞰中轴线全貌；东南侧可见元代万宁桥，现存为明代重建石桥。', 'El Pabellón Wanchun en la Colina Jingshan (88.7m) es el punto más alto de Beijing, con vista panorámica del Eje Central. Al sureste se encuentra el Puente Wanning de la dinastía Yuan, reconstruido en piedra durante Ming.', subtitleStyle, zhStyle, esStyle),
          _buildVerse('10. 钟楼鼓楼抒古韵，壮美帝都展新颜', '钟楼（42米）与鼓楼（46.7米）构成元明清时间中心，现存建筑为明代重建；周边胡同与现代商业交融，展现古今共生。', 'La Torre del Reloj (42m) y la Torre del Tambor (46.7m) marcaban el tiempo en Yuan-Ming-Qing, reconstruidas en Ming. Los callejones circundantes y la vida comercial moderna coexisten, mostrando la simbiosis pasado-presente.', subtitleStyle, zhStyle, esStyle),
          SizedBox(height: 24),
          Text('天坛相关术语', style: titleStyle),
          _buildTerm('祭祀', '传统仪式，通过供奉祭品向祖先或神灵表达敬意并祈求庇佑。', 'Sacrificio / Rito de ofrenda\nExplicación: Antigua práctica de rendir homenaje a ancestros o divinidades mediante ofrendas, buscando protección o bendiciones.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('鎏金宝顶', '建筑顶部以铜胎为基底、表面镀金的装饰性尖顶，常见于传统宫殿或庙宇。', 'Cúpula dorada de bronce / Finial chapado en oro\nExplicación: Elemento arquitectónico decorativo con base de bronce y capa dorada, típico en palacios o templos tradicionales.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('天圆地方', '中国古代哲学观念，认为天呈圆形、地呈方形，象征宇宙的和谐与秩序。', 'El cielo es redondo, la tierra es cuadrada\nExplicación: Concepto filosófico chino que simboliza la armonía cósmica: el cielo como esfera y la tierra como cuadrado.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('孟春正月上辛日', '农历春季第一个月（正月）中第一个天干为“辛”的日子，古代用于重要祭祀或仪式。', 'Primer día "Xin" del primer mes lunar de primavera\nExplicación: Día del calendario lunar (primer mes de primavera) cuyo carácter celestial es "Xin", utilizado en antiguas ceremonias sagradas.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('匾额', '悬挂于门楣或墙壁上的长方形木牌，刻有文字以表纪念、表彰或标识。', 'Placa conmemorativa / Tablilla de madera con inscripciones\nExplicación: Tabla rectangular de madera colgada en puertas o paredes, con textos que conmemoran, honran o identifican.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('五谷丰登', '指农作物丰收，年成良好，寓意生活富足。', 'Abundancia de granos / Cosecha exuberante\nExplicación: Buena cosecha de cereales, simbolizando prosperidad y bienestar.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('风调雨顺', '风雨适时，气候利于农耕，形容年景顺遂。', 'Clima favorable, lluvias oportunas\nExplicación: Condiciones climáticas ideales (lluvias y vientos a tiempo) que favorecen la agricultura.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('国泰民安', '国家安定、人民安康，形容社会和谐稳定。', 'País próspero y pueblo en paz / Estabilidad nacional y bienestar popular\nExplicación: Estado de armonía donde el país es fuerte y los ciudadanos viven en seguridad y bienestar.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('天人合一', '中国古代哲学核心思想，主张人与自然本质相通、和谐共存，强调顺应天道以实现身心与宇宙的统一。', 'Unidad entre el cielo y el hombre\nExplicación: Concepto filosófico central en China que postula la interconexión entre el ser humano y la naturaleza, enfatizando la armonía con el orden cósmico (Dao) para alcanzar la unidad entre el individuo y el universo.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('须弥座', '传统建筑中用于承载佛像或重要建筑的台基，形似佛教“须弥山”（世界中心），象征神圣与稳固。', 'Base de Sumeru / Pedestal de Monte Sumeru\nExplicación: Plataforma arquitectónica en forma de pirámide escalonada, inspirada en el Monte Sumeru (centro del mundo budista), utilizada para soportar estatuas sagradas o edificios importantes, simbolizando lo divino y la estabilidad.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('汉白玉', '中国特有的一种白色大理石，质地细腻洁白，常用于雕刻、建筑装饰（如故宫栏杆），象征纯洁与高贵。', 'Mármol blanco Hanbaiyu / Piedra blanca de Han\nExplicación: Mármol blanco de alta calidad, exclusivo de China, conocido por su textura suave y brillo perlado. Ampliamente utilizado en esculturas y decoración arquitectónica (por ejemplo, balaustradas de la Ciudad Prohibida), simbolizando pureza y nobleza.', subtitleStyle, zhStyle, esStyle),
          SizedBox(height: 24),
          Text('故宫相关专业术语', style: titleStyle),
          _buildTerm('榫卯', '中国传统木构建筑中，凸出部分（榫）与凹进部分（卯）的咬合结构，无需钉铁即可实现牢固连接，体现古人智慧。', 'Unión de madera con espiga y ranura\nExplicación: Técnica de ensamblaje en la arquitectura china tradicional, donde partes sobresalientes (espigas) se encastran en partes huecas (ranuras) para formar conexiones sólidas sin clavos ni tornillos, simbolizando la ingeniería ancestral.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('五门三朝', '古代宫殿布局制度，五道门象征礼制等级，三朝（外朝、治朝、燕朝）划分不同功能空间，体现皇权秩序。', 'Cinco puertas y tres salas de audiencia\nExplicación: Sistema de diseño palaciego antiguo: cinco puertas representan jerarquías rituales, mientras tres salas (exterior, administrativa y de descanso) delimitan espacios funcionales, reflejando el orden imperial.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('金銮殿', '故宫太和殿的别称，皇帝举行朝会、大典的核心场所，象征最高皇权。', 'Salón del Trono Imperial (Salón Jinluan)\nExplicación: Nombre alternativo del Salón Taihe en la Ciudad Prohibida, lugar central donde el emperador celebraba audiencias y ceremonias, simbolizando la autoridad suprema.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('面阔', '建筑正立面的宽度，通常以开间数量计量，反映建筑等级规模。', 'Anchura de la fachada\nExplicación: Medida de la anchura de la fachada principal de un edificio, generalmente expresada en número de columnas o módulos, indicando su escala y jerarquía.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('重檐庑殿顶', '屋顶形式，双层屋檐搭配庑殿式斜坡，为古代最高等级建筑屋顶。', 'Tejado de doble alero con estilo wudian\nExplicación: Forma de techo de máxima jerarquía en la arquitectura china antigua: dos capas de aleros combinadas con pendientes cuadruples, típico de templos o palacios imperiales.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('彩绘', '建筑表面绘制的装饰性图案，常用彩色颜料描绘龙凤、花卉等，寓意吉祥。', 'Pintura decorativa arquitectónica\nExplicación: Motivos ornamentales pintados en superficies de edificios, con colores vivos que representan dragones, flores u otros símbolos auspiciosos.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('深谙', '对某领域有深刻的理解与掌握，如“深谙建筑之道”。', 'Conocer profundamente / Dominar a fondo\nExplicación: Tener un entendimiento profundo y experimentado en un campo específico (por ejemplo, “dominar a fondo los principios arquitectónicos”).', subtitleStyle, zhStyle, esStyle),
          _buildTerm('嵌套', '建筑或装饰中不同层次结构的叠加设计，如门窗的层层嵌套。', 'Encaje anidado\nExplicación: Diseño en el que estructuras de diferentes niveles se superponen o encastran (por ejemplo, ventanas y puertas anidadas en arquitectura).', subtitleStyle, zhStyle, esStyle),
          _buildTerm('斗拱', '木构建筑中，支撑屋檐的弓形承重结构，兼具力学与美学功能。', 'Sistema dougong\nExplicación: Estructura de madera en forma de arco utilizada para sostener aleros en la arquitectura china, combinando funciones mecánicas y estéticas.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('镌刻', '在材料（如石、木）表面雕刻文字或图案，常见于碑文、匾额。', 'Grabado\nExplicación: Tallar textos o diseños en la superficie de materiales (piedra, madera), típico en inscripciones monumentales o placas conmemorativas.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('经纬', '建筑规划中纵向（经）与横向（纬）的布局轴线，象征秩序与方向。', 'Meridianos y paralelos en el diseño\nExplicación: Ejes longitudinales (meridianos) y transversales (paralelos) en la planificación arquitectónica, simbolizando orden y orientación espacial.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('鸱吻', '屋顶正脊两端的装饰性构件，形似鸱鸟，传说可避火灾。', 'Boca de dragón en el tejado (chiwen)\nExplicación: Adorno en forma de pájaro chi (mitológico) ubicado en los extremos del tejado, creído que protege contra incendios.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('举架', '屋顶坡度的设计比例，决定排水与美观，如“五举”指坡度高度为五份。', 'Proporción de pendiente del tejado\nExplicación: Diseño de la inclinación del techo que afecta el drenaje y estética (por ejemplo, “quju” indica una altura de pendiente de cinco unidades).', subtitleStyle, zhStyle, esStyle),
          _buildTerm('左祖右社', '古代都城规划，左侧设祖庙（祭祖），右侧设社稷坛（祭土地谷神），体现“敬天法祖”。', 'Templo ancestral a la izquierda, altar de la tierra a la derecha\nExplicación: Diseño urbano antiguo donde a la izquierda se ubica el templo ancestral y a la derecha el altar de la tierra y los cereales, reflejando el respeto por el cielo y los antepasados.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('千两白银地砖', '用价值千两白银的材料（如银箔、特殊工艺）制作的地砖，象征奢华与地位。', 'Losas de plata de mil taels\nExplicación: Baldosas elaboradas con materiales equivalentes a mil taels de plata (por ejemplo, pan de plata o técnicas especiales), simbolizando lujo y estatus.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('九五开间', '建筑面阔为九间（纵向）与五间（横向），象征帝王“九五之尊”的权威。', 'Nueve y cinco intervalos en la estructura\nExplicación: Diseño arquitectónico con nueve módulos de anchura (longitudinal) y cinco de profundidad (transversal), simbolizando la autoridad imperial (“nueve y cinco” como número sagrado del emperador).', subtitleStyle, zhStyle, esStyle),
          SizedBox(height: 24),
          Text('万宁桥相关术语', style: titleStyle),
          _buildTerm('什刹海', '北京历史水域，元大都时期漕运核心码头，由前海、后海、西海组成，周边分布大量文物古迹，如万宁桥、银锭桥，体现“山水城相融”的古代城市智慧。', 'Cuenca histórica de Beijing, centro de transporte fluvial durante la era de Yuan Dadu. Compuesta por el Qianhai, Houhai y Xihai, rodeada de monumentos culturales como Puente Wanning y Puente Yinding, simboliza la integración urbana de montaña, agua y ciudad en la antigüedad.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('元大都', '元朝首都（1267-1368），蒙古语称“汗八里”（大汗居所），由刘秉忠规划，奠定北京现代城市格局，现存北土城遗址、钟鼓楼等遗迹。', 'Capital de la dinastía Yuan (1267-1368), llamada "Khanbaliq" (residencia del Gran Kan) en mongol. Planeada por Liu Bingzhong, sentó las bases del diseño urbano moderno de Beijing. Restos incluyen las ruinas de la Ciudad Amurallada Norte y la Torre del Reloj.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('万宁桥', '元大都单孔石拱桥，桥闸一体设计，通过提放水闸调节水位，保障漕船通行，现存镇水兽石雕，为中轴线重要节点。', 'Puente de arco de piedra de un solo arco en Yuan Dadu, diseñado con compuerta integrada. Regulaba niveles de agua para el transporte fluvial. Conserva esculturas de bestias guardianas del agua, siendo un nodo clave del Eje Central.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('南北向桥梁', '元大都桥梁多呈南北走向，如万宁桥，连接城市南北交通，兼具水利功能，体现“经纬交织”的城市规划理念。', 'Puentes de Yuan Dadu orientados norte-sur, como Puente Wanning, conectaban el tráfico norte-sur y tenían funciones hidráulicas. Reflejan el concepto urbanístico de "tejido de ejes".', subtitleStyle, zhStyle, esStyle),
          _buildTerm('水利工程', '元代郭守敬主持修建通惠河，利用闸坝系统调节水位，使漕船直抵积水潭，解决大都物资运输难题，技术领先欧洲数百年。', 'Guo Shoujing dirigió la construcción del Río Tonghui, utilizando sistemas de compuertas para regular niveles de agua. Permitió a barcos de transporte llegar directamente al Lago Jishui, resolviendo problemas logísticos de Dadu, con tecnología avanzada siglos antes de Europa.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('茉莉花', '原产中亚，汉代传入中国，宋代与茶叶结合制成茉莉花茶，象征纯洁友谊，福州茉莉花茶为国家级非遗，以“冰糖甜”著称。', 'Originaria de Asia Central, introducida a China en la dinastía Han. En la dinastía Song, se combinó con té para crear el té de jazmín, símbolo de amistad pura. El té de jazmín de Fuzhou es Patrimonio Cultural Intangible Nacional, conocido por su "dulzura cristalina".', subtitleStyle, zhStyle, esStyle),
          _buildTerm('绿茶', '不发酵茶，经杀青、揉捻、干燥制成，保留天然物质，种类包括龙井、碧螺春，中国产量最大的茶类，历史可追溯至唐代蒸青工艺。', 'Té no fermentado, elaborado mediante fijación, enrollado y secado. Conserva sustancias naturales. Tipos incluyen Longjing y Biluochun. Es el té más producido en China, con orígenes en el método de vaporización de la dinastía Tang.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('窨制', '制茶工艺，将茉莉花与茶坯分层铺放，通过多次静置使茶叶吸收花香，福州工艺最高可达“九窨一提”，花朵最终融入茶中。', 'Técnica de elaboración de té donde se colocan capas de jazmín y té base. Mediante reposos repetidos, el té absorbe aroma floral. La artesanía de Fuzhou alcanza "nueve reposos y un refresco", con flores finalmente integradas al té.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('镇水兽', '万宁桥石雕，形似龙子“趴蝮”，头生独角，身覆鳞甲，监视水位，兼具实用与象征意义，体现古人“天人合一”的治水哲学。', 'Esculturas en piedra del Puente Wanning, similares a "Baxia" (hijo del dragón). Con cuernos únicos y escamas, vigilan niveles de agua. Combinan utilidad y simbolismo, reflejando la filosofía de "unidad entre cielo y hombre".', subtitleStyle, zhStyle, esStyle),
          _buildTerm('逆流而上', '元大都水利工程中，通过闸坝系统使漕船克服地势逆流而行，如通惠河设计，实现南粮北运，技术领先同时期欧洲运河工程。', 'En la hidráulica de Yuan Dadu, sistemas de compuertas permitieron a barcos de transporte remontar corrientes. El diseño del Río Tonghui logró transportar granos del sur al norte, tecnología avanzada respecto a canales europeos de la época.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('二龙戏珠', '传统装饰图案，两龙围绕火珠嬉戏，象征吉祥和谐，常见于建筑脊饰、藻井，如北海西天梵境影壁，寓意阴阳调和、生生不息。', 'Patrón decorativo tradicional de dos dragones jugando con una perla de fuego. Simboliza armonía y buena suerte, presente en aleros y cañones de techos, como en el muro del Templo Xitiánfeng del Lago Norte. Representa equilibrio yin-yang y vida perpetua.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('水文监测站', '现代水利设施，通过传感器实时监测水位、流量、水质，数据传输至监控中心，用于防洪预警、水资源管理，什刹海周边设有监测站点。', 'Instalaciones hidráulicas modernas que monitorean niveles de agua, caudal y calidad mediante sensores. Los datos se transmiten a centros de control para alertas de inundaciones y gestión de recursos. Existen estaciones de monitoreo alrededor de Shichahai.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('澄清水闸', '元代郭守敬所建三道闸口，木质结构后改石砌，调节积水潭水位，现存澄清下闸遗址，为大运河重要人文遗产。', 'Tres compuertas construidas por Guo Shoujing en la dinastía Yuan, inicialmente de madera y luego de piedra. Regulaban niveles del Lago Jishui. Las ruinas de la compuerta inferior conservan patrimonio cultural del Gran Canal.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('银锭桥', '明代始建单孔石拱桥，因形似银锭得名，1990年重建为钢筋混凝土结构，保留汉白玉栏板，为“银锭观山”景观核心，2021年恢复历史视廊。', 'Puente de arco de piedra de un solo arco construido en la dinastía Ming, llamado así por su forma de lingote de plata. Reconstruido en 1990 con hormigón armado y barandillas de mármol blanco. Es el núcleo del paisaje "Vista de Montaña desde Lingote de Plata", cuya visibilidad histórica se restauró en 2021.', subtitleStyle, zhStyle, esStyle),
          SizedBox(height: 24),
          Text('中轴线美食相关术语', style: titleStyle),
          _buildTerm('焦圈', '北京传统油炸面食，呈环形中空，口感酥脆，常与豆汁搭配食用，象征老北京早餐文化。', 'Anillo frito de Beijing\nExplicación: Pastel frito tradicional en forma de anillo hueco, crujiente y dorado. Se sirve con zumo de judía verde, simbolizando la cultura del desayuno en el Beijing antiguo.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('豆汁', '绿豆发酵制成的酸浆水，颜色灰绿，气味独特，北京传统早餐饮品，搭配焦圈解腻。', 'Zumo fermentado de judía verde\nExplicación: Bebida fermentada de judía verde, de color gris-verde y aroma fuerte. Típico desayuno en Beijing, combinado con anillos fritos para equilibrar sabores.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('发酵', '微生物分解有机物的生化过程，用于制作豆汁、酸奶、面包等，提升风味与营养价值。', 'Fermentación\nExplicación: Proceso bioquímico donde microorganismos descomponen materia orgánica. Utilizado en alimentos como zumo de judía verde, yogur y pan para mejorar sabor y nutrientes.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('冬瓜', '葫芦科植物，果肉白色清淡，常用于炖汤或制作冬瓜茶，寓意“清廉”与“清凉”。', 'Calabaza blanca (Benincasa hispida)\nExplicación: Vegetal de la familia Cucurbitaceae, con carne blanca y sabor suave. Usado en sopas o té frío, simboliza pureza y frescura.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('干贝丝', '干贝（扇贝柱）切成的细丝，用于提鲜，常见于吊汤或凉拌菜，属高档海味食材。', 'Hilo de vieira seca\nExplicación: Vieira deshidratada cortada en hebras finas, utilizada como condimento para realzar sabores en sopas o ensaladas.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('金华火腿', '浙江金华特产，以猪后腿经盐腌、发酵制成，色泽红润，香气浓郁，用于炖汤或蒸制。', 'Jamón de Jinhua\nExplicación: Producto de Zhejiang elaborado con pata trasera de cerdo, curada con sal y fermentada. De color rojo brillante y aroma intenso, usado en estofados o al vapor.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('吊汤', '中式烹饪技法，通过长时间熬煮鸡、骨等食材，提取鲜味制成清汤，是烹饪高级菜肴的基础。', 'Caldo concentrado\nExplicación: Técnica culinaria china donde pollo, huesos y otros ingredientes se hierven prolongadamente para extraer sabores, formando una base esencial para platos refinados.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('果木烤鸭', '北京烤鸭传统工艺，以枣木、梨木等果木明火烤制，果香渗透鸭皮，形成酥脆外皮与多汁肉质。', 'Pato asado con leña de frutales\nExplicación: Método tradicional de asar pato en Beijing usando leña de azufaifo o peral. El aroma de frutas penetra la piel, creando una textura crujiente y carne jugosa.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('薄如蝉翼', '形容刀工极致，如烤鸭片皮薄可透光，展现厨师精湛技艺，源自《诗经》比喻。', 'Delgado como alas de cigarra\nExplicación: Describe habilidad culinaria extrema, como rebanar piel de pato tan fina que deja pasar la luz. Originado en el Libro de los Cantos como metáfora de delicadeza.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('片鸭技术', '烤鸭制作关键步骤，厨师将整鸭片成108片薄片，每片连皮带肉，确保口感均衡。', 'Técnica de rebanado de pato\nExplicación: Paso crucial en la preparación del pato asado: el chef rebanar el ave en 108 láminas delgadas, cada una con piel y carne, para equilibrar texturas.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('甜面酱', '发酵豆酱，甜中带咸，用于烤鸭蘸料或炸酱面，北京传统调味品。', 'Salsa dulce de pasta de soja\nExplicación: Pasta de soja fermentada con sabor dulce y salado, utilizada como aderezo para pato asado o fideos con salsa.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('葱丝', '京葱切成的细丝，与黄瓜条、甜面酱一同卷入荷叶饼，中和烤鸭油腻感。', 'Juliana de cebolla larga\nExplicación: Cebolla larga cortada en tiras finas, servida con pepino y salsa dulce en tortitas de loto para equilibrar la grasa del pato.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('黄瓜条', '黄瓜去瓤切成长条，清爽解腻，与烤鸭搭配食用，增加口感层次。', 'Tiras de pepino\nExplicación: Pepino descarozado y cortado en tiras largas, refrescante y ligero, complementa la riqueza del pato asado.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('宫阙', '古代帝王宫殿，如故宫，象征皇权与礼制，北京中轴线核心建筑群。', 'Palacio imperial\nExplicación: Complejo arquitectónico de la antigua corte imperial, como la Ciudad Prohibida. Simboliza autoridad real y orden ritual, núcleo del eje central de Beijing.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('和牛', '日本培育的高档肉牛品种，以大理石纹脂肪著称，中国引进后形成本土化养殖体系。', 'Wagyu\nExplicación: Raza de ganado vacuno premium desarrollada en Japón, conocida por su grasa marmoleada. Cultivada ahora en China con estándares locales.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('土豆泥', '马铃薯蒸熟捣成泥状，常加奶油、黄油调味，西餐基础配菜，中餐融合创新菜品。', 'Puré de papa\nExplicación: Papa cocida al vapor y triturada en pasta, a menudo condimentada con crema y mantequilla. Plato básico en la cocina occidental, adaptado en innovaciones culinarias chinas.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('糖塑', '传统糖艺，将熬化的麦芽糖塑造成花鸟鱼虫等造型，用于节日装饰或宴会摆盘。', 'Escultura de azúcar\nExplicación: Arte tradicional donde malta calentada se moldea en figuras de flores, pájaros o insectos, utilizada en decoraciones festivas o presentaciones de banquetes.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('干冰', '固态二氧化碳，用于餐饮中制造烟雾效果，提升菜品视觉呈现，需注意安全使用。', 'Hielo seco\nExplicación: Dióxido de carbono sólido, utilizado en gastronomía para crear efectos de niebla y mejorar la presentación visual. Requiere precaución por su baja temperatura.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('芦笋', '春季时蔬，茎嫩可食，富含维生素与膳食纤维，常用于清炒或搭配海鲜。', 'Espárrago\nExplicación: Vegetal de primavera con tallos tiernos, rico en vitaminas y fibra. Se saltea o combina con mariscos.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('口蘑', '内蒙古草原野生蘑菇，菌盖小而厚，香气浓郁，适合炖汤或与肉类同炒。', 'Champiñón de montaña\nExplicación: Hongo silvestre de las praderas de Mongolia Interior, de tapa pequeña y gruesa. Ideal para estofados o salteados con carne.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('锅气', '中式烹饪术语，指食材在高温快炒中产生的独特焦香，体现“镬气”火候掌控。', 'Aroma de wok\nExplicación: Término culinario chino que describe el aroma tostado único obtenido al saltear ingredientes a alta temperatura, refleja dominio del fuego en la cocina.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('时蔬', '当季新鲜蔬菜，强调自然时令与营养，如春季荠菜、夏季冬瓜、秋季菠菜。', 'Verduras de temporada\nExplicación: Vegetales frescos cosechados en su temporada natural, enfatizando sabor y nutrientes. Ejemplos: hierba de cerdo en primavera, calabaza blanca en verano.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('豌豆黄', '北京传统点心，豌豆煮烂后加糖凝固成块，色泽浅黄，口感细腻，夏季消暑佳品。', 'Pastel de guisante amarillo\nExplicación: Postre tradicional de Beijing hecho de guisantes cocidos con azúcar, de color amarillo pálido y textura suave. Refrescante en verano.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('靠山', '比喻可依赖的支持力量，源自风水术语“背有靠山”，象征稳固与保护。', 'Apoyo sólido (metáfora)\nExplicación: Metáfora de una fuerza de apoyo confiable, originada en el término de feng shui "tener una montaña como respaldo", simboliza estabilidad y protección.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('大兴西瓜', '北京大兴区特产西瓜，沙瓤甜脆，因地理位置与土壤条件形成独特品质，夏季消暑水果。', 'Sandía de Daxing\nExplicación: Sandía característica del distrito Daxing de Beijing, con carne dulce y crujiente. Su calidad única proviene de condiciones geográficas y de suelo.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('北京茉莉花茶', '福州茉莉花茶工艺改良，以绿茶为底窨制茉莉花，香气鲜灵持久，北京人传统饮品。', 'Té de jazmín de Beijing\nExplicación: Versión mejorada del té de Fuzhou, elaborado con té verde y jazmín mediante técnicas de reposo. Aroma fresco y persistente, bebida tradicional en Beijing.', subtitleStyle, zhStyle, esStyle),
          SizedBox(height: 24),
          Text('北京中轴线相关纪念品相关术语', style: titleStyle),
          _buildTerm('纪念章邮票', '为纪念事件或人物发行的邮票，常附纪念章，兼具邮政功能与收藏价值。', 'Sello con medalla conmemorativa\nExplicación: Sello postal emitido para conmemorar eventos o figuras, a menudo incluyendo una medalla. Combina función postal con valor de colección.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('纪念徽章', '金属或珐琅制成的徽章，用于标识身份或纪念活动，如奥运会、文化展览等。', 'Insignia conmemorativa\nExplicación: Placa de metal o esmalte utilizada para identificar membresía o conmemorar eventos (por ejemplo, Juegos Olímpicos, exposiciones culturales).', subtitleStyle, zhStyle, esStyle),
          _buildTerm('五一劳动奖章', '中国国家级荣誉，由中华全国总工会颁发，授予在劳动中作出突出贡献的职工，象征劳模精神。', 'Medalla del Día del Trabajo del 1 de Mayo\nExplicación: Honor nacional de China otorgado por la Federación General de Sindicatos de China. Se concede a trabajadores destacados por sus contribuciones laborales, simbolizando el espíritu de los trabajadores modelo.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('明十三陵凤冠', '明代皇后礼冠，出土于定陵，以金丝编织框架，点翠工艺装饰，象征皇权尊贵，现存四顶于北京。', 'Tiara de la Tumba de los Trece Emperadores Ming\nExplicación: Tiara ceremonial de las emperatrices Ming, excavada en la Tumba Dingling. Estructura de hilo de oro y decoración con técnica de punto de jade, simbolizando la nobleza imperial. Cuatro ejemplares se conservan en Beijing.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('藻井', '中国古代建筑顶部装饰结构，呈穹窿状，以木构雕饰或彩绘，兼具防火寓意与美学价值。', 'Cúpula de aljibe\nExplicación: Estructura decorativa en el techo de la arquitectura china antigua, con forma de cúpula. Realizada en madera tallada o pintada, combinaba simbolismo contra incendios (mediante motivos acuáticos) con valor estético.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('金丝', '极细的金质丝线，直径小于1毫米，用于传统工艺或电子封装，体现黄金延展性与工艺精湛。', 'Hilo de oro\nExplicación: Filamento de oro con diámetro inferior a 1 mm, utilizado en artesanía tradicional o encapsulado electrónico. Refleja la maleabilidad del oro y la habilidad artesanal.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('冰箱贴', '磁性装饰品，贴于冰箱表面，常印有文化图案或旅游纪念，兼具实用记录与装饰功能。', 'Imán de nevera\nExplicación: Adorno magnético adherido a la superficie de refrigeradores, a menudo con diseños culturales o recuerdos de viaje. Combina funcionalidad (notas, recordatorios) con valor decorativo.', subtitleStyle, zhStyle, esStyle),
          _buildTerm('点翠工艺', '传统金银首饰工艺，以翠鸟羽毛镶嵌于金属底座，色彩艳丽且永不褪色，现为非遗保护项目。', 'Técnica de punto de jade\nExplicación: Técnica tradicional china para joyería de oro y plata, donde plumas de pájaros azules se incrustan en bases metálicas. Colores vibrantes e inalterables con el tiempo. Actualmente protegida como patrimonio cultural intangible.', subtitleStyle, zhStyle, esStyle),
        ],
      ),
    );
  }

  Widget _buildVerse(String title, String zh, String es, TextStyle subtitleStyle, TextStyle zhStyle, TextStyle esStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: subtitleStyle),
          SizedBox(height: 6),
          Text(zh, style: zhStyle),
          SizedBox(height: 4),
          Text(es, style: esStyle),
        ],
      ),
    );
  }

  Widget _buildTerm(String term, String zh, String es, TextStyle subtitleStyle, TextStyle zhStyle, TextStyle esStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(term, style: subtitleStyle),
          SizedBox(height: 4),
          Text(zh, style: zhStyle),
          SizedBox(height: 2),
          Text(es, style: esStyle),
        ],
      ),
    );
  }
} 