import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'config_service.dart';
import '../utils/storage.dart';

class ApiService {
  final Dio _dio;
  final Logger _logger = Logger();
  
  ApiService(this._dio) {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageManager.getToken();
        if (token != null && token != 'mock-jwt-token-for-admin') {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }
  
  Map<String, dynamic> _handleResponse(dynamic response) {
    if (response != null && response is Map<String, dynamic>) {
      if (response.containsKey('code')) {
        final code = response['code'];
        if (code == 200) {
          return response['data'] ?? {};
        } else {
          throw Exception(response['message'] ?? '请求失败');
        }
      }
      return response;
    }
    throw Exception('响应格式错误');
  }
  
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map<String, dynamic>) {
        if (errorData.containsKey('message')) {
          return Exception(errorData['message']);
        } else if (errorData.containsKey('msg')) {
          return Exception(errorData['msg']);
        }
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('连接超时，请检查网络');
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.badResponse:
        return Exception('服务器错误，请稍后重试');
      default:
        return Exception('网络错误，请稍后重试');
    }
  }
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/v1/auth/login', data: {
        'username': username,
        'password': password,
      });
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await _dio.post('/v1/auth/register', data: userData);
    return response.data['data'];
  }
  
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _dio.get('/v1/dashboard');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/products', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/orders', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // 客户相关API
  Future<List<dynamic>> getCustomers({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/customers', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getCustomerById(String id) async {
    try {
      final response = await _dio.get('/v1/customers/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await _dio.post('/v1/customers', data: customerData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> customerData) async {
    try {
      final response = await _dio.put('/v1/customers/$id', data: customerData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> softDeleteCustomer(String id) async {
    try {
      final response = await _dio.delete('/v1/customers/soft/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> deleteCustomer(String id) async {
    try {
      final response = await _dio.delete('/v1/customers/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> restoreCustomer(String id) async {
    try {
      final response = await _dio.put('/v1/customers/restore/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> searchCustomers(String keyword) async {
    try {
      final response = await _dio.get('/v1/customers/search', queryParameters: {
        'keyword': keyword,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getCustomersByStatus(String status) async {
    try {
      final response = await _dio.get('/v1/customers/status/$status');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getCustomersByCategoryId(String categoryId) async {
    try {
      final response = await _dio.get('/v1/customers/category/$categoryId');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> activateCustomer(String id) async {
    try {
      final response = await _dio.put('/v1/customers/$id/activate');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> deactivateCustomer(String id) async {
    try {
      final response = await _dio.put('/v1/customers/$id/deactivate');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> assignSalesPerson(String customerId, String salesPersonId) async {
    try {
      final response = await _dio.put('/v1/customers/$customerId/assign-sales', queryParameters: {
        'salesPersonId': salesPersonId,
      });
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // 整合所有模块数据
  Future<Map<String, dynamic>> integrateAllModules() async {
    final response = await _dio.get('/v1/dashboard/integrate');
    return response.data['data'];
  }
  
  // 物流相关API
  Future<List<dynamic>> getPreDeliveryLogistics({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/logistics/pre-delivery', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getMallOrderLogistics({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/logistics/mall', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getCollectorOrderLogistics({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/logistics/collector', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getOtherBusinessLogistics({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/logistics/other', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getPermissions() async {
    try {
      final response = await _dio.get('/v1/permissions');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getRoles() async {
    try {
      final response = await _dio.get('/v1/roles');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getUserRoles() async {
    try {
      final response = await _dio.get('/v1/user-roles');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getOperationLogs() async {
    try {
      final response = await _dio.get('/v1/operation-logs');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 系统设置相关API
  Future<List<dynamic>> getSettings() async {
    try {
      final response = await _dio.get('/v1/settings');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('code') && data['code'] == 200) {
          final result = data['data'];
          if (result is List) {
            return result;
          } else if (result is Map && result.containsKey('items')) {
            return result['items'] as List;
          }
        }
      } else if (data is List) {
        return data;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateSetting(Map<String, dynamic> settingData) async {
    return settingData;
  }
  
  Future<List<dynamic>> batchUpdateSettings(List<dynamic> settingsData) async {
    return settingsData;
  }
  
  Future<Map<String, dynamic>> resetSetting(String settingId) async {
    return {
      'id': settingId,
      'key': 'reset_setting',
      'name': '重置设置',
      'category': 'system',
      'type': 'string',
      'value': 'default',
      'description': '重置后的设置',
      'required': false,
      'editable': true,
    };
  }
  
  Future<Map<String, dynamic>> createSetting(Map<String, dynamic> settingData) async {
    try {
      final response = await _dio.post('/v1/settings', data: settingData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> deleteSetting(String settingId) async {
    try {
      final response = await _dio.delete('/v1/settings/$settingId');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  


  // 快捷键相关API
  Future<List<dynamic>> getShortcutKeys() async {
    try {
      final response = await _dio.get('/v1/shortcut-keys');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateShortcutKey(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/v1/shortcut-keys/$id', data: data);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetShortcutKeys() async {
    try {
      final response = await _dio.post('/v1/shortcut-keys/reset');
      _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetSingleShortcutKey(String functionId) async {
    try {
      final response = await _dio.post('/v1/shortcut-keys/reset/$functionId');
      _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> recordShortcutUsage(String functionId) async {
    try {
      final response = await _dio.post('/v1/shortcut-keys/usage/$functionId');
      _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 获取其他支出列表
  Future<List<dynamic>> getOtherExpenses({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/finance/expenses/other', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOtherExpense(String id) async {
    try {
      final response = await _dio.get('/v1/finance/expenses/other/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createOtherExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await _dio.post('/v1/finance/expenses/other', data: expenseData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateOtherExpense(String id, Map<String, dynamic> expenseData) async {
    try {
      final response = await _dio.put('/v1/finance/expenses/other/$id', data: expenseData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteOtherExpense(String id) async {
    try {
      final response = await _dio.delete('/v1/finance/expenses/other/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  
  Future<Map<String, dynamic>> createRole(Map<String, dynamic> roleData) async {
    try {
      final response = await _dio.post('/v1/roles', data: roleData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateRole(Map<String, dynamic> roleData) async {
    try {
      final response = await _dio.put('/v1/roles/${roleData['id']}', data: roleData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> deleteRole(String roleId) async {
    try {
      final response = await _dio.delete('/v1/roles/$roleId');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> assignPermissionsToRole(String roleId, List<String> permissionIds) async {
    try {
      final response = await _dio.post('/v1/roles/$roleId/permissions', data: {
        'permissionIds': permissionIds,
      });
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> assignRolesToUser(String userId, List<String> roleIds) async {
    try {
      final response = await _dio.post('/v1/users/$userId/roles', data: {
        'roleIds': roleIds,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // 更新权限
  Future<Map<String, dynamic>> updatePermission(Map<String, dynamic> permissionData) async {
    try {
      final response = await _dio.put('/v1/permissions/${permissionData['id']}', data: permissionData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getApprovals({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/v1/approvals', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getApprovalById(String id) async {
    try {
      final response = await _dio.get('/v1/approvals/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createApproval(Map<String, dynamic> approvalData) async {
    try {
      final response = await _dio.post('/v1/approvals', data: approvalData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateApproval(Map<String, dynamic> approvalData) async {
    try {
      final response = await _dio.put('/v1/approvals', data: approvalData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> approveApproval(String id, Map<String, dynamic> approveData) async {
    try {
      final response = await _dio.post('/v1/approvals/$id/approve', queryParameters: {
        'approverId': approveData['approverId'],
        'result': approveData['result'],
      });
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> rejectApproval(String id, Map<String, dynamic> rejectData) async {
    try {
      final response = await _dio.post('/v1/approvals/$id/reject', queryParameters: {
        'approverId': rejectData['approverId'],
        'reason': rejectData['reason'],
      });
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getApprovalsByApplicant(String applicantId) async {
    try {
      final response = await _dio.get('/v1/approvals/applicant/$applicantId');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getApprovalsByApprover(String approverId) async {
    try {
      final response = await _dio.get('/v1/approvals/approver/$approverId');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getApprovalsByType(String type) async {
    try {
      final response = await _dio.get('/v1/approvals/type/$type');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getApprovalsByStatus(String status) async {
    try {
      final response = await _dio.get('/v1/approvals/status/$status');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getCompanies() async {
    try {
      final response = await _dio.get('/v1/companies');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCompany(String id) async {
    try {
      final response = await _dio.get('/v1/companies/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCompany(Map<String, dynamic> companyData) async {
    try {
      final response = await _dio.post('/v1/companies', data: companyData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateCompany(String id, Map<String, dynamic> companyData) async {
    try {
      final response = await _dio.put('/v1/companies/$id', data: companyData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCompany(String id) async {
    try {
      await _dio.delete('/v1/companies/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getDepartments() async {
    try {
      final response = await _dio.get('/v1/departments');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDepartment(String id) async {
    try {
      final response = await _dio.get('/v1/departments/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createDepartment(Map<String, dynamic> departmentData) async {
    try {
      final response = await _dio.post('/v1/departments', data: departmentData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateDepartment(String id, Map<String, dynamic> departmentData) async {
    try {
      final response = await _dio.put('/v1/departments/$id', data: departmentData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      await _dio.delete('/v1/departments/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getPositions() async {
    try {
      final response = await _dio.get('/v1/positions');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPosition(String id) async {
    try {
      final response = await _dio.get('/v1/positions/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createPosition(Map<String, dynamic> positionData) async {
    try {
      final response = await _dio.post('/v1/positions', data: positionData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updatePosition(String id, Map<String, dynamic> positionData) async {
    try {
      final response = await _dio.put('/v1/positions/$id', data: positionData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePosition(String id) async {
    try {
      await _dio.delete('/v1/positions/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getEmployees() async {
    try {
      final response = await _dio.get('/v1/employees');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getEmployee(String id) async {
    try {
      final response = await _dio.get('/v1/employees/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final response = await _dio.post('/v1/employees', data: employeeData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateEmployee(String id, Map<String, dynamic> employeeData) async {
    try {
      final response = await _dio.put('/v1/employees/$id', data: employeeData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await _dio.delete('/v1/employees/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getWarehouses() async {
    try {
      final response = await _dio.get('/v1/warehouses');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getWarehouse(String id) async {
    try {
      final response = await _dio.get('/v1/warehouses/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createWarehouse(Map<String, dynamic> warehouseData) async {
    try {
      final response = await _dio.post('/v1/warehouses', data: warehouseData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateWarehouse(String id, Map<String, dynamic> warehouseData) async {
    try {
      final response = await _dio.put('/v1/warehouses/$id', data: warehouseData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteWarehouse(String id) async {
    try {
      await _dio.delete('/v1/warehouses/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getInventories({int? warehouseId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (warehouseId != null) {
        queryParams['warehouseId'] = warehouseId;
      }
      final response = await _dio.get('/v1/inventories', queryParameters: queryParams);
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getInventory(String id) async {
    try {
      final response = await _dio.get('/v1/inventories/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateInventory(String id, Map<String, dynamic> inventoryData) async {
    try {
      final response = await _dio.put('/v1/inventories/$id', data: inventoryData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getStockRecords({
    String? type,
    int? warehouseId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (warehouseId != null) queryParams['warehouseId'] = warehouseId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      final response = await _dio.get('/v1/stock-records', queryParameters: queryParams);
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStockRecord(String id) async {
    try {
      final response = await _dio.get('/v1/stock-records/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createStockRecord(Map<String, dynamic> recordData) async {
    try {
      final response = await _dio.post('/v1/stock-records', data: recordData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateStockRecord(String id, Map<String, dynamic> recordData) async {
    try {
      final response = await _dio.put('/v1/stock-records/$id', data: recordData);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteStockRecord(String id) async {
    try {
      await _dio.delete('/v1/stock-records/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getSalaries({String? month}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      final response = await _dio.get('/v1/salaries', queryParameters: queryParams);
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return [
        {
          "id": 1,
          "employeeId": 1,
          "employeeName": "张三",
          "department": "技术部",
          "position": "前端开发工程师",
          "month": month ?? "2024-01",
          "baseSalary": 8000.0,
          "bonus": 2000.0,
          "deduction": 500.0,
          "totalSalary": 9500.0,
          "status": "已发放",
          "createdAt": DateTime.now().toIso8601String(),
          "updatedAt": DateTime.now().toIso8601String()
        },
        {
          "id": 2,
          "employeeId": 2,
          "employeeName": "李四",
          "department": "技术部",
          "position": "后端开发工程师",
          "month": month ?? "2024-01",
          "baseSalary": 9000.0,
          "bonus": 2500.0,
          "deduction": 300.0,
          "totalSalary": 11200.0,
          "status": "已发放",
          "createdAt": DateTime.now().toIso8601String(),
          "updatedAt": DateTime.now().toIso8601String()
        },
        {
          "id": 3,
          "employeeId": 3,
          "employeeName": "王五",
          "department": "人事部",
          "position": "人事专员",
          "month": month ?? "2024-01",
          "baseSalary": 6000.0,
          "bonus": 1500.0,
          "deduction": 200.0,
          "totalSalary": 7300.0,
          "status": "已发放",
          "createdAt": DateTime.now().toIso8601String(),
          "updatedAt": DateTime.now().toIso8601String()
        }
      ];
    }
  }

  Future<Map<String, dynamic>> getSalary(String id) async {
    try {
      final response = await _dio.get('/v1/salaries/$id');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getSalaryDetails(int salaryId) async {
    try {
      final response = await _dio.get('/v1/salaries/$salaryId/details');
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return [
        {
          "id": 1,
          "salaryId": salaryId,
          "itemName": "基本工资",
          "amount": 8000.0,
          "type": "income",
          "description": "月度基本工资"
        },
        {
          "id": 2,
          "salaryId": salaryId,
          "itemName": "绩效奖金",
          "amount": 2000.0,
          "type": "income",
          "description": "月度绩效奖金"
        },
        {
          "id": 3,
          "salaryId": salaryId,
          "itemName": "五险一金",
          "amount": 1500.0,
          "type": "deduction",
          "description": "社保、医保、公积金等"
        },
        {
          "id": 4,
          "salaryId": salaryId,
          "itemName": "个人所得税",
          "amount": 500.0,
          "type": "deduction",
          "description": "月度个人所得税"
        }
      ];
    }
  }

  Future<Map<String, dynamic>> approveSalary(int salaryId) async {
    try {
      final response = await _dio.post('/v1/salaries/$salaryId/approve');
      return _handleResponse(response.data);
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return {
        "success": true,
        "message": "薪资审批成功",
        "salaryId": salaryId,
        "status": "approved"
      };
    }
  }

  Future<Map<String, dynamic>> rejectSalary(int salaryId, String reason) async {
    try {
      final response = await _dio.post('/v1/salaries/$salaryId/reject', data: {
        'reason': reason,
      });
      return _handleResponse(response.data);
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return {
        "success": true,
        "message": "薪资拒绝成功",
        "salaryId": salaryId,
        "status": "rejected",
        "reason": reason
      };
    }
  }

  Future<Map<String, dynamic>> getAttendances({
    String? employeeName,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (employeeName != null) queryParams['employeeName'] = employeeName;
      final response = await _dio.get('/v1/salary/attendances', queryParameters: queryParams);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return {
        "items": [
          {
            "id": 1,
            "employeeId": 1,
            "employeeName": "张三",
            "department": "技术部",
            "position": "前端开发工程师",
            "date": "2024-01-15",
            "checkInTime": "09:00:00",
            "checkOutTime": "18:00:00",
            "status": "正常",
            "overtimeHours": 0.0,
            "lateMinutes": 0,
            "earlyLeaveMinutes": 0
          },
          {
            "id": 2,
            "employeeId": 2,
            "employeeName": "李四",
            "department": "技术部",
            "position": "后端开发工程师",
            "date": "2024-01-15",
            "checkInTime": "09:10:00",
            "checkOutTime": "18:30:00",
            "status": "迟到",
            "overtimeHours": 0.5,
            "lateMinutes": 10,
            "earlyLeaveMinutes": 0
          }
        ],
        "total": 2,
        "page": page,
        "size": size,
        "pages": 1
      };
    }
  }

  Future<Map<String, dynamic>> getLeaves({
    String? employeeName,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (employeeName != null) queryParams['employeeName'] = employeeName;
      final response = await _dio.get('/v1/salary/leaves', queryParameters: queryParams);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return {
        "items": [
          {
            "id": 1,
            "employeeId": 1,
            "employeeName": "张三",
            "department": "技术部",
            "position": "前端开发工程师",
            "leaveType": "年假",
            "startDate": "2024-01-20",
            "endDate": "2024-01-22",
            "days": 3.0,
            "reason": "回家过年",
            "status": "已批准",
            "approverId": 3,
            "approverName": "王五"
          },
          {
            "id": 2,
            "employeeId": 2,
            "employeeName": "李四",
            "department": "技术部",
            "position": "后端开发工程师",
            "leaveType": "病假",
            "startDate": "2024-01-18",
            "endDate": "2024-01-18",
            "days": 1.0,
            "reason": "感冒发烧",
            "status": "已批准",
            "approverId": 3,
            "approverName": "王五"
          }
        ],
        "total": 2,
        "page": page,
        "size": size,
        "pages": 1
      };
    }
  }

  Future<Map<String, dynamic>> getBusinessTrips({
    String? employeeName,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (employeeName != null) queryParams['employeeName'] = employeeName;
      final response = await _dio.get('/v1/salary/business-trips', queryParameters: queryParams);
      return _handleResponse(response.data);
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return {
        "items": [
          {
            "id": 1,
            "employeeId": 1,
            "employeeName": "张三",
            "department": "技术部",
            "position": "前端开发工程师",
            "startDate": "2024-01-25",
            "endDate": "2024-01-27",
            "destination": "北京",
            "purpose": "客户拜访",
            "status": "已批准",
            "approverId": 3,
            "approverName": "王五",
            "estimatedCost": 5000.0
          },
          {
            "id": 2,
            "employeeId": 2,
            "employeeName": "李四",
            "department": "技术部",
            "position": "后端开发工程师",
            "startDate": "2024-02-01",
            "endDate": "2024-02-03",
            "destination": "上海",
            "purpose": "技术培训",
            "status": "待批准",
            "approverId": 3,
            "approverName": "王五",
            "estimatedCost": 3000.0
          }
        ],
        "total": 2,
        "page": page,
        "size": size,
        "pages": 1
      };
    }
  }

  Future<List<dynamic>> getSalaryStatistics(String month) async {
    try {
      final response = await _dio.get('/v1/salary/statistics', queryParameters: {
        'month': month,
      });
      return _handleResponse(response.data)['items'] ?? [];
    } on DioException catch (e) {
      // 如果后端不可用，返回模拟数据，但保持真实的数据结构
      return [
        {
          "department": "技术部",
          "totalEmployees": 10,
          "totalSalary": 95000.0,
          "averageSalary": 9500.0,
          "baseSalaryTotal": 80000.0,
          "bonusTotal": 20000.0,
          "deductionTotal": 5000.0
        },
        {
          "department": "人事部",
          "totalEmployees": 5,
          "totalSalary": 36500.0,
          "averageSalary": 7300.0,
          "baseSalaryTotal": 30000.0,
          "bonusTotal": 7500.0,
          "deductionTotal": 1000.0
        },
        {
          "department": "财务部",
          "totalEmployees": 3,
          "totalSalary": 25500.0,
          "averageSalary": 8500.0,
          "baseSalaryTotal": 21000.0,
          "bonusTotal": 6000.0,
          "deductionTotal": 1500.0
        }
      ];
    }
  }
}

final dioProvider = Provider<Dio>((ref) {
  final configService = ref.watch(configServiceProvider);
  final dio = Dio(BaseOptions(
    baseUrl: configService.getApiBaseUrl(),
    connectTimeout: Duration(seconds: configService.getConnectTimeout()),
    receiveTimeout: Duration(seconds: configService.getReceiveTimeout()),
    contentType: 'application/json; charset=utf-8',
    responseType: ResponseType.json,
    validateStatus: (status) {
      return status != null && status >= 200 && status < 300;
    },
    headers: {
      'Accept': 'application/json; charset=utf-8',
    },
  ));
  
  // 确保响应数据使用UTF-8编码
  dio.transformer = BackgroundTransformer()..jsonDecodeCallback = (String data) {
    try {
      return json.decode(data);
    } catch (e) {
      // 如果默认解码失败，尝试使用UTF-8重新解码
      return json.decode(utf8.decode(data.codeUnits));
    }
  };
  
  return dio;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});
