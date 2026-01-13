import 'package:hive_flutter/hive_flutter.dart';

part 'customer_category.g.dart';

@HiveType(typeId: 5)
class CustomerCategory {
  @HiveField(0)
  final int categoryId;
  @HiveField(1)
  final String categoryName;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final int sortOrder;
  @HiveField(4)
  final DateTime createTime;
  @HiveField(5)
  final DateTime updateTime;
  @HiveField(6)
  final bool deleted;

  CustomerCategory({
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.sortOrder,
    required this.createTime,
    required this.updateTime,
    required this.deleted,
  });

  factory CustomerCategory.fromJson(Map<String, dynamic> json) {
    return CustomerCategory(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      description: json['description'],
      sortOrder: json['sortOrder'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
      deleted: json['deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'sortOrder': sortOrder,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'deleted': deleted,
    };
  }
}
