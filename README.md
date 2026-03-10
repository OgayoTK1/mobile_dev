# Kigali City Directory

A Flutter mobile application for discovering and managing businesses and service locations across Kigali, Rwanda. Users can browse a real-time directory of places, search and filter by category, view listings on an interactive map, and create or manage their own listings — all backed by Firebase.

---

## Table of Contents

- [Features](#features)
- [Firebase Setup](#firebase-setup)
- [Firestore Collections & Schema](#firestore-collections--schema)
- [State Management](#state-management)
- [Architecture & Data Flow](#architecture--data-flow)
- [Folder Structure](#folder-structure)
- [Navigation Structure](#navigation-structure)
- [Running the Project](#running-the-project)
- [Dependencies](#dependencies)

---

## Features

- **Authentication** — Email/password sign-up and sign-in via Firebase Auth with enforced email verification before granting access to the app
- **User Profiles** — Firestore profile document created at `users/{uid}` on sign-up
- **Directory** — Real-time browsing of all listings, updated instantly when Firestore changes
- **Search & Filter** — Search listings by name and filter by category (Cafés, Pharmacies, Restaurants, Hotels, Banks, Salons, Hospitals, Supermarkets)
- **Full CRUD** — Create, read, update, and delete listings with name, category, address, contact number, description, and geographic coordinates
- **Map View** — Interactive OpenStreetMap showing all listing markers; tap a marker for a quick info sheet with Directions and Details actions
- **Detail Screen** — Per-listing detail with an embedded map, coordinates tile, and an Open in Google Maps button
- **Settings** — Authenticated user profile card sourced from Firestore, notification toggle persisted via SharedPreferences, and sign-out

---

## Firebase Setup

### Prerequisites

- Flutter SDK ≥ 3.11
- A Firebase project (this app uses `kigali-city-directory-39aad`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Steps to configure Firebase for a new environment

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** sign-in under **Authentication → Sign-in method**
3. Create a **Firestore** database in production mode
4. Apply the Security Rules below
5. Register an Android app with the package name `com.ogayo.kigali_city_app`
6. Download `google-services.json` and place it in `android/app/`
7. Run `flutterfire configure` to regenerate `lib/firebase_options.dart`
8. Enable **App Check** for your Android app in the Firebase Console
9. Run the app once to print the debug token in logcat (`DebugAppCheckProvider`), then register that token under **App Check → Manage debug tokens**
10. Enable the **Identity Toolkit API** in Google Cloud Console for your project

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own profile
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Anyone authenticated can read listings
    // Only the owner can update or delete their own listing
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
                            && request.auth.uid == resource.data.createdBy;
    }
  }
}
```

---

## Firestore Collections & Schema

### `users` collection

Each document is keyed by the Firebase Auth UID and is created automatically on sign-up.

| Field | Type | Description |
|---|---|---|
| `email` | String | User's email address |
| `displayName` | String | Full name entered at sign-up |
| `createdAt` | Timestamp | Server timestamp set on account creation |

**Path:** `users/{uid}`

---

### `listings` collection

Each document represents one service or place in Kigali.

| Field | Type | Description |
|---|---|---|
| `name` | String | Name of the service or place |
| `category` | String | One of the 8 predefined categories |
| `address` | String | Street address in Kigali |
| `contactNumber` | String | Phone number for the listing |
| `description` | String | Short description of the place |
| `latitude` | Number | Geographic latitude (decimal degrees) |
| `longitude` | Number | Geographic longitude (decimal degrees) |
| `createdBy` | String | Firebase Auth UID of the listing owner |
| `timestamp` | Timestamp | Server timestamp — used for ordering |
| `isVerified` | Boolean | Verification badge flag (default: false) |
| `rating` | Number | Optional star rating |

**Path:** `listings/{listingId}`

---

## State Management

This app uses **Riverpod** (`flutter_riverpod`) as the sole state management solution. No widget calls Firebase APIs directly.

### Provider hierarchy

```
FirebaseAuth / FirebaseFirestore
        │
   AuthService          FirestoreService
   (raw Firebase calls) (raw Firestore calls)
        │                      │
   AuthRepository         ListingRepository
   (orchestrates services) (delegates to FirestoreService)
        │                      │
        └──────────┬───────────┘
                   │  (exposed via Riverpod)
        ┌──────────▼───────────────────────────┐
        │           app_providers.dart          │
        │                                       │
        │  authStateProvider      StreamProvider│ ← Firebase authStateChanges()
        │  userProfileProvider    StreamProvider│ ← Firestore users/{uid}.snapshots()
        │  listingsStreamProvider StreamProvider│ ← Firestore listings.snapshots()
        │  myListingsStreamProvider StreamProvider← filtered by createdBy == uid
        │  searchQueryProvider    StateProvider │ ← current search string
        │  selectedCategoryProvider StateProvider← active category chip
        │  filteredListingsProvider    Provider │ ← derived: stream + search + category
        └──────────────────────────────────────┘
                   │
        ┌──────────▼──────────────────┐
        │         UI Screens          │
        │  ref.watch(provider) only   │
        │  ref.read(repo).method()    │
        └─────────────────────────────┘
```

### Key providers

| Provider | Type | Purpose |
|---|---|---|
| `authStateProvider` | `StreamProvider<User?>` | Drives `AuthWrapper` routing; null = Login, unverified = Verification screen, verified = HomeShell |
| `userProfileProvider` | `StreamProvider<UserProfile?>` | Real-time Firestore profile used in Settings |
| `listingsStreamProvider` | `StreamProvider<List<Listing>>` | Real-time stream of all listings for Directory and Map |
| `myListingsStreamProvider` | `StreamProvider<List<Listing>>` | User-specific listings for My Listings screen |
| `searchQueryProvider` | `StateProvider<String>` | Holds current search text |
| `selectedCategoryProvider` | `StateProvider<String?>` | Holds active category filter |
| `filteredListingsProvider` | `Provider<List<Listing>>` | Derived provider — combines stream + search + category filter |

### Loading, error, and success states

Every `StreamProvider` and `FutureProvider` is consumed with `.when(loading:, error:, data:)`. Loading shows a `CircularProgressIndicator`. Errors show `AppErrorWidget` with a retry callback. Success states show the data. All CRUD operations in `_ListingFormSheet` and `_confirmDelete` show green/red `SnackBar` feedback.

---

## Architecture & Data Flow

```
Firestore
   │  .snapshots() / .add() / .update() / .delete()
   ▼
FirestoreService          AuthService
   │  pure data layer        │  pure auth layer
   ▼                         ▼
ListingRepository         AuthRepository
   │  delegates to service   │  orchestrates auth + profile creation
   ▼                         ▼
app_providers.dart  (Riverpod StreamProviders / StateProviders)
   │  ref.watch() / ref.read()
   ▼
UI Screens  →  ref.watch(filteredListingsProvider)  →  DirectoryScreen rebuilds
            →  ref.watch(myListingsStreamProvider)  →  MyListingsScreen rebuilds
            →  ref.watch(allListingsProvider)        →  MapViewScreen rebuilds
            →  ref.watch(authStateProvider)          →  AuthWrapper reroutes
```

**Rule:** UI widgets only call `ref.watch(someProvider)` to read data and `ref.read(someRepository).method()` to trigger writes. Firebase is never imported into a screen file.

---

## Folder Structure

```
lib/
├── main.dart                        # Entry point — Firebase init, App Check, ProviderScope
├── firebase_options.dart            # Auto-generated by FlutterFire CLI
│
├── core/
│   ├── constants/app_constants.dart # AppColors, FirestoreConstants, AppCategories
│   ├── theme/app_theme.dart         # Dark theme definition
│   └── utils/helpers.dart           # Validators, snackbar helpers, launchGoogleMapsNavigation
│
├── models/
│   ├── listing.dart                 # Listing — fromFirestore, toFirestore, copyWith
│   └── user_profile.dart            # UserProfile — fromFirestore, toFirestore
│
├── services/
│   ├── auth_service.dart            # FirebaseAuth wrapper (sign in, sign up, verify, reload)
│   └── firestore_service.dart       # All Firestore reads/writes — listingsStream, CRUD
│
├── repositories/
│   ├── auth_repository.dart         # Coordinates AuthService + FirestoreService for auth flows
│   └── listing_repository.dart      # Delegates CRUD to FirestoreService
│
├── providers/
│   └── app_providers.dart           # All Riverpod providers
│
├── widgets/
│   └── common_widgets.dart          # ListingCard, CategoryBadge, StarRating, AppErrorWidget
│
└── screens/
    ├── auth_wrapper.dart            # Routes user based on auth + verification state
    ├── home_shell.dart              # IndexedStack + BottomNavigationBar (4 tabs)
    ├── auth/
    │   ├── login_screen.dart        # Sign In / Sign Up with animated tab toggle
    │   └── email_verification_screen.dart # Blocks access until email is verified
    ├── directory/
    │   └── directory_screen.dart    # Browse all listings, search bar, category chips
    ├── detail/
    │   └── listing_detail_screen.dart # Full listing info, embedded flutter_map, Google Maps launch
    ├── my_listings/
    │   └── my_listings_screen.dart  # CRUD screen — FAB to create, 3-dot to edit/delete
    ├── map_view/
    │   └── map_view_screen.dart     # Interactive map with all listing markers
    └── settings/
        └── settings_screen.dart     # User profile from Firestore, notification toggle, sign out
```

---

## Navigation Structure

```
AuthWrapper
├── LoginScreen               (unauthenticated)
├── EmailVerificationScreen   (authenticated, email not verified)
└── HomeShell                 (authenticated + verified)
    ├── Tab 0 — DirectoryScreen
    │              └── ListingDetailScreen (push)
    ├── Tab 1 — MyListingsScreen
    │              └── ListingDetailScreen (push)
    │              └── _ListingFormSheet   (modal bottom sheet — create / edit)
    ├── Tab 2 — MapViewScreen
    │              └── _MarkerBottomSheet  (modal bottom sheet — marker tap)
    │              └── ListingDetailScreen (push from bottom sheet)
    └── Tab 3 — SettingsScreen
```

`HomeShell` uses `IndexedStack` so all four tab screens remain alive. Scroll position, search state, and map camera are preserved when switching tabs.

---

## Running the Project

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on a connected device or emulator
flutter run

# 3. Build a release APK
flutter build apk --release
```

> **Note:** Ensure `android/app/google-services.json` is present before building. The file is excluded from version control via `.gitignore`.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `firebase_core` | ^3.6.0 | Firebase initialization |
| `firebase_auth` | ^5.3.0 | Email/password authentication |
| `firebase_app_check` | ^0.3.1 | App integrity verification (debug provider in dev) |
| `cloud_firestore` | ^5.4.0 | Real-time database for listings and user profiles |
| `flutter_riverpod` | ^2.5.1 | State management — providers, streams, derived state |
| `flutter_map` | ^7.0.2 | OpenStreetMap integration (no API key required) |
| `latlong2` | ^0.9.1 | LatLng coordinate type for flutter_map |
| `url_launcher` | ^6.3.0 | Launch Google Maps navigation from the app |
| `permission_handler` | ^11.3.1 | Request location permission on Map screen |
| `shared_preferences` | ^2.5.4 | Persist notification toggle in Settings |
