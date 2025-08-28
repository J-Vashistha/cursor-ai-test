// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ornament_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrnamentItemAdapter extends TypeAdapter<OrnamentItem> {
  @override
  final int typeId = 3;

  @override
  OrnamentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrnamentItem(
      description: fields[0] as String,
      numberOfPieces: fields[1] as int,
      grossWeightGrams: fields[2] as double,
      netWeightGrams: fields[3] as double,
      caratPurity: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrnamentItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.numberOfPieces)
      ..writeByte(2)
      ..write(obj.grossWeightGrams)
      ..writeByte(3)
      ..write(obj.netWeightGrams)
      ..writeByte(4)
      ..write(obj.caratPurity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrnamentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
