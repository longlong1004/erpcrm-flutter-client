// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_opportunity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesOpportunityAdapter extends TypeAdapter<SalesOpportunity> {
  @override
  final int typeId = 8;

  @override
  SalesOpportunity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesOpportunity(
      opportunityId: fields[0] as int,
      customerId: fields[1] as int,
      customerName: fields[2] as String,
      opportunityName: fields[3] as String,
      expectedAmount: fields[4] as double,
      stage: fields[5] as String,
      probability: fields[6] as String,
      expectedCloseDate: fields[7] as DateTime,
      responsiblePerson: fields[8] as String,
      description: fields[9] as String,
      createTime: fields[10] as DateTime,
      updateTime: fields[11] as DateTime,
      deleted: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SalesOpportunity obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.opportunityId)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.opportunityName)
      ..writeByte(4)
      ..write(obj.expectedAmount)
      ..writeByte(5)
      ..write(obj.stage)
      ..writeByte(6)
      ..write(obj.probability)
      ..writeByte(7)
      ..write(obj.expectedCloseDate)
      ..writeByte(8)
      ..write(obj.responsiblePerson)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.createTime)
      ..writeByte(11)
      ..write(obj.updateTime)
      ..writeByte(12)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesOpportunityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
