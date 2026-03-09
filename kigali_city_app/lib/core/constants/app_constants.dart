import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────────────────
/// App-wide color palette matching the dark UI design
/// ──────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF1A1A2E);
  static const Color backgroundCard = Color(0xFF16213E);
  static const Color backgroundDarker = Color(0xFF0F1629);
  static const Color backgroundNav = Color(0xFF0D1321);

  static const Color accent = Color(0xFFE6A919);
  static const Color accentLight = Color(0xFFF5C842);
  static const Color accentDim = Color(0x26E6A919); // 15% opacity

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8892A4);
  static const Color textDim = Color(0xFF5A6377);

  static const Color border = Color(0xFF2A3550);
  static const Color star = Color(0xFFE6A919);
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color categoryBg = Color(0xFF1E2D4A);

  static const Color primary = accent;
}

/// ──────────────────────────────────────────────────────────────
/// Firestore collection & field constants
/// ──────────────────────────────────────────────────────────────
class FirestoreConstants {
  FirestoreConstants._();

  // Collection names
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';

  // User document fields
  static const String fieldEmail = 'email';
  static const String fieldDisplayName = 'displayName';
  static const String fieldCreatedAt = 'createdAt';

  // Listing document fields
  static const String fieldName = 'name';
  static const String fieldCategory = 'category';
  static const String fieldAddress = 'address';
  static const String fieldContactNumber = 'contactNumber';
  static const String fieldDescription = 'description';
  static const String fieldLatitude = 'latitude';
  static const String fieldLongitude = 'longitude';
  static const String fieldCreatedBy = 'createdBy';
  static const String fieldTimestamp = 'timestamp';
}

/// ──────────────────────────────────────────────────────────────
/// Service categories available in the app
/// ──────────────────────────────────────────────────────────────
class AppCategories {
  AppCategories._();

  static const List<String> all = [
    'Cafés',
    'Pharmacies',
    'Restaurants',
    'Hotels',
    'Banks',
    'Salons',
    'Hospitals',
    'Supermarkets',
  ];

  static const Map<String, IconData> icons = {
    'Cafés': Icons.coffee,
    'Pharmacies': Icons.local_pharmacy,
    'Restaurants': Icons.restaurant,
    'Hotels': Icons.hotel,
    'Banks': Icons.account_balance,
    'Salons': Icons.content_cut,
    'Hospitals': Icons.local_hospital,
    'Supermarkets': Icons.shopping_cart,
  };
}

/// ──────────────────────────────────────────────────────────────
/// App-wide text styles
/// ──────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}