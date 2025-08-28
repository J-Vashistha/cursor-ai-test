import 'package:hive/hive.dart';

part 'branch.g.dart';

@HiveType(typeId: 2)
class Branch {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bankId;

  @HiveField(2)
  final String name;

  const Branch({required this.id, required this.bankId, required this.name});
}

