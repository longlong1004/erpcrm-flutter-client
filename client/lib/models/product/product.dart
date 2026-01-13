import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String code;
  @HiveField(3)
  final String specification;
  @HiveField(4)
  final String model;
  @HiveField(5)
  final String unit;
  @HiveField(6)
  final double price;
  @HiveField(7)
  final double costPrice;
  @HiveField(8)
  final double originalPrice;
  @HiveField(9)
  final int stock;
  @HiveField(10)
  final int safetyStock;
  @HiveField(11)
  final int categoryId;
  @HiveField(12)
  final String? brand;
  @HiveField(13)
  final String? manufacturer;
  @HiveField(14)
  final int? supplierId;
  @HiveField(15)
  final String? barcode;
  @HiveField(16)
  final String? imageUrl;
  @HiveField(17)
  final String? description;
  @HiveField(18)
  final String status;
  @HiveField(19)
  final DateTime createdAt;
  @HiveField(20)
  final DateTime updatedAt;
  @HiveField(21)
  final int? salespersonId;
  @HiveField(22)
  final String? salespersonName;
  @HiveField(23)
  final String? companyName;
  @HiveField(24)
  final String? categoryName;
  @HiveField(25)
  final double? weight;
  @HiveField(26)
  final String? dimensions;
  @HiveField(27)
  final String? railwayBureau;
  @HiveField(28)
  final String? station;
  @HiveField(29)
  final String? customer;
  @HiveField(30)
  final String? actualName;
  @HiveField(31)
  final String? actualModel;
  @HiveField(32)
  final double? purchasePrice;
  @HiveField(33)
  final String? supplierName;
  @HiveField(34)
  final List<String>? imageUrls;
  @HiveField(35)
  final String? note;
  @HiveField(36)
  final List<String>? mainImageUrls;
  @HiveField(37)
  final String? detailImageUrl;
  @HiveField(38)
  final String? barcode69;
  @HiveField(39)
  final String? externalLink;
  @HiveField(40)
  final int? approvalUserId;
  @HiveField(41)
  final String? approvalUserName;
  @HiveField(42)
  final DateTime? approvalTime;
  @HiveField(43)
  final String? approvalComment;
  @HiveField(44)
  final bool isSynced;

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.specification,
    required this.model,
    required this.unit,
    required this.price,
    required this.costPrice,
    required this.originalPrice,
    required this.stock,
    required this.safetyStock,
    required this.categoryId,
    this.brand,
    this.manufacturer,
    this.supplierId,
    this.barcode,
    this.imageUrl,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.salespersonId,
    this.salespersonName,
    this.companyName,
    this.categoryName,
    this.weight,
    this.dimensions,
    this.railwayBureau,
    this.station,
    this.customer,
    this.actualName,
    this.actualModel,
    this.purchasePrice,
    this.supplierName,
    this.imageUrls,
    this.note,
    this.mainImageUrls,
    this.detailImageUrl,
    this.barcode69,
    this.externalLink,
    this.approvalUserId,
    this.approvalUserName,
    this.approvalTime,
    this.approvalComment,
    this.isSynced = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      specification: json['specification'],
      model: json['model'],
      unit: json['unit'],
      price: json['price'].toDouble(),
      costPrice: json['costPrice'].toDouble(),
      originalPrice: json['originalPrice'].toDouble(),
      stock: json['stock'],
      safetyStock: json['safetyStock'],
      categoryId: json['categoryId'],
      brand: json['brand'],
      manufacturer: json['manufacturer'],
      supplierId: json['supplierId'],
      barcode: json['barcode'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      salespersonId: json['salespersonId'],
      salespersonName: json['salespersonName'],
      companyName: json['companyName'],
      categoryName: json['categoryName'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
      railwayBureau: json['railwayBureau'],
      station: json['station'],
      customer: json['customer'],
      actualName: json['actualName'],
      actualModel: json['actualModel'],
      purchasePrice: json['purchasePrice']?.toDouble(),
      supplierName: json['supplierName'],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      note: json['note'],
      mainImageUrls: json['mainImageUrls'] != null ? List<String>.from(json['mainImageUrls']) : null,
      detailImageUrl: json['detailImageUrl'],
      barcode69: json['barcode69'],
      externalLink: json['externalLink'],
      approvalUserId: json['approvalUserId'],
      approvalUserName: json['approvalUserName'],
      approvalTime: json['approvalTime'] != null ? DateTime.parse(json['approvalTime']) : null,
      approvalComment: json['approvalComment'],
      isSynced: json['isSynced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'specification': specification,
      'model': model,
      'unit': unit,
      'price': price,
      'costPrice': costPrice,
      'originalPrice': originalPrice,
      'stock': stock,
      'safetyStock': safetyStock,
      'categoryId': categoryId,
      'brand': brand,
      'manufacturer': manufacturer,
      'supplierId': supplierId,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'salespersonId': salespersonId,
      'salespersonName': salespersonName,
      'companyName': companyName,
      'categoryName': categoryName,
      'weight': weight,
      'dimensions': dimensions,
      'railwayBureau': railwayBureau,
      'station': station,
      'customer': customer,
      'actualName': actualName,
      'actualModel': actualModel,
      'purchasePrice': purchasePrice,
      'supplierName': supplierName,
      'imageUrls': imageUrls,
      'note': note,
      'mainImageUrls': mainImageUrls,
      'detailImageUrl': detailImageUrl,
      'barcode69': barcode69,
      'externalLink': externalLink,
      'approvalUserId': approvalUserId,
      'approvalUserName': approvalUserName,
      'approvalTime': approvalTime?.toIso8601String(),
      'approvalComment': approvalComment,
      'isSynced': isSynced,
    };
  }
}
