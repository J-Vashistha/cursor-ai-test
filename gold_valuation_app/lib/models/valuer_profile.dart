import 'package:hive/hive.dart';

part 'valuer_profile.g.dart';

@HiveType(typeId: 5)
class ValuerProfile {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String address;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String? logoFilePath;

  const ValuerProfile({
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.logoFilePath,
  });
}

