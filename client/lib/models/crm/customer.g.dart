// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 4;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      customerId: fields[0] as int,
      name: fields[1] as String,
      contactPerson: fields[2] as String,
      contactPhone: fields[3] as String,
      contactEmail: fields[4] as String,
      address: fields[5] as String,
      categoryId: fields[6] as int,
      categoryName: fields[7] as String,
      tagIds: (fields[8] as List).cast<int>(),
      tagNames: (fields[9] as List).cast<String>(),
      description: fields[10] as String,
      status: fields[11] as int,
      createTime: fields[12] as DateTime,
      updateTime: fields[13] as DateTime,
      deleted: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactPerson)
      ..writeByte(3)
      ..write(obj.contactPhone)
      ..writeByte(4)
      ..write(obj.contactEmail)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.categoryName)
      ..writeByte(8)
      ..write(obj.tagIds)
      ..writeByte(9)
      ..write(obj.tagNames)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.createTime)
      ..writeByte(13)
      ..write(obj.updateTime)
      ..writeByte(14)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
