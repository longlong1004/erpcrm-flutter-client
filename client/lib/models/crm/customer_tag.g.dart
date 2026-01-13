// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerTagAdapter extends TypeAdapter<CustomerTag> {
  @override
  final int typeId = 6;

  @override
  CustomerTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerTag(
      tagId: fields[0] as int,
      tagName: fields[1] as String,
      tagCode: fields[2] as String,
      tagDesc: fields[3] as String,
      status: fields[4] as int,
      createTime: fields[5] as DateTime,
      updateTime: fields[6] as DateTime,
      deleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerTag obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.tagId)
      ..writeByte(1)
      ..write(obj.tagName)
      ..writeByte(2)
      ..write(obj.tagCode)
      ..writeByte(3)
      ..write(obj.tagDesc)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createTime)
      ..writeByte(6)
      ..write(obj.updateTime)
      ..writeByte(7)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
