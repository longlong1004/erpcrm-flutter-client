import '../models/business/business.dart';
import '../utils/http_client.dart';
import './network_service.dart';
import './local_storage_service.dart';
import './sync_service.dart';
import '../models/sync/sync_operation.dart';

class BusinessService {
  final NetworkService _networkService;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;

  BusinessService() : 
    _networkService = NetworkService(),
    _localStorageService = LocalStorageService(),
    _syncService = SyncService();

  BusinessService.withDependencies({
    NetworkService? networkService,
    LocalStorageService? localStorageService,
    SyncService? syncService,
  }) : 
    _networkService = networkService ?? NetworkService(),
    _localStorageService = localStorageService ?? LocalStorageService(),
    _syncService = syncService ?? SyncService();

  // 业务相关API - 离线优先策略
  Future<List<Business>> getBusinesses({Map<String, dynamic>? params}) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/businesses', queryParameters: params);
        final businessesJson = response.data['data'] as List;
        final businesses = businessesJson.map((json) => Business.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveBusinesses(businesses);
        return businesses;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getBusinesses();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getBusinesses();
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<Business> getBusinessById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/businesses/$id');
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：从本地存储获取数据
        final business = await _localStorageService.getBusinessById(id);
        if (business == null) {
          throw Exception('业务不存在');
        }
        return business;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final business = await _localStorageService.getBusinessById(id);
        if (business == null) {
          throw Exception('业务不存在');
        }
        return business;
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<Business> createBusiness(Map<String, dynamic> businessData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/businesses', data: businessData);
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的业务
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final business = Business(
          id: tempId,
          name: businessData['name'],
          description: businessData['description'],
          businessType: businessData['businessType'],
          status: businessData['status'],
          startDate: businessData['startDate'] != null ? DateTime.parse(businessData['startDate']) : null,
          endDate: businessData['endDate'] != null ? DateTime.parse(businessData['endDate']) : null,
          amount: businessData['amount'] != null ? double.parse(businessData['amount'].toString()) : null,
          customerId: businessData['customerId'],
          createdBy: businessData['createdBy'],
          updatedBy: businessData['updatedBy'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveBusinesses([business]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'business',
          data: businessData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return business;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Business> updateBusiness(int id, Map<String, dynamic> businessData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/businesses/$id', data: businessData);
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：从本地存储获取业务，更新后保存，添加到同步队列
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness == null) {
          throw Exception('业务不存在');
        }
        
        final updatedBusiness = Business(
          id: existingBusiness.id,
          name: businessData['name'] ?? existingBusiness.name,
          description: businessData['description'] ?? existingBusiness.description,
          businessType: businessData['businessType'] ?? existingBusiness.businessType,
          status: businessData['status'] ?? existingBusiness.status,
          startDate: businessData['startDate'] != null ? DateTime.parse(businessData['startDate']) : existingBusiness.startDate,
          endDate: businessData['endDate'] != null ? DateTime.parse(businessData['endDate']) : existingBusiness.endDate,
          amount: businessData['amount'] != null ? double.parse(businessData['amount'].toString()) : existingBusiness.amount,
          customerId: businessData['customerId'] ?? existingBusiness.customerId,
          createdBy: existingBusiness.createdBy,
          updatedBy: businessData['updatedBy'] ?? existingBusiness.updatedBy,
          createdAt: existingBusiness.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveBusinesses([updatedBusiness]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'business',
          data: {...businessData, 'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedBusiness;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteBusiness(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/businesses/$id');
        
        // 更新本地存储
        await _localStorageService.deleteBusiness(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteBusiness(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'business',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteBusiness(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'business',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<void> softDeleteBusiness(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/businesses/soft/$id');
        
        // 更新本地存储（软删除可以通过状态更新实现）
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness != null) {
          final updatedBusiness = Business(
            id: existingBusiness.id,
            name: existingBusiness.name,
            description: existingBusiness.description,
            businessType: existingBusiness.businessType,
            status: 'deleted', // 假设软删除通过状态标记
            startDate: existingBusiness.startDate,
            endDate: existingBusiness.endDate,
            amount: existingBusiness.amount,
            customerId: existingBusiness.customerId,
            createdBy: existingBusiness.createdBy,
            updatedBy: existingBusiness.updatedBy,
            createdAt: existingBusiness.createdAt,
            updatedAt: DateTime.now(),
          );
          await _localStorageService.saveBusinesses([updatedBusiness]);
        }
      } else {
        // 离线：更新本地存储，添加到同步队列
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness != null) {
          final updatedBusiness = Business(
            id: existingBusiness.id,
            name: existingBusiness.name,
            description: existingBusiness.description,
            businessType: existingBusiness.businessType,
            status: 'deleted', // 假设软删除通过状态标记
            startDate: existingBusiness.startDate,
            endDate: existingBusiness.endDate,
            amount: existingBusiness.amount,
            customerId: existingBusiness.customerId,
            createdBy: existingBusiness.createdBy,
            updatedBy: existingBusiness.updatedBy,
            createdAt: existingBusiness.createdAt,
            updatedAt: DateTime.now(),
          );
          await _localStorageService.saveBusinesses([updatedBusiness]);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.update,
            dataType: 'business',
            data: {'id': id, 'status': 'deleted'},
            timestamp: DateTime.now(),
            tempId: id,
          );
          await _syncService.addSyncOperation(syncOperation);
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Business> restoreBusiness(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/businesses/restore/$id');
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：更新本地存储，添加到同步队列
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness == null) {
          throw Exception('业务不存在');
        }
        
        final restoredBusiness = Business(
          id: existingBusiness.id,
          name: existingBusiness.name,
          description: existingBusiness.description,
          businessType: existingBusiness.businessType,
          status: 'active', // 假设恢复后状态为active
          startDate: existingBusiness.startDate,
          endDate: existingBusiness.endDate,
          amount: existingBusiness.amount,
          customerId: existingBusiness.customerId,
          createdBy: existingBusiness.createdBy,
          updatedBy: existingBusiness.updatedBy,
          createdAt: existingBusiness.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([restoredBusiness]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'business',
          data: {'id': id, 'status': 'active'},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return restoredBusiness;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Business>> searchBusinesses(String keyword, {Map<String, dynamic>? params}) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final queryParams = {
          'keyword': keyword,
          ...?params,
        };
        final response = await HttpClient.get('/businesses/search', queryParameters: queryParams);
        final businessesJson = response.data['data'] as List;
        final businesses = businessesJson.map((json) => Business.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveBusinesses(businesses);
        return businesses;
      } else {
        // 离线：从本地存储搜索
        final allBusinesses = await _localStorageService.getBusinesses();
        return allBusinesses.where((business) => 
          business.name.contains(keyword) ||
          (business.description?.contains(keyword) ?? false) ||
          business.businessType.contains(keyword)
        ).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储搜索
      try {
        final allBusinesses = await _localStorageService.getBusinesses();
        return allBusinesses.where((business) => 
          business.name.contains(keyword) ||
          (business.description?.contains(keyword) ?? false) ||
          business.businessType.contains(keyword)
        ).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<Business> activateBusiness(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/businesses/$id/activate');
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：更新本地存储，添加到同步队列
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness == null) {
          throw Exception('业务不存在');
        }
        
        final updatedBusiness = Business(
          id: existingBusiness.id,
          name: existingBusiness.name,
          description: existingBusiness.description,
          businessType: existingBusiness.businessType,
          status: 'active',
          startDate: existingBusiness.startDate,
          endDate: existingBusiness.endDate,
          amount: existingBusiness.amount,
          customerId: existingBusiness.customerId,
          createdBy: existingBusiness.createdBy,
          updatedBy: existingBusiness.updatedBy,
          createdAt: existingBusiness.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([updatedBusiness]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'business',
          data: {'id': id, 'status': 'active'},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedBusiness;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Business> deactivateBusiness(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/businesses/$id/deactivate');
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：更新本地存储，添加到同步队列
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness == null) {
          throw Exception('业务不存在');
        }
        
        final updatedBusiness = Business(
          id: existingBusiness.id,
          name: existingBusiness.name,
          description: existingBusiness.description,
          businessType: existingBusiness.businessType,
          status: 'inactive',
          startDate: existingBusiness.startDate,
          endDate: existingBusiness.endDate,
          amount: existingBusiness.amount,
          customerId: existingBusiness.customerId,
          createdBy: existingBusiness.createdBy,
          updatedBy: existingBusiness.updatedBy,
          createdAt: existingBusiness.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([updatedBusiness]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'business',
          data: {'id': id, 'status': 'inactive'},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedBusiness;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Business> completeBusiness(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/businesses/$id/complete');
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：更新本地存储，添加到同步队列
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness == null) {
          throw Exception('业务不存在');
        }
        
        final updatedBusiness = Business(
          id: existingBusiness.id,
          name: existingBusiness.name,
          description: existingBusiness.description,
          businessType: existingBusiness.businessType,
          status: 'completed',
          startDate: existingBusiness.startDate,
          endDate: DateTime.now(), // 假设完成时更新结束日期
          amount: existingBusiness.amount,
          customerId: existingBusiness.customerId,
          createdBy: existingBusiness.createdBy,
          updatedBy: existingBusiness.updatedBy,
          createdAt: existingBusiness.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([updatedBusiness]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'business',
          data: {'id': id, 'status': 'completed', 'endDate': DateTime.now().toIso8601String()},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedBusiness;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Business> cancelBusiness(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/businesses/$id/cancel');
        final business = Business.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([business]);
        return business;
      } else {
        // 离线：更新本地存储，添加到同步队列
        final existingBusiness = await _localStorageService.getBusinessById(id);
        if (existingBusiness == null) {
          throw Exception('业务不存在');
        }
        
        final updatedBusiness = Business(
          id: existingBusiness.id,
          name: existingBusiness.name,
          description: existingBusiness.description,
          businessType: existingBusiness.businessType,
          status: 'cancelled',
          startDate: existingBusiness.startDate,
          endDate: existingBusiness.endDate,
          amount: existingBusiness.amount,
          customerId: existingBusiness.customerId,
          createdBy: existingBusiness.createdBy,
          updatedBy: existingBusiness.updatedBy,
          createdAt: existingBusiness.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 更新本地存储
        await _localStorageService.saveBusinesses([updatedBusiness]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'business',
          data: {'id': id, 'status': 'cancelled'},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedBusiness;
      }
    } catch (error) {
      rethrow;
    }
  }
}