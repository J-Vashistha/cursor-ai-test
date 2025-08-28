import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _saving = false;

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be at least 4 digits')));
      return;
    }
    if (pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PINs do not match')));
      return;
    }
    setState(() => _saving = true);
    await AuthService.setPin(pin);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _savePin,
                child: _saving ? const CircularProgressIndicator() : const Text('Save PIN'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

