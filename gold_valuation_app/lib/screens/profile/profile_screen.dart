import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/valuer_profile.dart';
import '../../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _addr = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final p = StorageService.profileBox.get('profile');
    if (p != null) {
      _name.text = p.name;
      _addr.text = p.address;
      _phone.text = p.phone;
      _email.text = p.email ?? '';
      _logoPath = p.logoFilePath;
    }
  }

  Future<void> _pickLogo() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.single.path != null) {
      setState(() => _logoPath = res.files.single.path);
    }
  }

  Future<void> _save() async {
    final profile = ValuerProfile(
      name: _name.text.trim(),
      address: _addr.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      logoFilePath: _logoPath,
    );
    await StorageService.profileBox.put('profile', profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valuer Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _addr, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email (optional)')),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(onPressed: _pickLogo, icon: const Icon(Icons.image), label: const Text('Pick Logo')),
            const SizedBox(width: 12),
            Expanded(child: Text(_logoPath ?? 'No logo selected')),
          ]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
        ],
      ),
    );
  }
}

