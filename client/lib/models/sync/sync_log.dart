import 'package:hive_flutter/hive_flutter.dart';
import 'sync_operation.dart';

part 'sync_log.g.dart';

/// 同步状态枚举
enum SyncStatus {
  success,
  failed,
  pending,
}

/// 同步日志类，用于记录同步操作的结果
@HiveType(typeId: 11)
class SyncLog {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int operationId;

  @HiveField(2)
  final SyncOperationType operationType;

  @HiveField(3)
  final String dataType;

  @HiveField(4)
  final SyncStatus status;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String message;

  @HiveField(7)
  final String? errorDetails;

  SyncLog({
    required this.id,
    required this.operationId,
    required this.operationType,
    required this.dataType,
    required this.status,
    required this.timestamp,
    required this.message,
    this.errorDetails,
  });

  @override
  String toString() {
    return 'SyncLog{id: $id, operationId: $operationId, operationType: $operationType, dataType: $dataType, status: $status, timestamp: $timestamp, message: $message}';
  }
}


