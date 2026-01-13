import 'package:hive/hive.dart';
import 'dart:convert';

part 'data_dictionary.g.dart';

@HiveType(typeId: 102)
class DataDictionary {
  @HiveField(0)
  int? id;
  
  @HiveField(1)
  String dictType;
  
  @HiveField(2)
  String dictCode;
  
  @HiveField(3)
  String dictValue;
  
  @HiveField(4)
  String dictName;
  
  @HiveField(5)
  String? description;
  
  @HiveField(6)
  int sortOrder;
  
  @HiveField(7)
  bool isActive;
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime updatedAt;
  
  @HiveField(10)
  bool isSynced;

  DataDictionary({
    this.id,
    required this.dictType,
    required this.dictCode,
    required this.dictValue,
    required this.dictName,
    this.description,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dictType': dictType,
      'dictCode': dictCode,
      'dictValue': dictValue,
      'dictName': dictName,
      'description': description,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DataDictionary.fromJson(Map<String, dynamic> json) {
    return DataDictionary(
      id: json['id'],
      dictType: json['dictType'],
      dictCode: json['dictCode'],
      dictValue: json['dictValue'],
      dictName: json['dictName'],
      description: json['description'],
      sortOrder: json['sortOrder'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? true,
    );
  }
}
