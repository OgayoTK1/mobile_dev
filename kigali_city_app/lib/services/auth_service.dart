import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ No current user - cannot send verification email');
        return;
      }

      if (user.emailVerified) {
        debugPrint('✓ Email already verified');
        return;
      }

      debugPrint(' Attempting to send verification email to: ${user.email}');
      await user.sendEmailVerification();
      debugPrint('✓ Verification email sent successfully');
    } catch (e) {
      debugPrint(' Error sending verification email: $e');
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
