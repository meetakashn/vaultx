// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'encryption_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    if (cred.user != null) {
      await EncryptionService.initialize(cred.user!.uid);
    }
    return cred;
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) {
      await EncryptionService.initialize(cred.user!.uid);
    }
    return cred;
  }

  static Future<void> logout() async {
    final uid = currentUser?.uid;
    await _auth.signOut();
    if (uid != null) {
      await EncryptionService.clearKeys(uid);
    }
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
