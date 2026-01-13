// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      priority: (json['priority'] as num).toInt(),
      senderId: (json['senderId'] as num?)?.toInt(),
      senderName: json['senderName'] as String?,
      receiverId: (json['receiverId'] as num).toInt(),
      isRead: json['isRead'] as bool,
      readTime: json['readTime'] == null
          ? null
          : DateTime.parse(json['readTime'] as String),
      expireTime: json['expireTime'] == null
          ? null
          : DateTime.parse(json['expireTime'] as String),
      relatedId: json['relatedId'] as String?,
      relatedType: json['relatedType'] as String?,
      actionUrl: json['actionUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isTop: json['isTop'] as bool?,
      isArchived: json['isArchived'] as bool?,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'type': instance.type,
      'priority': instance.priority,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'receiverId': instance.receiverId,
      'isRead': instance.isRead,
      'readTime': instance.readTime?.toIso8601String(),
      'expireTime': instance.expireTime?.toIso8601String(),
      'relatedId': instance.relatedId,
      'relatedType': instance.relatedType,
      'actionUrl': instance.actionUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isTop': instance.isTop,
      'isArchived': instance.isArchived,
    };
