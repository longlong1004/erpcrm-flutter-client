// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as int,
      name: fields[1] as String,
      code: fields[2] as String,
      specification: fields[3] as String,
      model: fields[4] as String,
      unit: fields[5] as String,
      price: fields[6] as double,
      costPrice: fields[7] as double,
      originalPrice: fields[8] as double,
      stock: fields[9] as int,
      safetyStock: fields[10] as int,
      categoryId: fields[11] as int,
      brand: fields[12] as String?,
      manufacturer: fields[13] as String?,
      supplierId: fields[14] as int?,
      barcode: fields[15] as String?,
      imageUrl: fields[16] as String?,
      description: fields[17] as String?,
      status: fields[18] as String,
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
      salespersonId: fields[21] as int?,
      salespersonName: fields[22] as String?,
      companyName: fields[23] as String?,
      categoryName: fields[24] as String?,
      weight: fields[25] as double?,
      dimensions: fields[26] as String?,
      railwayBureau: fields[27] as String?,
      station: fields[28] as String?,
      customer: fields[29] as String?,
      actualName: fields[30] as String?,
      actualModel: fields[31] as String?,
      purchasePrice: fields[32] as double?,
      supplierName: fields[33] as String?,
      imageUrls: (fields[34] as List?)?.cast<String>(),
      note: fields[35] as String?,
      mainImageUrls: (fields[36] as List?)?.cast<String>(),
      detailImageUrl: fields[37] as String?,
      barcode69: fields[38] as String?,
      externalLink: fields[39] as String?,
      approvalUserId: fields[40] as int?,
      approvalUserName: fields[41] as String?,
      approvalTime: fields[42] as DateTime?,
      approvalComment: fields[43] as String?,
      isSynced: fields[44] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(45)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.specification)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.costPrice)
      ..writeByte(8)
      ..write(obj.originalPrice)
      ..writeByte(9)
      ..write(obj.stock)
      ..writeByte(10)
      ..write(obj.safetyStock)
      ..writeByte(11)
      ..write(obj.categoryId)
      ..writeByte(12)
      ..write(obj.brand)
      ..writeByte(13)
      ..write(obj.manufacturer)
      ..writeByte(14)
      ..write(obj.supplierId)
      ..writeByte(15)
      ..write(obj.barcode)
      ..writeByte(16)
      ..write(obj.imageUrl)
      ..writeByte(17)
      ..write(obj.description)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.salespersonId)
      ..writeByte(22)
      ..write(obj.salespersonName)
      ..writeByte(23)
      ..write(obj.companyName)
      ..writeByte(24)
      ..write(obj.categoryName)
      ..writeByte(25)
      ..write(obj.weight)
      ..writeByte(26)
      ..write(obj.dimensions)
      ..writeByte(27)
      ..write(obj.railwayBureau)
      ..writeByte(28)
      ..write(obj.station)
      ..writeByte(29)
      ..write(obj.customer)
      ..writeByte(30)
      ..write(obj.actualName)
      ..writeByte(31)
      ..write(obj.actualModel)
      ..writeByte(32)
      ..write(obj.purchasePrice)
      ..writeByte(33)
      ..write(obj.supplierName)
      ..writeByte(34)
      ..write(obj.imageUrls)
      ..writeByte(35)
      ..write(obj.note)
      ..writeByte(36)
      ..write(obj.mainImageUrls)
      ..writeByte(37)
      ..write(obj.detailImageUrl)
      ..writeByte(38)
      ..write(obj.barcode69)
      ..writeByte(39)
      ..write(obj.externalLink)
      ..writeByte(40)
      ..write(obj.approvalUserId)
      ..writeByte(41)
      ..write(obj.approvalUserName)
      ..writeByte(42)
      ..write(obj.approvalTime)
      ..writeByte(43)
      ..write(obj.approvalComment)
      ..writeByte(44)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
