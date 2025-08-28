// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuer_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ValuerProfileAdapter extends TypeAdapter<ValuerProfile> {
  @override
  final int typeId = 5;

  @override
  ValuerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ValuerProfile(
      name: fields[0] as String,
      address: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String?,
      logoFilePath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ValuerProfile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.logoFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValuerProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
