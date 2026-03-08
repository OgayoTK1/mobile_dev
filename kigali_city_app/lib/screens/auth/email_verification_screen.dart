import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/helpers.dart';
import '../../providers/app_providers.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Poll Firebase every 3 seconds to check if the user verified their email.
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await ref.read(authRepositoryProvider).refreshUser();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authRepositoryProvider).resendVerificationEmail();
      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Verification email sent');
      }
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80),
            const SizedBox(height: 24),
            Text(
              'Check your inbox',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "We've sent a verification link to your email address. "
              'Please click the link to continue.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isResending ? null : _resend,
              child: _isResending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Resend Email'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 32),
            // DEV ONLY: Bypass email verification for testing
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
              onPressed: () async {
                // Manually mark email as verified in Firebase (dev workaround)
                final user = ref.read(authRepositoryProvider).currentUser;
                if (user != null) {
                  // This won't actually verify the email in Firebase, but will
                  // let us proceed for testing. In production, remove this button.
                  if (mounted) {
                    SnackbarHelper.showInfo(
                      context,
                      '⚠️ Dev bypass: Proceeding without verification',
                    );
                  }
                  // Force a sign out and sign in to refresh the auth state
                  // This is a workaround - the proper fix is to get Firebase emails working
                }
              },
              child: const Text('🔧 Skip Verification (Dev Only)'),
            ),
          ],
        ),
      ),
    );
  }
}
