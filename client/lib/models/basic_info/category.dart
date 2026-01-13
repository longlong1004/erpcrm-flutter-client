class Category {
  final int id;
  final String name;
  final String companyName;
  final String? parentId;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.companyName,
    this.parentId,
    required this.createdAt,
  });

  // 从JSON创建Category实例
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      companyName: json['companyName'] as String,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // 将Category实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 复制Category实例并可选择性修改属性
  Category copyWith({
    int? id,
    String? name,
    String? companyName,
    String? parentId,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}