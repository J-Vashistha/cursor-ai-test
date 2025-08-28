import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _biometricAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final canBio = await AuthService.canCheckBiometrics();
    final bioEnabled = await AuthService.isBiometricEnabled();
    setState(() {
      _biometricAvailable = canBio && bioEnabled;
      _loading = false;
    });
    if (_biometricAvailable) {
      final ok = await AuthService.authenticateWithBiometrics(reason: 'Unlock Gold Valuation App');
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _loginWithPin() async {
    final pin = _pinController.text.trim();
    final valid = await AuthService.verifyPin(pin);
    if (valid) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loginWithPin,
              child: const Text('Unlock'),
            ),
            if (_biometricAvailable) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final ok = await AuthService.authenticateWithBiometrics(reason: 'Unlock with biometrics');
                  if (!mounted) return;
                  if (ok) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
                child: const Text('Use Biometrics'),
              ),
            ],
            const Spacer(),
            TextButton(
              onPressed: () async {
                final enabled = await AuthService.isBiometricEnabled();
                await AuthService.setBiometricEnabled(!enabled);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Biometric ${!enabled ? 'enabled' : 'disabled'}')));
                _init();
              },
              child: const Text('Toggle Biometric'),
            ),
          ],
        ),
      ),
    );
  }
}

