import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/bank.dart';
import '../../models/branch.dart';
import '../../services/storage_service.dart';
import '../../services/bank_branch_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _service = BankBranchService();
  String _query = '';
  Bank? _bank;
  Branch? _branch;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');
    final all = StorageService.valuationsBox.values.toList();
    final filtered = all.where((v) {
      final matchesText = _query.isEmpty || v.customerName.toLowerCase().contains(_query.toLowerCase());
      final matchesBank = _bank == null || v.bankId == _bank!.id;
      final matchesBranch = _branch == null || v.branchId == _branch!.id;
      return matchesText && matchesBank && matchesBranch;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final banks = _service.getBanks();
    final branches = _bank == null ? <Branch>[] : _service.getBranchesByBank(_bank!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Records')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by customer'), onChanged: (v) => setState(() => _query = v))),
              const SizedBox(width: 8),
              SizedBox(width: 160, child: DropdownButton<Bank>(isExpanded: true, value: _bank, hint: const Text('Bank'), items: banks.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(), onChanged: (b) => setState(() { _bank = b; _branch = null; }))),
              const SizedBox(width: 8),
              SizedBox(width: 160, child: DropdownButton<Branch>(isExpanded: true, value: _branch, hint: const Text('Branch'), items: branches.map((br) => DropdownMenuItem(value: br, child: Text(br.name))).toList(), onChanged: (br) => setState(() { _branch = br; }))),
            ]),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final v = filtered[i];
                return ListTile(
                  title: Text(v.customerName),
                  subtitle: Text('${df.format(v.date)} • Loan: ₹${v.loanAmountRupees} • Fee: ₹${v.feeRupees}'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

