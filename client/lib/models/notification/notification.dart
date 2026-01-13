import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  @JsonKey(name: 'id')
  final int? id;
  
  @JsonKey(name: 'title')
  final String title;
  
  @JsonKey(name: 'content')
  final String content;
  
  @JsonKey(name: 'type')
  final String type;
  
  @JsonKey(name: 'priority')
  final int priority;
  
  @JsonKey(name: 'senderId')
  final int? senderId;
  
  @JsonKey(name: 'senderName')
  final String? senderName;
  
  @JsonKey(name: 'receiverId')
  final int receiverId;
  
  @JsonKey(name: 'isRead')
  final bool isRead;
  
  @JsonKey(name: 'readTime')
  final DateTime? readTime;
  
  @JsonKey(name: 'expireTime')
  final DateTime? expireTime;
  
  @JsonKey(name: 'relatedId')
  final String? relatedId;
  
  @JsonKey(name: 'relatedType')
  final String? relatedType;
  
  @JsonKey(name: 'actionUrl')
  final String? actionUrl;
  
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;
  
  @JsonKey(name: 'isTop')
  final bool? isTop;
  
  @JsonKey(name: 'isArchived')
  final bool? isArchived;

  Notification({
    this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    this.senderId,
    this.senderName,
    required this.receiverId,
    required this.isRead,
    this.readTime,
    this.expireTime,
    this.relatedId,
    this.relatedType,
    this.actionUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isTop,
    this.isArchived,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  // 复制方法，用于更新通知对象
  Notification copyWith({
    int? id,
    String? title,
    String? content,
    String? type,
    int? priority,
    int? senderId,
    String? senderName,
    int? receiverId,
    bool? isRead,
    DateTime? readTime,
    DateTime? expireTime,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isTop,
    bool? isArchived,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      isRead: isRead ?? this.isRead,
      readTime: readTime ?? this.readTime,
      expireTime: expireTime ?? this.expireTime,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isTop: isTop ?? this.isTop,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
