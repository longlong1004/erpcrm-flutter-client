import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'order_item.dart';

part 'order.g.dart';

@HiveType(typeId: 3)
class Order extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String orderNumber;
  @HiveField(2)
  final int userId;
  @HiveField(3)
  final List<OrderItem> orderItems;
  @HiveField(4)
  final double totalAmount;
  @HiveField(5)
  final String status;
  @HiveField(6)
  final String? paymentMethod;
  @HiveField(7)
  final String? paymentStatus;
  @HiveField(8)
  final String? shippingAddress;
  @HiveField(9)
  final String? billingAddress;
  @HiveField(10)
  final String? shippingMethod;
  @HiveField(11)
  final String? trackingNumber;
  @HiveField(12)
  final String? notes;
  @HiveField(13)
  final DateTime createdAt;
  @HiveField(14)
  final DateTime updatedAt;
  @HiveField(15)
  final String? orderType;

  // orderDate getter - 使用 createdAt 作为订单日期
  DateTime get orderDate => createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.orderItems,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.shippingAddress,
    this.billingAddress,
    this.shippingMethod,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.orderType,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      userId: json['userId'] as int,
      orderItems: (json['orderItems'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: json['totalAmount'] as double,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
      billingAddress: json['billingAddress'] as String?,
      shippingMethod: json['shippingMethod'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      orderType: json['orderType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'shippingMethod': shippingMethod,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'orderType': orderType,
    };
  }

  // 获取状态的中文显示
  String get statusText {
    switch (status) {
      case 'PENDING':
        return '待审核';
      case 'APPROVED':
        return '已通过';
      case 'REJECTED':
        return '审核驳回';
      case 'PROCESSING':
        return '处理中';
      case 'SHIPPED':
        return '已发货';
      case 'DELIVERED':
        return '已送达';
      case 'CANCELLED':
        return '已取消';
      case 'REFUNDED':
        return '已退款';
      default:
        return status;
    }
  }

  // 获取支付状态的中文显示
  String get paymentStatusText {
    switch (paymentStatus) {
      case 'PAID':
        return '已支付';
      case 'UNPAID':
        return '未支付';
      case 'REFUNDED':
        return '已退款';
      case 'PARTIALLY_REFUNDED':
        return '部分退款';
      default:
        return paymentStatus ?? '未知';
    }
  }

  // 格式化日期
  String get formattedCreatedAt {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);
  }

  // 格式化日期
  String get formattedUpdatedAt {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt);
  }

  // 格式化金额
  String get formattedTotalAmount {
    return '¥${totalAmount.toStringAsFixed(2)}';
  }

  // 获取状态选项
  static List<String> get statusOptions => [
    'PENDING',
    'APPROVED',
    'REJECTED',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED',
    'REFUNDED',
  ];

  // 获取支付状态选项
  static List<String> get paymentStatusOptions => [
    'PAID',
    'UNPAID',
    'REFUNDED',
    'PARTIALLY_REFUNDED',
  ];
}