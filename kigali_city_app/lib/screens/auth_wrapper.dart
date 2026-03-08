import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'auth/email_verification_screen.dart';
import 'auth/login_screen.dart';
import 'home_shell.dart';

// DEV ONLY: Set to true to bypass email verification during testing
// TODO: Remove this in production or set to false
const bool kBypassEmailVerification = true;

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginScreen(),
      data: (User? user) {
        if (user == null) return const LoginScreen();

        // DEV: Skip email verification if bypass flag is enabled
        if (!kBypassEmailVerification && !user.emailVerified) {
          return const EmailVerificationScreen();
        }

        return const HomeShell();
      },
    );
  }
}
