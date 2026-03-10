import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/listing.dart';
import '../models/user_profile.dart';

/// ──────────────────────────────────────────────────────────────
/// FirestoreService
///
/// Handles ALL Firestore read/write operations.
/// This is the data layer — it knows about Firestore but nothing
/// about UI state or widgets.
///
/// Why Streams instead of Futures for reads?
///   - Firestore snapshots() returns a real-time stream
///   - When any client adds/updates/deletes a listing, ALL
///     listeners receive the update automatically
///   - No manual refresh needed
///   - StreamProvider in Riverpod maps this directly to UI state
///
/// Data flow: Firestore → FirestoreService (stream) →
///            Repository → StreamProvider → UI widget rebuilds
/// ──────────────────────────────────────────────────────────────
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  // ─── References ────────────────────────────────────────────

  CollectionReference get _usersRef =>
      _db.collection(FirestoreConstants.usersCollection);

  CollectionReference get _listingsRef =>
      _db.collection(FirestoreConstants.listingsCollection);

  // ─── User Profile Operations ───────────────────────────────

  /// Creates a user profile document in Firestore after signup.
  /// Document ID = Firebase Auth UID for easy lookups.
  Future<void> createUserProfile(UserProfile profile) async {
    await _usersRef.doc(profile.uid).set(profile.toFirestore());
  }

  /// Fetches a single user profile by UID.
  /// Returns null if the document doesn't exist.
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Real-time stream of a user's profile.
  /// Useful for the Settings screen to show live profile data.
  Stream<UserProfile?> userProfileStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  // ─── Listing CRUD Operations ───────────────────────────────

  /// CREATE: Adds a new listing to Firestore.
  /// Returns the generated document ID.
  Future<String> createListing(Listing listing) async {
    final data = listing.toFirestore();
    data[FirestoreConstants.fieldTimestamp] = FieldValue.serverTimestamp();
    final docRef = await _listingsRef.add(data);
    return docRef.id;
  }

  /// READ: Returns a real-time stream of ALL listings.
  /// Ordered by timestamp descending (newest first).
  Stream<List<Listing>> listingsStream() {
    return _listingsRef
        .orderBy(FirestoreConstants.fieldTimestamp, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  /// READ: Stream of listings created by a specific user.
  /// Filters by createdBy at Firestore query level (server-side).
  Stream<List<Listing>> myListingsStream(String uid) {
    return _listingsRef
        .where(FirestoreConstants.fieldCreatedBy, isEqualTo: uid)
        .orderBy(FirestoreConstants.fieldTimestamp, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  /// UPDATE: Updates an existing listing.
  Future<void> updateListing(String listingId, Map<String, dynamic> data) async {
    data[FirestoreConstants.fieldTimestamp] = FieldValue.serverTimestamp();
    await _listingsRef.doc(listingId).update(data);
  }

  /// DELETE: Removes a listing from Firestore.
  Future<void> deleteListing(String listingId) async {
    await _listingsRef.doc(listingId).delete();
  }

  /// Fetches a single listing by ID (one-time read).
  Future<Listing?> getListing(String listingId) async {
    final doc = await _listingsRef.doc(listingId).get();
    if (!doc.exists) return null;
    return Listing.fromFirestore(doc);
  }
}
