class TaxCategory {
  final int id;
  final String taxCode;
  final String shortCode;
  final String productName;
  final String categoryName;
  final String description;
  final String taxRate;
  final String keywords;
  final bool isSummary;
  final String specialManagement;
  final String taxPolicy;
  final String consumptionTaxPolicy;
  final String consumptionTaxRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaxCategory({
    required this.id,
    required this.taxCode,
    required this.shortCode,
    required this.productName,
    required this.categoryName,
    required this.description,
    required this.taxRate,
    required this.keywords,
    required this.isSummary,
    required this.specialManagement,
    required this.taxPolicy,
    required this.consumptionTaxPolicy,
    required this.consumptionTaxRule,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从JSON创建TaxCategory实例
  factory TaxCategory.fromJson(Map<String, dynamic> json) {
    return TaxCategory(
      id: json['id'] as int,
      taxCode: json['taxCode'] as String,
      shortCode: json['shortCode'] as String,
      productName: json['productName'] as String,
      categoryName: json['categoryName'] as String,
      description: json['description'] as String,
      taxRate: json['taxRate'] as String,
      keywords: json['keywords'] as String,
      isSummary: json['isSummary'] as bool,
      specialManagement: json['specialManagement'] as String,
      taxPolicy: json['taxPolicy'] as String,
      consumptionTaxPolicy: json['consumptionTaxPolicy'] as String,
      consumptionTaxRule: json['consumptionTaxRule'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // 将TaxCategory实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taxCode': taxCode,
      'shortCode': shortCode,
      'productName': productName,
      'categoryName': categoryName,
      'description': description,
      'taxRate': taxRate,
      'keywords': keywords,
      'isSummary': isSummary,
      'specialManagement': specialManagement,
      'taxPolicy': taxPolicy,
      'consumptionTaxPolicy': consumptionTaxPolicy,
      'consumptionTaxRule': consumptionTaxRule,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 复制TaxCategory实例并可选择性修改属性
  TaxCategory copyWith({
    int? id,
    String? taxCode,
    String? shortCode,
    String? productName,
    String? categoryName,
    String? description,
    String? taxRate,
    String? keywords,
    bool? isSummary,
    String? specialManagement,
    String? taxPolicy,
    String? consumptionTaxPolicy,
    String? consumptionTaxRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxCategory(
      id: id ?? this.id,
      taxCode: taxCode ?? this.taxCode,
      shortCode: shortCode ?? this.shortCode,
      productName: productName ?? this.productName,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      taxRate: taxRate ?? this.taxRate,
      keywords: keywords ?? this.keywords,
      isSummary: isSummary ?? this.isSummary,
      specialManagement: specialManagement ?? this.specialManagement,
      taxPolicy: taxPolicy ?? this.taxPolicy,
      consumptionTaxPolicy: consumptionTaxPolicy ?? this.consumptionTaxPolicy,
      consumptionTaxRule: consumptionTaxRule ?? this.consumptionTaxRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}