import 'package:hive/hive.dart';

import '../models/bank.dart';
import '../models/branch.dart';
import 'storage_service.dart';

class BankBranchService {
  final Box<Bank> _banks = StorageService.banksBox;
  final Box<Branch> _branches = StorageService.branchesBox;

  List<Bank> getBanks() => _banks.values.toList();
  List<Branch> getBranchesByBank(String bankId) =>
      _branches.values.where((b) => b.bankId == bankId).toList();

  Future<void> addOrUpdateBank(Bank bank) async {
    await _banks.put(bank.id, bank);
  }

  Future<void> removeBank(String bankId) async {
    await _banks.delete(bankId);
    // Remove branches under bank
    final toRemove = _branches.values.where((b) => b.bankId == bankId).map((b) => b.id).toList();
    await _branches.deleteAll(toRemove);
  }

  Future<void> addOrUpdateBranch(Branch branch) async {
    await _branches.put(branch.id, branch);
  }

  Future<void> removeBranch(String branchId) async {
    await _branches.delete(branchId);
  }
}

