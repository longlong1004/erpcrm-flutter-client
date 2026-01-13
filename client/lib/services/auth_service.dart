import 'dart:async';

import '../models/auth/user.dart';
import '../utils/http_client.dart';
import '../utils/storage.dart';
import '../providers/auth_provider.dart';

class AuthService {
  final _authStateController = StreamController<AuthState?>.broadcast();
  final Function _httpClientGet;
  final Function _httpClientPost;
  final Function _httpClientPut;
  final Function _storageManagerSaveToken;
  final Function _storageManagerSaveUserInfo;
  final Function _storageManagerGetToken;
  final Function _storageManagerGetUserInfo;
  final Function _storageManagerClearAuthInfo;

  Stream<AuthState?> get authStateStream => _authStateController.stream;

  // 默认构造函数使用真实的方法
  AuthService({
    Function httpClientGet = HttpClient.get,
    Function httpClientPost = HttpClient.post,
    Function httpClientPut = HttpClient.put,
    Function storageManagerSaveToken = StorageManager.saveToken,
    Function storageManagerSaveUserInfo = StorageManager.saveUserInfo,
    Function storageManagerGetToken = StorageManager.getToken,
    Function storageManagerGetUserInfo = StorageManager.getUserInfo,
    Function storageManagerClearAuthInfo = StorageManager.clearAuthInfo,
  })  : _httpClientGet = httpClientGet,
        _httpClientPost = httpClientPost,
        _httpClientPut = httpClientPut,
        _storageManagerSaveToken = storageManagerSaveToken,
        _storageManagerSaveUserInfo = storageManagerSaveUserInfo,
        _storageManagerGetToken = storageManagerGetToken,
        _storageManagerGetUserInfo = storageManagerGetUserInfo,
        _storageManagerClearAuthInfo = storageManagerClearAuthInfo;

  Future<AuthState> login(String username, String password) async {
    try {
      final response = await _httpClientPost('/v1/auth/login', data: {
        'username': username,
        'password': password,
      });

      final authResponse = response.data['data'];
      final token = authResponse['accessToken'];
      final userJson = authResponse['user'];

      // 保存认证信息到本地存储
      await _storageManagerSaveToken(token);
      await _storageManagerSaveUserInfo(userJson);

      final user = User.fromJson(userJson);
      final authState = AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
      );

      _authStateController.add(authState);
      return authState;
    } catch (error) {
      rethrow;
    }
  }

  Future<AuthState> register(Map<String, dynamic> userData) async {
    try {
      final response = await _httpClientPost('/v1/auth/register', data: userData);
      
      // 注册成功后需要重新登录获取令牌
      return await login(userData['username'], userData['password']);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // 后端没有logout API，直接清理本地存储
    } finally {
      // 清除本地存储的认证信息
      await _storageManagerClearAuthInfo();

      final authState = AuthState(isAuthenticated: false);
      _authStateController.add(authState);
    }
  }

  Future<AuthState> refreshToken() async {
    try {
      final response = await _httpClientPost('/v1/auth/refresh');

      final authResponse = response.data['data'];
      final token = authResponse['accessToken'];
      final userJson = authResponse['user'];

      // 更新本地存储的认证信息
      await _storageManagerSaveToken(token);
      await _storageManagerSaveUserInfo(userJson);

      final user = User.fromJson(userJson);
      final authState = AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
      );

      _authStateController.add(authState);
      return authState;
    } catch (error) {
      // 刷新失败，清除本地存储
      await _storageManagerClearAuthInfo();
      final authState = AuthState(isAuthenticated: false);
      _authStateController.add(authState);
      rethrow;
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _httpClientPut('/v1/auth/profile', data: profileData);

      final userJson = response.data['data'];
      await _storageManagerSaveUserInfo(userJson);

      final user = User.fromJson(userJson);
      
      // 更新当前认证状态
      final currentState = await _getCurrentAuthState();
      if (currentState != null && currentState.isAuthenticated) {
        final updatedAuthState = currentState.copyWith(user: user);
        _authStateController.add(updatedAuthState);
      }

      return user;
    } catch (error) {
      rethrow;
    }
  }

  Future<AuthState?> _getCurrentAuthState() async {
    final token = await _storageManagerGetToken();
    final userJson = await _storageManagerGetUserInfo();

    if (token != null && userJson != null) {
      final user = User.fromJson(userJson);
      return AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
      );
    }

    return null;
  }

  void dispose() {
    _authStateController.close();
  }
}