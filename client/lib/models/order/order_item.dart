import 'package:hive/hive.dart';

part 'order_item.g.dart';

@HiveType(typeId: 2)
class OrderItem {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int productId;
  @HiveField(2)
  final int quantity;
  @HiveField(3)
  final double unitPrice;
  @HiveField(4)
  final double subtotal;
  @HiveField(5)
  final String productName;
  @HiveField(6)
  final String productSku;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.productName,
    this.productSku = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as double,
      subtotal: json['subtotal'] as double,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'productName': productName,
      'productSku': productSku,
    };
  }
}