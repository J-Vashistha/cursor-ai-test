import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/bank.dart';
import '../models/branch.dart';
import '../models/valuation.dart';
import '../models/valuer_profile.dart';
import 'storage_service.dart';

class BackupService {
  static Future<File> exportToLocalJson() async {
    final banks = StorageService.banksBox.values.toList();
    final branches = StorageService.branchesBox.values.toList();
    final valuations = StorageService.valuationsBox.values.toList();
    final profile = StorageService.profileBox.get('profile');

    Map<String, dynamic> toMap() => {
          'banks': banks.map(_bankToMap).toList(),
          'branches': branches.map(_branchToMap).toList(),
          'valuations': valuations.map(_valuationToMap).toList(),
          'profile': profile == null ? null : _profileToMap(profile),
          'exportedAt': DateTime.now().toIso8601String(),
        };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/gold_valuation_backup.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(toMap()));
    return file;
  }

  static Map<String, dynamic> _bankToMap(Bank b) => {'id': b.id, 'name': b.name};
  static Map<String, dynamic> _branchToMap(Branch b) => {'id': b.id, 'bankId': b.bankId, 'name': b.name};
  static Map<String, dynamic> _valuationToMap(Valuation v) => {
        'id': v.id,
        'bankId': v.bankId,
        'branchId': v.branchId,
        'date': v.date.toIso8601String(),
        'loanAmountRupees': v.loanAmountRupees,
        'customerName': v.customerName,
        'customerAddress': v.customerAddress,
        'feeRupees': v.feeRupees,
        'ornaments': v.ornaments
            .map((o) => {
                  'description': o.description,
                  'numberOfPieces': o.numberOfPieces,
                  'grossWeightGrams': o.grossWeightGrams,
                  'netWeightGrams': o.netWeightGrams,
                  'caratPurity': o.caratPurity,
                })
            .toList(),
      };
  static Map<String, dynamic> _profileToMap(ValuerProfile p) => {
        'name': p.name,
        'address': p.address,
        'phone': p.phone,
        'email': p.email,
        'logoFilePath': p.logoFilePath,
      };
}

