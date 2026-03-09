import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart'; // add this import

/// ──────────────────────────────────────────────────────────────
/// UserProfile model
///
/// Maps to: Firestore → users/{uid}
/// Fields: email, displayName, createdAt
///
/// Uses factory constructors for Firestore serialization.
/// Stored after successful signup to maintain user metadata
/// separate from Firebase Auth.
/// ──────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  /// Creates UserProfile from a Firestore document snapshot.
  /// The [doc.id] is used as the uid since documents are stored
  /// under users/{uid}.
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the UserProfile to a Map for Firestore storage.
  /// Uses FieldValue.serverTimestamp() for createdAt to ensure
  /// consistent timestamps across clients.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a copy with optional overrides.
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'UserProfile(uid: $uid, email: $email, displayName: $displayName)';
}
