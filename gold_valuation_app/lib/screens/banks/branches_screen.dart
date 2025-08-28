import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/bank.dart';
import '../../models/branch.dart';
import '../../services/bank_branch_service.dart';

class BranchesScreen extends StatefulWidget {
  final Bank bank;
  const BranchesScreen({super.key, required this.bank});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final BankBranchService _service = BankBranchService();
  final _uuid = const Uuid();

  Future<void> _addBranchDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Branch'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Branch name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await _service.addOrUpdateBranch(Branch(id: _uuid.v4(), bankId: widget.bank.id, name: name));
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = _service.getBranchesByBank(widget.bank.id);
    return Scaffold(
      appBar: AppBar(title: Text('Branches - ${widget.bank.name}')),
      body: ListView.builder(
        itemCount: branches.length,
        itemBuilder: (_, i) {
          final branch = branches[i];
          return ListTile(
            title: Text(branch.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _service.removeBranch(branch.id);
                if (mounted) setState(() {});
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBranchDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

