import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 已运行 hive_generator，device.g.dart 将在下次构建时自动生成
part 'device.g.dart';

@HiveType(typeId: 53)
class Device {
  @HiveField(0)
  final String deviceId;

  @HiveField(1)
  final String deviceName;

  @HiveField(2)
  final DeviceType type;

  @HiveField(3)
  final DateTime lastActiveTime;

  @HiveField(4)
  final bool isOnline;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final int? userId;

  @HiveField(7)
  final String? osVersion;

  @HiveField(8)
  final String? appVersion;

  Device({
    required this.deviceId,
    required this.deviceName,
    required this.type,
    required this.lastActiveTime,
    required this.isOnline,
    required this.createdAt,
    this.userId,
    this.osVersion,
    this.appVersion,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => DeviceType.WINDOWS,
      ),
      lastActiveTime: DateTime.parse(json['lastActiveTime'] as String),
      isOnline: json['isOnline'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as int?,
      osVersion: json['osVersion'] as String?,
      appVersion: json['appVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'type': type.toString(),
      'lastActiveTime': lastActiveTime.toIso8601String(),
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'osVersion': osVersion,
      'appVersion': appVersion,
    };
  }

  Device copyWith({
    String? deviceId,
    String? deviceName,
    DeviceType? type,
    DateTime? lastActiveTime,
    bool? isOnline,
    DateTime? createdAt,
    int? userId,
    String? osVersion,
    String? appVersion,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      type: type ?? this.type,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

@HiveType(typeId: 54)
enum DeviceType {
  ANDROID,
  IOS,
  WINDOWS,
}
