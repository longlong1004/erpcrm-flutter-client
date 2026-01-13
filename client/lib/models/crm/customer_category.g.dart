// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerCategoryAdapter extends TypeAdapter<CustomerCategory> {
  @override
  final int typeId = 5;

  @override
  CustomerCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerCategory(
      categoryId: fields[0] as int,
      categoryName: fields[1] as String,
      description: fields[2] as String,
      sortOrder: fields[3] as int,
      createTime: fields[4] as DateTime,
      updateTime: fields[5] as DateTime,
      deleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerCategory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.categoryId)
      ..writeByte(1)
      ..write(obj.categoryName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.sortOrder)
      ..writeByte(4)
      ..write(obj.createTime)
      ..writeByte(5)
      ..write(obj.updateTime)
      ..writeByte(6)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
