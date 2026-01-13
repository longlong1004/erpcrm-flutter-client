// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperationLogAdapter extends TypeAdapter<OperationLog> {
  @override
  final int typeId = 100;

  @override
  OperationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OperationLog(
      id: fields[0] as int?,
      userId: fields[1] as int,
      userName: fields[2] as String,
      operationModule: fields[3] as String,
      operationType: fields[4] as String,
      operationContent: fields[5] as String,
      operationResult: fields[6] as String,
      errorMessage: fields[7] as String,
      clientIp: fields[8] as String,
      userAgent: fields[9] as String,
      createdAt: fields[10] as DateTime,
      isSynced: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OperationLog obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.operationModule)
      ..writeByte(4)
      ..write(obj.operationType)
      ..writeByte(5)
      ..write(obj.operationContent)
      ..writeByte(6)
      ..write(obj.operationResult)
      ..writeByte(7)
      ..write(obj.errorMessage)
      ..writeByte(8)
      ..write(obj.clientIp)
      ..writeByte(9)
      ..write(obj.userAgent)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
