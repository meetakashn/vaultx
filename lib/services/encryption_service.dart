// lib/services/encryption_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'vaultx_master_enc_key';
  static const _ivStorageKey = 'vaultx_master_enc_iv';

  static enc.Encrypter? _encrypter;
  static enc.IV? _iv;

  /// Initialize encryption with user's UID as seed
  static Future<void> initialize(String uid) async {
    String? storedKey = await _storage.read(key: '${_keyStorageKey}_$uid');
    String? storedIv = await _storage.read(key: '${_ivStorageKey}_$uid');

    if (storedKey == null || storedIv == null) {
      // Generate deterministic key from uid using SHA-256
      final keyBytes = sha256.convert(utf8.encode('vaultx_$uid')).bytes;
      final ivBytes = md5.convert(utf8.encode('vaultx_iv_$uid')).bytes;

      storedKey = base64.encode(keyBytes);
      storedIv = base64.encode(ivBytes);

      await _storage.write(key: '${_keyStorageKey}_$uid', value: storedKey);
      await _storage.write(key: '${_ivStorageKey}_$uid', value: storedIv);
    }

    final keyBytes = Uint8List.fromList(base64.decode(storedKey));
    final ivBytes = Uint8List.fromList(base64.decode(storedIv));

    final key = enc.Key(keyBytes);
    _iv = enc.IV(ivBytes);
    _encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
  }

  /// Encrypt a plain text string
  static String encrypt(String plainText) {
    if (_encrypter == null || _iv == null) {
      throw Exception('EncryptionService not initialized');
    }
    if (plainText.isEmpty) return '';
    final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
    return encrypted.base64;
  }

  /// Decrypt an encrypted base64 string
  static String decrypt(String encryptedText) {
    if (_encrypter == null || _iv == null) {
      throw Exception('EncryptionService not initialized');
    }
    if (encryptedText.isEmpty) return '';
    try {
      final decrypted = _encrypter!.decrypt64(encryptedText, iv: _iv!);
      return decrypted;
    } catch (e) {
      return '••••••••';
    }
  }

  static Future<void> clearKeys(String uid) async {
    await _storage.delete(key: '${_keyStorageKey}_$uid');
    await _storage.delete(key: '${_ivStorageKey}_$uid');
    _encrypter = null;
    _iv = null;
  }
}
