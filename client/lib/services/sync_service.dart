import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_service.dart';
import '../models/crm/customer.dart';
import '../models/product/product.dart';
import '../models/order/order.dart';
import '../models/approval/approval.dart';
import '../models/sync/sync_operation.dart';
import '../models/sync/sync_log.dart';
import '../models/settings/operation_log.dart';
import '../models/settings/system_parameter.dart';
import '../models/settings/data_dictionary.dart';
import 'websocket_service.dart';
import '../utils/http_client.dart';
import 'local_storage_service.dart';
import 'hash_service.dart';

/// 数据同步服务，用于在网络恢复时自动同步本地数据至服务器
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final NetworkService _networkService = NetworkService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final HashService _hashService = HashService();
  final WebSocketService _webSocketService = WebSocketService();
  late Box<SyncOperation> _syncQueueBox;
  late Box<SyncLog> _syncLogsBox;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<DataChangeEvent>? _dataChangeSubscription;
  bool _isInitialized = false;
  bool _isSyncing = false;

  /// 初始化同步服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 注册Hive适配器
    Hive.registerAdapter(SyncOperationAdapter());
    Hive.registerAdapter(SyncLogAdapter());

    // 打开Hive Boxes
    _syncQueueBox = await Hive.openBox<SyncOperation>('sync_queue');
    _syncLogsBox = await Hive.openBox<SyncLog>('sync_logs');

    // 监听网络状态变化
    _connectionSubscription = _networkService.connectionStream.listen((isConnected) {
      if (isConnected) {
        // 网络恢复，触发自动同步
        _autoSync();
      }
    });

    // 监听WebSocket数据变更事件
    _dataChangeSubscription = _webSocketService.dataChangeStream.listen((event) {
      _handleWebSocketDataChange(event);
    });

    _isInitialized = true;
    print('SyncService initialized');
  }

  /// 自动同步数据
  Future<void> _autoSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      print('开始自动同步数据...');
      // 执行基于哈希的双向同步
      await _syncDataByHash('product');
      await _syncDataByHash('order');
      await _syncDataByHash('customer');
      await _syncDataByHash('approval');
      await _syncDataByHash('systemParameter');
      await _syncDataByHash('dataDictionary');
      // 同步待处理的操作
      await _syncPendingOperations();
      print('自动同步数据完成');
    } catch (error) {
      print('自动同步数据失败: $error');
    } finally {
      _isSyncing = false;
    }
  }

  /// 同步订单数据
  Future<void> syncOrders() async {
    // 如果未初始化，先初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 检查网络连接
    final isConnected = await _networkService.isConnected();
    
    if (isConnected) {
      // 有网络，先执行基于哈希的双向同步
      await _syncDataByHash('order');
      // 再同步待处理的操作
      await _syncPendingOperations();
    } else {
      // 无网络，等待网络恢复后自动同步
      print('网络未连接，将在网络恢复后自动同步订单数据');
    }
  }

  /// 同步客户数据
  Future<void> syncCustomers() async {
    // 如果未初始化，先初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 检查网络连接
    final isConnected = await _networkService.isConnected();
    
    if (isConnected) {
      // 有网络，先执行基于哈希的双向同步
      await _syncDataByHash('customer');
      // 再同步待处理的操作
      await _syncPendingOperations();
    } else {
      // 无网络，等待网络恢复后自动同步
      print('网络未连接，将在网络恢复后自动同步客户数据');
    }
  }

  /// 手动触发同步
  Future<void> manualSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      print('开始手动同步数据...');
      await _syncPendingOperations();
      print('手动同步数据完成');
    } catch (error) {
      print('手动同步数据失败: $error');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// 同步商品数据
  Future<void> syncProducts() async {
    // 如果未初始化，先初始化
    if (!_isInitialized) {
      await initialize();
    }

    // 检查网络连接
    final isConnected = await _networkService.isConnected();
    
    if (isConnected) {
      // 有网络，先执行基于哈希的双向同步
      await _syncDataByHash('product');
      // 再同步待处理的操作
      await _syncPendingOperations();
    } else {
      // 无网络，等待网络恢复后自动同步
      print('网络未连接，将在网络恢复后自动同步商品数据');
    }
  }

  /// 基于哈希值的双向同步
  Future<void> _syncDataByHash(String dataType) async {
    print('开始基于哈希值同步数据: $dataType');
    
    try {
      // 1. 从服务器获取数据哈希信息
      final serverHashResponse = await HttpClient.get('${_getApiUrl(dataType)}/hash');
      final serverHashes = serverHashResponse.data['data'] as Map<String, dynamic>;
      
      // 2. 获取本地数据并计算哈希值
      final localHashes = await _calculateLocalHashes(dataType);
      
      // 3. 比较哈希值，确定差异
      final differences = _hashService.compareHashMaps(
        Map<String, String>.from(localHashes),
        Map<String, String>.from(serverHashes)
      );
      
      if (differences.isEmpty) {
        print('数据无差异，无需同步: $dataType');
        return;
      }
      
      print('发现 ${differences.length} 个差异项，开始同步: $dataType');
      
      // 4. 同步差异数据
      await _syncDifferences(dataType, differences, serverHashes, localHashes);
      
      print('基于哈希值同步完成: $dataType');
    } catch (error) {
      print('基于哈希值同步失败: $error');
      // 哈希同步失败时，回退到传统同步方式
      print('回退到传统同步方式');
    }
  }

  /// 计算本地数据的哈希值
  Future<Map<String, String>> _calculateLocalHashes(String dataType) async {
    final hashes = <String, String>{};
    
    switch (dataType) {
      case 'product':
        final products = await _localStorageService.getProducts();
        for (final product in products) {
          hashes[product.id.toString()] = _hashService.calculateHash(product.toJson());
        }
        break;
      case 'order':
        final orders = await _localStorageService.getOrders();
        for (final order in orders) {
          hashes[order.id.toString()] = _hashService.calculateHash(order.toJson());
        }
        break;
      case 'customer':
        final customers = await _localStorageService.getCustomers();
        for (final customer in customers) {
          hashes[customer.customerId.toString()] = _hashService.calculateHash(customer.toJson());
        }
        break;
      case 'approval':
        final approvals = await _localStorageService.getApprovals();
        for (final approval in approvals) {
          hashes[approval.approvalId.toString()] = _hashService.calculateHash(approval.toJson());
        }
        break;
      case 'systemParameter':
        final parameters = await _localStorageService.getAllSystemParameters();
        for (final parameter in parameters) {
          hashes[parameter.id.toString()] = _hashService.calculateHash(parameter.toJson());
        }
        break;
      case 'dataDictionary':
        final dictionaries = await _localStorageService.getAllDataDictionaries();
        for (final dictionary in dictionaries) {
          hashes[dictionary.id.toString()] = _hashService.calculateHash(dictionary.toJson());
        }
        break;
    }
    
    return hashes;
  }

  /// 同步差异数据
  Future<void> _syncDifferences(
    String dataType,
    Set<String> differences,
    Map<String, dynamic> serverHashes,
    Map<String, String> localHashes
  ) async {
    for (final id in differences) {
      final hasServerData = serverHashes.containsKey(id);
      final hasLocalData = localHashes.containsKey(id);
      
      if (hasServerData && !hasLocalData) {
        // 服务器有，本地没有：从服务器获取
        await _fetchDataFromServer(dataType, int.parse(id));
      } else if (!hasServerData && hasLocalData) {
        // 本地有，服务器没有：同步到服务器
        await _syncLocalDataToServer(dataType, int.parse(id));
      } else {
        // 两边都有但哈希值不同：需要冲突解决
        await _resolveConflict(dataType, int.parse(id));
      }
    }
  }

  /// 从服务器获取数据
  Future<void> _fetchDataFromServer(String dataType, int id) async {
    print('从服务器获取数据: $dataType/$id');
    final response = await HttpClient.get('${_getApiUrl(dataType)}/$id');
    final data = response.data['data'];
    
    switch (dataType) {
      case 'product':
        await _localStorageService.saveProducts([Product.fromJson(data)]);
        break;
      case 'order':
        await _localStorageService.saveOrders([Order.fromJson(data)]);
        break;
      case 'customer':
        await _localStorageService.saveCustomers([Customer.fromJson(data)]);
        break;
      case 'approval':
        await _localStorageService.saveApprovals([Approval.fromJson(data)]);
        break;
      case 'systemParameter':
        await _localStorageService.saveSystemParameters([SystemParameter.fromJson(data)]);
        break;
      case 'dataDictionary':
        await _localStorageService.saveDataDictionaries([DataDictionary.fromJson(data)]);
        break;
    }
  }

  /// 将本地数据同步到服务器
  Future<void> _syncLocalDataToServer(String dataType, int id) async {
    print('将本地数据同步到服务器: $dataType/$id');
    
    dynamic localData;
    switch (dataType) {
      case 'product':
        localData = await _localStorageService.getProductById(id);
        break;
      case 'order':
        localData = await _localStorageService.getOrderById(id);
        break;
      case 'customer':
        localData = await _localStorageService.getCustomerById(id);
        break;
      case 'approval':
        localData = await _localStorageService.getApprovalById(id);
        break;
      case 'systemParameter':
        localData = await _localStorageService.getSystemParameterById(id);
        break;
      case 'dataDictionary':
        localData = await _localStorageService.getDataDictionaryById(id);
        break;
    }
    
    if (localData != null) {
      final response = await HttpClient.post(_getApiUrl(dataType), data: localData.toJson());
      // 如果需要更新ID，处理临时ID
    }
  }

  /// 解决数据冲突
  Future<void> _resolveConflict(String dataType, int id) async {
    print('解决数据冲突: $dataType/$id');
    
    // 1. 获取服务器数据和本地数据
    final serverResponse = await HttpClient.get('${_getApiUrl(dataType)}/$id');
    final serverData = serverResponse.data['data'];
    
    dynamic localData;
    switch (dataType) {
      case 'product':
        localData = await _localStorageService.getProductById(id);
        break;
      case 'order':
        localData = await _localStorageService.getOrderById(id);
        break;
      case 'customer':
        localData = await _localStorageService.getCustomerById(id);
        break;
      case 'approval':
        localData = await _localStorageService.getApprovalById(id);
        break;
      case 'systemParameter':
        localData = await _localStorageService.getSystemParameterById(id);
        break;
      case 'dataDictionary':
        localData = await _localStorageService.getDataDictionaryById(id);
        break;
    }
    
    if (localData == null) return;
    
    // 2. 比较更新时间，使用最新的数据
    final serverUpdateTime = DateTime.parse(serverData['updatedAt']);
    DateTime localUpdateTime;
    
    switch (dataType) {
      case 'product':
        localUpdateTime = (localData as Product).updatedAt;
        break;
      case 'order':
        localUpdateTime = (localData as Order).updatedAt;
        break;
      case 'customer':
        localUpdateTime = (localData as Customer).updateTime;
        break;
      case 'approval':
        localUpdateTime = (localData as Approval).updatedAt;
        break;
      case 'systemParameter':
        localUpdateTime = (localData as SystemParameter).updatedAt;
        break;
      case 'dataDictionary':
        localUpdateTime = (localData as DataDictionary).updatedAt;
        break;
      default:
        localUpdateTime = DateTime.now();
    }
    
    if (localUpdateTime.isAfter(serverUpdateTime)) {
      // 本地数据更新时间更新，同步到服务器
      await _syncLocalDataToServer(dataType, id);
    } else {
      // 服务器数据更新时间更新，从服务器获取
      await _fetchDataFromServer(dataType, id);
    }
  }

  /// 同步所有待处理的操作
  Future<void> _syncPendingOperations() async {
    // 获取所有待同步的操作
    final pendingOperations = _syncQueueBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (pendingOperations.isEmpty) {
      print('没有待同步的操作');
      return;
    }

    print('发现 ${pendingOperations.length} 个待同步的操作');

    for (final operation in pendingOperations) {
      try {
        // 执行同步操作
        await _executeSyncOperation(operation);
        
        // 同步成功，记录日志并移除操作
        await _logSyncSuccess(operation);
        await _syncQueueBox.delete(operation.id);
      } catch (error) {
        // 同步失败，记录日志
        await _logSyncFailure(operation, error.toString());
      }
    }
  }

  /// 执行单个同步操作
  Future<void> _executeSyncOperation(SyncOperation operation) async {
    print('执行同步操作: ${operation.id}, 类型: ${operation.operationType}, 数据类型: ${operation.dataType}');

    switch (operation.operationType) {
      case SyncOperationType.create:
        await _syncCreateOperation(operation);
        break;
      case SyncOperationType.update:
        await _syncUpdateOperation(operation);
        break;
      case SyncOperationType.delete:
        await _syncDeleteOperation(operation);
        break;
    }
  }

  /// 同步创建操作
  Future<void> _syncCreateOperation(SyncOperation operation) async {
    final url = _getApiUrl(operation.dataType);
    final response = await HttpClient.post(url, data: operation.data);
    
    // 如果是临时ID，需要更新本地存储中的ID
    if (operation.tempId != null && operation.tempId! > 0) {
      await _updateLocalId(operation.dataType, operation.tempId!, response.data['data']['id']);
    }
  }

  /// 同步更新操作
  Future<void> _syncUpdateOperation(SyncOperation operation) async {
    final url = '${_getApiUrl(operation.dataType)}/${operation.id}';
    await HttpClient.put(url, data: operation.data);
  }

  /// 同步删除操作
  Future<void> _syncDeleteOperation(SyncOperation operation) async {
    final url = '${_getApiUrl(operation.dataType)}/${operation.id}';
    await HttpClient.delete(url);
  }

  /// 获取API URL
  String _getApiUrl(String dataType) {
    switch (dataType) {
      case 'product':
        return '/v1/products';
      case 'order':
        return '/v1/orders';
      case 'customer':
        return '/v1/crm/customers';
      case 'systemParameter':
        return '/v1/settings/system-parameters';
      case 'dataDictionary':
        return '/v1/settings/data-dictionaries';
      case 'approval':
        return '/v1/approval/requests';
      default:
        throw Exception('未知的数据类型: $dataType');
    }
  }

  /// 更新本地存储中的ID
  Future<void> _updateLocalId(String dataType, int oldId, int newId) async {
    switch (dataType) {
      case 'product':
        final product = await _localStorageService.getProductById(oldId);
        if (product != null) {
          // 创建新的Product对象，更新id
          final updatedProduct = Product(
            id: newId,
            name: product.name,
            code: product.code,
            specification: product.specification,
            model: product.model,
            unit: product.unit,
            price: product.price,
            costPrice: product.costPrice,
            originalPrice: product.originalPrice,
            stock: product.stock,
            safetyStock: product.safetyStock,
            categoryId: product.categoryId,
            brand: product.brand,
            manufacturer: product.manufacturer,
            supplierId: product.supplierId,
            barcode: product.barcode,
            imageUrl: product.imageUrl,
            description: product.description,
            status: product.status,
            createdAt: product.createdAt,
            updatedAt: product.updatedAt,
          );
          await _localStorageService.saveProducts([updatedProduct]);
        }
        break;
      case 'order':
        final order = await _localStorageService.getOrderById(oldId);
        if (order != null) {
          // 创建新的Order对象，更新id
          final updatedOrder = Order(
            id: newId,
            orderNumber: order.orderNumber,
            userId: order.userId,
            orderItems: order.orderItems,
            totalAmount: order.totalAmount,
            status: order.status,
            paymentMethod: order.paymentMethod,
            paymentStatus: order.paymentStatus,
            shippingAddress: order.shippingAddress,
            billingAddress: order.billingAddress,
            shippingMethod: order.shippingMethod,
            trackingNumber: order.trackingNumber,
            notes: order.notes,
            createdAt: order.createdAt,
            updatedAt: order.updatedAt,
          );
          await _localStorageService.saveOrders([updatedOrder]);
        }
        break;
      case 'customer':
        final customer = await _localStorageService.getCustomerById(oldId);
        if (customer != null) {
          // 创建新的Customer对象，更新customerId
          final updatedCustomer = Customer(
            customerId: newId,
            name: customer.name,
            contactPerson: customer.contactPerson,
            contactPhone: customer.contactPhone,
            contactEmail: customer.contactEmail,
            address: customer.address,
            categoryId: customer.categoryId,
            categoryName: customer.categoryName,
            tagIds: customer.tagIds,
            tagNames: customer.tagNames,
            description: customer.description,
            status: customer.status,
            createTime: customer.createTime,
            updateTime: customer.updateTime,
            deleted: customer.deleted,
          );
          await _localStorageService.saveCustomers([updatedCustomer]);
        }
        break;
      case 'approval':
        final approval = await _localStorageService.getApprovalById(oldId);
        if (approval != null) {
          // 创建新的Approval对象，更新approvalId
          final updatedApproval = Approval(
            approvalId: newId,
            title: approval.title,
            content: approval.content,
            requesterId: approval.requesterId,
            requesterName: approval.requesterName,
            approverId: approval.approverId,
            approverName: approval.approverName,
            status: approval.status,
            type: approval.type,
            createdAt: approval.createdAt,
            updatedAt: approval.updatedAt,
            relatedData: approval.relatedData,
            comment: approval.comment,
            isSynced: approval.isSynced,
          );
          await _localStorageService.saveApprovals([updatedApproval]);
        }
        break;
      case 'systemParameter':
        final parameter = await _localStorageService.getSystemParameterById(oldId);
        if (parameter != null) {
          // 创建新的SystemParameter对象，更新id
          final updatedParameter = SystemParameter(
            id: newId,
            parameterKey: parameter.parameterKey,
            parameterValue: parameter.parameterValue,
            parameterDescription: parameter.parameterDescription,
            parameterType: parameter.parameterType,
            defaultValue: parameter.defaultValue,
            isEditable: parameter.isEditable,
            createdAt: parameter.createdAt,
            updatedAt: parameter.updatedAt,
          );
          await _localStorageService.saveSystemParameters([updatedParameter]);
        }
        break;
      case 'dataDictionary':
        final dictionary = await _localStorageService.getDataDictionaryById(oldId);
        if (dictionary != null) {
          // 创建新的DataDictionary对象，更新id
          final updatedDictionary = DataDictionary(
            id: newId,
            dictType: dictionary.dictType,
            dictCode: dictionary.dictCode,
            dictValue: dictionary.dictValue,
            dictName: dictionary.dictName,
            description: dictionary.description,
            sortOrder: dictionary.sortOrder,
            isActive: dictionary.isActive,
            createdAt: dictionary.createdAt,
            updatedAt: dictionary.updatedAt,
          );
          await _localStorageService.saveDataDictionaries([updatedDictionary]);
        }
        break;
      default:
        throw Exception('未知的数据类型: $dataType');
    }
  }

  /// 添加同步操作到队列
  Future<void> addSyncOperation(SyncOperation operation) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _syncQueueBox.put(operation.id, operation);
  }

  /// 记录同步成功日志
  Future<void> _logSyncSuccess(SyncOperation operation) async {
    final log = SyncLog(
      id: DateTime.now().millisecondsSinceEpoch,
      operationId: operation.id,
      operationType: operation.operationType,
      dataType: operation.dataType,
      status: SyncStatus.success,
      timestamp: DateTime.now(),
      message: '同步成功',
    );
    await _syncLogsBox.put(log.id, log);
    print('同步成功日志: ${log.toString()}');
  }

  /// 记录同步失败日志
  Future<void> _logSyncFailure(SyncOperation operation, String errorMessage) async {
    final log = SyncLog(
      id: DateTime.now().millisecondsSinceEpoch,
      operationId: operation.id,
      operationType: operation.operationType,
      dataType: operation.dataType,
      status: SyncStatus.failed,
      timestamp: DateTime.now(),
      message: errorMessage,
    );
    await _syncLogsBox.put(log.id, log);
    print('同步失败日志: ${log.toString()}');
  }

  /// 获取同步日志
  Future<List<SyncLog>> getSyncLogs({int limit = 50}) async {
    if (!_isInitialized) {
      await initialize();
    }
    final logs = _syncLogsBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  /// 获取待同步操作数量
  Future<int> getPendingOperationsCount() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _syncQueueBox.length;
  }

  /// 清理旧的同步日志
  Future<void> cleanupOldLogs({Duration olderThan = const Duration(days: 30)}) async {
    if (!_isInitialized) {
      await initialize();
    }
    final cutoffTime = DateTime.now().subtract(olderThan);
    final oldLogs = _syncLogsBox.values
        .where((log) => log.timestamp.isBefore(cutoffTime))
        .toList();
    
    for (final log in oldLogs) {
      await _syncLogsBox.delete(log.id);
    }
  }

  /// 处理WebSocket数据变更事件
  Future<void> _handleWebSocketDataChange(DataChangeEvent event) async {
    print('处理WebSocket数据变更: $event');
    
    try {
      // 根据数据变更类型执行相应操作
      switch (event.operation) {
        case 'create':
        case 'update':
          // 从服务器获取最新数据
          await _fetchDataFromServer(event.dataType, event.data['id']);
          break;
        case 'delete':
          // 删除本地数据
          await _deleteLocalData(event.dataType, event.data['id']);
          break;
      }
    } catch (error) {
      print('处理WebSocket数据变更失败: $error');
    }
  }

  /// 删除本地数据
  Future<void> _deleteLocalData(String dataType, int id) async {
    switch (dataType) {
      case 'product':
        await _localStorageService.deleteProduct(id);
        break;
      case 'order':
        await _localStorageService.deleteOrder(id);
        break;
      case 'customer':
        await _localStorageService.deleteCustomer(id);
        break;
      case 'approval':
        await _localStorageService.deleteApproval(id);
        break;
      case 'systemParameter':
        await _localStorageService.deleteSystemParameter(id);
        break;
      case 'dataDictionary':
        await _localStorageService.deleteDataDictionary(id);
        break;
    }
  }

  /// 关闭同步服务
  Future<void> dispose() async {
    _connectionSubscription?.cancel();
    _dataChangeSubscription?.cancel();
    _isInitialized = false;
  }
}

/// 同步服务提供者
final syncServiceProvider = Provider<SyncService>((ref) {
  final syncService = SyncService();
  syncService.initialize();
  return syncService;
});
