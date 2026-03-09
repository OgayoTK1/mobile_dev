import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/listing_repository.dart';

/// ══════════════════════════════════════════════════════════════
/// PROVIDER ARCHITECTURE OVERVIEW
///
/// Data flow: Firestore → Service → Repository → Provider → UI
///
/// Layer responsibilities:
///   Service:    Raw Firebase SDK calls
///   Repository: Orchestrates services, business logic
///   Provider:   Exposes state to UI, manages loading/error/data
///   UI:         Consumes providers via ref.watch(), rebuilds auto
///
/// Why Riverpod over Bloc?
///   - Less boilerplate (no event classes)
///   - Compile-safe: providers are typed, no context dependency
///   - Built-in support for StreamProvider (maps Firestore streams)
///   - AutoDispose: cleans up when widgets are unmounted
///   - Provider dependencies are explicit and testable
/// ══════════════════════════════════════════════════════════════

// ─── Service Providers (Dependency Injection) ────────────────

/// Provides AuthService singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provides FirestoreService singleton.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ─── Repository Providers ────────────────────────────────────

/// Provides AuthRepository with injected dependencies.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.read(authServiceProvider),
    firestoreService: ref.read(firestoreServiceProvider),
  );
});

/// Provides ListingRepository with injected dependencies.
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(
    firestoreService: ref.read(firestoreServiceProvider),
  );
});

// ─── Auth State Provider ─────────────────────────────────────

/// Streams the current Firebase Auth user.
///
/// How auth state is tracked:
///   - FirebaseAuth.authStateChanges() emits a User? stream
///   - When user signs in → emits User object
///   - When user signs out → emits null
///   - StreamProvider maps this to AsyncValue User?
///   - AsyncValue gives us loading, error, and data states
///   - UI uses ref.watch(authStateProvider) to react:
///     - AsyncLoading → show spinner
///     - AsyncData(null) → show login screen
///     - AsyncData(user) → check email verification → show app
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ─── User Profile Provider ───────────────────────────────────

/// Streams the current user's Firestore profile.
/// Only active when a user is authenticated.
/// Auto-disposes when the widget tree unmounts.
final userProfileProvider = StreamProvider.autoDispose<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;

  if (user == null) return Stream.value(null);

  return ref.read(firestoreServiceProvider).userProfileStream(user.uid);
});

// ─── Listings Providers ──────────────────────────────────────

/// Real-time stream of ALL listings from Firestore.
///
/// Why StreamProvider?
///   - Firestore snapshots() returns a stream of QuerySnapshots
///   - StreamProvider automatically maps this to AsyncValue
///   - AsyncValue gives us loading, error, and data states
///   - When Firestore data changes, the stream emits new data
///   - StreamProvider triggers a rebuild of all watching widgets
///   - No manual refresh needed — fully reactive
///
/// How UI rebuilds automatically:
///   1. User A adds a listing → Firestore updates
///   2. Firestore stream emits new snapshot
///   3. StreamProvider maps snapshot to List
///   4. All widgets watching listingsStreamProvider rebuild with new data
///   4. All widgets watching this provider rebuild with new data
final listingsStreamProvider = StreamProvider<List<Listing>>((ref) {
  return ref.watch(listingRepositoryProvider).getListings();
});

/// Stream of listings created by the current user.
/// Used for the "My Listings" screen.
/// Returns empty stream if no user is logged in.
final myListingsStreamProvider = StreamProvider<List<Listing>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(listingRepositoryProvider).getMyListings(uid);
});

// ─── Search & Filter Providers ───────────────────────────────

/// Current search query text entered by user.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Currently selected category filter (null = show all).
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Filtered listings based on search query AND category.
///
/// Filtering approach: CLIENT-SIDE (local filtering)
///
/// Trade-offs of local vs server-side filtering:
///
/// LOCAL FILTERING (our approach):
///   ✅ Instant results — no network round-trip
///   ✅ Works offline (Firestore cache)
///   ✅ Combined text search + category filter easily
///   ✅ Firestore doesn't support full-text search natively
///   ❌ All data loaded in memory (fine for <10k listings)
///   ❌ Doesn't scale to millions of documents
///
/// SERVER-SIDE FILTERING:
///   ✅ Only loads matching documents (bandwidth efficient)
///   ✅ Scales to large datasets
///   ❌ Firestore .where() can't do partial text matching
///   ❌ Would need Algolia/Typesense for full-text search
///   ❌ Combined queries require composite indexes
///   ❌ Each filter change = new Firestore read (costs money)
///
/// For a city directory with hundreds to low thousands of
/// listings, local filtering is the pragmatic choice.
final filteredListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  final listingsAsync = ref.watch(listingsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return listingsAsync.when(
    data: (listings) {
      var filtered = listings;

      // Apply category filter
      if (selectedCategory != null && selectedCategory.isNotEmpty) {
        filtered = filtered
            .where((l) => l.category == selectedCategory)
            .toList();
      }

      // Apply search filter (name match)
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((l) => l.name.toLowerCase().contains(searchQuery))
            .toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});