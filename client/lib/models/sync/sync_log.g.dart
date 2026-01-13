// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncLogAdapter extends TypeAdapter<SyncLog> {
  @override
  final int typeId = 11;

  @override
  SyncLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncLog(
      id: fields[0] as int,
      operationId: fields[1] as int,
      operationType: fields[2] as SyncOperationType,
      dataType: fields[3] as String,
      status: fields[4] as SyncStatus,
      timestamp: fields[5] as DateTime,
      message: fields[6] as String,
      errorDetails: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operationId)
      ..writeByte(2)
      ..write(obj.operationType)
      ..writeByte(3)
      ..write(obj.dataType)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.message)
      ..writeByte(7)
      ..write(obj.errorDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
