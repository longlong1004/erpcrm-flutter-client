// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WarehouseAdapter extends TypeAdapter<Warehouse> {
  @override
  final int typeId = 10;

  @override
  Warehouse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Warehouse(
      id: fields[0] as int,
      name: fields[1] as String,
      code: fields[2] as String,
      address: fields[3] as String?,
      manager: fields[4] as String?,
      phone: fields[5] as String?,
      description: fields[6] as String?,
      status: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Warehouse obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.manager)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.status)
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
      other is WarehouseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryAdapter extends TypeAdapter<Inventory> {
  @override
  final int typeId = 11;

  @override
  Inventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inventory(
      id: fields[0] as int,
      productId: fields[1] as int,
      productName: fields[2] as String,
      productCode: fields[3] as String,
      warehouseId: fields[4] as int,
      warehouseName: fields[5] as String,
      quantity: fields[6] as int,
      safetyStock: fields[7] as int,
      unitPrice: fields[8] as double,
      totalValue: fields[9] as double,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      isSynced: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Inventory obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.productCode)
      ..writeByte(4)
      ..write(obj.warehouseId)
      ..writeByte(5)
      ..write(obj.warehouseName)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.safetyStock)
      ..writeByte(8)
      ..write(obj.unitPrice)
      ..writeByte(9)
      ..write(obj.totalValue)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StockRecordAdapter extends TypeAdapter<StockRecord> {
  @override
  final int typeId = 12;

  @override
  StockRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockRecord(
      id: fields[0] as int,
      recordNo: fields[1] as String,
      type: fields[2] as String,
      productId: fields[3] as int,
      productName: fields[4] as String,
      warehouseId: fields[5] as int,
      warehouseName: fields[6] as String,
      quantity: fields[7] as int,
      unitPrice: fields[8] as double,
      totalAmount: fields[9] as double,
      supplierName: fields[10] as String?,
      customerName: fields[11] as String?,
      remark: fields[12] as String?,
      status: fields[13] as String,
      operationTime: fields[14] as DateTime,
      createdAt: fields[15] as DateTime,
      operatorName: fields[16] as String?,
      isSynced: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StockRecord obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recordNo)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.productId)
      ..writeByte(4)
      ..write(obj.productName)
      ..writeByte(5)
      ..write(obj.warehouseId)
      ..writeByte(6)
      ..write(obj.warehouseName)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.unitPrice)
      ..writeByte(9)
      ..write(obj.totalAmount)
      ..writeByte(10)
      ..write(obj.supplierName)
      ..writeByte(11)
      ..write(obj.customerName)
      ..writeByte(12)
      ..write(obj.remark)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.operationTime)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.operatorName)
      ..writeByte(17)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
