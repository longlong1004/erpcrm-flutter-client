import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'message.g.dart';

@HiveType(typeId: 50)
class Message {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String messageId;

  @HiveField(2)
  final int senderId;

  @HiveField(3)
  final int receiverId;

  @HiveField(4)
  final int? groupId;

  @HiveField(5)
  final MessageType type;

  @HiveField(6)
  final String content;

  @HiveField(7)
  final String? fileUrl;

  @HiveField(8)
  final String? fileName;

  @HiveField(9)
  final int? fileSize;

  @HiveField(10)
  final MessageStatus status;

  @HiveField(11)
  final bool isRecalled;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime? readAt;

  @HiveField(14)
  final DateTime? deliveredAt;

  @HiveField(15)
  final String? deviceId;

  @HiveField(16)
  final String? senderName;

  @HiveField(17)
  final String? senderAvatar;

  @HiveField(18)
  final bool isOffline;

  Message({
    required this.id,
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    this.groupId,
    required this.type,
    required this.content,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.status,
    this.isRecalled = false,
    required this.createdAt,
    this.readAt,
    this.deliveredAt,
    this.deviceId,
    this.senderName,
    this.senderAvatar,
    this.isOffline = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      groupId: json['groupId'] as int?,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.TEXT,
      ),
      content: json['content'] as String,
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.SENDING,
      ),
      isRecalled: json['isRecalled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      deviceId: json['deviceId'] as String?,
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
      isOffline: json['isOffline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'groupId': groupId,
      'type': type.toString(),
      'content': content,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'status': status.toString(),
      'isRecalled': isRecalled,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'deviceId': deviceId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'isOffline': isOffline,
    };
  }

  Message copyWith({
    int? id,
    String? messageId,
    int? senderId,
    int? receiverId,
    int? groupId,
    MessageType? type,
    String? content,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    MessageStatus? status,
    bool? isRecalled,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? deliveredAt,
    String? deviceId,
    String? senderName,
    String? senderAvatar,
    bool? isOffline,
  }) {
    return Message(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      isRecalled: isRecalled ?? this.isRecalled,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deviceId: deviceId ?? this.deviceId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

@HiveType(typeId: 51)
enum MessageType {
  TEXT,
  IMAGE,
  FILE,
  VOICE,
  VIDEO,
}

@HiveType(typeId: 52)
enum MessageStatus {
  SENDING,
  SENT,
  DELIVERED,
  READ,
}
