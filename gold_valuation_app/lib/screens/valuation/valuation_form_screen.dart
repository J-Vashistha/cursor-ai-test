import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/bank.dart';
import '../../models/branch.dart';
import '../../models/ornament_item.dart';
import '../../models/valuation.dart';
import '../../models/valuer_profile.dart';
import '../../services/bank_branch_service.dart';
import '../../services/fee_service.dart';
import '../../services/storage_service.dart';
import '../../services/pdf_service.dart';

class ValuationFormScreen extends StatefulWidget {
  const ValuationFormScreen({super.key});

  @override
  State<ValuationFormScreen> createState() => _ValuationFormScreenState();
}

class _ValuationFormScreenState extends State<ValuationFormScreen> {
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();
  final _bankBranchService = BankBranchService();

  Bank? _selectedBank;
  Branch? _selectedBranch;
  DateTime _date = DateTime.now();
  final TextEditingController _loanCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addrCtrl = TextEditingController();

  final List<OrnamentItem> _items = [];

  final List<String> _descriptions = const [
    'Ring', 'Bangle', 'Chain', 'Necklace', 'Pendant', 'Earrings', 'Bracelet', 'Mangalsutra', 'Kada', 'Nose Pin', 'Anklet', 'Waist Belt'
  ];

  double get _totalGross => _items.fold(0.0, (s, o) => s + o.grossWeightGrams);
  double get _totalNet => _items.fold(0.0, (s, o) => s + o.netWeightGrams);

  Future<void> _addItemDialog() async {
    final descCtrl = TextEditingController();
    String? desc = _descriptions.first;
    final pcsCtrl = TextEditingController();
    final grossCtrl = TextEditingController();
    final netCtrl = TextEditingController();
    final caratCtrl = TextEditingController();
    bool manual = false;

    final item = await showDialog<OrnamentItem>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setStateDialog) {
        return AlertDialog(
          title: const Text('Add Ornament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: manual ? null : desc,
                      hint: const Text('Description'),
                      items: _descriptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setStateDialog(() { manual = false; desc = v; }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(onPressed: () => setStateDialog(() { manual = true; }), child: const Text('Manual')),
                ]),
                if (manual)
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Enter description')),
                TextField(controller: pcsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'No. of Pcs')),
                TextField(controller: grossCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gross Weight (g)')),
                TextField(controller: netCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Net Weight (g)')),
                TextField(controller: caratCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carat (purity)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final String finalDesc = manual ? descCtrl.text.trim() : (desc ?? 'Item');
                final int pcs = int.tryParse(pcsCtrl.text.trim()) ?? 0;
                final double gross = double.tryParse(grossCtrl.text.trim()) ?? 0;
                final double net = double.tryParse(netCtrl.text.trim()) ?? 0;
                final double carat = double.tryParse(caratCtrl.text.trim()) ?? 0;
                Navigator.pop(
                  context,
                  OrnamentItem(
                    description: finalDesc,
                    numberOfPieces: pcs,
                    grossWeightGrams: gross,
                    netWeightGrams: net,
                    caratPurity: carat,
                  ),
                );
              },
              child: const Text('Add'),
            )
          ],
        );
      }),
    );

    if (item != null) {
      setState(() => _items.add(item));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedBank == null || _selectedBranch == null || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete all fields and add ornaments')));
      return;
    }
    final int loan = int.tryParse(_loanCtrl.text.trim()) ?? 0;
    final int fee = FeeService.computeFeeRupees(loan);
    final v = Valuation(
      id: _uuid.v4(),
      bankId: _selectedBank!.id,
      branchId: _selectedBranch!.id,
      date: _date,
      loanAmountRupees: loan,
      customerName: _nameCtrl.text.trim(),
      customerAddress: _addrCtrl.text.trim(),
      ornaments: List.of(_items),
      feeRupees: fee,
    );
    await StorageService.valuationsBox.put(v.id, v);

    final profile = StorageService.profileBox.get('profile') ?? const ValuerProfile(name: 'Valuer', address: '', phone: '');
    final file = await PdfService.generateValuationPdf(
      valuation: v,
      bank: _selectedBank!,
      branch: _selectedBranch!,
      profile: profile,
    );
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.save_alt), title: const Text('Saved PDF'), subtitle: Text(file.path)),
          ListTile(leading: const Icon(Icons.share), title: const Text('Share'), onTap: () async { Navigator.pop(context); await PdfService.sharePdf(file); }),
          ListTile(leading: const Icon(Icons.print), title: const Text('Print'), onTap: () async { Navigator.pop(context); await PdfService.printPdf(file); }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banks = _bankBranchService.getBanks();
    final branches = _selectedBank != null ? _bankBranchService.getBranchesByBank(_selectedBank!.id) : <Branch>[];
    final DateFormat df = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('New Valuation')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<Bank>(
              value: _selectedBank,
              items: banks.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
              onChanged: (b) => setState(() { _selectedBank = b; _selectedBranch = null; }),
              decoration: const InputDecoration(labelText: 'Bank'),
              validator: (v) => v == null ? 'Select bank' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Branch>(
              value: _selectedBranch,
              items: branches.map((br) => DropdownMenuItem(value: br, child: Text(br.name))).toList(),
              onChanged: (br) => setState(() { _selectedBranch = br; }),
              decoration: const InputDecoration(labelText: 'Branch'),
              validator: (v) => v == null ? 'Select branch' : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(df.format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: _date);
                if (picked != null) setState(() => _date = picked);
              },
            ),
            TextFormField(controller: _loanCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Loan Amount (₹)'), validator: (v) => (v==null||v.isEmpty)?'Required':null),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name'), validator: (v) => (v==null||v.isEmpty)?'Required':null),
            TextFormField(controller: _addrCtrl, decoration: const InputDecoration(labelText: 'Customer Address'), maxLines: 2, validator: (v) => (v==null||v.isEmpty)?'Required':null),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ornament Details', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: _addItemDialog, icon: const Icon(Icons.add), label: const Text('Add')),
              ],
            ),
            ..._items.asMap().entries.map((e) {
              final i = e.key;
              final o = e.value;
              return Card(
                child: ListTile(
                  title: Text(o.description),
                  subtitle: Text('Pcs: ${o.numberOfPieces}  Gross: ${o.grossWeightGrams} g  Net: ${o.netWeightGrams} g  ${o.caratPurity} ct'),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _items.removeAt(i))),
                ),
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Gross: ${_totalGross.toStringAsFixed(3)} g'),
                Text('Total Net: ${_totalNet.toStringAsFixed(3)} g'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Save & Generate PDF'))),
          ],
        ),
      ),
    );
  }
}

