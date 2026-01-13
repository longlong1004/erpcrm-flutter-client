// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_factory_database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SysUiConfigAdapter extends TypeAdapter<SysUiConfig> {
  @override
  final int typeId = 100;

  @override
  SysUiConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SysUiConfig(
      id: fields[0] as String?,
      moduleCode: fields[1] as String?,
      fieldCode: fields[2] as String?,
      fieldName: fields[3] as String?,
      fieldType: fields[4] as String?,
      validationRule: fields[5] as String?,
      validationParams: fields[6] as String?,
      defaultValue: fields[7] as String?,
      visible: fields[8] as bool?,
      displayOrder: fields[9] as int?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SysUiConfig obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.moduleCode)
      ..writeByte(2)
      ..write(obj.fieldCode)
      ..writeByte(3)
      ..write(obj.fieldName)
      ..writeByte(4)
      ..write(obj.fieldType)
      ..writeByte(5)
      ..write(obj.validationRule)
      ..writeByte(6)
      ..write(obj.validationParams)
      ..writeByte(7)
      ..write(obj.defaultValue)
      ..writeByte(8)
      ..write(obj.visible)
      ..writeByte(9)
      ..write(obj.displayOrder)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysUiConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SysMenuConfigAdapter extends TypeAdapter<SysMenuConfig> {
  @override
  final int typeId = 101;

  @override
  SysMenuConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SysMenuConfig(
      id: fields[0] as String?,
      menuCode: fields[1] as String?,
      menuName: fields[2] as String?,
      parentId: fields[3] as String?,
      icon: fields[4] as String?,
      route: fields[5] as String?,
      displayOrder: fields[6] as int?,
      visible: fields[7] as bool?,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      routePath: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SysMenuConfig obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.menuCode)
      ..writeByte(2)
      ..write(obj.menuName)
      ..writeByte(3)
      ..write(obj.parentId)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.route)
      ..writeByte(6)
      ..write(obj.displayOrder)
      ..writeByte(7)
      ..write(obj.visible)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.routePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysMenuConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
