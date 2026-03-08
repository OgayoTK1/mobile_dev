import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';
import '../models/user_profile.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Profile ---

  Future<void> createUserProfile(UserProfile profile) async {
    await _db
        .collection(kUsersCollection)
        .doc(profile.uid)
        .set(profile.toFirestore());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection(kUsersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(kUsersCollection).doc(uid).update(data);
  }

  // --- Listings ---

  Stream<List<Listing>> getAllListings() {
    return _db
        .collection(kListingsCollection)
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  Stream<List<Listing>> getListingsByCategory(String category) {
    return _db
        .collection(kListingsCollection)
        .where(FirestoreFields.category, isEqualTo: category)
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  Stream<List<Listing>> getUserListings(String uid) {
    return _db
        .collection(kListingsCollection)
        .where(FirestoreFields.ownerId, isEqualTo: uid)
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  Future<Listing?> getListingById(String id) async {
    final doc = await _db.collection(kListingsCollection).doc(id).get();
    if (!doc.exists) return null;
    return Listing.fromFirestore(doc);
  }

  Future<String> createListing(Listing listing) async {
    final ref = await _db
        .collection(kListingsCollection)
        .add(listing.toFirestore());
    return ref.id;
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _db.collection(kListingsCollection).doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _db.collection(kListingsCollection).doc(id).delete();
  }
}
