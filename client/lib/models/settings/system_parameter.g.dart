// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_parameter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemParameterAdapter extends TypeAdapter<SystemParameter> {
  @override
  final int typeId = 101;

  @override
  SystemParameter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemParameter(
      id: fields[0] as int?,
      parameterKey: fields[1] as String,
      parameterValue: fields[2] as String,
      parameterDescription: fields[3] as String,
      parameterType: fields[4] as String,
      defaultValue: fields[5] as String,
      isEditable: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SystemParameter obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parameterKey)
      ..writeByte(2)
      ..write(obj.parameterValue)
      ..writeByte(3)
      ..write(obj.parameterDescription)
      ..writeByte(4)
      ..write(obj.parameterType)
      ..writeByte(5)
      ..write(obj.defaultValue)
      ..writeByte(6)
      ..write(obj.isEditable)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemParameterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
