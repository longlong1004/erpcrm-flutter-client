import '../models/order/order.dart';
import '../models/order/order_item.dart';
import '../utils/http_client.dart';
import './network_service.dart';
import './local_storage_service.dart';
import './sync_service.dart';
import '../models/sync/sync_operation.dart';

class OrderService {
  final NetworkService _networkService;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;

  OrderService() : 
    _networkService = NetworkService(),
    _localStorageService = LocalStorageService(),
    _syncService = SyncService();

  OrderService.withDependencies({
    NetworkService? networkService,
    LocalStorageService? localStorageService,
    SyncService? syncService,
  }) : 
    _networkService = networkService ?? NetworkService(),
    _localStorageService = localStorageService ?? LocalStorageService(),
    _syncService = syncService ?? SyncService();

  // 获取订单列表 - 离线优先策略
  Future<List<Order>> getOrders({Map<String, dynamic>? params}) async {
    // 1. 先从本地获取数据作为兜底，确保快速响应
    List<Order> localOrders = [];
    try {
      localOrders = await _localStorageService.getOrders();
    } catch (e) {
      print('获取本地订单数据失败: $e');
      // 如果本地存储也失败，使用空列表
      localOrders = [];
    }
    
    // 2. 如果本地没有数据，使用mock数据初始化
    if (localOrders.isEmpty) {
      print('本地没有订单数据，使用mock数据');
      // 从order_provider中获取mock数据
      // 这里我们需要创建一个临时的OrdersNotifier实例来获取mock数据
      final mockOrders = _getMockOrders();
      // 保存到本地存储
      await _localStorageService.saveOrders(mockOrders).catchError((e) {
        print('保存mock数据到本地失败: $e');
      });
      return mockOrders;
    }
    
    try {
      // 3. 检查网络连接状态（超时控制）
      bool isConnected = false;
      try {
        // 设置网络检查超时
        isConnected = await _networkService.isConnected().timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        );
      } catch (e) {
        print('网络状态检查失败: $e');
        isConnected = false;
      }
      
      if (isConnected) {
        // 在线：从API获取数据，合并本地存储，更新本地存储，返回数据
        try {
          // 设置API请求超时
          final response = await HttpClient.get('/orders', queryParameters: params)
              .timeout(const Duration(seconds: 10));
          final ordersJson = response.data['data'] as List;
          final apiOrders = ordersJson.map((json) => Order.fromJson(json)).toList();
          
          // 合并订单：保留API返回的订单，同时添加本地新增但API中没有的订单
          final mergedOrders = <Order>[];
          final apiOrderIds = apiOrders.map((order) => order.id).toSet();
          
          // 添加API返回的所有订单
          mergedOrders.addAll(apiOrders);
          
          // 添加本地新增但API中没有的订单（通常是离线创建的订单）
          for (final localOrder in localOrders) {
            if (!apiOrderIds.contains(localOrder.id)) {
              mergedOrders.add(localOrder);
            }
          }
          
          // 更新本地存储（异步执行，不阻塞返回）
          _localStorageService.saveOrders(mergedOrders).catchError((e) {
            print('更新本地订单存储失败: $e');
          });
          
          return mergedOrders;
        } catch (apiError) {
          print('获取API订单数据失败: $apiError');
          // API请求失败，返回本地数据
          return localOrders;
        }
      } else {
        // 离线：返回本地存储的数据
        return localOrders;
      }
    } catch (error) {
      print('获取订单数据失败: $error');
      // 所有方法都失败，返回本地数据作为最后兜底
      return localOrders;
    }
  }
  
  // 临时方法：获取mock订单数据（复制自order_provider.dart）
  List<Order> _getMockOrders() {
    final now = DateTime.now();
    return [
      // 商城订单
      Order(
        id: 1,
        orderNumber: 'MALL-20251228-001',
        userId: 1001,
        orderItems: [
          OrderItem(id: 1, productId: 1, productName: '商品1', quantity: 2, unitPrice: 100.0, subtotal: 200.0),
          OrderItem(id: 2, productId: 2, productName: '商品2', quantity: 1, unitPrice: 150.0, subtotal: 150.0),
        ],
        totalAmount: 350.0,
        status: 'PENDING',
        paymentMethod: '微信支付',
        paymentStatus: 'PAID',
        shippingAddress: '北京市朝阳区',
        billingAddress: '北京市朝阳区',
        shippingMethod: '快递',
        trackingNumber: 'SF1234567890',
        notes: '加急订单',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        orderType: 'mall',
      ),
      Order(
        id: 2,
        orderNumber: 'MALL-20251228-002',
        userId: 1002,
        orderItems: [
          OrderItem(id: 3, productId: 3, productName: '商品3', quantity: 3, unitPrice: 80.0, subtotal: 240.0),
        ],
        totalAmount: 240.0,
        status: 'APPROVED',
        paymentMethod: '支付宝',
        paymentStatus: 'PAID',
        shippingAddress: '上海市浦东新区',
        billingAddress: '上海市浦东新区',
        shippingMethod: '快递',
        trackingNumber: 'YT9876543210',
        notes: '',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        orderType: 'mall',
      ),
      // 集货商订单
      Order(
        id: 3,
        orderNumber: 'COLLECTOR-20251228-001',
        userId: 2001,
        orderItems: [
          OrderItem(id: 4, productId: 1, productName: '商品1', quantity: 10, unitPrice: 95.0, subtotal: 950.0),
          OrderItem(id: 5, productId: 2, productName: '商品2', quantity: 5, unitPrice: 145.0, subtotal: 725.0),
        ],
        totalAmount: 1675.0,
        status: 'PROCESSING',
        paymentMethod: '银行转账',
        paymentStatus: 'PAID',
        shippingAddress: '广州市天河区',
        billingAddress: '广州市天河区',
        shippingMethod: '物流',
        trackingNumber: 'JD1234567890',
        notes: '集货商订单',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        orderType: 'collector',
      ),
      // 其它订单
      Order(
        id: 4,
        orderNumber: 'OTHER-20251228-001',
        userId: 3001,
        orderItems: [
          OrderItem(id: 6, productId: 4, productName: '商品4', quantity: 1, unitPrice: 500.0, subtotal: 500.0),
        ],
        totalAmount: 500.0,
        status: 'SHIPPED',
        paymentMethod: '微信支付',
        paymentStatus: 'PAID',
        shippingAddress: '深圳市南山区',
        billingAddress: '深圳市南山区',
        shippingMethod: '快递',
        trackingNumber: 'ZT1112223334',
        notes: '其它类型订单',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        orderType: 'other',
      ),
      // 补发货（退换货）订单
      Order(
        id: 5,
        orderNumber: 'SUPPLEMENT-20251228-001',
        userId: 1001,
        orderItems: [
          OrderItem(id: 7, productId: 1, productName: '商品1', quantity: 1, unitPrice: 100.0, subtotal: 100.0),
        ],
        totalAmount: 100.0,
        status: 'PENDING',
        paymentMethod: '微信支付',
        paymentStatus: 'REFUNDED',
        shippingAddress: '北京市朝阳区',
        billingAddress: '北京市朝阳区',
        shippingMethod: '快递',
        trackingNumber: 'SF0001112223',
        notes: '补发货订单',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        orderType: 'supplement',
      ),
      // 办理订单（待处理）
      Order(
        id: 6,
        orderNumber: 'HANDLE-20251228-001',
        userId: 4001,
        orderItems: [
          OrderItem(id: 8, productId: 5, productName: '商品5', quantity: 2, unitPrice: 200.0, subtotal: 400.0),
        ],
        totalAmount: 400.0,
        status: 'PENDING',
        paymentMethod: '支付宝',
        paymentStatus: 'UNPAID',
        shippingAddress: '杭州市西湖区',
        billingAddress: '杭州市西湖区',
        shippingMethod: '快递',
        trackingNumber: null,
        notes: '待处理订单',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        orderType: 'handle',
      ),
    ];
  }

  // 根据ID获取订单详情 - 离线优先策略
  Future<Order> getOrderById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/orders/$id');
        final order = Order.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveOrders([order]);
        return order;
      } else {
        // 离线：从本地存储获取数据
        final order = await _localStorageService.getOrderById(id);
        if (order == null) {
          throw Exception('订单不存在');
        }
        return order;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final order = await _localStorageService.getOrderById(id);
        if (order == null) {
          throw Exception('订单不存在');
        }
        return order;
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 创建订单 - 离线优先策略
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/orders', data: orderData);
        final order = Order.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveOrders([order]);
        return order;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的订单
        // 注意：离线创建时需要生成临时ID，同步时替换
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final order = Order(
          id: tempId, // 临时ID
          orderNumber: 'OFFLINE-${tempId}',
          userId: orderData['userId'],
          orderItems: (orderData['orderItems'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList(),
          totalAmount: orderData['totalAmount'],
          status: 'PENDING',
          paymentMethod: orderData['paymentMethod'],
          paymentStatus: orderData['paymentStatus'],
          shippingAddress: orderData['shippingAddress'],
          billingAddress: orderData['billingAddress'],
          shippingMethod: orderData['shippingMethod'],
          trackingNumber: orderData['trackingNumber'],
          notes: orderData['notes'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveOrders([order]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'order',
          data: orderData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return order;
      }
    } catch (error) {
      rethrow;
    }
  }

  // 更新订单 - 离线优先策略
  Future<Order> updateOrder(int id, Map<String, dynamic> orderData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/orders/$id', data: orderData);
        final order = Order.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveOrders([order]);
        return order;
      } else {
        // 离线：从本地存储获取订单，更新后保存，添加到同步队列
        final existingOrder = await _localStorageService.getOrderById(id);
        if (existingOrder == null) {
          throw Exception('订单不存在');
        }
        
        // 从orderData获取orderItems，如果没有则使用现有订单的orderItems
        final orderItems = orderData.containsKey('orderItems')
            ? (orderData['orderItems'] as List<dynamic>)
                .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
                .toList()
            : existingOrder.orderItems;
        
        final updatedOrder = Order(
          id: existingOrder.id,
          orderNumber: existingOrder.orderNumber,
          userId: existingOrder.userId,
          orderItems: orderItems,
          totalAmount: orderData['totalAmount'] ?? existingOrder.totalAmount,
          status: orderData['status'] ?? existingOrder.status,
          paymentMethod: orderData['paymentMethod'] ?? existingOrder.paymentMethod,
          paymentStatus: orderData['paymentStatus'] ?? existingOrder.paymentStatus,
          shippingAddress: orderData['shippingAddress'] ?? existingOrder.shippingAddress,
          billingAddress: orderData['billingAddress'] ?? existingOrder.billingAddress,
          shippingMethod: orderData['shippingMethod'] ?? existingOrder.shippingMethod,
          trackingNumber: orderData['trackingNumber'] ?? existingOrder.trackingNumber,
          notes: orderData['notes'] ?? existingOrder.notes,
          createdAt: existingOrder.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveOrders([updatedOrder]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'order',
          data: {...orderData, 'id': id}, // 确保数据中包含ID
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedOrder;
      }
    } catch (error) {
      rethrow;
    }
  }

  // 更新订单状态 - 离线优先策略
  Future<Order> updateOrderStatus(int id, String status) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/orders/$id/status', data: status);
        final order = Order.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveOrders([order]);
        return order;
      } else {
        // 离线：从本地存储获取订单，更新后保存，添加到同步队列
        final existingOrder = await _localStorageService.getOrderById(id);
        if (existingOrder == null) {
          throw Exception('订单不存在');
        }
        
        final updatedOrder = Order(
          id: existingOrder.id,
          orderNumber: existingOrder.orderNumber,
          userId: existingOrder.userId,
          orderItems: existingOrder.orderItems,
          totalAmount: existingOrder.totalAmount,
          status: status,
          paymentMethod: existingOrder.paymentMethod,
          paymentStatus: existingOrder.paymentStatus,
          shippingAddress: existingOrder.shippingAddress,
          billingAddress: existingOrder.billingAddress,
          shippingMethod: existingOrder.shippingMethod,
          trackingNumber: existingOrder.trackingNumber,
          notes: existingOrder.notes,
          createdAt: existingOrder.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveOrders([updatedOrder]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'order',
          data: {'id': id, 'status': status},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedOrder;
      }
    } catch (error) {
      rethrow;
    }
  }

  // 更新订单支付状态 - 离线优先策略
  Future<Order> updatePaymentStatus(int id, String paymentStatus) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/orders/$id/payment-status', data: paymentStatus);
        final order = Order.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveOrders([order]);
        return order;
      } else {
        // 离线：从本地存储获取订单，更新后保存，添加到同步队列
        final existingOrder = await _localStorageService.getOrderById(id);
        if (existingOrder == null) {
          throw Exception('订单不存在');
        }
        
        final updatedOrder = Order(
          id: existingOrder.id,
          orderNumber: existingOrder.orderNumber,
          userId: existingOrder.userId,
          orderItems: existingOrder.orderItems,
          totalAmount: existingOrder.totalAmount,
          status: existingOrder.status,
          paymentMethod: existingOrder.paymentMethod,
          paymentStatus: paymentStatus,
          shippingAddress: existingOrder.shippingAddress,
          billingAddress: existingOrder.billingAddress,
          shippingMethod: existingOrder.shippingMethod,
          trackingNumber: existingOrder.trackingNumber,
          notes: existingOrder.notes,
          createdAt: existingOrder.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveOrders([updatedOrder]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'order',
          data: {'id': id, 'paymentStatus': paymentStatus},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedOrder;
      }
    } catch (error) {
      rethrow;
    }
  }

  // 取消订单 - 离线优先策略
  Future<Order> cancelOrder(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/orders/$id/cancel');
        final order = Order.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveOrders([order]);
        return order;
      } else {
        // 离线：从本地存储获取订单，更新后保存，添加到同步队列
        final existingOrder = await _localStorageService.getOrderById(id);
        if (existingOrder == null) {
          throw Exception('订单不存在');
        }
        
        final updatedOrder = Order(
          id: existingOrder.id,
          orderNumber: existingOrder.orderNumber,
          userId: existingOrder.userId,
          orderItems: existingOrder.orderItems,
          totalAmount: existingOrder.totalAmount,
          status: 'CANCELLED',
          paymentMethod: existingOrder.paymentMethod,
          paymentStatus: existingOrder.paymentStatus,
          shippingAddress: existingOrder.shippingAddress,
          billingAddress: existingOrder.billingAddress,
          shippingMethod: existingOrder.shippingMethod,
          trackingNumber: existingOrder.trackingNumber,
          notes: existingOrder.notes,
          createdAt: existingOrder.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveOrders([updatedOrder]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'order',
          data: {'id': id, 'status': 'CANCELLED'},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedOrder;
      }
    } catch (error) {
      rethrow;
    }
  }

  // 删除订单 - 离线优先策略
  Future<void> deleteOrder(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/orders/$id');
        
        // 更新本地存储
        await _localStorageService.deleteOrder(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteOrder(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'order',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteOrder(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'order',
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

  // 批量删除订单 - 离线优先策略
  Future<void> batchDeleteOrders(List<int> ids) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/orders/batch', data: {'ids': ids});
        
        // 更新本地存储
        for (final id in ids) {
          await _localStorageService.deleteOrder(id);
        }
      } else {
        // 离线：直接从本地存储删除，逐个添加到同步队列
        for (final id in ids) {
          await _localStorageService.deleteOrder(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'order',
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
          await _localStorageService.deleteOrder(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'order',
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

  // 搜索订单 - 离线优先策略
  Future<List<Order>> searchOrders(String keyword, {Map<String, dynamic>? params}) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final queryParams = {
          'keyword': keyword,
          ...?params,
        };
        final response = await HttpClient.get('/orders/search', queryParameters: queryParams);
        final ordersJson = response.data['data'] as List;
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        // 离线：从本地存储搜索
        final allOrders = await _localStorageService.getOrders();
        return allOrders.where((order) => 
          order.orderNumber.contains(keyword) || 
          order.shippingAddress?.contains(keyword) == true ||
          order.billingAddress?.contains(keyword) == true
        ).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储搜索
      try {
        final allOrders = await _localStorageService.getOrders();
        return allOrders.where((order) => 
          order.orderNumber.contains(keyword) || 
          order.shippingAddress?.contains(keyword) == true ||
          order.billingAddress?.contains(keyword) == true
        ).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 获取用户的订单列表 - 离线优先策略
  Future<List<Order>> getUserOrders(int userId, {Map<String, dynamic>? params}) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/orders/user/$userId', queryParameters: params);
        final ordersJson = response.data['data'] as List;
        final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
        
        // 更新本地存储
        await _localStorageService.saveOrders(orders);
        return orders;
      } else {
        // 离线：从本地存储获取数据
        final allOrders = await _localStorageService.getOrders();
        return allOrders.where((order) => order.userId == userId).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final allOrders = await _localStorageService.getOrders();
        return allOrders.where((order) => order.userId == userId).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }
}