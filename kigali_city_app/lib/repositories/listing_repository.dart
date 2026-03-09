import '../models/listing.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_constants.dart'; // ensure imported

/// ──────────────────────────────────────────────────────────────
/// ListingRepository
///
/// Provides a clean API for listing operations.
/// The repository pattern allows:
///   - Caching strategies (not implemented here but easy to add)
///   - Combining multiple data sources
///   - Keeping providers thin and focused on state
///
/// All CRUD operations delegate to FirestoreService.
/// Ownership enforcement for update/delete happens at 2 levels:
///   1. App-level: UI only shows edit/delete for listings
///      where listing.createdBy == currentUser.uid
///   2. Server-level: Firestore security rules enforce
///      request.auth.uid == resource.data.createdBy
/// ──────────────────────────────────────────────────────────────
class ListingRepository {
  final FirestoreService _firestoreService;

  ListingRepository({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  /// Real-time stream of all listings.
  /// Consumed by StreamProvider in listing_providers.dart.
  /// UI automatically rebuilds when Firestore data changes.
  Stream<List<Listing>> listingsStream() {
    return _firestoreService.listingsStream();
  }

  /// Stream of listings created by a specific user (uid).
  /// Used for the My Listings screen.
  Stream<List<Listing>> myListingsStream(String uid) {
    return _firestoreService.myListingsStream(uid);
  }

  /// Creates a new listing and returns the document ID.
  Future<String> createListing(Listing listing) async {
    final data = listing.toJson();
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _db.collection(kListingsCollection).add(data);
  }

  /// Updates a listing. Only the fields in [data] are changed.
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _db.collection(kListingsCollection).doc(id).update(data);
  }

  /// Deletes a listing by its document ID.
  Future<void> deleteListing(String id) async {
    await _db.collection(kListingsCollection).doc(id).delete();
  }

  /// One-time fetch of a single listing.
  Future<Listing?> getListing(String listingId) {
    return _firestoreService.getListing(listingId);
  }
}
