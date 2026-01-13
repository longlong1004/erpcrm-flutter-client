// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_dictionary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataDictionaryAdapter extends TypeAdapter<DataDictionary> {
  @override
  final int typeId = 102;

  @override
  DataDictionary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataDictionary(
      id: fields[0] as int?,
      dictType: fields[1] as String,
      dictCode: fields[2] as String,
      dictValue: fields[3] as String,
      dictName: fields[4] as String,
      description: fields[5] as String?,
      sortOrder: fields[6] as int,
      isActive: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DataDictionary obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dictType)
      ..writeByte(2)
      ..write(obj.dictCode)
      ..writeByte(3)
      ..write(obj.dictValue)
      ..writeByte(4)
      ..write(obj.dictName)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.sortOrder)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataDictionaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
