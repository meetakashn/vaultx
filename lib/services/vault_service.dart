// lib/services/vault_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vault_item.dart';
import '../models/account_entry.dart';
import 'encryption_service.dart';
import 'auth_service.dart';

class VaultService {
  static final _db = FirebaseFirestore.instance;

  static String get _uid => AuthService.currentUser!.uid;

  static CollectionReference get _vaults =>
      _db.collection('users').doc(_uid).collection('vaults');

  // ─── VAULTS ─────────────────────────────────────────────

  static Stream<List<VaultItem>> streamVaults() {
    return _vaults
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => VaultItem.fromDoc(doc)).toList());
  }

  static Future<String> addVault(VaultItem item) async {
    final doc = await _vaults.add(item.toMap());
    return doc.id;
  }

  static Future<void> updateVault(VaultItem item) async {
    await _vaults.doc(item.id).update(item.toMap());
  }

  static Future<void> deleteVault(String vaultId) async {
    // Delete all accounts first
    final accounts = await _vaults
        .doc(vaultId)
        .collection('accounts')
        .get();
    for (final doc in accounts.docs) {
      await doc.reference.delete();
    }
    await _vaults.doc(vaultId).delete();
  }

  // ─── ACCOUNTS ────────────────────────────────────────────

  static CollectionReference _accounts(String vaultId) =>
      _vaults.doc(vaultId).collection('accounts');

  static Stream<List<AccountEntry>> streamAccounts(String vaultId) {
    return _accounts(vaultId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => AccountEntry.fromDoc(doc)).toList());
  }

  static Future<void> addAccount(
      String vaultId, AccountEntry entry) async {
    // Encrypt sensitive fields before storing
    final encrypted = AccountEntry(
      label: entry.label,
      username: EncryptionService.encrypt(entry.username),
      password: EncryptionService.encrypt(entry.password),
      notes: EncryptionService.encrypt(entry.notes),
      createdAt: entry.createdAt,
    );
    await _accounts(vaultId).add(encrypted.toMap());
  }

  static Future<void> updateAccount(
      String vaultId, AccountEntry entry) async {
    final encrypted = AccountEntry(
      id: entry.id,
      label: entry.label,
      username: EncryptionService.encrypt(entry.username),
      password: EncryptionService.encrypt(entry.password),
      notes: EncryptionService.encrypt(entry.notes),
      createdAt: entry.createdAt,
    );
    await _accounts(vaultId).doc(entry.id).update(encrypted.toMap());
  }

  static Future<void> deleteAccount(
      String vaultId, String accountId) async {
    await _accounts(vaultId).doc(accountId).delete();
  }

  static AccountEntry decryptAccount(AccountEntry entry) {
    return AccountEntry(
      id: entry.id,
      label: entry.label,
      username: EncryptionService.decrypt(entry.username),
      password: EncryptionService.decrypt(entry.password),
      notes: EncryptionService.decrypt(entry.notes),
      createdAt: entry.createdAt,
    );
  }
}
