import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/bank.dart';
import '../../services/bank_branch_service.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({super.key});

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  final BankBranchService _service = BankBranchService();
  final _uuid = const Uuid();

  Future<void> _addBankDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Bank'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Bank name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await _service.addOrUpdateBank(Bank(id: _uuid.v4(), name: name));
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final banks = _service.getBanks();
    return Scaffold(
      appBar: AppBar(title: const Text('Banks')),
      body: ListView.builder(
        itemCount: banks.length,
        itemBuilder: (_, i) {
          final bank = banks[i];
          return ListTile(
            title: Text(bank.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _service.removeBank(bank.id);
                if (mounted) setState(() {});
              },
            ),
            onTap: () => Navigator.of(context).pushNamed('/branches', arguments: bank),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBankDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

