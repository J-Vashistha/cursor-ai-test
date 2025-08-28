import 'package:flutter/material.dart';

import '../../services/backup_service.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gold Valuation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Export Local Backup'),
            subtitle: const Text('Saves JSON backup to device storage'),
            onTap: () async {
              final file = await BackupService.exportToLocalJson();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved: ${file.path}')));
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Banks & Branches'),
            onTap: () => Navigator.of(context).pushNamed('/banks'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('New Valuation'),
            onTap: () => Navigator.of(context).pushNamed('/valuation/new'),
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Records'),
            onTap: () => Navigator.of(context).pushNamed('/records'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.of(context).pushNamed('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Valuer Profile'),
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
    );
  }
}

