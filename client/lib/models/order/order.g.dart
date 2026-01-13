// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 3;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as int,
      orderNumber: fields[1] as String,
      userId: fields[2] as int,
      orderItems: (fields[3] as List).cast<OrderItem>(),
      totalAmount: fields[4] as double,
      status: fields[5] as String,
      paymentMethod: fields[6] as String?,
      paymentStatus: fields[7] as String?,
      shippingAddress: fields[8] as String?,
      billingAddress: fields[9] as String?,
      shippingMethod: fields[10] as String?,
      trackingNumber: fields[11] as String?,
      notes: fields[12] as String?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      orderType: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.orderItems)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.paymentStatus)
      ..writeByte(8)
      ..write(obj.shippingAddress)
      ..writeByte(9)
      ..write(obj.billingAddress)
      ..writeByte(10)
      ..write(obj.shippingMethod)
      ..writeByte(11)
      ..write(obj.trackingNumber)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.orderType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
