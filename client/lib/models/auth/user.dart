import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  final String name;
  final String phoneNumber;
  final String department;
  final String position;
  final String avatarUrl;
  final bool enabled;
  final Set<String> roleNames;
  final DateTime lastLoginTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.position,
    required this.avatarUrl,
    required this.enabled,
    required this.roleNames,
    required this.lastLoginTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
