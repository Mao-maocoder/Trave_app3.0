class AppConfig {
  // 开发环境配置
  static const bool isDevelopment = true;
  
  // 后端服务器配置
  static const String defaultBackendHost = 'localhost';
  static const String defaultBackendPort = '3000';
  
  // ngrok 配置 - 请根据实际 ngrok URL 修改
  // 请将下面的 URL 替换为您的实际 ngrok URL
  static const String ngrokUrl = 'https://trave-app2-0.onrender.com'; // Render新URL
  
  // API配置
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // 文件上传配置
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  
  // 缓存配置
  static const int cacheExpirationHours = 24;
  
  // 调试配置
  static const bool enableDebugLogs = true;
  static const bool enableNetworkLogs = true;
  
  // 获取后端URL - 支持 ngrok 和本地开发
  static String get backendUrl {
    // 如果配置了 ngrok URL，优先使用
    if (ngrokUrl != 'https://your-ngrok-url.ngrok.io') {
      return ngrokUrl;
    }
    
    // 默认使用本地地址
    const host = String.fromEnvironment('BACKEND_HOST', defaultValue: defaultBackendHost);
    const port = String.fromEnvironment('BACKEND_PORT', defaultValue: defaultBackendPort);
    return 'http://$host:$port';
  }
  
  // 获取API基础URL
  static String get apiBaseUrl => '$backendUrl/api';
  
  // 获取上传URL
  static String get uploadUrl => '$backendUrl/uploads';
  
  // 获取静态资源URL
  static String get staticUrl => '$backendUrl/static';
} 