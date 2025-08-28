// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ValuationAdapter extends TypeAdapter<Valuation> {
  @override
  final int typeId = 4;

  @override
  Valuation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Valuation(
      id: fields[0] as String,
      bankId: fields[1] as String,
      branchId: fields[2] as String,
      date: fields[3] as DateTime,
      loanAmountRupees: fields[4] as int,
      customerName: fields[5] as String,
      customerAddress: fields[6] as String,
      ornaments: (fields[7] as List).cast<OrnamentItem>(),
      feeRupees: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Valuation obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bankId)
      ..writeByte(2)
      ..write(obj.branchId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.loanAmountRupees)
      ..writeByte(5)
      ..write(obj.customerName)
      ..writeByte(6)
      ..write(obj.customerAddress)
      ..writeByte(7)
      ..write(obj.ornaments)
      ..writeByte(8)
      ..write(obj.feeRupees);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValuationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
