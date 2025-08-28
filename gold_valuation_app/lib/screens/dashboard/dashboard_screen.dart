import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final valuations = StorageService.valuationsBox.values.toList();
    final now = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
    bool isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

    final today = valuations.where((v) => isSameDay(v.date, now)).toList();
    final month = valuations.where((v) => isSameMonth(v.date, now)).toList();
    final year = valuations.where((v) => v.date.year == now.year).toList();

    int totalFee(List list) => list.fold<int>(0, (s, v) => s + v.feeRupees as int);

    Widget card(String title, List items) => Card(
          child: ListTile(
            title: Text(title),
            subtitle: Text('Valuations: ${items.length}\nEarnings: ₹${totalFee(items)}'),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card('Today', today),
          card('This Month', month),
          card('This Year', year),
        ],
      ),
    );
  }
}

