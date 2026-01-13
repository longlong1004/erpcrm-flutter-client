// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_contact_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerContactLogAdapter extends TypeAdapter<CustomerContactLog> {
  @override
  final int typeId = 7;

  @override
  CustomerContactLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerContactLog(
      contactLogId: fields[0] as int,
      customerId: fields[1] as int,
      customerName: fields[2] as String,
      contactPerson: fields[3] as String,
      contactWay: fields[4] as String,
      contactContent: fields[5] as String,
      contactResult: fields[6] as String,
      contactTime: fields[7] as DateTime,
      planNextTime: fields[8] as DateTime,
      operatorId: fields[9] as int,
      operatorName: fields[10] as String,
      createTime: fields[11] as DateTime,
      updateTime: fields[12] as DateTime,
      deleted: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerContactLog obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.contactLogId)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.contactPerson)
      ..writeByte(4)
      ..write(obj.contactWay)
      ..writeByte(5)
      ..write(obj.contactContent)
      ..writeByte(6)
      ..write(obj.contactResult)
      ..writeByte(7)
      ..write(obj.contactTime)
      ..writeByte(8)
      ..write(obj.planNextTime)
      ..writeByte(9)
      ..write(obj.operatorId)
      ..writeByte(10)
      ..write(obj.operatorName)
      ..writeByte(11)
      ..write(obj.createTime)
      ..writeByte(12)
      ..write(obj.updateTime)
      ..writeByte(13)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerContactLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
