// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      avatarUrl: json['avatarUrl'] as String,
      enabled: json['enabled'] as bool,
      roleNames:
          (json['roleNames'] as List<dynamic>).map((e) => e as String).toSet(),
      lastLoginTime: DateTime.parse(json['lastLoginTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'department': instance.department,
      'position': instance.position,
      'avatarUrl': instance.avatarUrl,
      'enabled': instance.enabled,
      'roleNames': instance.roleNames.toList(),
      'lastLoginTime': instance.lastLoginTime.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
