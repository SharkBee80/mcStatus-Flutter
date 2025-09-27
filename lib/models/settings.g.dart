// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      selectedServerUuid: fields[0] as String?,
      autoRefresh: fields[1] == null ? false : fields[1] as bool,
      refreshInterval: fields[2] == null ? 30 : fields[2] as int,
      theme: fields[3] == null ? 'system' : fields[3] as String,
      language: fields[4] == null ? 'system' : fields[4] as String,
      showServerIcon: fields[5] == null ? true : fields[5] as bool,
      cardColumns: fields[6] == null ? 2 : fields[6] as int,
      connectionTimeout: fields[7] == null ? 5 : fields[7] as int,
      enableNotifications: fields[8] == null ? true : fields[8] as bool,
      notifyServerOffline: fields[9] == null ? true : fields[9] as bool,
      notifyPlayerCountChange: fields[10] == null ? false : fields[10] as bool,
      enableDebugMode: fields[11] == null ? false : fields[11] as bool,
      keepScreenOn: fields[12] == null ? false : fields[12] as bool,
      animationSpeed: fields[13] == null ? 1.0 : fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.selectedServerUuid)
      ..writeByte(1)
      ..write(obj.autoRefresh)
      ..writeByte(2)
      ..write(obj.refreshInterval)
      ..writeByte(3)
      ..write(obj.theme)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.showServerIcon)
      ..writeByte(6)
      ..write(obj.cardColumns)
      ..writeByte(7)
      ..write(obj.connectionTimeout)
      ..writeByte(8)
      ..write(obj.enableNotifications)
      ..writeByte(9)
      ..write(obj.notifyServerOffline)
      ..writeByte(10)
      ..write(obj.notifyPlayerCountChange)
      ..writeByte(11)
      ..write(obj.enableDebugMode)
      ..writeByte(12)
      ..write(obj.keepScreenOn)
      ..writeByte(13)
      ..write(obj.animationSpeed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
