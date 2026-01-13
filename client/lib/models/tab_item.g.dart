// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TabItemAdapter extends TypeAdapter<TabItem> {
  @override
  final int typeId = 30;

  @override
  TabItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TabItem(
      id: fields[0] as String,
      title: fields[1] as String,
      route: fields[2] as String,
      subtitle: fields[3] as String?,
      isActive: fields[4] as bool,
      params: (fields[5] as Map?)?.cast<String, dynamic>(),
      queryParams: (fields[6] as Map?)?.cast<String, dynamic>(),
      state: (fields[7] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, TabItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.route)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.params)
      ..writeByte(6)
      ..write(obj.queryParams)
      ..writeByte(7)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
