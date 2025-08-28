import 'package:hive/hive.dart';
import 'ornament_item.dart';

part 'valuation.g.dart';

@HiveType(typeId: 4)
class Valuation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bankId;

  @HiveField(2)
  final String branchId;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int loanAmountRupees;

  @HiveField(5)
  final String customerName;

  @HiveField(6)
  final String customerAddress;

  @HiveField(7)
  final List<OrnamentItem> ornaments;

  @HiveField(8)
  final int feeRupees;

  const Valuation({
    required this.id,
    required this.bankId,
    required this.branchId,
    required this.date,
    required this.loanAmountRupees,
    required this.customerName,
    required this.customerAddress,
    required this.ornaments,
    required this.feeRupees,
  });

  double get totalGrossWeightGrams => ornaments.fold(0.0, (sum, o) => sum + o.grossWeightGrams);
  double get totalNetWeightGrams => ornaments.fold(0.0, (sum, o) => sum + o.netWeightGrams);
}

