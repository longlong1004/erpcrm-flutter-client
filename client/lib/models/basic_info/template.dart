class Template {
  final int id;
  final String name;
  final String associatedObject;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Template({
    required this.id,
    required this.name,
    required this.associatedObject,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从JSON创建Template实例
  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as int,
      name: json['name'] as String,
      associatedObject: json['associatedObject'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // 将Template实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'associatedObject': associatedObject,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 复制Template实例并可选择性修改属性
  Template copyWith({
    int? id,
    String? name,
    String? associatedObject,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      associatedObject: associatedObject ?? this.associatedObject,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}