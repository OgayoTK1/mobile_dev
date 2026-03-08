import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingRepository {
  final FirestoreService _firestoreService;

  ListingRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Stream<List<Listing>> watchAllListings() =>
      _firestoreService.getAllListings();

  Stream<List<Listing>> watchListingsByCategory(String category) {
    if (category == 'All') return watchAllListings();
    return _firestoreService.getListingsByCategory(category);
  }

  Stream<List<Listing>> watchUserListings(String uid) =>
      _firestoreService.getUserListings(uid);

  Future<Listing?> fetchListingById(String id) =>
      _firestoreService.getListingById(id);

  Future<String> addListing(Listing listing) =>
      _firestoreService.createListing(listing);

  Future<void> editListing(String id, Map<String, dynamic> data) =>
      _firestoreService.updateListing(id, data);

  Future<void> removeListing(String id) =>
      _firestoreService.deleteListing(id);
}
