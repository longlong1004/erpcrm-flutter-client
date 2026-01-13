import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 4)
class Customer extends HiveObject {
  @HiveField(0)
  final int customerId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String contactPerson;
  @HiveField(3)
  final String contactPhone;
  @HiveField(4)
  final String contactEmail;
  @HiveField(5)
  final String address;
  @HiveField(6)
  final int categoryId;
  @HiveField(7)
  final String categoryName;
  @HiveField(8)
  final List<int> tagIds;
  @HiveField(9)
  final List<String> tagNames;
  @HiveField(10)
  final String description;
  @HiveField(11)
  final int status;
  @HiveField(12)
  final DateTime createTime;
  @HiveField(13)
  final DateTime updateTime;
  @HiveField(14)
  final bool deleted;

  Customer({
    required this.customerId,
    required this.name,
    required this.contactPerson,
    required this.contactPhone,
    required this.contactEmail,
    required this.address,
    required this.categoryId,
    required this.categoryName,
    required this.tagIds,
    required this.tagNames,
    required this.description,
    required this.status,
    required this.createTime,
    required this.updateTime,
    required this.deleted,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      name: json['name'],
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      contactEmail: json['contactEmail'],
      address: json['address'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      tagIds: List<int>.from(json['tagIds'] ?? []),
      tagNames: List<String>.from(json['tagNames'] ?? []),
      description: json['description'],
      status: json['status'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
      deleted: json['deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'address': address,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'tagIds': tagIds,
      'tagNames': tagNames,
      'description': description,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'deleted': deleted,
    };
  }
}