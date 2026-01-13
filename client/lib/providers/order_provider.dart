import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order/order.dart';
import '../models/order/order_item.dart';
import '../services/order_service.dart';

// 创建OrderService的provider
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// 订单列表状态管理
final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(
  () => OrdersNotifier(),
);

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  late final OrderService _orderService;

  @override
  Future<List<Order>> build() async {
    _orderService = ref.read(orderServiceProvider);
    try {
      return await _orderService.getOrders();
    } catch (e) {
      // API调用失败，返回模拟订单数据
      print('获取订单数据失败，使用模拟数据: $e');
      return _getMockOrders();
    }
  }

  // 模拟订单数据
  List<Order> _getMockOrders() {
    final now = DateTime.now();
    return [
      // 商城订单
      Order(
        id: 1,
        orderNumber: '【订单示例1】MALL-20251228-001',
        userId: 1001,
        orderItems: [
          OrderItem(id: 1, productId: 1, productName: '【商品示例1】铁路信号设备', quantity: 2, unitPrice: 15000.00, subtotal: 30000.00),
          OrderItem(id: 2, productId: 2, productName: '【商品示例2】铁路轨道扣件', quantity: 5, unitPrice: 800.00, subtotal: 4000.00),
        ],
        totalAmount: 34000.00,
        status: 'PENDING',
        paymentMethod: '微信支付',
        paymentStatus: 'PAID',
        shippingAddress: '北京市朝阳区',
        billingAddress: '北京市朝阳区',
        shippingMethod: '快递',
        trackingNumber: 'SF1234567890',
        notes: '【订单示例1】加急订单，示例数据',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        orderType: 'mall',
      ),
      Order(
        id: 2,
        orderNumber: '【订单示例2】MALL-20251228-002',
        userId: 1002,
        orderItems: [
          OrderItem(id: 3, productId: 3, productName: '【商品示例3】铁路通信设备', quantity: 1, unitPrice: 25000.00, subtotal: 25000.00),
        ],
        totalAmount: 25000.00,
        status: 'APPROVED',
        paymentMethod: '支付宝',
        paymentStatus: 'PAID',
        shippingAddress: '上海市浦东新区',
        billingAddress: '上海市浦东新区',
        shippingMethod: '快递',
        trackingNumber: 'YT9876543210',
        notes: '【订单示例2】示例数据',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        orderType: 'mall',
      ),
      // 集货商订单
      Order(
        id: 3,
        orderNumber: '【订单示例3】COLLECTOR-20251228-001',
        userId: 2001,
        orderItems: [
          OrderItem(id: 4, productId: 1, productName: '【商品示例1】铁路信号设备', quantity: 10, unitPrice: 14500.00, subtotal: 145000.00),
          OrderItem(id: 5, productId: 2, productName: '【商品示例2】铁路轨道扣件', quantity: 20, unitPrice: 750.00, subtotal: 15000.00),
        ],
        totalAmount: 160000.00,
        status: 'PROCESSING',
        paymentMethod: '银行转账',
        paymentStatus: 'PAID',
        shippingAddress: '广州市天河区',
        billingAddress: '广州市天河区',
        shippingMethod: '物流',
        trackingNumber: 'JD1234567890',
        notes: '【订单示例3】集货商订单，示例数据',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        orderType: 'collector',
      ),
      // 其它订单
      Order(
        id: 4,
        orderNumber: '【订单示例4】OTHER-20251228-001',
        userId: 3001,
        orderItems: [
          OrderItem(id: 6, productId: 4, productName: '【商品示例4】铁路照明设备', quantity: 3, unitPrice: 5000.00, subtotal: 15000.00),
        ],
        totalAmount: 15000.00,
        status: 'SHIPPED',
        paymentMethod: '微信支付',
        paymentStatus: 'PAID',
        shippingAddress: '深圳市南山区',
        billingAddress: '深圳市南山区',
        shippingMethod: '快递',
        trackingNumber: 'ZT1112223334',
        notes: '【订单示例4】其它类型订单，示例数据',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        orderType: 'other',
      ),
      // 补发货（退换货）订单
      Order(
        id: 5,
        orderNumber: '【订单示例5】SUPPLEMENT-20251228-001',
        userId: 1001,
        orderItems: [
          OrderItem(id: 7, productId: 1, productName: '【商品示例1】铁路信号设备', quantity: 1, unitPrice: 15000.00, subtotal: 15000.00),
        ],
        totalAmount: 15000.00,
        status: 'PENDING',
        paymentMethod: '微信支付',
        paymentStatus: 'REFUNDED',
        shippingAddress: '北京市朝阳区',
        billingAddress: '北京市朝阳区',
        shippingMethod: '快递',
        trackingNumber: 'SF0001112223',
        notes: '【订单示例5】补发货订单，示例数据',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        orderType: 'supplement',
      ),
      // 办理订单（待处理）
      Order(
        id: 6,
        orderNumber: '【订单示例6】HANDLE-20251228-001',
        userId: 4001,
        orderItems: [
          OrderItem(id: 8, productId: 5, productName: '【商品示例5】铁路电力设备', quantity: 2, unitPrice: 30000.00, subtotal: 60000.00),
        ],
        totalAmount: 60000.00,
        status: 'PENDING',
        paymentMethod: '支付宝',
        paymentStatus: 'UNPAID',
        shippingAddress: '杭州市西湖区',
        billingAddress: '杭州市西湖区',
        shippingMethod: '快递',
        trackingNumber: null,
        notes: '【订单示例6】待处理订单，示例数据',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        orderType: 'handle',
      ),
      // 更多模拟订单，确保各标签页都有数据
      Order(
        id: 7,
        orderNumber: '【订单示例7】MALL-20251227-003',
        userId: 1003,
        orderItems: [
          OrderItem(id: 9, productId: 4, productName: '【商品示例4】铁路照明设备', quantity: 1, unitPrice: 5000.00, subtotal: 5000.00),
          OrderItem(id: 10, productId: 2, productName: '【商品示例2】铁路轨道扣件', quantity: 3, unitPrice: 800.00, subtotal: 2400.00),
        ],
        totalAmount: 7400.00,
        status: 'DELIVERED',
        paymentMethod: '微信支付',
        paymentStatus: 'PAID',
        shippingAddress: '成都市武侯区',
        billingAddress: '成都市武侯区',
        shippingMethod: '快递',
        trackingNumber: 'ST4445556667',
        notes: '【订单示例7】示例数据',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 3)),
        orderType: 'mall',
      ),
      Order(
        id: 8,
        orderNumber: '【订单示例8】COLLECTOR-20251227-002',
        userId: 2002,
        orderItems: [
          OrderItem(id: 11, productId: 2, productName: '【商品示例2】铁路轨道扣件', quantity: 8, unitPrice: 750.00, subtotal: 6000.00),
          OrderItem(id: 12, productId: 4, productName: '【商品示例4】铁路照明设备', quantity: 5, unitPrice: 4800.00, subtotal: 24000.00),
        ],
        totalAmount: 30000.00,
        status: 'APPROVED',
        paymentMethod: '银行转账',
        paymentStatus: 'PAID',
        shippingAddress: '武汉市江汉区',
        billingAddress: '武汉市江汉区',
        shippingMethod: '物流',
        trackingNumber: 'JD6667778889',
        notes: '【订单示例8】集货商订单，示例数据',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
        orderType: 'collector',
      ),
    ];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        return await _orderService.getOrders();
      } catch (e) {
        // API调用失败，使用模拟数据
        print('刷新订单数据失败，使用模拟数据: $e');
        return _getMockOrders();
      }
    });
  }

  Future<void> fetchOrders({Map<String, dynamic>? params}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        return await _orderService.getOrders(params: params);
      } catch (e) {
        // API调用失败，使用模拟数据并根据params过滤
        print('获取订单数据失败，使用模拟数据: $e');
        final mockOrders = _getMockOrders();
        
        // 根据params过滤模拟数据
        if (params != null && params.isNotEmpty) {
          return mockOrders.where((order) {
            // 过滤订单类型
            if (params.containsKey('orderType')) {
              final orderType = params['orderType'] as String;
              if (order.orderType != orderType) {
                // 兼容旧系统的订单号前缀过滤
                switch (orderType) {
                  case 'mall':
                    if (!order.orderNumber.contains('MALL')) return false;
                    break;
                  case 'collector':
                    if (!order.orderNumber.contains('COLLECTOR')) return false;
                    break;
                  case 'supplement':
                    if (!order.orderNumber.contains('SUPPLEMENT') && 
                        !order.status.contains('REFUND') && 
                        !order.status.contains('RETURN')) return false;
                    break;
                  case 'other':
                    if (order.orderNumber.contains('MALL') || 
                        order.orderNumber.contains('COLLECTOR')) return false;
                    break;
                }
              }
            }
            
            // 过滤关键字
            if (params.containsKey('keyword')) {
              final keyword = params['keyword'] as String;
              if (!order.orderNumber.contains(keyword) && 
                  !order.shippingAddress!.contains(keyword)) {
                return false;
              }
            }
            
            // 过滤状态
            if (params.containsKey('status')) {
              final status = params['status'] as String;
              if (order.status != status) return false;
            }
            
            // 过滤支付状态
            if (params.containsKey('paymentStatus')) {
              final paymentStatus = params['paymentStatus'] as String;
              if (order.paymentStatus != paymentStatus) return false;
            }
            
            return true;
          }).toList();
        }
        
        return mockOrders;
      }
    });
  }

  Future<void> searchOrders(String keyword, {Map<String, dynamic>? params}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        return await _orderService.searchOrders(keyword, params: params);
      } catch (e) {
        // API调用失败，使用模拟数据并搜索
        print('搜索订单数据失败，使用模拟数据: $e');
        final mockOrders = _getMockOrders();
        
        // 根据关键字搜索模拟数据
        return mockOrders.where((order) => 
          order.orderNumber.contains(keyword) || 
          order.shippingAddress?.contains(keyword) == true ||
          order.billingAddress?.contains(keyword) == true
        ).toList();
      }
    });
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    state = await AsyncValue.guard(() async {
      final newOrder = await _orderService.createOrder(orderData);
      final currentOrders = state.value ?? [];
      return [...currentOrders, newOrder];
    });
  }

  Future<void> updateOrder(int id, Map<String, dynamic> orderData) async {
    state = await AsyncValue.guard(() async {
      final updatedOrder = await _orderService.updateOrder(id, orderData);
      final currentOrders = state.value ?? [];
      return currentOrders
          .map((order) => order.id == id ? updatedOrder : order)
          .toList();
    });
  }

  Future<void> updateOrderStatus(int id, String status) async {
    state = await AsyncValue.guard(() async {
      final updatedOrder = await _orderService.updateOrderStatus(id, status);
      final currentOrders = state.value ?? [];
      return currentOrders
          .map((order) => order.id == id ? updatedOrder : order)
          .toList();
    });
  }

  Future<void> updatePaymentStatus(int id, String paymentStatus) async {
    state = await AsyncValue.guard(() async {
      final updatedOrder = await _orderService.updatePaymentStatus(id, paymentStatus);
      final currentOrders = state.value ?? [];
      return currentOrders
          .map((order) => order.id == id ? updatedOrder : order)
          .toList();
    });
  }

  Future<void> cancelOrder(int id) async {
    state = await AsyncValue.guard(() async {
      final updatedOrder = await _orderService.cancelOrder(id);
      final currentOrders = state.value ?? [];
      return currentOrders
          .map((order) => order.id == id ? updatedOrder : order)
          .toList();
    });
  }

  Future<void> deleteOrder(int id) async {
    state = await AsyncValue.guard(() async {
      await _orderService.deleteOrder(id);
      final currentOrders = state.value ?? [];
      return currentOrders
          .where((order) => order.id != id)
          .toList();
    });
  }

  Future<void> batchDeleteOrders(List<int> ids) async {
    state = await AsyncValue.guard(() async {
      await _orderService.batchDeleteOrders(ids);
      final currentOrders = state.value ?? [];
      return currentOrders
          .where((order) => !ids.contains(order.id))
          .toList();
    });
  }
}

// 单个订单状态管理
final orderProvider = AsyncNotifierProviderFamily<OrderNotifier, Order, int>(
  () => OrderNotifier(),
);

class OrderNotifier extends FamilyAsyncNotifier<Order, int> {
  late final OrderService _orderService;

  @override
  Future<Order> build(int orderId) async {
    _orderService = ref.read(orderServiceProvider);
    return await _orderService.getOrderById(orderId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _orderService.getOrderById(arg);
    });
  }

  Future<void> updateOrder(Map<String, dynamic> orderData) async {
    state = await AsyncValue.guard(() async {
      return await _orderService.updateOrder(arg, orderData);
    });
  }

  Future<void> updateOrderStatus(String status) async {
    state = await AsyncValue.guard(() async {
      return await _orderService.updateOrderStatus(arg, status);
    });
  }
}