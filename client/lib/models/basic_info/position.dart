class Position {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;

  Position({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  // 从JSON创建Position实例
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // 将Position实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 复制Position实例并可选择性修改属性
  Position copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Position(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}