import 'package:cloud_firestore/cloud_firestore.dart';

/// ──────────────────────────────────────────────────────────────
/// Listing model
///
/// Maps to: Firestore → listings/{listingId}
/// Fields: name, category, address, contactNumber, description,
///         latitude, longitude, createdBy, timestamp
///
/// IMPORTANT: latitude and longitude are stored as double in
/// Firestore (not String). This is critical for Google Maps
/// integration — LatLng requires double values. Storing them
/// as strings would require parsing and risk NumberFormatException.
/// ──────────────────────────────────────────────────────────────
class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;
  // Map this to your real image field:
  // Example if your model has `image`:
  String? get imageUrl => image;

  // If instead you have a list, use:
  // String? get imageUrl => images.isNotEmpty ? images.first : null;
  final String? image;
  final bool isVerified;
  final num? rating;

  const Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.image,
    this.isVerified = false,
    this.rating,
  });

  /// Creates a Listing from a Firestore document snapshot.
  ///
  /// Coordinates are explicitly cast to double using .toDouble()
  /// to handle cases where Firestore may return int or num types.
  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      image: data['image'] ?? '',
      isVerified: data['isVerified'] as bool? ?? false,
      rating:
          (data['rating'] as num?) ??
          (data['averageRating'] as num?) ??
          (data['avg_rating'] as num?),
    );
  }

  /// Converts to a Firestore-compatible map.
  /// Uses FieldValue.serverTimestamp() for the timestamp field
  /// so the server determines the exact time (avoids client clock issues).
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': FieldValue.serverTimestamp(),
      'image': image,
      'isVerified': isVerified,
      'rating': rating,
    };
  }

  /// Creates a copy with optional field overrides.
  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
    String? image,
    bool? isVerified,
    num? rating,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      image: image ?? this.image,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
    );
  }

  // Compatibility getter for UI code expecting `title`
  String get title => name;

  @override
  String toString() => 'Listing(id: $id, name: $name, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Listing && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Creates a Listing from a JSON map.
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdBy: json['createdBy'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      image: json['image'] ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      rating:
          (json['rating'] as num?) ??
          (json['averageRating'] as num?) ??
          (json['avg_rating'] as num?),
    );
  }

  /// Converts a Listing to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': timestamp,
      'image': imageUrl,
      'isVerified': isVerified,
      'rating': rating,
    };
  }
}
