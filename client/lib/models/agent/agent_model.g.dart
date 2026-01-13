// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgentCapabilityAdapter extends TypeAdapter<AgentCapability> {
  @override
  final int typeId = 10;

  @override
  AgentCapability read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgentCapability(
      id: fields[0] as String?,
      name: fields[1] as String?,
      description: fields[2] as String,
      isEnabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AgentCapability obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentCapabilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AgentAdapter extends TypeAdapter<Agent> {
  @override
  final int typeId = 11;

  @override
  Agent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Agent(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      role: fields[3] as AgentRole,
      status: fields[4] as AgentStatus,
      icon: fields[5] as String,
      capabilities: (fields[6] as List).cast<AgentCapability>(),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Agent obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.capabilities)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AgentConfigAdapter extends TypeAdapter<AgentConfig> {
  @override
  final int typeId = 12;

  @override
  AgentConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgentConfig(
      isEnabled: fields[0] as bool,
      defaultAgentId: fields[1] as String,
      showAgentPanel: fields[2] as bool,
      maxAgentCount: fields[3] as int,
      updatedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AgentConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.defaultAgentId)
      ..writeByte(2)
      ..write(obj.showAgentPanel)
      ..writeByte(3)
      ..write(obj.maxAgentCount)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
