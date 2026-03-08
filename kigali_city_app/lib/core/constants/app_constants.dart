import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1DB954);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color error = Color(0xFFCF6679);
  static const Color starColor = Color(0xFFFFC107);
}

class FirestoreFields {
  // User profile fields
  static const String uid = 'uid';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoUrl = 'photoUrl';
  static const String createdAt = 'createdAt';
  static const String notificationsEnabled = 'notificationsEnabled';

  // Listing fields
  static const String listingId = 'listingId';
  static const String title = 'title';
  static const String description = 'description';
  static const String category = 'category';
  static const String address = 'address';
  static const String phone = 'phone';
  static const String website = 'website';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String ownerId = 'ownerId';
  static const String ownerName = 'ownerName';
  static const String rating = 'rating';
  static const String reviewCount = 'reviewCount';
  static const String imageUrl = 'imageUrl';
  static const String updatedAt = 'updatedAt';
  static const String isVerified = 'isVerified';
}

const List<String> kCategories = [
  'All',
  'Restaurants',
  'Hotels',
  'Shopping',
  'Healthcare',
  'Education',
  'Finance',
  'Entertainment',
  'Transport',
  'Services',
  'Attractions',
];

const String kUsersCollection = 'users';
const String kListingsCollection = 'listings';
