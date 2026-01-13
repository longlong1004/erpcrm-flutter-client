import 'package:hive/hive.dart';
import 'dart:convert';

part 'system_parameter.g.dart';

@HiveType(typeId: 101)
class SystemParameter {
  @HiveField(0)
  int? id;
  
  @HiveField(1)
  String parameterKey;
  
  @HiveField(2)
  String parameterValue;
  
  @HiveField(3)
  String parameterDescription;
  
  @HiveField(4)
  String parameterType;
  
  @HiveField(5)
  String defaultValue;
  
  @HiveField(6)
  bool isEditable;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;
  
  @HiveField(9)
  bool isSynced;

  SystemParameter({
    this.id,
    required this.parameterKey,
    required this.parameterValue,
    required this.parameterDescription,
    required this.parameterType,
    required this.defaultValue,
    required this.isEditable,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parameterKey': parameterKey,
      'parameterValue': parameterValue,
      'parameterDescription': parameterDescription,
      'parameterType': parameterType,
      'defaultValue': defaultValue,
      'isEditable': isEditable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SystemParameter.fromJson(Map<String, dynamic> json) {
    return SystemParameter(
      id: json['id'],
      parameterKey: json['parameterKey'],
      parameterValue: json['parameterValue'],
      parameterDescription: json['parameterDescription'],
      parameterType: json['parameterType'],
      defaultValue: json['defaultValue'],
      isEditable: json['isEditable'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? true,
    );
  }
}
