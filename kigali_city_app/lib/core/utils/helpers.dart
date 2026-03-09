import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

/// ──────────────────────────────────────────────────────────────
/// Launches Google Maps with directions to the given coordinates
/// ──────────────────────────────────────────────────────────────
Future<void> launchGoogleMapsNavigation({
  required double latitude,
  required double longitude,
  String? label,
}) async {
  final Uri googleMapsUri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
  );

  if (await canLaunchUrl(googleMapsUri)) {
    await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Could not launch Google Maps');
  }
}

/// ──────────────────────────────────────────────────────────────
/// Form Validators
/// ──────────────────────────────────────────────────────────────
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? latitude(String? value) {
    if (value == null || value.trim().isEmpty) return 'Latitude is required';
    final lat = double.tryParse(value);
    if (lat == null || lat < -90 || lat > 90) {
      return 'Enter valid latitude (-90 to 90)';
    }
    return null;
  }

  static String? longitude(String? value) {
    if (value == null || value.trim().isEmpty) return 'Longitude is required';
    final lng = double.tryParse(value);
    if (lng == null || lng < -180 || lng > 180) {
      return 'Enter valid longitude (-180 to 180)';
    }
    return null;
  }
}

/// ──────────────────────────────────────────────────────────────
/// Snackbar Helpers
/// ──────────────────────────────────────────────────────────────
void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}
