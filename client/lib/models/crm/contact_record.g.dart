// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactRecordAdapter extends TypeAdapter<ContactRecord> {
  @override
  final int typeId = 9;

  @override
  ContactRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactRecord(
      recordId: fields[0] as int,
      customerId: fields[1] as int,
      contactId: fields[2] as int,
      contactType: fields[3] as String,
      contactDate: fields[4] as String,
      contactContent: fields[5] as String,
      contactPerson: fields[6] as String,
      nextContactPlan: fields[7] as String,
      contactStatus: fields[8] as String,
      createdBy: fields[9] as String,
      createdAt: fields[10] as String,
      updatedBy: fields[11] as String,
      updatedAt: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContactRecord obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.recordId)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.contactId)
      ..writeByte(3)
      ..write(obj.contactType)
      ..writeByte(4)
      ..write(obj.contactDate)
      ..writeByte(5)
      ..write(obj.contactContent)
      ..writeByte(6)
      ..write(obj.contactPerson)
      ..writeByte(7)
      ..write(obj.nextContactPlan)
      ..writeByte(8)
      ..write(obj.contactStatus)
      ..writeByte(9)
      ..write(obj.createdBy)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedBy)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
