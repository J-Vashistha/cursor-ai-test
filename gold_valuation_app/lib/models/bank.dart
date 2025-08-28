import 'package:hive/hive.dart';

part 'bank.g.dart';

@HiveType(typeId: 1)
class Bank {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  const Bank({required this.id, required this.name});
}

