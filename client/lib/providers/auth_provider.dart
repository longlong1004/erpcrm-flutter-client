import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/auth/user.dart';
import 'package:erpcrm_client/models/auth/employee.dart';
import 'package:erpcrm_client/services/api_service.dart';
import 'package:erpcrm_client/utils/storage.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? token;
  final bool isLoading;
  
  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.token,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? token,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService apiService;
  final Box userBox;
  
  AuthNotifier(this.apiService, this.userBox) : super(const AuthState(isAuthenticated: false)) {
    _loadSavedCredentials();
  }
  
  Future<void> _loadSavedCredentials() async {
    final token = await StorageManager.getToken();
    final userJson = userBox.get('user_data');
    
    if (token != null) {
      User? user;
      if (userJson != null) {
        try {
          user = User.fromJson(Map<String, dynamic>.from(userJson as Map));
        } catch (e) {
          user = null;
        }
      }
      
      state = AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
      );
    }
  }
  
  Future<bool> login(String username, String password) async {
    state = state.copyWith(
      isLoading: true,
    );
    
    try {
      final employeeBox = Hive.box('employee_box');
      final employeesJson = employeeBox.get('employees') as List?;
      
      if (employeesJson != null) {
        final employees = employeesJson.map((json) => Employee.fromJson(json as Map<String, dynamic>)).toList();
        late Employee? employee;
        try {
          employee = employees.firstWhere(
            (emp) => emp.username == username && emp.verifyPassword(password),
          );
        } catch (e) {
          employee = null;
        }
        
        if (employee != null) {
          const token = 'employee-jwt-token';
          
          final now = DateTime.now();
          final user = User(
            id: employee.id,
            username: employee.username,
            email: '$username@erpcrm.com',
            name: employee.name,
            phoneNumber: employee.phoneNumber,
            department: employee.department,
            position: employee.position,
            avatarUrl: '',
            enabled: true,
            roleNames: const <String>{'ROLE_USER'},
            lastLoginTime: now,
            createdAt: employee.createdAt,
            updatedAt: now,
          );
          
          await userBox.put('user_data', user.toJson());
          await StorageManager.saveToken(token);
          
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
            token: token,
            isLoading: false,
          );
          
          return true;
        }
      }
      
      const bool isTestEnvironment = true;
      if (isTestEnvironment && username == 'admin' && password == '123456') {
        const token = 'admin-jwt-token';
        
        final now = DateTime.now();
        final user = User(
          id: 1,
          username: 'admin',
          email: 'admin@erpcrm.com',
          name: '系统管理员（测试账号）',
          phoneNumber: '13800138000',
          department: '系统管理部',
          position: '系统管理员',
          avatarUrl: '',
          enabled: true,
          roleNames: const <String>{'ROLE_ADMIN'},
          lastLoginTime: now,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now,
        );
        
        await userBox.put('user_data', user.toJson());
        await StorageManager.saveToken(token);
        
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          token: token,
          isLoading: false,
        );
        
        return true;
      }
      
      try {
        final response = await apiService.login(username, password);
        
        final token = response['accessToken'] ?? response['token'];
        
        User? user;
        if (response.containsKey('user') && response['user'] != null) {
          try {
            user = User.fromJson(response['user'] as Map<String, dynamic>);
            await userBox.put('user_data', response['user']);
          } catch (e) {
            user = null;
          }
        }
        
        await StorageManager.saveToken(token);
        
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          token: token as String,
          isLoading: false,
        );
        
        return true;
      } catch (e) {
        throw Exception('登录失败，用户名或密码错误');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
      );
      rethrow;
    }
  }
  
  Future<bool> register(Map<String, dynamic> userData) async {
    // 使用copyWith方法更新状态，保留原有状态的其他属性
    state = state.copyWith(
      isLoading: true,
    );
    
    try {
      final response = await apiService.register(userData);
      
      // 使用copyWith方法更新状态，保留原有状态的其他属性
      state = state.copyWith(
        isLoading: false,
      );
      
      return response['success'] == true;
    } catch (e) {
      // 使用copyWith方法更新状态，保留原有状态的其他属性
      state = state.copyWith(
        isLoading: false,
      );
      return false;
    }
  }
  
  Future<void> logout() async {
    await userBox.delete('user_data');
    await StorageManager.deleteToken();
    
    state = const AuthState(isAuthenticated: false);
  }
  
  Future<bool> refreshToken() async {
    try {
      // 这里应该调用实际的刷新令牌API
      // 暂时返回false表示刷新失败
      return false;
    } catch (e) {
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final userBox = Hive.box('user_box');
  return AuthNotifier(apiService, userBox);
});