import 'package:hive/hive.dart';

part 'warehouse.g.dart';

@HiveType(typeId: 10)
class Warehouse extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String code;
  @HiveField(3)
  final String? address;
  @HiveField(4)
  final String? manager;
  @HiveField(5)
  final String? phone;
  @HiveField(6)
  final String? description;
  @HiveField(7)
  final String status;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final DateTime updatedAt;
  @HiveField(10)
  final bool isSynced;

  Warehouse({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.manager,
    this.phone,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String?,
      manager: json['manager'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'manager': manager,
      'phone': phone,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }
}

@HiveType(typeId: 11)
class Inventory extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int productId;
  @HiveField(2)
  final String productName;
  @HiveField(3)
  final String productCode;
  @HiveField(4)
  final int warehouseId;
  @HiveField(5)
  final String warehouseName;
  @HiveField(6)
  final int quantity;
  @HiveField(7)
  final int safetyStock;
  @HiveField(8)
  final double unitPrice;
  @HiveField(9)
  final double totalValue;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime updatedAt;
  @HiveField(12)
  final bool isSynced;

  Inventory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.safetyStock,
    required this.unitPrice,
    required this.totalValue,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      productCode: json['productCode'] as String,
      warehouseId: json['warehouseId'] as int,
      warehouseName: json['warehouseName'] as String,
      quantity: json['quantity'] as int,
      safetyStock: json['safetyStock'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'quantity': quantity,
      'safetyStock': safetyStock,
      'unitPrice': unitPrice,
      'totalValue': totalValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  bool get isLowStock => quantity <= safetyStock;
}

@HiveType(typeId: 12)
class StockRecord extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String recordNo;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final int productId;
  @HiveField(4)
  final String productName;
  @HiveField(5)
  final int warehouseId;
  @HiveField(6)
  final String warehouseName;
  @HiveField(7)
  final int quantity;
  @HiveField(8)
  final double unitPrice;
  @HiveField(9)
  final double totalAmount;
  @HiveField(10)
  final String? supplierName;
  @HiveField(11)
  final String? customerName;
  @HiveField(12)
  final String? remark;
  @HiveField(13)
  final String status;
  @HiveField(14)
  final DateTime operationTime;
  @HiveField(15)
  final DateTime createdAt;
  @HiveField(16)
  final String? operatorName;
  @HiveField(17)
  final bool isSynced;

  StockRecord({
    required this.id,
    required this.recordNo,
    required this.type,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.supplierName,
    this.customerName,
    this.remark,
    required this.status,
    required this.operationTime,
    required this.createdAt,
    this.operatorName,
    this.isSynced = true,
  });

  factory StockRecord.fromJson(Map<String, dynamic> json) {
    return StockRecord(
      id: json['id'] as int,
      recordNo: json['recordNo'] as String,
      type: json['type'] as String,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      warehouseId: json['warehouseId'] as int,
      warehouseName: json['warehouseName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      supplierName: json['supplierName'] as String?,
      customerName: json['customerName'] as String?,
      remark: json['remark'] as String?,
      status: json['status'] as String,
      operationTime: DateTime.parse(json['operationTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      operatorName: json['operatorName'] as String?,
      isSynced: json['isSynced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordNo': recordNo,
      'type': type,
      'productId': productId,
      'productName': productName,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'supplierName': supplierName,
      'customerName': customerName,
      'remark': remark,
      'status': status,
      'operationTime': operationTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'operatorName': operatorName,
      'isSynced': isSynced,
    };
  }
}
