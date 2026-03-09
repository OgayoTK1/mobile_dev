import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingRepository {
  final FirestoreService _firestoreService;

  ListingRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  // ── Streams ──────────────────────────────────────────────
  Stream<List<Listing>> getListings() => _firestoreService.listingsStream();

  Stream<List<Listing>> getMyListings(String uid) =>
      _firestoreService.myListingsStream(uid);

  // ── Single fetch ─────────────────────────────────────────
  Future<Listing?> getListingById(String id) =>
      _firestoreService.getListing(id);

  // ── Writes ───────────────────────────────────────────────
  Future<String> createListing(Listing listing) =>
      _firestoreService.createListing(listing);

  Future<void> updateListing(String id, Map<String, dynamic> data) =>
      _firestoreService.updateListing(id, data);

  Future<void> deleteListing(String id) => _firestoreService.deleteListing(id);
}
