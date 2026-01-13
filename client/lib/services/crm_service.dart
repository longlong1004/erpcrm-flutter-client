import '../models/crm/customer.dart';
import '../models/crm/customer_category.dart';
import '../models/crm/customer_tag.dart';
import '../models/crm/customer_contact_log.dart';
import '../models/crm/sales_opportunity.dart';
import '../models/crm/contact_record.dart';
import '../utils/http_client.dart';
import './network_service.dart';
import './local_storage_service.dart';
import './sync_service.dart';
import '../models/sync/sync_operation.dart';

class CrmService {
  final NetworkService _networkService;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;

  CrmService() : 
    _networkService = NetworkService(),
    _localStorageService = LocalStorageService(),
    _syncService = SyncService();

  CrmService.withDependencies({
    NetworkService? networkService,
    LocalStorageService? localStorageService,
    SyncService? syncService,
  }) : 
    _networkService = networkService ?? NetworkService(),
    _localStorageService = localStorageService ?? LocalStorageService(),
    _syncService = syncService ?? SyncService();

  // 客户分类相关API - 离线优先策略
  Future<List<CustomerCategory>> getCustomerCategories() async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customer-categories');
        final categoriesJson = response.data['data'] as List;
        final categories = categoriesJson.map((json) => CustomerCategory.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveCustomerCategories(categories);
        return categories;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getCustomerCategories();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getCustomerCategories();
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<CustomerCategory> getCustomerCategoryById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customer-categories/$id');
        final category = CustomerCategory.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveCustomerCategories([category]);
        return category;
      } else {
        // 离线：从本地存储获取数据
        final category = await _localStorageService.getCustomerCategoryById(id);
        if (category == null) {
          throw Exception('客户分类不存在');
        }
        return category;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final category = await _localStorageService.getCustomerCategoryById(id);
        if (category == null) {
          throw Exception('客户分类不存在');
        }
        return category;
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<CustomerCategory> createCustomerCategory(Map<String, dynamic> categoryData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/crm/customer-categories', data: categoryData);
        final category = CustomerCategory.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomerCategories([category]);
        return category;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的分类
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final category = CustomerCategory(
          categoryId: tempId,
          categoryName: categoryData['categoryName'],
          description: categoryData['description'],
          sortOrder: categoryData['sortOrder'],
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
          deleted: false,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomerCategories([category]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'customer-category',
          data: categoryData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return category;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<CustomerCategory> updateCustomerCategory(int id, Map<String, dynamic> categoryData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/crm/customer-categories/$id', data: categoryData);
        final category = CustomerCategory.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomerCategories([category]);
        return category;
      } else {
        // 离线：从本地存储获取分类，更新后保存，添加到同步队列
        final existingCategory = await _localStorageService.getCustomerCategoryById(id);
        if (existingCategory == null) {
          throw Exception('客户分类不存在');
        }
        
        final updatedCategory = CustomerCategory(
          categoryId: existingCategory.categoryId,
          categoryName: categoryData['categoryName'] ?? existingCategory.categoryName,
          description: categoryData['description'] ?? existingCategory.description,
          sortOrder: categoryData['sortOrder'] ?? existingCategory.sortOrder,
          createTime: existingCategory.createTime,
          updateTime: DateTime.now(),
          deleted: existingCategory.deleted,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomerCategories([updatedCategory]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'customer-category',
          data: {...categoryData, 'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedCategory;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCustomerCategory(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/crm/customer-categories/$id');
        
        // 更新本地存储
        await _localStorageService.deleteCustomerCategory(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteCustomerCategory(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer-category',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteCustomerCategory(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer-category',
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

  Future<List<CustomerCategory>> getCustomerCategoryTree() async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final response = await HttpClient.get('/crm/customer-categories/tree');
        final categoriesJson = response.data as List;
        return categoriesJson.map((json) => CustomerCategory.fromJson(json)).toList();
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getCustomerCategories();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getCustomerCategories();
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 客户标签相关API - 离线优先策略
  Future<List<CustomerTag>> getCustomerTags() async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customer-tags');
        final tagsJson = response.data['data'] as List;
        final tags = tagsJson.map((json) => CustomerTag.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveCustomerTags(tags);
        return tags;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getCustomerTags();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getCustomerTags();
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<CustomerTag> getCustomerTagById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customer-tags/$id');
        final tag = CustomerTag.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveCustomerTags([tag]);
        return tag;
      } else {
        // 离线：从本地存储获取数据
        final tag = await _localStorageService.getCustomerTagById(id);
        if (tag == null) {
          throw Exception('客户标签不存在');
        }
        return tag;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final tag = await _localStorageService.getCustomerTagById(id);
        if (tag == null) {
          throw Exception('客户标签不存在');
        }
        return tag;
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<CustomerTag> createCustomerTag(Map<String, dynamic> tagData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/crm/customer-tags', data: tagData);
        final tag = CustomerTag.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomerTags([tag]);
        return tag;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的标签
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final tag = CustomerTag(
          tagId: tempId,
          tagName: tagData['tagName'],
          tagCode: tagData['tagCode'],
          tagDesc: tagData['tagDesc'],
          status: tagData['status'],
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
          deleted: false,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomerTags([tag]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'customer-tag',
          data: tagData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return tag;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<CustomerTag> updateCustomerTag(int id, Map<String, dynamic> tagData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/crm/customer-tags/$id', data: tagData);
        final tag = CustomerTag.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomerTags([tag]);
        return tag;
      } else {
        // 离线：从本地存储获取标签，更新后保存，添加到同步队列
        final existingTag = await _localStorageService.getCustomerTagById(id);
        if (existingTag == null) {
          throw Exception('客户标签不存在');
        }
        
        final updatedTag = CustomerTag(
          tagId: existingTag.tagId,
          tagName: tagData['tagName'] ?? existingTag.tagName,
          tagCode: tagData['tagCode'] ?? existingTag.tagCode,
          tagDesc: tagData['tagDesc'] ?? existingTag.tagDesc,
          status: tagData['status'] ?? existingTag.status,
          createTime: existingTag.createTime,
          updateTime: DateTime.now(),
          deleted: existingTag.deleted,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomerTags([updatedTag]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'customer-tag',
          data: {...tagData, 'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedTag;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCustomerTag(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/crm/customer-tags/$id');
        
        // 更新本地存储
        await _localStorageService.deleteCustomerTag(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteCustomerTag(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer-tag',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteCustomerTag(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer-tag',
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

  Future<void> batchDeleteCustomerTags(List<int> ids) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/crm/customer-tags/batch', data: {'ids': ids});
        
        // 更新本地存储
        for (final id in ids) {
          await _localStorageService.deleteCustomerTag(id);
        }
      } else {
        // 离线：直接从本地存储删除，逐个添加到同步队列
        for (final id in ids) {
          await _localStorageService.deleteCustomerTag(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'customer-tag',
            data: {'id': id},
            timestamp: DateTime.now(),
            tempId: id,
          );
          await _syncService.addSyncOperation(syncOperation);
        }
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        for (final id in ids) {
          await _localStorageService.deleteCustomerTag(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'customer-tag',
            data: {'id': id},
            timestamp: DateTime.now(),
            tempId: id,
          );
          await _syncService.addSyncOperation(syncOperation);
        }
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 客户联系记录相关API - 离线优先策略
  Future<List<CustomerContactLog>> getCustomerContactLogs(int customerId) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customer-contact-logs', queryParameters: {'customerId': customerId});
        final logsJson = response.data['data'] as List;
        final logs = logsJson.map((json) => CustomerContactLog.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveCustomerContactLogs(logs);
        return logs;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getCustomerContactLogsByCustomerId(customerId);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getCustomerContactLogsByCustomerId(customerId);
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<CustomerContactLog> getCustomerContactLogById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customer-contact-logs/$id');
        final log = CustomerContactLog.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveCustomerContactLogs([log]);
        return log;
      } else {
        // 离线：从本地存储获取数据
        final log = await _localStorageService.getCustomerContactLogById(id);
        if (log == null) {
          throw Exception('客户联系记录不存在');
        }
        return log;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final log = await _localStorageService.getCustomerContactLogById(id);
        if (log == null) {
          throw Exception('客户联系记录不存在');
        }
        return log;
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<CustomerContactLog> createCustomerContactLog(Map<String, dynamic> logData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/crm/customer-contact-logs', data: logData);
        final log = CustomerContactLog.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomerContactLogs([log]);
        return log;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的记录
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final log = CustomerContactLog(
          contactLogId: tempId,
          customerId: logData['customerId'],
          customerName: logData['customerName'] ?? '',
          contactPerson: logData['contactPerson'] ?? '',
          contactWay: logData['contactType'] ?? '',
          contactContent: logData['contactContent'] ?? '',
          contactResult: logData['contactResult'] ?? '',
          contactTime: DateTime.parse(logData['contactTime']),
          planNextTime: logData['nextContactTime'] != null ? DateTime.parse(logData['nextContactTime']) : DateTime.now(),
          operatorId: logData['operatorId'] ?? 0,
          operatorName: logData['operatorName'] ?? '',
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
          deleted: false,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomerContactLogs([log]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'customer-contact-log',
          data: logData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return log;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<CustomerContactLog> updateCustomerContactLog(int id, Map<String, dynamic> logData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/crm/customer-contact-logs/$id', data: logData);
        final log = CustomerContactLog.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomerContactLogs([log]);
        return log;
      } else {
        // 离线：从本地存储获取记录，更新后保存，添加到同步队列
        final existingLog = await _localStorageService.getCustomerContactLogById(id);
        if (existingLog == null) {
          throw Exception('客户联系记录不存在');
        }
        
        final updatedLog = CustomerContactLog(
          contactLogId: existingLog.contactLogId,
          customerId: existingLog.customerId,
          customerName: existingLog.customerName,
          contactPerson: logData['contactPerson'] ?? existingLog.contactPerson,
          contactWay: logData['contactType'] ?? existingLog.contactWay,
          contactContent: logData['contactContent'] ?? existingLog.contactContent,
          contactResult: logData['contactResult'] ?? existingLog.contactResult,
          contactTime: logData['contactTime'] != null ? DateTime.parse(logData['contactTime']) : existingLog.contactTime,
          planNextTime: logData['nextContactTime'] != null ? DateTime.parse(logData['nextContactTime']) : existingLog.planNextTime,
          operatorId: existingLog.operatorId,
          operatorName: logData['operatorName'] ?? existingLog.operatorName,
          createTime: existingLog.createTime,
          updateTime: DateTime.now(),
          deleted: existingLog.deleted,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomerContactLogs([updatedLog]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'customer-contact-log',
          data: {...logData, 'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedLog;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCustomerContactLog(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/crm/customer-contact-logs/$id');
        
        // 更新本地存储
        await _localStorageService.deleteCustomerContactLog(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteCustomerContactLog(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer-contact-log',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteCustomerContactLog(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer-contact-log',
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

  Future<List<CustomerContactLog>> getFollowUpRecords(int days) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final response = await HttpClient.get('/crm/customer-contact-logs/follow-up', queryParameters: {'days': days});
        final logsJson = response.data as List;
        final logs = logsJson.map((json) => CustomerContactLog.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveCustomerContactLogs(logs);
        return logs;
      } else {
        // 离线：从本地存储获取数据
        final allLogs = await _localStorageService.getCustomerContactLogs();
        final cutoffDate = DateTime.now().subtract(Duration(days: days));
        return allLogs.where((log) => log.planNextTime.isBefore(cutoffDate)).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final allLogs = await _localStorageService.getCustomerContactLogs();
        final cutoffDate = DateTime.now().subtract(Duration(days: days));
        return allLogs.where((log) => log.planNextTime.isBefore(cutoffDate)).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 客户相关API - 离线优先策略
  Future<List<Customer>> getCustomers({Map<String, dynamic>? queryParameters}) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，合并本地存储，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customers', queryParameters: queryParameters);
        final customersJson = response.data['data'] as List;
        final apiCustomers = customersJson.map((json) => Customer.fromJson(json)).toList();
        
        // 获取本地存储的所有客户
        final localCustomers = await _localStorageService.getCustomers();
        
        // 合并客户：保留API返回的客户，同时添加本地新增但API中没有的客户
        final mergedCustomers = <Customer>[];
        final apiCustomerIds = apiCustomers.map((customer) => customer.customerId).toSet();
        
        // 添加API返回的所有客户
        mergedCustomers.addAll(apiCustomers);
        
        // 添加本地新增但API中没有的客户（通常是离线创建的客户）
        for (final localCustomer in localCustomers) {
          if (!apiCustomerIds.contains(localCustomer.customerId)) {
            mergedCustomers.add(localCustomer);
          }
        }
        
        // 更新本地存储
        await _localStorageService.saveCustomers(mergedCustomers);
        return mergedCustomers;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getCustomers();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getCustomers();
      } catch (localError) {
        // 本地存储也失败，返回示例数据
        return _generateSampleCustomers();
      }
    }
  }
  
  // 生成示例客户数据
  List<Customer> _generateSampleCustomers() {
    final now = DateTime.now();
    return [
      Customer(
        customerId: 1,
        name: '【客户示例1】北京铁路设备有限公司',
        contactPerson: '张经理',
        contactPhone: '13800138001',
        contactEmail: 'customer-sample-1@railway-beijing.com',
        address: '北京市朝阳区建国路88号',
        categoryId: 1,
        categoryName: '铁路设备供应商',
        tagIds: [1, 2],
        tagNames: ['优质客户', '长期合作'],
        description: '【客户示例1】主要供应铁路信号设备和通信设备，示例数据',
        status: 1,
        createTime: now.subtract(const Duration(days: 30)),
        updateTime: now,
        deleted: false,
      ),
      Customer(
        customerId: 2,
        name: '【客户示例2】上海轨道交通股份有限公司',
        contactPerson: '李工程师',
        contactPhone: '13900139002',
        contactEmail: 'customer-sample-2@metro-shanghai.com',
        address: '上海市浦东新区世纪大道100号',
        categoryId: 2,
        categoryName: '轨道交通运营商',
        tagIds: [2, 3],
        tagNames: ['长期合作', '大客户'],
        description: '【客户示例2】上海地铁运营管理公司，示例数据',
        status: 1,
        createTime: now.subtract(const Duration(days: 45)),
        updateTime: now.subtract(const Duration(days: 10)),
        deleted: false,
      ),
      Customer(
        customerId: 3,
        name: '【客户示例3】广州铁路集团有限公司',
        contactPerson: '王部长',
        contactPhone: '13700137003',
        contactEmail: 'customer-sample-3@railway-guangzhou.com',
        address: '广州市越秀区中山一路151号',
        categoryId: 1,
        categoryName: '铁路设备供应商',
        tagIds: [1, 3],
        tagNames: ['优质客户', '大客户'],
        description: '【客户示例3】广州铁路集团物资采购部门，示例数据',
        status: 1,
        createTime: now.subtract(const Duration(days: 60)),
        updateTime: now.subtract(const Duration(days: 5)),
        deleted: false,
      ),
      Customer(
        customerId: 4,
        name: '【客户示例4】成都铁路局成都机务段',
        contactPerson: '刘主任',
        contactPhone: '13600136004',
        contactEmail: 'customer-sample-4@cd-railway.com',
        address: '成都市金牛区北站西一巷1号',
        categoryId: 3,
        categoryName: '铁路维修服务商',
        tagIds: [2],
        tagNames: ['长期合作'],
        description: '【客户示例4】负责成都地区铁路机车维修服务，示例数据',
        status: 0,
        createTime: now.subtract(const Duration(days: 20)),
        updateTime: now,
        deleted: false,
      ),
      Customer(
        customerId: 5,
        name: '【客户示例5】武汉高速铁路建设指挥部',
        contactPerson: '陈总指挥',
        contactPhone: '13500135005',
        contactEmail: 'customer-sample-5@wuhan-hsr.com',
        address: '武汉市洪山区珞喻路1037号',
        categoryId: 4,
        categoryName: '铁路建设单位',
        tagIds: [3],
        tagNames: ['大客户'],
        description: '【客户示例5】武汉至广州高速铁路建设项目指挥部，示例数据',
        status: 1,
        createTime: now.subtract(const Duration(days: 15)),
        updateTime: now.subtract(const Duration(days: 2)),
        deleted: false,
      ),
    ];
  }

  // 客户相关API - 离线优先策略
  Future<Customer> getCustomerById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/customers/$id');
        final customer = Customer.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveCustomers([customer]);
        return customer;
      } else {
        // 离线：从本地存储获取数据
        final customer = await _localStorageService.getCustomerById(id);
        if (customer == null) {
          throw Exception('客户不存在');
        }
        return customer;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final customer = await _localStorageService.getCustomerById(id);
        if (customer == null) {
          throw Exception('客户不存在');
        }
        return customer;
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 客户相关API - 离线优先策略
  Future<Customer> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/crm/customers', data: customerData);
        final customer = Customer.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomers([customer]);
        return customer;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的客户
        // 注意：离线创建时需要生成临时ID，同步时替换
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final customer = Customer(
          customerId: tempId, // 临时ID
          name: customerData['name'],
          contactPerson: customerData['contactPerson'],
          contactPhone: customerData['contactPhone'],
          contactEmail: customerData['contactEmail'],
          address: customerData['address'],
          categoryId: customerData['categoryId'],
          categoryName: customerData['categoryName'],
          tagIds: List<int>.from(customerData['tagIds'] ?? []),
          tagNames: List<String>.from(customerData['tagNames'] ?? []),
          description: customerData['description'],
          status: customerData['status'],
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
          deleted: false,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomers([customer]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'customer',
          data: customerData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return customer;
      }
    } catch (error) {
      rethrow;
    }
  }

  // 客户相关API - 离线优先策略
  Future<Customer> updateCustomer(int id, Map<String, dynamic> customerData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/crm/customers/$id', data: customerData);
        final customer = Customer.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveCustomers([customer]);
        return customer;
      } else {
        // 离线：从本地存储获取客户，更新后保存，添加到同步队列
        final existingCustomer = await _localStorageService.getCustomerById(id);
        if (existingCustomer == null) {
          throw Exception('客户不存在');
        }
        
        final updatedCustomer = Customer(
          customerId: existingCustomer.customerId,
          name: customerData['name'] ?? existingCustomer.name,
          contactPerson: customerData['contactPerson'] ?? existingCustomer.contactPerson,
          contactPhone: customerData['contactPhone'] ?? existingCustomer.contactPhone,
          contactEmail: customerData['contactEmail'] ?? existingCustomer.contactEmail,
          address: customerData['address'] ?? existingCustomer.address,
          categoryId: customerData['categoryId'] ?? existingCustomer.categoryId,
          categoryName: customerData['categoryName'] ?? existingCustomer.categoryName,
          tagIds: customerData.containsKey('tagIds') ? List<int>.from(customerData['tagIds']) : existingCustomer.tagIds,
          tagNames: customerData.containsKey('tagNames') ? List<String>.from(customerData['tagNames']) : existingCustomer.tagNames,
          description: customerData['description'] ?? existingCustomer.description,
          status: customerData['status'] ?? existingCustomer.status,
          createTime: existingCustomer.createTime,
          updateTime: DateTime.now(),
          deleted: existingCustomer.deleted,
        );
        
        // 保存到本地存储
        await _localStorageService.saveCustomers([updatedCustomer]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'customer',
          data: {...customerData, 'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedCustomer;
      }
    } catch (error) {
      rethrow;
    }
  }

  // 客户相关API - 离线优先策略
  Future<void> deleteCustomer(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/crm/customers/$id');
        
        // 更新本地存储
        await _localStorageService.deleteCustomer(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteCustomer(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteCustomer(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'customer',
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

  // 客户相关API - 离线优先策略
  Future<void> batchDeleteCustomers(List<int> ids) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/crm/customers/batch', data: {'ids': ids});
        
        // 更新本地存储
        for (final id in ids) {
          await _localStorageService.deleteCustomer(id);
        }
      } else {
        // 离线：直接从本地存储删除，逐个添加到同步队列
        for (final id in ids) {
          await _localStorageService.deleteCustomer(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'customer',
            data: {'id': id},
            timestamp: DateTime.now(),
            tempId: id,
          );
          await _syncService.addSyncOperation(syncOperation);
        }
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        for (final id in ids) {
          await _localStorageService.deleteCustomer(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'customer',
            data: {'id': id},
            timestamp: DateTime.now(),
            tempId: id,
          );
          await _syncService.addSyncOperation(syncOperation);
        }
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<List<Customer>> getCustomersByCategory(int categoryId) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final response = await HttpClient.get('/crm/customers/category/$categoryId');
        final customersJson = response.data as List;
        return customersJson.map((json) => Customer.fromJson(json)).toList();
      } else {
        // 离线：从本地存储过滤
        final allCustomers = await _localStorageService.getCustomers();
        return allCustomers.where((customer) => customer.categoryId == categoryId).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储过滤
      try {
        final allCustomers = await _localStorageService.getCustomers();
        return allCustomers.where((customer) => customer.categoryId == categoryId).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<List<Customer>> getCustomersByTag(int tagId) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final response = await HttpClient.get('/crm/customers/tag/$tagId');
        final customersJson = response.data as List;
        return customersJson.map((json) => Customer.fromJson(json)).toList();
      } else {
        // 离线：从本地存储过滤
        final allCustomers = await _localStorageService.getCustomers();
        return allCustomers.where((customer) => customer.tagIds.contains(tagId)).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储过滤
      try {
        final allCustomers = await _localStorageService.getCustomers();
        return allCustomers.where((customer) => customer.tagIds.contains(tagId)).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<List<Customer>> searchCustomers(String keyword) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final response = await HttpClient.get('/crm/customers/search', queryParameters: {'keyword': keyword});
        final customersJson = response.data as List;
        return customersJson.map((json) => Customer.fromJson(json)).toList();
      } else {
        // 离线：从本地存储搜索
        final allCustomers = await _localStorageService.getCustomers();
        return allCustomers.where((customer) => 
          customer.name.contains(keyword) || 
          customer.contactPerson.contains(keyword) ||
          customer.contactPhone.contains(keyword) ||
          customer.contactEmail.contains(keyword)
        ).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储搜索
      try {
        final allCustomers = await _localStorageService.getCustomers();
        return allCustomers.where((customer) => 
          customer.name.contains(keyword) || 
          customer.contactPerson.contains(keyword) ||
          customer.contactPhone.contains(keyword) ||
          customer.contactEmail.contains(keyword)
        ).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 联系记录相关API - 离线优先策略
  Future<List<ContactRecord>> getContactRecords() async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/contact-records');
        final recordsJson = response.data['data'] as List;
        final records = recordsJson.map((json) => ContactRecord.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveContactRecords(records);
        return records;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getContactRecords();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getContactRecords();
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 销售机会相关API - 离线优先策略
  Future<List<SalesOpportunity>> getSalesOpportunities() async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/sales-opportunities');
        final opportunitiesJson = response.data['data'] as List;
        final opportunities = opportunitiesJson.map((json) => SalesOpportunity.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveSalesOpportunities(opportunities);
        return opportunities;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getSalesOpportunities();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getSalesOpportunities();
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<List<SalesOpportunity>> getSalesOpportunitiesByCustomer(int customerId) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final response = await HttpClient.get('/crm/sales-opportunities', queryParameters: {'customerId': customerId});
        final opportunitiesJson = response.data as List;
        final opportunities = opportunitiesJson.map((json) => SalesOpportunity.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveSalesOpportunities(opportunities);
        return opportunities;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getSalesOpportunitiesByCustomerId(customerId);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getSalesOpportunitiesByCustomerId(customerId);
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<SalesOpportunity> getSalesOpportunityById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/crm/sales-opportunities/$id');
        final opportunity = SalesOpportunity.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveSalesOpportunities([opportunity]);
        return opportunity;
      } else {
        // 离线：从本地存储获取数据
        final opportunity = await _localStorageService.getSalesOpportunityById(id);
        if (opportunity == null) {
          throw Exception('销售机会不存在');
        }
        return opportunity;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final opportunity = await _localStorageService.getSalesOpportunityById(id);
        if (opportunity == null) {
          throw Exception('销售机会不存在');
        }
        return opportunity;
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<SalesOpportunity> createSalesOpportunity(Map<String, dynamic> opportunityData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/crm/sales-opportunities', data: opportunityData);
        final opportunity = SalesOpportunity.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveSalesOpportunities([opportunity]);
        return opportunity;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的销售机会
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final opportunity = SalesOpportunity(
          opportunityId: tempId,
          customerId: opportunityData['customerId'],
          customerName: opportunityData['customerName'],
          opportunityName: opportunityData['opportunityName'],
          expectedAmount: opportunityData['estimatedAmount'] ?? 0.0,
          stage: opportunityData['stage'],
          probability: opportunityData['probability'] ?? '0%',
          expectedCloseDate: DateTime.parse(opportunityData['expectedCloseDate']),
          responsiblePerson: opportunityData['responsiblePerson'] ?? '',
          description: opportunityData['description'] ?? '',
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
          deleted: false,
        );
        
        // 保存到本地存储
        await _localStorageService.saveSalesOpportunities([opportunity]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'sales-opportunity',
          data: opportunityData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return opportunity;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<SalesOpportunity> updateSalesOpportunity(int id, Map<String, dynamic> opportunityData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/crm/sales-opportunities/$id', data: opportunityData);
        final opportunity = SalesOpportunity.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveSalesOpportunities([opportunity]);
        return opportunity;
      } else {
        // 离线：从本地存储获取销售机会，更新后保存，添加到同步队列
        final existingOpportunity = await _localStorageService.getSalesOpportunityById(id);
        if (existingOpportunity == null) {
          throw Exception('销售机会不存在');
        }
        
        final updatedOpportunity = SalesOpportunity(
          opportunityId: existingOpportunity.opportunityId,
          customerId: existingOpportunity.customerId,
          customerName: existingOpportunity.customerName,
          opportunityName: opportunityData['opportunityName'] ?? existingOpportunity.opportunityName,
          expectedAmount: opportunityData['estimatedAmount'] ?? existingOpportunity.expectedAmount,
          stage: opportunityData['stage'] ?? existingOpportunity.stage,
          probability: opportunityData['probability'] ?? existingOpportunity.probability,
          expectedCloseDate: opportunityData['expectedCloseDate'] != null ? DateTime.parse(opportunityData['expectedCloseDate']) : existingOpportunity.expectedCloseDate,
          responsiblePerson: opportunityData['responsiblePerson'] ?? existingOpportunity.responsiblePerson,
          description: opportunityData['description'] ?? existingOpportunity.description,
          createTime: existingOpportunity.createTime,
          updateTime: DateTime.now(),
          deleted: existingOpportunity.deleted,
        );
        
        // 保存到本地存储
        await _localStorageService.saveSalesOpportunities([updatedOpportunity]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'sales-opportunity',
          data: {...opportunityData, 'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedOpportunity;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteSalesOpportunity(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/api/crm/sales-opportunities/$id');
        
        // 更新本地存储
        await _localStorageService.deleteSalesOpportunity(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteSalesOpportunity(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'sales-opportunity',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteSalesOpportunity(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'sales-opportunity',
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

  // 联系记录相关API
  Future<List<ContactRecord>> getContactRecordsByCustomer(int customerId) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final response = await HttpClient.get('/api/crm/contact-records', queryParameters: {'customerId': customerId});
        final recordsJson = response.data as List;
        final records = recordsJson.map((json) => ContactRecord.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveContactRecords(records);
        return records;
      } else {
        // 离线：从本地存储获取数据
        return await _localStorageService.getContactRecordsByCustomerId(customerId);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        return await _localStorageService.getContactRecordsByCustomerId(customerId);
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<ContactRecord> getContactRecordById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/api/crm/contact-records/$id');
        final record = ContactRecord.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveContactRecords([record]);
        return record;
      } else {
        // 离线：从本地存储获取数据
        final record = await _localStorageService.getContactRecordById(id);
        if (record == null) {
          throw Exception('联系记录不存在');
        }
        return record;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final record = await _localStorageService.getContactRecordById(id);
        if (record == null) {
          throw Exception('联系记录不存在');
        }
        return record;
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<ContactRecord> createContactRecord(Map<String, dynamic> recordData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/api/crm/contact-records', data: recordData);
        final record = ContactRecord.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveContactRecords([record]);
        return record;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的记录
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final now = DateTime.now().toIso8601String();
        final record = ContactRecord(
          recordId: tempId,
          customerId: recordData['customerId'] ?? 0,
          contactId: recordData['contactId'] ?? 0,
          contactType: recordData['contactType'] ?? '',
          contactDate: recordData['contactDate'] ?? now,
          contactContent: recordData['contactContent'] ?? '',
          contactPerson: recordData['contactPerson'] ?? '',
          nextContactPlan: recordData['nextContactPlan'] ?? '',
          contactStatus: recordData['contactStatus'] ?? 'pending',
          createdBy: recordData['createdBy'] ?? '',
          createdAt: now,
          updatedBy: recordData['updatedBy'] ?? '',
          updatedAt: now,
        );
        
        // 保存到本地存储
        await _localStorageService.saveContactRecords([record]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'contact-record',
          data: recordData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return record;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<ContactRecord> updateContactRecord(int id, Map<String, dynamic> recordData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/api/crm/contact-records/$id', data: recordData);
        final record = ContactRecord.fromJson(response.data);
        
        // 更新本地存储
        await _localStorageService.saveContactRecords([record]);
        return record;
      } else {
        // 离线：从本地存储获取记录，更新后保存，添加到同步队列
        final existingRecord = await _localStorageService.getContactRecordById(id);
        if (existingRecord == null) {
          throw Exception('联系记录不存在');
        }
        
        final updatedRecord = ContactRecord(
          recordId: existingRecord.recordId,
          customerId: existingRecord.customerId,
          contactId: existingRecord.contactId,
          contactType: recordData['contactType'] ?? existingRecord.contactType,
          contactDate: recordData['contactDate'] ?? existingRecord.contactDate,
          contactContent: recordData['contactContent'] ?? existingRecord.contactContent,
          contactPerson: recordData['contactPerson'] ?? existingRecord.contactPerson,
          nextContactPlan: recordData['nextContactPlan'] ?? existingRecord.nextContactPlan,
          contactStatus: recordData['contactStatus'] ?? existingRecord.contactStatus,
          createdBy: existingRecord.createdBy,
          createdAt: existingRecord.createdAt,
          updatedBy: recordData['updatedBy'] ?? existingRecord.updatedBy,
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveContactRecords([updatedRecord]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'contact-record',
          data: {...recordData, 'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedRecord;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteContactRecord(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/api/crm/contact-records/$id');
        
        // 更新本地存储
        await _localStorageService.deleteContactRecord(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteContactRecord(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'contact-record',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteContactRecord(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'contact-record',
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
}