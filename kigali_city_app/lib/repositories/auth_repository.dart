import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  bool get isEmailVerified => _authService.isEmailVerified;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authService.signInWithEmail(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _authService.createUserWithEmail(
      email: email,
      password: password,
    );
    await _authService.updateDisplayName(displayName);
    await _authService.sendEmailVerification();
    final profile = UserProfile(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    await _firestoreService.createUserProfile(profile);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> resendVerificationEmail() async {
    await _authService.reloadUser();
    await _authService.sendEmailVerification();
  }

  Future<void> refreshUser() async {
    await _authService.reloadUser();
  }
}
