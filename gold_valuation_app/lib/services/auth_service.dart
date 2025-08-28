import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _pinKey = 'auth_pin_hash_v1';
  static const String _biometricEnabledKey = 'biometric_enabled_v1';

  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  static Future<bool> isPinSet() async {
    final value = await _secureStorage.read(key: _pinKey);
    return value != null && value.isNotEmpty;
  }

  static Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _secureStorage.write(key: _pinKey, value: hash);
  }

  static Future<bool> verifyPin(String pin) async {
    final stored = await _secureStorage.read(key: _pinKey);
    if (stored == null) return false;
    return stored == _hashPin(pin);
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  static Future<bool> canCheckBiometrics() async {
    final localAuth = LocalAuthentication();
    try {
      return await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics({String reason = 'Authenticate to continue'}) async {
    final localAuth = LocalAuthentication();
    try {
      final didAuth = await localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      return didAuth;
    } on PlatformException {
      return false;
    }
  }
}

