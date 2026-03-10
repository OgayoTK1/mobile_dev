import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../providers/app_providers.dart';

/// ──────────────────────────────────────────────────────────────
/// Login Screen — Sign In / Sign Up
///
/// Sign In:  email + password
/// Sign Up:  full name + email + password + confirm password
///           → creates Firebase Auth account
///           → creates Firestore users/{uid} profile
///           → sends email verification link
///
/// After sign-up the user is shown EmailVerificationScreen
/// (enforced by AuthWrapper) until they verify their address.
/// ──────────────────────────────────────────────────────────────
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _signInKey = GlobalKey<FormState>();
  final _signUpKey = GlobalKey<FormState>();

  // Sign-in controllers
  final _siEmailCtrl = TextEditingController();
  final _siPasswordCtrl = TextEditingController();

  // Sign-up controllers
  final _suNameCtrl = TextEditingController();
  final _suEmailCtrl = TextEditingController();
  final _suPasswordCtrl = TextEditingController();
  final _suConfirmCtrl = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscureSignIn = true;
  bool _obscureSignUp = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _siEmailCtrl.dispose();
    _siPasswordCtrl.dispose();
    _suNameCtrl.dispose();
    _suEmailCtrl.dispose();
    _suPasswordCtrl.dispose();
    _suConfirmCtrl.dispose();
    super.dispose();
  }

  // ─── Sign In ────────────────────────────────────────────────
  Future<void> _signIn() async {
    if (!_signInKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: _siEmailCtrl.text, password: _siPasswordCtrl.text);
    } on Exception catch (e) {
      if (mounted) showErrorSnackbar(context, _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Sign Up ────────────────────────────────────────────────
  Future<void> _signUp() async {
    if (!_signUpKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _suEmailCtrl.text,
            password: _suPasswordCtrl.text,
            displayName: _suNameCtrl.text,
          );
      if (mounted) {
        showSuccessSnackbar(
          context,
          'Account created! Check your inbox to verify your email.',
        );
      }
    } on Exception catch (e) {
      if (mounted) showErrorSnackbar(context, _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Forgot Password ─────────────────────────────────────────
  void _showForgotPassword() {
    final emailCtrl = TextEditingController(text: _siEmailCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Reset Password',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email and we\'ll send you a reset link.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.textDim,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref
                    .read(authRepositoryProvider)
                    .sendPasswordReset(email: email);
                if (mounted) {
                  showSuccessSnackbar(context, 'Password reset email sent!');
                }
              } on Exception catch (e) {
                if (mounted) {
                  showErrorSnackbar(context, _parseError(e.toString()));
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  // ─── Error parsing ───────────────────────────────────────────
  String _parseError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }
    if (error.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (error.contains('network-request-failed')) {
      return 'Network error. Check your connection.';
    }
    if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (error.contains('blocked') || error.contains('BLOCKED')) {
      return 'Sign-up is currently disabled. Please contact the administrator.';
    }
    if (error.contains('internal-error') || error.contains('INTERNAL')) {
      return 'A server error occurred. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  // ─── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 56),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.location_city,
                  size: 44,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kigali City',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Services & Places Directory',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 36),

              // Tab toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildTab('Sign In', _isLogin),
                    _buildTab('Sign Up', !_isLogin),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Animated form switcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isLogin ? _buildSignInForm() : _buildSignUpForm(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sign In form ─────────────────────────────────────────────
  Widget _buildSignInForm() {
    return Form(
      key: _signInKey,
      child: Column(
        key: const ValueKey('signin'),
        children: [
          TextFormField(
            controller: _siEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textDim),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _siPasswordCtrl,
            obscureText: _obscureSignIn,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.textDim,
              ),
              suffixIcon: _visibilityIcon(
                obscure: _obscureSignIn,
                onTap: () => setState(() => _obscureSignIn = !_obscureSignIn),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            validator: Validators.password,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPassword,
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontSize: 13, color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.backgroundDarker,
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sign Up form ─────────────────────────────────────────────
  Widget _buildSignUpForm() {
    return Form(
      key: _signUpKey,
      child: Column(
        key: const ValueKey('signup'),
        children: [
          // Full name
          TextFormField(
            controller: _suNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textDim),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            validator: (v) => Validators.required(v, 'Full name'),
          ),
          const SizedBox(height: 14),

          // Email
          TextFormField(
            controller: _suEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textDim),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            validator: Validators.email,
          ),
          const SizedBox(height: 14),

          // Password
          TextFormField(
            controller: _suPasswordCtrl,
            obscureText: _obscureSignUp,
            decoration: InputDecoration(
              hintText: 'Password (min. 6 characters)',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.textDim,
              ),
              suffixIcon: _visibilityIcon(
                obscure: _obscureSignUp,
                onTap: () => setState(() => _obscureSignUp = !_obscureSignUp),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            validator: Validators.password,
          ),
          const SizedBox(height: 14),

          // Confirm password
          TextFormField(
            controller: _suConfirmCtrl,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.textDim,
              ),
              suffixIcon: _visibilityIcon(
                obscure: _obscureConfirm,
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm your password';
              }
              if (v != _suPasswordCtrl.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          const Text(
            'A verification email will be sent to activate your account.',
            style: TextStyle(fontSize: 12, color: AppColors.textDim),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.backgroundDarker,
                      ),
                    )
                  : const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────
  Widget _buildTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLogin = label == 'Sign In'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? AppColors.backgroundDarker
                  : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _visibilityIcon({required bool obscure, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off : Icons.visibility,
        color: AppColors.textDim,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}
