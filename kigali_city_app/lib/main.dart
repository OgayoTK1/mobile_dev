import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth_wrapper.dart';

/// ──────────────────────────────────────────────────────────────
/// Kigali City Services & Places Directory
///
/// Entry point for the Flutter application.
///
/// Initialization flow:
///   1. WidgetsFlutterBinding.ensureInitialized()
///   2. Firebase.initializeApp()
///   3. FirebaseAppCheck.activate() — debug token for dev/emulator,
///      Play Integrity for production release builds
///   4. ProviderScope wraps the entire app
///   5. AuthWrapper handles routing based on auth state
///
/// Architecture summary:
///   main.dart → AuthWrapper → LoginScreen / HomeShell
///   HomeShell → BottomNav → Directory / MyListings / Map / Settings
///   All data flows: Firestore → Service → Repository → Provider → UI
/// ──────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Activate App Check.
  // In debug mode (emulator/dev) the debug provider prints a token
  // to logcat — register it in Firebase Console → App Check → Apps.
  // In release builds, Play Integrity is used automatically.
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );

  runApp(const ProviderScope(child: KigaliCityApp()));
}

class KigaliCityApp extends StatelessWidget {
  const KigaliCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kigali City Directory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}
