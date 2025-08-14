import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAuthenticated => _currentUser != null;
  String? get token => _token;
  
  // 角色相关便捷方法
  bool get isTourist => _currentUser?.isTourist ?? false;
  bool get isGuide => _currentUser?.isGuide ?? false;
  UserRole? get userRole => _currentUser?.role;

  // 初始化时检查登录状态
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登录
  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(username, password, rememberMe: rememberMe);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 注册 - 支持指定角色
  Future<bool> register(String username, String email, String password, {UserRole role = UserRole.tourist}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(username, email, password, role: role);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登出
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新用户信息
  Future<void> updateUser(User user) async {
    try {
      await _authService.updateUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 切换用户角色（仅用于测试）
  void switchRole(UserRole newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      notifyListeners();
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 