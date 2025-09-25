// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServersAdapter extends TypeAdapter<Servers> {
  @override
  final int typeId = 0;

  @override
  Servers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Servers(
      name: fields[0] as String,
      address: fields[1] as String,
      fulladdress: fields[2] as String,
      uuid: fields[3] as int,
      addtime: fields[4] as String,
      edittime: fields[5] as String,
      sortIndex: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Servers obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.fulladdress)
      ..writeByte(3)
      ..write(obj.uuid)
      ..writeByte(4)
      ..write(obj.addtime)
      ..writeByte(5)
      ..write(obj.edittime)
      ..writeByte(6)
      ..write(obj.sortIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
