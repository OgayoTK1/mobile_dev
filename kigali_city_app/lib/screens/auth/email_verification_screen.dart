import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../providers/app_providers.dart';

/// ──────────────────────────────────────────────────────────────
/// Email Verification Screen
///
/// Displayed when user is authenticated but email is NOT verified.
/// This screen BLOCKS access to the Directory and all main screens.
///
/// Flow:
///   1. User sees this screen after signup
///   2. They check their email and click the verification link
///   3. They come back and tap "I've Verified My Email"
///   4. App calls reloadUser() to refresh the emailVerified flag
///   5. If verified → auth wrapper routes to main app
///   6. If not verified → shows error message
/// ──────────────────────────────────────────────────────────────
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final isVerified = await authRepo.checkEmailVerified();

      if (!isVerified && mounted) {
        showErrorSnackbar(
          context,
          'Email not yet verified. Please check your inbox.',
        );
      }
      // If verified, authStateChanges will emit and the auth
      // wrapper will automatically navigate to the main app.
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Error checking verification status.');
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);

    try {
      await ref.read(authRepositoryProvider).sendVerificationEmail();
      if (mounted) {
        showSuccessSnackbar(context, 'Verification email sent!');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Could not send verification email.');
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 72,
                color: AppColors.accent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We sent a verification link to your email address. '
                'Please click the link to verify your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Check verification button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  child: _isChecking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundDarker,
                          ),
                        )
                      : const Text("I've Verified My Email"),
                ),
              ),
              const SizedBox(height: 14),

              // Resend button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isResending ? null : _resendVerification,
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        )
                      : const Text('Resend Verification Email'),
                ),
              ),
              const SizedBox(height: 20),

              // Sign out
              TextButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.textDim),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
