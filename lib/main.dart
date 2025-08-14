import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'constants.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'models/user.dart';
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
import 'screens/guide_dashboard_screen.dart';
import 'screens/video_screen.dart';
import 'screens/animation_screen.dart';
import 'screens/culture_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/voice_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/performance_config.dart';
import 'screens/music_screen.dart';
import 'screens/terms_page.dart';
import 'screens/community_screen.dart';
import 'providers/chat_provider.dart';
import 'screens/tourist_management_screen.dart';
import 'screens/media_review_screen.dart';
import 'screens/review_management_screen.dart';
import 'screens/favorite_spots_screen.dart';
import 'screens/exhibitions_screen.dart';
import 'screens/xk_codebook_detail_page.dart';
import 'screens/settings_screen.dart';
import 'screens/browsing_history_screen.dart';
import 'screens/profile_edit_screen.dart';

void main() {
  // 性能优化配置
  PerformanceConfig.adjustForDevicePerformance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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

  // 根据 AppLocale 获取对应的 Locale
  Locale _getLocaleFromProvider(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.zh:
        return const Locale('zh', 'CN');
      case AppLocale.en:
        return const Locale('en', 'US');
      case AppLocale.es:
        return const Locale('es', 'ES');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '中轴奇遇',
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
        Locale('en'),
        Locale('zh'),
        Locale('es'),
      ],
      locale: _getLocaleFromProvider(Provider.of<LocaleProvider>(context).locale),

      // 路由管理 - 使用生成器模式优化性能
      initialRoute: '/',
      onGenerateRoute: _generateRoute,

      // 备用路由配置
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/spot_detail': (context) => const SpotDetailScreen(),
        '/guide_dashboard': (context) => const GuideDashboardScreen(),
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
        '/rewards': (context) => const RewardsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/bind_guide': (context) => Scaffold(appBar: AppBar(title: Text('绑定导游')), body: Center(child: Text('绑定导游功能待实现'))),
        '/music': (context) => MusicScreen(),
        '/terms': (context) => const TermsPage(),
        '/community': (context) => const CommunityScreen(),
        '/tourist-management': (context) => TouristManagementScreen(),
        '/media-review': (context) => const MediaReviewScreen(),
        '/review-management': (context) => const ReviewManagementScreen(),
        '/favorites': (context) => const FavoriteSpotsScreen(),
        '/exhibitions': (context) => const ExhibitionsScreen(),
        '/terminology': (context) => const XKCodebookDetailPage(),
        '/settings': (context) => const SettingsScreen(),
        '/browsing-history': (context) => const BrowsingHistoryScreen(),
        '/profile-edit': (context) => const ProfileEditScreen(),
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
      case '/photo':
        page = const PhotoWallScreen();
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
      case '/rewards':
        page = const RewardsScreen();
        break;
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/bind_guide':
        page = Scaffold(appBar: AppBar(title: Text('绑定导游')), body: Center(child: Text('绑定导游功能待实现')));
        break;
      case '/spot_detail':
        page = const SpotDetailScreen();
        break;
      case '/music':
        page = MusicScreen();
        break;
      case '/media-review':
        page = const MediaReviewScreen();
        break;
      case '/review-management':
        page = const ReviewManagementScreen();
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
          // 检查用户角色和问卷完成状态
          final user = authProvider.currentUser;
          if (user != null) {
            // 如果是导游账号，直接显示后台管理界面
            if (user.role == UserRole.guide) {
              return const ItineraryScreen(); // 导游界面
            }
            
            // 如果是游客账号，检查是否完成问卷
            if (user.hasCompletedSurvey == false) {
              return const SurveyScreen(); // 显示问卷
            }
          }
          
          return const HomeScreen(); // 显示主界面
        }
        
        return const LoginScreen();
      },
    );
  }
}