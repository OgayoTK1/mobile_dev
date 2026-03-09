import 'package:firebase_auth/firebase_auth.dart';

/// ──────────────────────────────────────────────────────────────
/// AuthService
///
/// Abstracts all Firebase Authentication operations.
/// This service is consumed by AuthRepository, NEVER directly
/// by UI widgets. This separation allows:
///   1. Easy testing (mock this service)
///   2. Swapping auth providers without UI changes
///   3. Single source of truth for auth logic
///
/// Auth State Flow:
///   FirebaseAuth.authStateChanges() → StreamProvider → UI
///   The stream automatically emits when:
///     - User signs in
///     - User signs out
///     - User email is verified (after reload)
///     - Token is refreshed
/// ──────────────────────────────────────────────────────────────
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Returns the currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  /// Emits User? whenever the authentication state changes.
  /// Used by authStateProvider to drive the entire app's auth state.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in with email and password.
  ///
  /// Throws FirebaseAuthException on failure with codes like:
  ///   - 'user-not-found': No user with this email
  ///   - 'wrong-password': Incorrect password
  ///   - 'user-disabled': Account has been disabled
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates a new user account with email and password.
  ///
  /// After successful creation, immediately sends email verification.
  /// Throws FirebaseAuthException with codes like:
  ///   - 'email-already-in-use': Account exists
  ///   - 'weak-password': Password too short
  ///   - 'invalid-email': Malformed email
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Send verification email immediately after signup
    await credential.user?.sendEmailVerification();

    return credential;
  }

  /// Sends a verification email to the current user.
  /// Called again if the user requests to resend verification.
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Reloads the current user's data from Firebase.
  /// This is necessary to check if emailVerified has changed,
  /// since the local User object doesn't auto-update.
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Returns true if the current user's email is verified.
  /// Must call reloadUser() first to get the latest status.
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email.
  Future<void> sendPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
