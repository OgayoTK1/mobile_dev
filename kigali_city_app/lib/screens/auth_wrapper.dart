import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';
import 'auth/login_screen.dart';
import 'auth/email_verification_screen.dart';
import 'home_shell.dart';

/// ──────────────────────────────────────────────────────────────
/// Auth Wrapper
///
/// Top-level widget that routes the user based on auth state.
/// This is the single point where authentication and email
/// verification are enforced.
///
/// Routing logic:
///   authStateProvider → AsyncValue User? → Widget
///     ├── AsyncLoading  → AppLoadingWidget (spinner)
///     ├── AsyncLoading  → Loading spinner
///     ├── AsyncError    → Error screen with retry
///     ├── AsyncData(null) → LoginScreen (not authenticated)
///     └── AsyncData(user)
///           ├── user.emailVerified == false → EmailVerificationScreen
///           └── user.emailVerified == true  → HomeShell (main app)
///
/// The user CANNOT access the Directory, My Listings, Map, or
/// Settings screens unless:
///   1. They are signed in (Firebase Auth)
///   2. Their email is verified (emailVerified == true)
/// ──────────────────────────────────────────────────────────────
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  // ─── DEV BYPASS ──────────────────────────────────────────────
  // Set to true to skip authentication and go straight to the app.
  // Set back to false before production release.
  static const bool _devBypass = false;
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_devBypass) return const HomeShell();

    final authState = ref.watch(authStateProvider);

    return authState.when(
      // ─── Loading ─────────────────────────────────────────
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      // ─── Error ───────────────────────────────────────────
      error: (error, _) => Scaffold(
        body: AppErrorWidget(
          message: 'Authentication error: $error',
          onRetry: () => ref.invalidate(authStateProvider),
        ),
      ),

      // ─── Data ────────────────────────────────────────────
      data: (user) {
        // Not authenticated → Login
        if (user == null) {
          return const LoginScreen();
        }

        // Authenticated but email NOT verified → Verification
        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        // Authenticated AND verified → Main App
        return const HomeShell();
      },
    );
  }
}
