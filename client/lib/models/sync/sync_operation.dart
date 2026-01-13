import 'package:hive_flutter/hive_flutter.dart';

part 'sync_operation.g.dart';

/// 同步操作类型枚举
enum SyncOperationType {
  create,
  update,
  delete,
}

/// 同步操作类，用于记录需要同步到服务器的操作
@HiveType(typeId: 12)
class SyncOperation {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final SyncOperationType operationType;

  @HiveField(2)
  final String dataType;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final int? tempId;

  @HiveField(6)
  int retryCount;

  @HiveField(7)
  DateTime? lastRetryAt;

  SyncOperation({
    required this.id,
    required this.operationType,
    required this.dataType,
    required this.data,
    required this.timestamp,
    this.tempId,
    this.retryCount = 0,
    this.lastRetryAt,
  });

  @override
  String toString() {
    return 'SyncOperation{id: $id, operationType: $operationType, dataType: $dataType, timestamp: $timestamp, retryCount: $retryCount}';
  }
}


