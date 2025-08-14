import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/spot_detail_screen.dart';
import 'screens/search_screen.dart';
import 'screens/survey_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/handbook_screen.dart';
import 'screens/translation_screen.dart';
import 'screens/map_screen.dart';
import 'screens/photo_wall_screen.dart';
import 'screens/photo_management_screen.dart';
import 'screens/video_screen.dart';
import 'screens/animation_screen.dart';
import 'screens/culture_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/voice_screen.dart';
import 'screens/ai_assistant_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 初始化认证状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '北京中轴线中秘文明互鉴',
      debugShowCheckedModeBanner: false,

      // 性能优化配置
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // 固定文本缩放，避免布局重计算
          ),
          child: child!,
        );
      },

      // 页面切换动画优化的主题
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),

      // 国际化支持
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: Provider.of<LocaleProvider>(context).locale == AppLocale.zh
          ? const Locale('zh', 'CN')
          : const Locale('en', 'US'),

      // 路由管理 - 使用生成器模式优化性能
      initialRoute: '/',
      onGenerateRoute: _generateRoute,

      // 备用路由配置
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/spot_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final spotId = args is Map<String, dynamic> ? args['spotId'] ?? '' : '';
          return SpotDetailScreen(spotId: spotId);
        },
        '/search': (context) => const SearchScreen(),
        '/survey': (context) => const SurveyScreen(),
        '/itinerary': (context) => const ItineraryScreen(),
        '/handbook': (context) => const HandbookScreen(),
        '/translation': (context) => const TranslationScreen(),
        '/voice': (context) => const VoiceScreen(),
        '/ai_assistant': (context) => const AIAssistantScreen(),
        '/map': (context) => const MapScreen(),
        '/photo': (context) => const PhotoWallScreen(),
        '/photo_management': (context) => PhotoManagementScreen(),
        '/video': (context) => const VideoScreen(),
        '/animation': (context) => const AnimationScreen(),
        '/culture': (context) => const CultureScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },
    );
  }

  // 优化的路由生成器
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // 使用自定义页面切换动画
    Widget page;

    switch (settings.name) {
      case '/search':
        page = const SearchScreen();
        break;
      case '/survey':
        page = const SurveyScreen();
        break;
      case '/itinerary':
        page = const ItineraryScreen();
        break;
      case '/handbook':
        page = const HandbookScreen();
        break;
      case '/translation':
        page = const TranslationScreen();
        break;
      case '/voice':
        page = const VoiceScreen();
        break;
      case '/ai_assistant':
        page = const AIAssistantScreen();
        break;
      case '/map':
        page = const MapScreen();
        break;
      case '/photo':
        page = const PhotoWallScreen();
        break;
      case '/photo_management':
        page = PhotoManagementScreen();
        break;
      case '/video':
        page = const VideoScreen();
        break;
      case '/animation':
        page = const AnimationScreen();
        break;
      case '/culture':
        page = const CultureScreen();
        break;
      case '/feedback':
        page = const FeedbackScreen();
        break;
      case '/spot_detail':
        final args = settings.arguments;
        final spotId = args is Map<String, dynamic> ? args['spotId'] ?? '' : '';
        page = SpotDetailScreen(spotId: spotId);
        break;
      default:
        return null;
    }

    // 使用优化的页面切换动画
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 250), // 减少动画时间
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用淡入淡出 + 轻微缩放的动画，性能更好
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }
        
        if (authProvider.isLoggedIn) {
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}