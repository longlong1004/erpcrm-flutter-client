// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApprovalAdapter extends TypeAdapter<Approval> {
  @override
  final int typeId = 10;

  @override
  Approval read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Approval(
      approvalId: fields[0] as int,
      title: fields[1] as String,
      content: fields[2] as String,
      requesterId: fields[3] as int,
      requesterName: fields[4] as String,
      approverId: fields[5] as int,
      approverName: fields[6] as String,
      status: fields[7] as String,
      type: fields[8] as String,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      relatedData: (fields[11] as Map?)?.cast<String, dynamic>(),
      comment: fields[12] as String?,
      isSynced: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Approval obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.approvalId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.requesterId)
      ..writeByte(4)
      ..write(obj.requesterName)
      ..writeByte(5)
      ..write(obj.approverId)
      ..writeByte(6)
      ..write(obj.approverName)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.relatedData)
      ..writeByte(12)
      ..write(obj.comment)
      ..writeByte(13)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
