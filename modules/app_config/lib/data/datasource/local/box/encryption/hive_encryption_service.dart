import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive_ce.dart';

/// Service for managing Hive encryption keys using secure storage.
///
/// This service generates and stores encryption keys in the device's
/// secure storage (Keychain on iOS, Keystore on Android) to protect
/// sensitive financial data stored in Hive boxes.
class HiveEncryptionService {
  static const String _encryptionKeyStorageKey = 'hive_encryption_key';
  static const int _keyLength = 32; // 256-bit key for AES-256

  final FlutterSecureStorage _secureStorage;
  String? _cachedKey;

  HiveEncryptionService(this._secureStorage);

  /// Gets or generates the encryption key for Hive.
  ///
  /// The key is stored in secure storage and cached in memory for performance.
  /// Returns a 32-character string suitable for HiveAesCipher.
  Future<String> getEncryptionKey() async {
    if (_cachedKey != null) {
      return _cachedKey!;
    }

    // Try to read existing key from secure storage
    final storedKey = await _secureStorage.read(key: _encryptionKeyStorageKey);
    if (storedKey != null && storedKey.length == _keyLength) {
      _cachedKey = storedKey;
      return _cachedKey!;
    }

    // Generate new key if none exists or is invalid
    final newKey = _generateSecureKey();
    await _secureStorage.write(key: _encryptionKeyStorageKey, value: newKey);
    _cachedKey = newKey;
    return newKey;
  }

  /// Generates a cryptographically secure random key.
  String _generateSecureKey() {
    final random = Random.secure();
    final bytes = Uint8List(_keyLength);
    for (int i = 0; i < _keyLength; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Url.encode(bytes).substring(0, _keyLength);
  }

  /// Creates a Hive AES cipher using the encryption key.
  ///
  /// This cipher can be passed to Hive.init() for encrypting boxes.
  Future<HiveAesCipher> createCipher() async {
    final key = await getEncryptionKey();
    return HiveAesCipher(Uint8List.fromList(key.codeUnits));
  }

  /// Clears the cached encryption key from memory.
  ///
  /// The key remains in secure storage and will be reloaded on next access.
  void clearCachedKey() {
    _cachedKey = null;
  }

  /// Deletes the encryption key from secure storage.
  ///
  /// ⚠️ WARNING: This will make all encrypted data inaccessible.
  /// Only use this for testing or when implementing a data reset feature.
  Future<void> deleteEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyStorageKey);
    _cachedKey = null;
  }
}
