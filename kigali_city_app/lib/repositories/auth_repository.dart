import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// ──────────────────────────────────────────────────────────────
/// AuthRepository
///
/// Orchestrates sign-up / sign-in / sign-out flows across
/// AuthService (Firebase Auth) and FirestoreService (Firestore).
///
/// Sign-up flow:
///   1. AuthService.signUpWithEmail()  → Firebase Auth account
///   2. user.updateDisplayName()       → set display name in Auth
///   3. FirestoreService.createUserProfile() → users/{uid} doc
///   4. AuthService.sendEmailVerification() → verification email
///
/// The Firestore profile uses the Firebase Auth UID as doc ID,
/// so every listing the user creates stores ownerId = uid and
/// links back to their profile.
/// ──────────────────────────────────────────────────────────────
class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  // ─── Auth state ──────────────────────────────────────────────

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  bool get isEmailVerified => _authService.isEmailVerified;

  // ─── Sign Up ─────────────────────────────────────────────────
  //
  // 1. Creates Firebase Auth account
  // 2. Sets display name
  // 3. Creates Firestore users/{uid} profile document
  // 4. Sends verification email
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _authService.signUpWithEmail(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(displayName.trim());

      await _firestoreService.createUserProfile(
        UserProfile(
          uid: user.uid,
          email: email.trim(),
          displayName: displayName.trim(),
          createdAt: DateTime.now(),
        ),
      );

      await _authService.sendEmailVerification();
    }

    return user;
  }

  // ─── Sign In ─────────────────────────────────────────────────
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  // ─── Sign Out ────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // ─── Email Verification ──────────────────────────────────────

  /// Re-sends the verification email to the current user.
  Future<void> resendVerificationEmail() async {
    await _authService.sendEmailVerification();
  }

  /// Reloads the Firebase Auth user token and returns whether
  /// the email address is now verified.
  Future<bool> refreshUser() async {
    await _authService.reloadUser();
    return _authService.isEmailVerified;
  }

  // ─── Password Reset ──────────────────────────────────────────
  Future<void> sendPasswordReset({required String email}) async {
    await _authService.sendPasswordReset(email: email.trim());
  }

  // ─── User Profile ────────────────────────────────────────────
  Future<UserProfile?> getUserProfile(String uid) async {
    return _firestoreService.getUserProfile(uid);
  }

  Stream<UserProfile?> userProfileStream(String uid) {
    return _firestoreService.userProfileStream(uid);
  }
}
