import 'package:hive/hive.dart';

part 'ornament_item.g.dart';

@HiveType(typeId: 3)
class OrnamentItem {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final int numberOfPieces;

  @HiveField(2)
  final double grossWeightGrams;

  @HiveField(3)
  final double netWeightGrams;

  @HiveField(4)
  final double caratPurity;

  const OrnamentItem({
    required this.description,
    required this.numberOfPieces,
    required this.grossWeightGrams,
    required this.netWeightGrams,
    required this.caratPurity,
  });
}

