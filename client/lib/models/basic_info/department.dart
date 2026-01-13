class Department {
  final int id;
  final String name;
  final String manager;
  final String phoneNumber;
  final DateTime createdAt;

  Department({
    required this.id,
    required this.name,
    required this.manager,
    required this.phoneNumber,
    required this.createdAt,
  });

  // 从JSON创建Department实例
  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      name: json['name'] as String,
      manager: json['manager'] as String,
      phoneNumber: json['phoneNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // 将Department实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manager': manager,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 复制Department实例并可选择性修改属性
  Department copyWith({
    int? id,
    String? name,
    String? manager,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      manager: manager ?? this.manager,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}