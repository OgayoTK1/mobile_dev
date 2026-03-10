import 'package:firebase_core/firebase_core.dart';
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
///      - Required before calling async code in main()
///   2. Firebase.initializeApp()
///      - Connects to Firebase project using google-services.json
///        (Android) or GoogleService-Info.plist (iOS)
///   3. ProviderScope wraps the entire app
///      - Enables Riverpod dependency injection
///      - All providers are accessible from any widget below this
///   4. AuthWrapper handles routing based on auth state
///
/// Architecture summary:
///   main.dart → AuthWrapper → LoginScreen / HomeShell
///   HomeShell → BottomNav → Directory / MyListings / Map / Settings
///   All data flows: Firestore → Service → Repository → Provider → UI
/// ──────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
