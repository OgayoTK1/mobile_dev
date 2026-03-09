import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/listing.dart';

class ListingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Streams ──────────────────────────────────────────────
  Stream<List<Listing>> getListings() {
    return _db
        .collection(kListingsCollection)
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Listing.fromFirestore(d)).toList());
  }

  Stream<List<Listing>> getListingsByCategory(String category) {
    return _db
        .collection(kListingsCollection)
        .where(FirestoreFields.category, isEqualTo: category)
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Listing.fromFirestore(d)).toList());
  }

  Stream<List<Listing>> getMyListings(String uid) {
    return _db
        .collection(kListingsCollection)
        .where(FirestoreFields.ownerId, isEqualTo: uid)
        .orderBy(FirestoreFields.updatedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Listing.fromFirestore(d)).toList());
  }

  // ── Single fetch ─────────────────────────────────────────
  Future<Listing?> getListingById(String id) async {
    final doc = await _db.collection(kListingsCollection).doc(id).get();
    if (!doc.exists) return null;
    return Listing.fromFirestore(doc);
  }

  // ── Writes ───────────────────────────────────────────────
  Future<String> createListing(Listing listing) async {
    final data = listing.toJson();
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    final docRef = await _db.collection(kListingsCollection).add(data);
    return docRef.id;
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _db.collection(kListingsCollection).doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _db.collection(kListingsCollection).doc(id).delete();
  }
}
