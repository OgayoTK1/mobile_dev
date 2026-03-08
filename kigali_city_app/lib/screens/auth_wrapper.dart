import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'auth/email_verification_screen.dart';
import 'auth/login_screen.dart';
import 'home_shell.dart';

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
        if (!user.emailVerified) return const EmailVerificationScreen();
        return const HomeShell();
      },
    );
  }
}
