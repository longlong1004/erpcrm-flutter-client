import 'package:hive_flutter/hive_flutter.dart';

part 'customer_tag.g.dart';

@HiveType(typeId: 6)
class CustomerTag {
  @HiveField(0)
  final int tagId;
  @HiveField(1)
  final String tagName;
  @HiveField(2)
  final String tagCode;
  @HiveField(3)
  final String tagDesc;
  @HiveField(4)
  final int status;
  @HiveField(5)
  final DateTime createTime;
  @HiveField(6)
  final DateTime updateTime;
  @HiveField(7)
  final bool deleted;

  CustomerTag({
    required this.tagId,
    required this.tagName,
    required this.tagCode,
    required this.tagDesc,
    required this.status,
    required this.createTime,
    required this.updateTime,
    required this.deleted,
  });

  factory CustomerTag.fromJson(Map<String, dynamic> json) {
    return CustomerTag(
      tagId: json['tagId'],
      tagName: json['tagName'],
      tagCode: json['tagCode'],
      tagDesc: json['tagDesc'],
      status: json['status'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
      deleted: json['deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagId': tagId,
      'tagName': tagName,
      'tagCode': tagCode,
      'tagDesc': tagDesc,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'deleted': deleted,
    };
  }
}