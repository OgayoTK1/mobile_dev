import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/listing_repository.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// --- Service Providers ---

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

// --- Repository Providers ---

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

// --- Auth State ---

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// --- User Profile ---

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(firestoreServiceProvider).getUserProfile(user.uid);
});

// --- Listings ---

final allListingsProvider = StreamProvider<List<Listing>>((ref) {
  return ref.watch(listingRepositoryProvider).watchAllListings();
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredListingsProvider = StreamProvider<List<Listing>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  return ref.watch(listingRepositoryProvider).watchListingsByCategory(category);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final listingsAsync = ref.watch(filteredListingsProvider);
  if (query.isEmpty) return listingsAsync;
  return listingsAsync.whenData(
    (listings) => listings
        .where(
          (l) =>
              l.title.toLowerCase().contains(query) ||
              l.description.toLowerCase().contains(query) ||
              l.address.toLowerCase().contains(query),
        )
        .toList(),
  );
});

final userListingsProvider = StreamProvider<List<Listing>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(listingRepositoryProvider).watchUserListings(user.uid);
});
