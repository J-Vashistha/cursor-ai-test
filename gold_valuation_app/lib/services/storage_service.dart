import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/bank.dart';
import '../models/branch.dart';
import '../models/ornament_item.dart';
import '../models/valuation.dart';
import '../models/valuer_profile.dart';

class StorageService {
  static const String banksBoxName = 'banks_box';
  static const String branchesBoxName = 'branches_box';
  static const String valuationsBoxName = 'valuations_box';
  static const String profileBoxName = 'profile_box';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(BankAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(BranchAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(OrnamentItemAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ValuationAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ValuerProfileAdapter());

    await Future.wait([
      Hive.openBox<Bank>(banksBoxName),
      Hive.openBox<Branch>(branchesBoxName),
      Hive.openBox<Valuation>(valuationsBoxName),
      Hive.openBox<ValuerProfile>(profileBoxName),
    ]);
  }

  static Box<Bank> get banksBox => Hive.box<Bank>(banksBoxName);
  static Box<Branch> get branchesBox => Hive.box<Branch>(branchesBoxName);
  static Box<Valuation> get valuationsBox => Hive.box<Valuation>(valuationsBoxName);
  static Box<ValuerProfile> get profileBox => Hive.box<ValuerProfile>(profileBoxName);
}

