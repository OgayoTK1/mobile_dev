import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final bool notificationsEnabled;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: data[FirestoreFields.uid] as String,
      email: data[FirestoreFields.email] as String,
      displayName: data[FirestoreFields.displayName] as String? ?? '',
      photoUrl: data[FirestoreFields.photoUrl] as String?,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp).toDate(),
      notificationsEnabled:
          data[FirestoreFields.notificationsEnabled] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreFields.uid: uid,
      FirestoreFields.email: email,
      FirestoreFields.displayName: displayName,
      FirestoreFields.photoUrl: photoUrl,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.notificationsEnabled: notificationsEnabled,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
