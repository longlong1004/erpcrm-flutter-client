class ProductCategory {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? parentId;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductCategory>? children;

  ProductCategory({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.parentId,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.children,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      parentId: json['parentId'],
      sortOrder: json['sortOrder'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      children: json['children'] != null
          ? (json['children'] as List).map((child) => ProductCategory.fromJson(child)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'parentId': parentId,
      'sortOrder': sortOrder,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }
}
